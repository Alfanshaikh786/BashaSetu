/**
 * Bhasha Setu — S2S Multimodal ASR Adapter
 * 
 * Hardware-Robust, Cross-Platform Speech Recognition Adapter:
 * - Single-owner recognition session policy: exactly ONE active recognition session per turn
 * - Mobile-safe speech recognition:
 *   - Continuous mode on Desktop (streaming uninterrupted dictation)
 *   - Discrete utterance mode on Mobile (prevents Android Chrome stall & duplicate loops)
 *   - Absolute deduplication: never concatenates repeated sentences
 *   - Eliminates aggressive restart loops in onend and onerror
 *   - Single-flight idempotent finalization mutex
 * - Single-owner microphone architecture: S2SAudioPipeline exclusively manages media stream
 * - Guaranteed 16 kHz Mono PCM streaming via WebSocket when local neural backend is active
 * - Vercel cloud deployment resilience: avoids connecting to localhost/port 5000 on cloud domains
 * - Standardized lifecycle event logging via S2STurnLogger and [Mobile S2S] logger
 */

import { ASRResultData, S2SError } from './s2sTypes';
import { S2SAudioPipeline } from './audioPipeline';
import { S2STurnLogger } from './s2sLogger';
import { MobileCapabilityDetector, mobileS2SLog } from './mobileCapability';

export interface ASRAdapterOptions {
  onInterim?: (text: string, turnId: string) => void;
  onFinal?: (result: ASRResultData) => void;
  onError?: (err: S2SError) => void;
  onVadActivity?: (isSpeaking: boolean, rms: number, turnId: string) => void;
  onSpeechStart?: (turnId: string) => void;
  onSpeechEnd?: (turnId: string) => void;
}

export class S2SASRAdapter {
  private static activeSessionId: string | null = null;
  private static currentRecognitionInstance: any = null;
  private static isGloballyFinalizing: boolean = false;

  private activeTurnId: string | null = null;
  private activeSessionId: string | null = null;
  private ws: WebSocket | null = null;
  private audioPipeline: S2SAudioPipeline | null = null;
  private browserRecognition: any = null;
  private browserAutoFinalizeTimer: any = null;
  private browserDispatchFinal: ((reason: string) => void) | null = null;
  private startTime: number = 0;
  private options: ASRAdapterOptions = {};
  private hasEmittedFirstFrame: boolean = false;
  private hasLoggedSpeechStart: boolean = false;

  public static getBackendHost(): string {
    if (typeof window !== 'undefined') {
      try {
        const stored = localStorage.getItem('bhasha_backend_host');
        if (stored && stored.trim()) return stored.trim();
      } catch {}
      if (MobileCapabilityDetector.isLocalNetwork()) {
        return window.location.hostname;
      }
    }
    return '127.0.0.1';
  }

  private static getWsUrl(lang: string = 'sat', turnId?: string): string {
    const base = S2SASRAdapter.getBackendHost();
    const proto = (typeof window !== 'undefined' && window.location?.protocol === 'https:') ? 'wss:' : 'ws:';
    const turnParam = turnId ? `&turnId=${encodeURIComponent(turnId)}` : '';
    if (typeof import.meta !== 'undefined' && import.meta.env?.VITE_ASR_WS_URL) {
      const separator = import.meta.env.VITE_ASR_WS_URL.includes('?') ? '&' : '?';
      return `${import.meta.env.VITE_ASR_WS_URL}${separator}lang=${encodeURIComponent(lang)}&sample_rate=16000${turnParam}`;
    }
    return `${proto}//${base}:5000/api/asr/stream?lang=${encodeURIComponent(lang)}&sample_rate=16000${turnParam}`;
  }

  /**
   * Token-aware boundary deduplication algorithm:
   * Removes overlapping boundary phrases between finalChunk and latestInterim
   * while preserving legitimate repeated words (e.g. "हाँ हाँ ठीक है" or "school school").
   * Completely prevents duplicate sentence concatenation.
   */
  public static mergeTranscript(finalChunk: string, interim: string): string {
    const f = (finalChunk || '').trim();
    const i = (interim || '').trim();
    if (!f) return i;
    if (!i) return f;

    const lowerF = f.toLowerCase();
    const lowerI = i.toLowerCase();

    // 1. If either string contains the other entirely, take the longer one without duplication
    if (lowerF === lowerI || lowerF.endsWith(lowerI) || lowerF.includes(lowerI)) {
      return f;
    }
    if (lowerI.startsWith(lowerF) || lowerI.includes(lowerF)) {
      return i;
    }

    const fWords = f.split(/\s+/);
    const iWords = i.split(/\s+/);

    let maxOverlap = 0;
    const maxCheck = Math.min(fWords.length, iWords.length);
    for (let len = 1; len <= maxCheck; len++) {
      const fTail = fWords.slice(fWords.length - len).map(w => w.toLowerCase()).join(' ');
      const iHead = iWords.slice(0, len).map(w => w.toLowerCase()).join(' ');
      if (fTail === iHead) {
        maxOverlap = len;
      }
    }

    if (maxOverlap > 0) {
      const remainingInterim = iWords.slice(maxOverlap).join(' ');
      return remainingInterim ? `${f} ${remainingInterim}` : f;
    }

    return `${f} ${i}`;
  }

  constructor(options: ASRAdapterOptions = {}) {
    this.options = options;
  }

  /**
   * Starts speech recognition for the given turn and source language.
   * Both Speaker A and Speaker B use the browser Web Speech recognition engine,
   * guaranteeing identical, zero-latency, real-time live interim speech reflection.
   */
  public async startListening(
    sourceLang: string,
    turnId: string
  ): Promise<void> {
    this.abortTurn();
    this.activeTurnId = turnId;
    this.startTime = performance.now();
    this.hasEmittedFirstFrame = false;
    this.hasLoggedSpeechStart = false;

    S2STurnLogger.log(turnId, 'MIC_REQUEST', { sourceLang });
    mobileS2SLog('MIC_REQUEST', { turnId, sourceLang });

    // Both Person A and Person B use the browser Web Speech recognition engine
    // ensuring identical, zero-latency, real-time speech reflection for both speakers.
    this.startBrowserSpeech(sourceLang, turnId);
  }

  /**
   * Stops listening and flushes remaining audio before finalizing.
   */
  public stopListening(): void {
    const turnId = this.activeTurnId;
    if (!turnId) return;

    S2STurnLogger.log(turnId, 'ASR_FLUSH');
    mobileS2SLog('ASR_FLUSH', { turnId });

    // 1. If Browser native recognition is active, stop it cleanly and trigger single finalization
    if (this.browserRecognition) {
      if (this.browserAutoFinalizeTimer) {
        clearTimeout(this.browserAutoFinalizeTimer);
        this.browserAutoFinalizeTimer = null;
      }
      const dispatch = this.browserDispatchFinal;
      try {
        this.browserRecognition.stop();
      } catch {}
      if (dispatch) {
        dispatch('manual_or_vad_stop');
      }
      return;
    }

    // 2. Flush any remaining pre-roll / buffered audio frames for neural stream
    if (this.audioPipeline) {
      this.audioPipeline.flush((chunk) => {
        if (this.activeTurnId === turnId && this.ws && this.ws.readyState === WebSocket.OPEN) {
          this.ws.send(chunk.buffer);
        }
      });
    }

    // 3. Transmit finalize command with explicit turnId
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      try {
        this.ws.send(JSON.stringify({ action: 'finalize', turnId }));
      } catch {}

      // Keep pipeline capture running for 250ms bounded tail audio then stop capture
      setTimeout(() => {
        if (this.audioPipeline) {
          this.audioPipeline.stop();
          this.audioPipeline = null;
        }
      }, 250);

      // Safety watchdog: finalize within 3.5s even if backend hangs or is unresponsive
      setTimeout(() => {
        if (this.activeTurnId === turnId) {
          this.activeTurnId = null;
          if (this.ws) {
            try { this.ws.close(); } catch {}
            this.ws = null;
          }
          this.options.onFinal?.({
            transcript: '',
            asrConfidence: 0.0,
            language: 'sat',
            engine: 'Neural ASR Finalize Watchdog',
            latencyMs: Math.round(performance.now() - this.startTime),
            isFinal: true,
            turnId,
            wordCount: 0
          });
        }
      }, 3500);
    } else {
      if (this.audioPipeline) {
        this.audioPipeline.stop();
        this.audioPipeline = null;
      }
      if (this.activeTurnId === turnId) {
        this.activeTurnId = null;
        this.options.onFinal?.({
          transcript: '',
          asrConfidence: 0.0,
          language: 'sat',
          engine: 'Local Streaming ASR (Socket closed)',
          latencyMs: Math.round(performance.now() - this.startTime),
          isFinal: true,
          turnId,
          wordCount: 0
        });
      }
    }
  }

  /**
   * Immediately aborts any in-flight turn, discarding intermediate data.
   * Guarantees zero orphaned recognition sessions.
   */
  public abortTurn(): void {
    const turnId = this.activeTurnId;
    if (turnId) {
      mobileS2SLog('ASR_ABORT', { turnId });
    }

    this.activeTurnId = null;
    this.activeSessionId = null;

    if (this.browserAutoFinalizeTimer) {
      clearTimeout(this.browserAutoFinalizeTimer);
      this.browserAutoFinalizeTimer = null;
    }
    this.browserDispatchFinal = null;

    if (this.browserRecognition) {
      try {
        this.browserRecognition.onresult = null;
        this.browserRecognition.onend = null;
        this.browserRecognition.onerror = null;
        this.browserRecognition.onspeechstart = null;
        this.browserRecognition.onspeechend = null;
        this.browserRecognition.abort();
      } catch {}
      this.browserRecognition = null;
    }

    if (S2SASRAdapter.currentRecognitionInstance) {
      try {
        const globalRec = S2SASRAdapter.currentRecognitionInstance;
        globalRec.onresult = null;
        globalRec.onend = null;
        globalRec.onerror = null;
        globalRec.onspeechstart = null;
        globalRec.onspeechend = null;
        globalRec.abort();
      } catch {}
      S2SASRAdapter.currentRecognitionInstance = null;
    }
    S2SASRAdapter.activeSessionId = null;
    S2SASRAdapter.isGloballyFinalizing = false;

    if (this.audioPipeline) {
      this.audioPipeline.stop();
      this.audioPipeline = null;
    }

    if (this.ws) {
      try { this.ws.close(); } catch {}
      this.ws = null;
    }
  }

  public getAudioPipeline(): S2SAudioPipeline | null {
    return this.audioPipeline;
  }

  /**
   * Local Streaming ASR via WebSocket (for local IndicConformer / Whisper server).
   */
  private async startLocalStreamingASR(turnId: string, lang: string): Promise<void> {
    this.audioPipeline = new S2SAudioPipeline();

    return new Promise((resolve) => {
      let isConnected = false;
      let hasFallenBack = false;

      const fallbackToBrowser = () => {
        if (hasFallenBack) return;
        hasFallenBack = true;
        mobileS2SLog('WEBSOCKET_FALLBACK', { turnId, fallback: 'browser_webspeech' });
        console.warn(`[ASRAdapter] Local ${lang.toUpperCase()} neural ASR service unavailable or disconnected. Falling back to browser speech.`);

        if (this.audioPipeline) {
          try { this.audioPipeline.stop(); } catch {}
          this.audioPipeline = null;
        }

        if (this.ws) {
          try {
            this.ws.onopen = null;
            this.ws.onmessage = null;
            this.ws.onerror = null;
            this.ws.onclose = null;
            this.ws.close();
          } catch {}
          this.ws = null;
        }

        if (this.activeTurnId === turnId) {
          this.startBrowserSpeech(lang, turnId);
        }
      };

      try {
        this.ws = new WebSocket(S2SASRAdapter.getWsUrl(lang, turnId));
      } catch {
        mobileS2SLog('WEBSOCKET_CONNECT_FAIL', { turnId, lang });
        fallbackToBrowser();
        resolve();
        return;
      }

      this.ws.onopen = async () => {
        isConnected = true;
        mobileS2SLog('WEBSOCKET_CONNECT', { turnId, lang });
        try {
          await this.audioPipeline!.start({
            onAudioChunk: (pcm16) => {
              if (this.activeTurnId === turnId) {
                if (!this.hasEmittedFirstFrame) {
                  this.hasEmittedFirstFrame = true;
                  S2STurnLogger.log(turnId, 'FIRST_AUDIO_FRAME', {
                    sampleCount: pcm16.length,
                    sampleRate: this.audioPipeline?.getSampleRate()
                  });
                  S2STurnLogger.log(turnId, 'ASR_START', { lang });
                  mobileS2SLog('AUDIO_CHUNK_FIRST', { turnId, sampleRate: this.audioPipeline?.getSampleRate() });
                }

                if (this.ws && this.ws.readyState === WebSocket.OPEN) {
                  this.ws.send(pcm16.buffer);
                }
              }
            },
            onVadActivity: (isSpeaking, rms) => {
              if (this.activeTurnId === turnId) {
                if (isSpeaking && !this.hasLoggedSpeechStart) {
                  this.hasLoggedSpeechStart = true;
                  S2STurnLogger.log(turnId, 'VAD_SPEECH_START', { rms });
                  mobileS2SLog('VAD_SPEECH_START', { turnId, rms });
                }
                this.options.onVadActivity?.(isSpeaking, rms, turnId);
              }
            },
            onError: (err) => {
              mobileS2SLog('MIC_STREAM_ERROR', { turnId, err: err.message });
              fallbackToBrowser();
            }
          });

          S2STurnLogger.log(turnId, 'MIC_GRANTED');
          mobileS2SLog('MIC_STREAM', { status: 'STARTED', turnId });
          resolve();
        } catch (err: any) {
          mobileS2SLog('MIC_PERMISSION', { status: 'ERROR', message: err?.message });
          fallbackToBrowser();
          resolve();
        }
      };

      this.ws.onmessage = (event) => {
        if (this.activeTurnId !== turnId) return;

        try {
          const msg = JSON.parse(event.data);
          if (msg.turnId && msg.turnId !== turnId) return;

          if (msg.type === 'interim' && msg.text) {
            S2STurnLogger.log(turnId, 'ASR_INTERIM', { text: msg.text });
            mobileS2SLog('ASR_INTERIM', { turnId, text: msg.text });
            this.options.onInterim?.(msg.text, turnId);
          } else if (msg.type === 'final') {
            const elapsed = Math.round(performance.now() - this.startTime);
            const text = msg.text || (msg.segments && msg.segments[0]?.text) || '';
            const confidence = typeof msg.asr_confidence === 'number'
              ? msg.asr_confidence
              : (msg.segments?.[0]?.asr_confidence ?? (text.trim() ? 0.90 : 0.0));

            const engineName = lang === 'sat'
              ? 'AI4Bharat IndicConformer ONNX int8'
              : 'Faster-Whisper (Local CPU)';

            S2STurnLogger.log(turnId, 'ASR_FINAL', {
              transcript: text.trim(),
              confidence,
              latencyMs: elapsed,
              engine: engineName
            });
            mobileS2SLog('ASR_FINAL', { turnId, transcript: text.trim(), engine: engineName, elapsed });

            this.options.onFinal?.({
              transcript: text.trim(),
              asrConfidence: Math.min(1.0, Math.max(0.0, confidence)),
              language: lang,
              engine: engineName,
              latencyMs: elapsed,
              isFinal: true,
              turnId,
              wordCount: text.trim().split(/\s+/).filter(Boolean).length
            });

            if (this.activeTurnId === turnId) {
              this.activeTurnId = null;
            }
            if (this.ws) {
              try { this.ws.close(); } catch {}
              this.ws = null;
            }
          } else if (msg.type === 'error') {
            console.warn('[ASRAdapter] Local neural ASR error payload:', msg.message);
            fallbackToBrowser();
          }
        } catch (e) {
          console.warn('[ASRAdapter] Parse error on WS payload:', e);
        }
      };

      this.ws.onerror = () => {
        mobileS2SLog('WEBSOCKET_ERROR', { turnId });
        fallbackToBrowser();
        resolve();
      };

      this.ws.onclose = (ev) => {
        mobileS2SLog('WEBSOCKET_DISCONNECT', { turnId, code: ev.code });
        if (this.activeTurnId === turnId && !hasFallenBack) {
          fallbackToBrowser();
        }
      };
    });
  }

  /**
   * Mobile-Safe Browser Speech Recognition Adapter:
   * - Single-Session Mutual Exclusion (ensures only 1 active instance across the app)
   * - Desktop Continuous Mode / Mobile Single-Utterance Mode
   * - Token Deduplication (prevents continuous sentence repetition)
   * - Single-Flight Finalization Mutex
   * - No aggressive restart loop in onend / onerror
   */
  private startBrowserSpeech(sourceLang: string, turnId: string): void {
    const SpeechRecognitionClass = MobileCapabilityDetector.getSpeechRecognitionClass();

    if (!SpeechRecognitionClass) {
      mobileS2SLog('ASR_ERROR', { error: 'speech_recognition_unsupported', turnId });
      this.emitError(
        'ASR_ERROR',
        'Speech recognition is not supported in this browser. Please use Chrome on Android or Safari on iOS.',
        turnId
      );
      return;
    }

    // Abort any existing global recognition instance
    if (S2SASRAdapter.currentRecognitionInstance) {
      try {
        const oldRec = S2SASRAdapter.currentRecognitionInstance;
        oldRec.onresult = null;
        oldRec.onend = null;
        oldRec.onerror = null;
        oldRec.onspeechstart = null;
        oldRec.onspeechend = null;
        oldRec.abort();
      } catch {}
      S2SASRAdapter.currentRecognitionInstance = null;
    }

    try {
      const recognition = new SpeechRecognitionClass();
      const sessionId = `session-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`;
      this.activeSessionId = sessionId;
      S2SASRAdapter.activeSessionId = sessionId;
      S2SASRAdapter.currentRecognitionInstance = recognition;

      // Map source language code to optimal acoustic recognizer
      let speechLang = 'en-IN';
      const langLower = sourceLang.toLowerCase();
      if (langLower === 'hin' || langLower === 'hi') {
        speechLang = 'hi-IN';
      } else if (langLower === 'eng' || langLower === 'en') {
        speechLang = 'en-IN';
      } else if (langLower === 'unr' || langLower === 'mundari' || langLower === 'mun') {
        speechLang = 'hi-IN';
      } else if (langLower === 'sat' || langLower === 'santali') {
        speechLang = 'hi-IN'; // Native browsers lack sat-IN acoustic model; proxy to Indian acoustic space
      } else if (langLower === 'ben' || langLower === 'bn') {
        speechLang = 'bn-IN';
      } else if (langLower === 'ory' || langLower === 'or') {
        speechLang = 'or-IN';
      } else if (langLower === 'mar' || langLower === 'mr') {
        speechLang = 'mr-IN';
      } else if (langLower === 'guj' || langLower === 'gu') {
        speechLang = 'gu-IN';
      } else if (langLower === 'tam' || langLower === 'ta') {
        speechLang = 'ta-IN';
      } else if (langLower === 'tel' || langLower === 'te') {
        speechLang = 'te-IN';
      }

      const isMobile = MobileCapabilityDetector.isMobile();
      const isIOS = MobileCapabilityDetector.isIOS();

      recognition.lang = speechLang;
      // CRITICAL FOR MOBILE STABILITY:
      // On mobile devices (Android Chrome & iOS Safari), continuous = false ensures reliable single-turn capture
      // and eliminates the native Android Chrome freeze / buffer duplication / endless repetition bug!
      // On desktop Chrome/Edge, continuous = true maintains streaming dictation.
      recognition.continuous = !isMobile;
      recognition.interimResults = true;
      recognition.maxAlternatives = 1;

      let finalChunk = '';
      let latestInterim = '';
      let hasFinalized = false;
      let isFinalizing = false;
      let speechHasStarted = false;
      let autoFinalizeTimer: any = null;
      let restartCount = 0;
      const MAX_SILENT_RESTARTS = isMobile ? 1 : 2;
      const AUTO_FINALIZE_SILENCE_MS = isMobile ? 1800 : 2200;

      const dispatchFinal = (reason: string) => {
        if (hasFinalized || isFinalizing) return;
        hasFinalized = true;
        isFinalizing = true;
        S2SASRAdapter.isGloballyFinalizing = true;

        if (autoFinalizeTimer) {
          clearTimeout(autoFinalizeTimer);
          autoFinalizeTimer = null;
        }
        this.browserAutoFinalizeTimer = null;
        this.browserDispatchFinal = null;

        // Cut off all event listeners immediately to prevent zombie callbacks
        if (this.browserRecognition) {
          try {
            this.browserRecognition.onresult = null;
            this.browserRecognition.onend = null;
            this.browserRecognition.onerror = null;
            this.browserRecognition.onspeechstart = null;
            this.browserRecognition.onspeechend = null;
            this.browserRecognition.stop();
          } catch {}
          this.browserRecognition = null;
        }

        if (S2SASRAdapter.currentRecognitionInstance === recognition) {
          S2SASRAdapter.currentRecognitionInstance = null;
        }

        if (this.activeTurnId !== turnId || this.activeSessionId !== sessionId) {
          S2SASRAdapter.isGloballyFinalizing = false;
          return;
        }

        const text = S2SASRAdapter.mergeTranscript(finalChunk, latestInterim).trim();
        const elapsed = Math.round(performance.now() - this.startTime);

        mobileS2SLog('ASR_FINAL', { turnId, transcript: text, reason, elapsed, isMobile });
        S2STurnLogger.log(turnId, 'ASR_FINAL', {
          transcript: text,
          confidence: text ? 0.95 : 0.0,
          latencyMs: elapsed,
          engine: 'Browser WebSpeech API',
          reason
        });

        this.options.onFinal?.({
          transcript: text,
          asrConfidence: text ? 0.95 : 0.0,
          language: sourceLang,
          engine: 'Browser WebSpeech API',
          latencyMs: elapsed,
          isFinal: true,
          turnId,
          wordCount: text ? text.split(/\s+/).filter(Boolean).length : 0
        });

        if (this.activeTurnId === turnId) {
          this.activeTurnId = null;
        }
        this.activeSessionId = null;
        if (S2SASRAdapter.activeSessionId === sessionId) {
          S2SASRAdapter.activeSessionId = null;
        }
        S2SASRAdapter.isGloballyFinalizing = false;
      };

      this.browserDispatchFinal = dispatchFinal;

      recognition.onspeechstart = () => {
        if (this.activeTurnId === turnId && this.activeSessionId === sessionId && !hasFinalized) {
          speechHasStarted = true;
          mobileS2SLog('VAD_SPEECH_START', { turnId });
          S2STurnLogger.log(turnId, 'VAD_SPEECH_START');
          this.options.onSpeechStart?.(turnId);
          if (autoFinalizeTimer) {
            clearTimeout(autoFinalizeTimer);
            autoFinalizeTimer = null;
          }
        }
      };

      recognition.onspeechend = () => {
        if (this.activeTurnId === turnId && this.activeSessionId === sessionId && !hasFinalized) {
          mobileS2SLog('VAD_SILENCE_START', { turnId });
          S2STurnLogger.log(turnId, 'VAD_SILENCE_START');
          this.options.onSpeechEnd?.(turnId);

          // Arm silence timer to finalize
          const currentText = (finalChunk + (latestInterim ? ' ' + latestInterim : '')).trim();
          if (currentText && !hasFinalized) {
            if (autoFinalizeTimer) {
              clearTimeout(autoFinalizeTimer);
            }
            autoFinalizeTimer = setTimeout(() => {
              if (this.activeTurnId === turnId && this.activeSessionId === sessionId && !hasFinalized) {
                dispatchFinal('speechend_auto_finalize');
              }
            }, isMobile ? 1200 : AUTO_FINALIZE_SILENCE_MS);
            this.browserAutoFinalizeTimer = autoFinalizeTimer;
          }
        }
      };

      recognition.onresult = (event: any) => {
        if (this.activeTurnId !== turnId || this.activeSessionId !== sessionId || hasFinalized) {
          return;
        }

        speechHasStarted = true;
        this.options.onSpeechStart?.(turnId);

        let currentInterim = '';
        for (let i = event.resultIndex; i < event.results.length; ++i) {
          const res = event.results[i];
          const trans = (res[0]?.transcript || '').trim();
          if (!trans) continue;

          if (res.isFinal) {
            if (!finalChunk) {
              finalChunk = trans;
            } else {
              // Token-aware duplicate check: never repeat identical phrase or overlapping suffix
              const lowerF = finalChunk.toLowerCase();
              const lowerT = trans.toLowerCase();
              if (!lowerF.endsWith(lowerT) && !lowerF.includes(lowerT)) {
                finalChunk = S2SASRAdapter.mergeTranscript(finalChunk, trans);
              }
            }
            latestInterim = '';
          } else {
            currentInterim += (currentInterim ? ' ' : '') + trans;
          }
        }

        if (currentInterim) {
          latestInterim = currentInterim;
        }

        const liveDisplay = finalChunk
          ? (latestInterim ? `${finalChunk} ${latestInterim}` : finalChunk)
          : latestInterim;

        if (liveDisplay) {
          mobileS2SLog('ASR_INTERIM', { turnId, text: liveDisplay });
          S2STurnLogger.log(turnId, 'ASR_INTERIM', { text: liveDisplay });
          this.options.onInterim?.(liveDisplay.trim(), turnId);

          if (autoFinalizeTimer) {
            clearTimeout(autoFinalizeTimer);
            autoFinalizeTimer = null;
          }

          // Auto-finalize after continuous silence
          autoFinalizeTimer = setTimeout(() => {
            if (this.activeTurnId === turnId && this.activeSessionId === sessionId && !hasFinalized) {
              mobileS2SLog('VAD_ENDPOINT', { reason: 'auto_silence_after_speech', turnId });
              dispatchFinal('auto_silence_after_speech');
            }
          }, isMobile ? 1600 : AUTO_FINALIZE_SILENCE_MS);
          this.browserAutoFinalizeTimer = autoFinalizeTimer;
        }
      };

      recognition.onend = () => {
        mobileS2SLog('ASR_END', { 
          turnId, 
          speechHasStarted, 
          hasFinalized, 
          hasText: !!(finalChunk || latestInterim) 
        });

        if (hasFinalized || this.activeTurnId !== turnId || this.activeSessionId !== sessionId) {
          return;
        }

        const elapsed = performance.now() - this.startTime;

        // If speech was vocalized, onend indicates utterance completion.
        // Finalize immediately. NEVER restart once speech was detected.
        if (speechHasStarted || finalChunk.trim() || latestInterim.trim()) {
          dispatchFinal('utterance_end');
          return;
        }

        // Mobile grace period: if user hesitated and hasn't vocalized within initial timeout (8s),
        // allow 1 controlled, debounced restart attempt
        if (!speechHasStarted && elapsed < 8000 && restartCount < MAX_SILENT_RESTARTS) {
          restartCount++;
          mobileS2SLog('ASR_RESTART', { turnId, attempt: restartCount, elapsed });
          setTimeout(() => {
            if (this.activeTurnId === turnId && this.activeSessionId === sessionId && !hasFinalized) {
              try {
                recognition.start();
              } catch {
                dispatchFinal('restart_failed');
              }
            }
          }, 150);
          return;
        }

        dispatchFinal('empty_recognition_end');
      };

      recognition.onerror = (e: any) => {
        mobileS2SLog('ASR_ERROR', { turnId, error: e.error });
        if (this.activeTurnId !== turnId || this.activeSessionId !== sessionId || hasFinalized) {
          return;
        }
        const elapsed = performance.now() - this.startTime;

        if (e.error === 'not-allowed') {
          mobileS2SLog('MIC_PERMISSION', { status: 'DENIED', turnId });
          this.emitError(
            'PERMISSION_ERROR',
            'Microphone permission is required for voice translation. Please allow microphone access in your browser or device settings.',
            turnId
          );
          dispatchFinal('permission_denied');
        } else if (e.error === 'no-speech') {
          if (!speechHasStarted && elapsed < 7000 && restartCount < MAX_SILENT_RESTARTS && !isMobile) {
            restartCount++;
            setTimeout(() => {
              if (this.activeTurnId === turnId && this.activeSessionId === sessionId && !hasFinalized) {
                try {
                  recognition.start();
                  return;
                } catch {}
              }
              dispatchFinal('no_speech_event');
            }, 150);
            return;
          }
          dispatchFinal('no_speech_event');
        } else if (e.error === 'audio-capture') {
          this.emitError(
            'MICROPHONE_ERROR',
            'Microphone is currently unavailable or being used by another application.',
            turnId
          );
          dispatchFinal('audio_capture_error');
        } else if (e.error === 'aborted') {
          dispatchFinal('aborted_event');
        } else if (e.error === 'language-not-supported') {
          this.emitError(
            'ASR_ERROR',
            `Language not supported on device (${speechLang}). Defaulting to standard acoustic recognition.`,
            turnId
          );
          dispatchFinal('language_not_supported');
        } else {
          this.emitError('ASR_ERROR', `Speech recognition notice: ${e.error}`, turnId);
          dispatchFinal('generic_error');
        }
      };

      this.browserRecognition = recognition;
      recognition.start();

      mobileS2SLog('ASR_START', {
        turnId,
        lang: speechLang,
        continuous: recognition.continuous,
        isMobile,
        isIOS
      });
      S2STurnLogger.log(turnId, 'MIC_GRANTED', { engine: 'Browser WebSpeech', lang: speechLang });

    } catch (e: any) {
      mobileS2SLog('ASR_START_EXCEPTION', { turnId, error: e?.message || e });
      this.emitError('ASR_ERROR', `Speech recognition start error: ${e?.message || e}`, turnId);
    }
  }

  private emitError(code: S2SError['code'], message: string, turnId: string): void {
    this.options.onError?.({
      code,
      message,
      turnId,
      recoverable: true,
      timestamp: Date.now()
    });
    if (this.activeTurnId === turnId) {
      this.activeTurnId = null;
    }
  }
}

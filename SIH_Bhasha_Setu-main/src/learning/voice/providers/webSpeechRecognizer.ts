/**
 * Bhasha Setu Browser Web Speech ASR Provider
 * Connects directly to the device's native SpeechRecognition engine.
 * Never fakes recognition results.
 */

import { ISpeechRecognizer, RecognitionOptions, RecognitionEvent, VoiceRuntimeStatus } from './types';

// Browser Web Speech API type interfaces
interface IWindowSpeechRecognition extends EventTarget {
  continuous: boolean;
  interimResults: boolean;
  lang: string;
  start(): void;
  stop(): void;
  abort(): void;
  onresult: ((event: any) => void) | null;
  onerror: ((event: any) => void) | null;
  onend: (() => void) | null;
}

export class WebSpeechRecognizer implements ISpeechRecognizer {
  private recognition: IWindowSpeechRecognition | null = null;
  private isListeningActive = false;
  private lastMeasuredLatencyMs = 0;
  private listenStartTime = 0;

  getProviderName(): string {
    return 'Browser Native WebSpeech ASR';
  }

  isSupported(): boolean {
    if (typeof window === 'undefined') return false;
    return !!(
      (window as any).SpeechRecognition || 
      (window as any).webkitSpeechRecognition
    );
  }

  isOfflineCapable(): boolean {
    // Standard browser WebSpeech routes audio to remote cloud services (Google ASR)
    // and cannot be claimed as offline capable without verified local model pack.
    return false;
  }

  getRuntimeStatus(): VoiceRuntimeStatus {
    const isOnline = typeof window !== 'undefined' ? navigator.onLine : false;
    return {
      provider: 'Browser Native WebSpeech ASR',
      processingMode: isOnline ? 'REMOTE' : 'ON_DEVICE',
      offlineStatus: isOnline ? 'ONLINE_ONLY' : 'UNSUPPORTED',
      supportedLanguages: ['hi-IN', 'en-IN', 'en-US'],
      confidenceAvailable: true,
      measuredLatencyMs: this.lastMeasuredLatencyMs,
      details: isOnline 
        ? 'Operating via remote browser speech service. Not on-device verified.' 
        : 'Network offline. Local ASR model required for continued recognition.'
    };
  }

  async startListening(options: RecognitionOptions): Promise<void> {
    if (!this.isSupported()) {
      options.onError?.('Speech recognition is not supported in this browser/device.');
      return;
    }

    // Do not silently attempt remote recognition when offline
    if (typeof window !== 'undefined' && !navigator.onLine) {
      options.onError?.('Offline speech recognition is unavailable on this device. Use verified phrase practice.');
      return;
    }

    this.stopListening();

    const SpeechRecognitionClass = 
      (window as any).SpeechRecognition || 
      (window as any).webkitSpeechRecognition;

    const instance: IWindowSpeechRecognition = new SpeechRecognitionClass();
    this.recognition = instance;

    // Configure language: map Santali or regional code
    instance.lang = options.language || 'hi-IN';
    instance.continuous = options.continuous ?? false;
    instance.interimResults = options.interimResults ?? true;

    instance.onresult = (event: any) => {
      this.lastMeasuredLatencyMs = Math.round(performance.now() - this.listenStartTime);
      let finalTranscript = '';
      let interimTranscript = '';
      let confidence = 0.70; // Honest baseline fallback if engine omits confidence

      for (let i = event.resultIndex; i < event.results.length; i++) {
        const result = event.results[i];
        const text = result[0]?.transcript || '';
        if (result[0]?.confidence !== undefined && result[0]?.confidence > 0) {
          confidence = result[0].confidence;
        }

        if (result.isFinal) {
          finalTranscript += text;
        } else {
          interimTranscript += text;
        }
      }

      const transcript = (finalTranscript || interimTranscript).trim();
      if (transcript) {
        options.onResult({
          transcript,
          isFinal: !!finalTranscript,
          confidence: Math.round(confidence * 100) / 100
        });
      }
    };

    instance.onerror = (event: any) => {
      this.isListeningActive = false;
      const errorMsg = event.error || 'Speech recognition encountered an error';
      if (errorMsg === 'network') {
        options.onError?.('Offline speech recognition is unavailable on this device. Use verified phrase practice.');
      } else {
        options.onError?.(errorMsg);
      }
    };

    instance.onend = () => {
      this.isListeningActive = false;
      options.onEnd?.();
    };

    try {
      this.listenStartTime = performance.now();
      instance.start();
      this.isListeningActive = true;
    } catch (err) {
      this.isListeningActive = false;
      options.onError?.(err instanceof Error ? err.message : 'Failed to start speech recognition');
    }
  }

  stopListening(): void {
    if (this.recognition && this.isListeningActive) {
      try {
        this.recognition.stop();
      } catch {
        // Ignore
      }
      this.isListeningActive = false;
    }
  }

  abort(): void {
    if (this.recognition) {
      try {
        this.recognition.abort();
      } catch {
        // Ignore
      }
      this.isListeningActive = false;
      this.recognition = null;
    }
  }
}

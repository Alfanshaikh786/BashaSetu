/**
 * Bhasha Setu — Mobile & Cross-Platform Capability Detection Matrix
 * 
 * Accurately detects client device capabilities, operating systems, and browser APIs
 * to select optimal speech recognition, audio capture, and synthesis modes.
 * 
 * Capabilities probed:
 * 1. navigator.mediaDevices & getUserMedia (Microphone hardware)
 * 2. SpeechRecognition & webkitSpeechRecognition (Web Speech API)
 * 3. AudioContext & webkitAudioContext (Web Audio API)
 * 4. MediaRecorder (Audio container encoding)
 * 5. window.speechSynthesis & SpeechSynthesisUtterance (TTS)
 * 6. WebSocket (Real-time neural audio streaming)
 * 7. Secure Context (HTTPS requirement for audio capture)
 */

export interface MobileCapabilityMatrix {
  hasMediaDevices: boolean;
  hasGetUserMedia: boolean;
  hasSpeechRecognition: boolean;
  hasWebkitSpeechRecognition: boolean;
  hasAnySpeechRecognition: boolean;
  hasAudioContext: boolean;
  hasMediaRecorder: boolean;
  hasSpeechSynthesis: boolean;
  hasWebSocket: boolean;
  isSecureContext: boolean;
  isMobile: boolean;
  isIOS: boolean;
  isAndroid: boolean;
  isCloudDeployment: boolean;
  canConnectLocalBackend: boolean;
  browserName: string;
  osName: string;
  recommendedRecognitionMode: 'browser_webspeech_discrete' | 'browser_webspeech_continuous' | 'local_neural_stream' | 'offline_phrase_fallback';
}

export class MobileCapabilityDetector {
  private static cachedMatrix: MobileCapabilityMatrix | null = null;

  public static isClient(): boolean {
    return typeof window !== 'undefined';
  }

  public static isIOS(): boolean {
    if (!this.isClient()) return false;
    const ua = navigator.userAgent || '';
    return /iPad|iPhone|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  }

  public static isAndroid(): boolean {
    if (!this.isClient()) return false;
    return /Android/i.test(navigator.userAgent || '');
  }

  public static isMobile(): boolean {
    if (!this.isClient()) return false;
    return this.isIOS() || this.isAndroid() || (navigator.maxTouchPoints > 0 && /Mobi|Tablet|Android/i.test(navigator.userAgent || ''));
  }

  public static isCloudDeployment(): boolean {
    if (!this.isClient() || !window.location?.hostname) return false;
    const host = window.location.hostname.toLowerCase();
    return host.endsWith('.vercel.app') || 
           host.endsWith('.pages.dev') || 
           host.endsWith('.netlify.app') || 
           host.endsWith('.onrender.com') ||
           host.endsWith('.amplifyapp.com');
  }

  public static isLocalNetwork(): boolean {
    if (!this.isClient() || !window.location?.hostname) return false;
    const host = window.location.hostname.toLowerCase();
    return host === 'localhost' || 
           host === '127.0.0.1' || 
           host === '0.0.0.0' || 
           host.startsWith('192.168.') || 
           host.startsWith('10.') || 
           host.endsWith('.local');
  }

  public static hasCustomBackendConfigured(): boolean {
    if (!this.isClient()) return false;
    try {
      const stored = localStorage.getItem('bhasha_backend_host');
      return !!(stored && stored.trim());
    } catch {
      return false;
    }
  }

  public static getSpeechRecognitionClass(): any {
    if (!this.isClient()) return null;
    const win = window as any;
    return win.SpeechRecognition || win.webkitSpeechRecognition || null;
  }

  public static getAudioContextClass(): typeof AudioContext | null {
    if (!this.isClient()) return null;
    const win = window as any;
    return win.AudioContext || win.webkitAudioContext || null;
  }

  public static detectCapabilities(): MobileCapabilityMatrix {
    const hasMediaDev = this.isClient() && typeof navigator.mediaDevices !== 'undefined';
    const hasGum = hasMediaDev && typeof navigator.mediaDevices.getUserMedia === 'function';
    const win = this.isClient() ? (window as any) : {};
    const hasStdSpeech = !!win.SpeechRecognition;
    const hasWkSpeech = !!win.webkitSpeechRecognition;
    const hasAnySpeech = hasStdSpeech || hasWkSpeech;
    const hasAudioCtx = !!(win.AudioContext || win.webkitAudioContext);
    const hasMediaRec = this.isClient() && typeof win.MediaRecorder !== 'undefined';
    const hasSynth = this.isClient() && 'speechSynthesis' in window && typeof win.SpeechSynthesisUtterance !== 'undefined';
    const hasWs = this.isClient() && typeof win.WebSocket !== 'undefined';
    const isSec = this.isClient() && (window.isSecureContext || window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');

    const isIos = this.isIOS();
    const isAndr = this.isAndroid();
    const isMob = this.isMobile();
    const isCloud = this.isCloudDeployment();
    const isLocal = this.isLocalNetwork();
    const hasCustomBackend = this.hasCustomBackendConfigured();

    const ua = this.isClient() ? navigator.userAgent : '';
    let browserName = 'Unknown Browser';
    if (ua.includes('Edg/')) browserName = 'Microsoft Edge';
    else if (ua.includes('Chrome/') && !ua.includes('Edg/')) browserName = 'Google Chrome';
    else if (ua.includes('Safari/') && !ua.includes('Chrome/')) browserName = 'Apple Safari';
    else if (ua.includes('Firefox/')) browserName = 'Mozilla Firefox';
    else if (ua.includes('OPR/') || ua.includes('Opera/')) browserName = 'Opera';

    let osName = 'Unknown OS';
    if (isIos) osName = 'Apple iOS';
    else if (isAndr) osName = 'Google Android';
    else if (ua.includes('Win')) osName = 'Microsoft Windows';
    else if (ua.includes('Mac')) osName = 'Apple macOS';
    else if (ua.includes('Linux')) osName = 'Linux';

    // Select optimal recognition mode
    let recommendedMode: MobileCapabilityMatrix['recommendedRecognitionMode'] = 'offline_phrase_fallback';
    if (hasCustomBackend || isLocal) {
      recommendedMode = 'local_neural_stream';
    } else if (hasAnySpeech) {
      recommendedMode = isMob ? 'browser_webspeech_discrete' : 'browser_webspeech_continuous';
    }

    const matrix: MobileCapabilityMatrix = {
      hasMediaDevices: hasMediaDev,
      hasGetUserMedia: hasGum,
      hasSpeechRecognition: hasStdSpeech,
      hasWebkitSpeechRecognition: hasWkSpeech,
      hasAnySpeechRecognition: hasAnySpeech,
      hasAudioContext: hasAudioCtx,
      hasMediaRecorder: hasMediaRec,
      hasSpeechSynthesis: hasSynth,
      hasWebSocket: hasWs,
      isSecureContext: isSec,
      isMobile: isMob,
      isIOS: isIos,
      isAndroid: isAndr,
      isCloudDeployment: isCloud,
      canConnectLocalBackend: isLocal || hasCustomBackend,
      browserName,
      osName,
      recommendedRecognitionMode: recommendedMode
    };

    this.cachedMatrix = matrix;
    return matrix;
  }

  public static getCapabilityTable(): Array<{ feature: string; supported: boolean; fallback: string }> {
    const caps = this.detectCapabilities();
    return [
      {
        feature: 'Microphone (getUserMedia)',
        supported: caps.hasGetUserMedia,
        fallback: caps.hasGetUserMedia ? 'Hardware Available' : 'Text Input / Curated Phrasebook'
      },
      {
        feature: 'Browser SpeechRecognition',
        supported: caps.hasAnySpeechRecognition,
        fallback: caps.hasAnySpeechRecognition 
          ? (caps.isMobile ? 'Mobile Discrete WebSpeech Adapter' : 'Desktop Continuous WebSpeech') 
          : 'Backend Neural ASR / Phrasebook'
      },
      {
        feature: 'Web Audio API (AudioContext)',
        supported: caps.hasAudioContext,
        fallback: caps.hasAudioContext ? '16 kHz Mono Resampling Active' : 'Native Browser Media Pipeline'
      },
      {
        feature: 'SpeechSynthesis (TTS)',
        supported: caps.hasSpeechSynthesis,
        fallback: caps.hasSpeechSynthesis ? 'Indian-accented Multilingual TTS' : 'Web Audio Acoustic Chime'
      },
      {
        feature: 'WebSocket Streaming',
        supported: caps.hasWebSocket && caps.canConnectLocalBackend,
        fallback: caps.canConnectLocalBackend ? 'Active (Port 5000 Stream)' : 'Standalone Mobile WebSpeech'
      },
      {
        feature: 'Secure Context (HTTPS)',
        supported: caps.isSecureContext,
        fallback: caps.isSecureContext ? 'Secure Audio Context Granted' : 'HTTPS Required for Mic Access'
      }
    ];
  }
}

/**
 * Diagnostic logger specifically labeled for Mobile S2S trace analysis.
 */
export const mobileS2SLog = (event: string, details?: any): void => {
  if (typeof console !== 'undefined') {
    if (details !== undefined) {
      console.log(`[Mobile S2S] ${event}`, details);
    } else {
      console.log(`[Mobile S2S] ${event}`);
    }
  }
};

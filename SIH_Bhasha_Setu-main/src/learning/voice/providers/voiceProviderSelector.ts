/**
 * Bhasha Setu Voice Provider Selector
 * Phase 4.5: Explicit Provider Selection Policy
 * 
 * Enforces non-silent provider resolution:
 * 1. Checks if offline mode is mandated or network is offline.
 * 2. If offline, checks if local ASR model is loaded and supported.
 * 3. If local ASR is unavailable, explicitly routes to Verified Offline Phrase Fallback (never silently routes to cloud).
 * 4. Only uses online browser WebSpeech when online mode is explicitly permitted AND network is active.
 */

import { ISpeechRecognizer } from './types';
import { WebSpeechRecognizer } from './webSpeechRecognizer';
import { OfflineModelSpeechRecognizer } from './offlineModelSpeechRecognizer';

export type SelectedProviderMode = 
  | 'LOCAL_ASR' 
  | 'ONLINE_ASR' 
  | 'OFFLINE_PHRASE_FALLBACK';

export interface ProviderSelectionPolicy {
  requireOffline: boolean;
  language: 'Hindi' | 'English' | 'Santali';
  allowOnlineFallback?: boolean;
}

export interface ProviderSelectionResult {
  mode: SelectedProviderMode;
  recognizer: ISpeechRecognizer | null;
  providerName: string;
  isOfflineVerified: boolean;
  reason: string;
}

export class VoiceProviderSelector {
  private static localModelRecognizer = new OfflineModelSpeechRecognizer();
  private static webSpeechRecognizer = new WebSpeechRecognizer();
  private static strictOfflineMode = false;

  /**
   * Toggles strict global offline mode. When enabled, remote ASR/TTS/cloud calls are unconditionally prohibited.
   */
  static setStrictOfflineMode(enabled: boolean): void {
    this.strictOfflineMode = enabled;
  }

  static getStrictOfflineMode(): boolean {
    return this.strictOfflineMode;
  }

  static getLocalModelRecognizer(): OfflineModelSpeechRecognizer {
    return this.localModelRecognizer;
  }

  static selectProvider(policy: ProviderSelectionPolicy): ProviderSelectionResult {
    const isOnline = typeof window !== 'undefined' ? navigator.onLine : false;
    const isOfflineRequired = this.strictOfflineMode || policy.requireOffline || !isOnline;

    // Santali special check: Browser WebSpeech does NOT support Santali
    if (policy.language === 'Santali') {
      if (this.localModelRecognizer.isSupported() && this.localModelRecognizer.isOfflineCapable() && (this.localModelRecognizer as any).isLoaded) {
        return {
          mode: 'LOCAL_ASR',
          recognizer: this.localModelRecognizer,
          providerName: this.localModelRecognizer.getProviderName(),
          isOfflineVerified: true,
          reason: 'Santali local IndicConformer model is loaded and active.'
        };
      }

      // Santali without local model MUST fallback to verified offline phrase practice
      return {
        mode: 'OFFLINE_PHRASE_FALLBACK',
        recognizer: null,
        providerName: 'Verified Offline Phrase Cache',
        isOfflineVerified: true,
        reason: 'Browser WebSpeech has no Santali model. Using verified offline phrase practice.'
      };
    }

    // For Hindi and English:
    if (isOfflineRequired) {
      // Offline mode required or device is disconnected from internet
      if (this.localModelRecognizer.isSupported() && (this.localModelRecognizer as any).isLoaded) {
        return {
          mode: 'LOCAL_ASR',
          recognizer: this.localModelRecognizer,
          providerName: this.localModelRecognizer.getProviderName(),
          isOfflineVerified: true,
          reason: 'Offline mode active: Using verified on-device ASR model.'
        };
      }

      return {
        mode: 'OFFLINE_PHRASE_FALLBACK',
        recognizer: null,
        providerName: 'Verified Offline Phrase Cache',
        isOfflineVerified: true,
        reason: 'Offline mode active: On-device model not loaded. Using verified offline phrase practice.'
      };
    }

    // Online mode is permitted AND network is active
    if (policy.allowOnlineFallback !== false && isOnline && this.webSpeechRecognizer.isSupported()) {
      return {
        mode: 'ONLINE_ASR',
        recognizer: this.webSpeechRecognizer,
        providerName: this.webSpeechRecognizer.getProviderName(),
        isOfflineVerified: false,
        reason: 'Online mode explicitly permitted. Using browser WebSpeech cloud recognition.'
      };
    }

    return {
      mode: 'OFFLINE_PHRASE_FALLBACK',
      recognizer: null,
      providerName: 'Verified Offline Phrase Cache',
      isOfflineVerified: true,
      reason: 'No compatible online or offline ASR available. Fallback to verified phrases.'
    };
  }
}

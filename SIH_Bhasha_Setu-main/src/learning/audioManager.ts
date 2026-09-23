/**
 * Bhasha Setu Audio Manager
 * Implements honest audio resolution hierarchy, lightweight memory management,
 * and preloading for current + next flashcard only.
 * 
 * Hierarchy:
 * 1. Verified native Santali recording (/audio/santali/{id}.ogg or .mp3)
 * 2. Clearly labeled phonetic fallback via Web Speech API
 * 3. Honest "Santali audio unavailable" without disguising Hindi/English as native Santali
 */

import { SantaliDatasetEntry } from '../data/santaliDataset';
import { playTextSpeech, stopTextSpeech } from '../services/translationService';

export interface AudioPlayResult {
  source: 'native' | 'phonetic_fallback' | 'unavailable';
  playing: boolean;
  message?: string;
}

class AudioManager {
  private activeAudio: HTMLAudioElement | null = null;
  private preloadedAudios: Map<string, HTMLAudioElement> = new Map();
  private verifiedNativeCache: Set<string> = new Set();
  private missingNativeCache: Set<string> = new Set();

  /**
   * Checks if native audio file exists locally for a card.
   * Strictly validates content-type to avoid SPAs returning 200 OK with index.html.
   */
  async checkNativeAudioExists(cardId: string): Promise<boolean> {
    if (this.verifiedNativeCache.has(cardId)) return true;
    if (this.missingNativeCache.has(cardId)) return false;

    // Check local assets
    const paths = [`/audio/santali/${cardId}.ogg`, `/audio/santali/${cardId}.mp3`];
    for (const path of paths) {
      try {
        const res = await fetch(path, { method: 'HEAD' });
        const contentType = res.headers.get('content-type') || '';
        // In Single Page Applications (SPAs), non-existent routes return 200 OK with text/html.
        // We only accept genuine audio responses.
        if (res.ok && contentType.startsWith('audio/')) {
          this.verifiedNativeCache.add(cardId);
          return true;
        }
      } catch {
        // Offline or not found
      }
    }

    this.missingNativeCache.add(cardId);
    return false;
  }

  /**
   * Preload audio for current card and next card only.
   * Disposes of any previously preloaded audio objects outside this window.
   */
  async preloadWindow(currentCardId?: string, nextCardId?: string): Promise<void> {
    const keepKeys = new Set<string>();
    if (currentCardId) keepKeys.add(currentCardId);
    if (nextCardId) keepKeys.add(nextCardId);

    // Dispose unneeded preloads
    for (const [id, audio] of this.preloadedAudios.entries()) {
      if (!keepKeys.has(id)) {
        audio.src = '';
        audio.load();
        this.preloadedAudios.delete(id);
      }
    }

    // Preload current and next if verified native exists
    for (const id of keepKeys) {
      if (!this.preloadedAudios.has(id)) {
        const exists = await this.checkNativeAudioExists(id);
        if (exists) {
          const audio = new Audio(`/audio/santali/${id}.ogg`);
          audio.preload = 'auto';
          this.preloadedAudios.set(id, audio);
        }
      }
    }
  }

  /**
   * Plays audio with honest resolution hierarchy:
   * 1. Verified native recording (real audio/ MIME type)
   * 2. Labeled phonetic pronunciation synthesis (via curated Roman phonetics or Ol Chiki)
   * 3. Honest unavailable
   */
  async playCardAudio(
    card: SantaliDatasetEntry,
    options: {
      onStart?: () => void;
      onEnd?: () => void;
      onError?: (err: unknown) => void;
      allowPhoneticFallback?: boolean;
    } = {}
  ): Promise<AudioPlayResult> {
    this.stop();

    const hasNative = await this.checkNativeAudioExists(card.id);

    if (hasNative) {
      options.onStart?.();
      try {
        const audio = this.preloadedAudios.get(card.id) || new Audio(`/audio/santali/${card.id}.ogg`);
        this.activeAudio = audio;
        audio.onended = () => {
          this.activeAudio = null;
          options.onEnd?.();
        };
        audio.onerror = (e) => {
          this.activeAudio = null;
          // Fall back gracefully to phonetic synthesis if native audio decode fails
          if (options.allowPhoneticFallback !== false) {
            this.playPhoneticFallback(card, options);
          } else {
            options.onError?.(e);
          }
        };
        await audio.play();
        return { source: 'native', playing: true };
      } catch (err) {
        if (options.allowPhoneticFallback === false) {
          options.onError?.(err);
          return { source: 'unavailable', playing: false, message: 'Audio playback failed' };
        }
        // Fall through to phonetic fallback
      }
    }

    // Honest fallback check: Synthesize speech using curated Roman phonetics or Ol Chiki
    if (options.allowPhoneticFallback !== false) {
      return this.playPhoneticFallback(card, options);
    }

    return { 
      source: 'unavailable', 
      playing: false, 
      message: 'Authentic Santali audio recording unavailable' 
    };
  }

  /**
   * Synthesizes phonetic pronunciation guide using curated Roman phonetics.
   */
  private playPhoneticFallback(
    card: SantaliDatasetEntry,
    options: {
      onStart?: () => void;
      onEnd?: () => void;
      onError?: (err: unknown) => void;
    }
  ): AudioPlayResult {
    options.onStart?.();
    // Prefer curated Roman phonetic guide (e.g., "Nui do mihu kanay.") for crisp pronunciation
    const textToSpeak = card.roman ? card.roman.trim() : card.sat;
    playTextSpeech(
      textToSpeak,
      'sat',
      0.9,
      () => options.onEnd?.(),
      undefined
    );
    return { 
      source: 'phonetic_fallback', 
      playing: true, 
      message: 'Playing synthesized phonetic pronunciation guide' 
    };
  }

  /**
   * Stops all active audio immediately.
   */
  stop(): void {
    if (this.activeAudio) {
      try {
        this.activeAudio.pause();
        this.activeAudio.currentTime = 0;
      } catch {
        // Ignore
      }
      this.activeAudio = null;
    }
    stopTextSpeech();
  }

  /**
   * Release all resources when unmounting.
   */
  dispose(): void {
    this.stop();
    for (const audio of this.preloadedAudios.values()) {
      audio.src = '';
      audio.load();
    }
    this.preloadedAudios.clear();
  }
}

export const audioManager = new AudioManager();

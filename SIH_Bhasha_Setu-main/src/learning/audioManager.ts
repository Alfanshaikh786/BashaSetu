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
   */
  async checkNativeAudioExists(cardId: string): Promise<boolean> {
    if (this.verifiedNativeCache.has(cardId)) return true;
    if (this.missingNativeCache.has(cardId)) return false;

    // Check local assets
    const paths = [`/audio/santali/${cardId}.ogg`, `/audio/santali/${cardId}.mp3`];
    for (const path of paths) {
      try {
        const res = await fetch(path, { method: 'HEAD' });
        if (res.ok) {
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

    // Preload current and next if native exists
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
   * 1. Native recording
   * 2. Labeled phonetic fallback
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
          options.onError?.(e);
        };
        await audio.play();
        return { source: 'native', playing: true };
      } catch (err) {
        options.onError?.(err);
        return { source: 'unavailable', playing: false, message: 'Audio playback failed' };
      }
    }

    // Honest fallback check
    if (options.allowPhoneticFallback !== false) {
      options.onStart?.();
      playTextSpeech(
        card.sat,
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

    return { 
      source: 'unavailable', 
      playing: false, 
      message: 'Authentic Santali audio recording unavailable' 
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

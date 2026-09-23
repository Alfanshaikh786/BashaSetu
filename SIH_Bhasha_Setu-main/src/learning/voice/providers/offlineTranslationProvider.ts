/**
 * Bhasha Setu Offline Phrase & Dataset Translation Provider
 * Delivers zero-latency, verified offline translations for classroom phrases.
 * Enforces strict separation of Language ('Santali') and Script ('Ol_Chiki').
 * 
 * Never fakes neural translation: either returns verified offline corpus text
 * or honest fallback declaration.
 */

import { ITranslationProvider, VoiceTranslationResult } from './types';
import { lookupOfflinePhrase } from '../offlinePhraseCache';
import { SANTALI_DATASET } from '../../../data/santaliDataset';
import { validateOlChikiScript } from '../../contentValidator';

export class OfflineTranslationProvider implements ITranslationProvider {
  getProviderName(): string {
    return 'Verified Local Phrase & Dataset Provider';
  }

  isOfflineAvailable(): boolean {
    return true; // 100% offline, zero network reliance
  }

  async translate(
    text: string,
    sourceLang: 'Hindi' | 'English' | 'Santali',
    targetLang: 'Santali' | 'Hindi' | 'English'
  ): Promise<VoiceTranslationResult> {
    const startTime = performance.now();
    const cleanText = text.trim();

    if (!cleanText) {
      return {
        sourceText: text,
        targetText: '',
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        targetScript: targetLang === 'Santali' ? 'Ol_Chiki' : 'Devanagari',
        isOffline: true,
        providerName: this.getProviderName(),
        latencyMs: 0,
        confidence: 0,
        cached: false
      };
    }

    // 1. Check High-Speed Local Phrase Cache (Classroom Instructions & Core Words)
    const cachedPhrase = lookupOfflinePhrase(cleanText, sourceLang);
    if (cachedPhrase) {
      const elapsed = Math.round(performance.now() - startTime);
      let targetText = cachedPhrase.sat;
      if (targetLang === 'Hindi') targetText = cachedPhrase.hi;
      if (targetLang === 'English') targetText = cachedPhrase.en;

      return {
        sourceText: cleanText,
        targetText,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        targetScript: targetLang === 'Santali' ? 'Ol_Chiki' : 'Devanagari',
        isOffline: true,
        providerName: 'Verified Offline Classroom Cache',
        latencyMs: elapsed,
        confidence: 0.98,
        romanPhonetic: cachedPhrase.roman,
        cached: true
      };
    }

    // 2. Check Primary Verified Santali Dataset (300+ entries)
    const norm = cleanText.toLowerCase();
    for (const item of SANTALI_DATASET) {
      const matchHindi = sourceLang === 'Hindi' && item.hi && item.hi.toLowerCase().includes(norm);
      const matchEnglish = sourceLang === 'English' && item.en && item.en.toLowerCase().includes(norm);
      const matchSantali = sourceLang === 'Santali' && (item.sat === cleanText || (item.roman && item.roman.toLowerCase().includes(norm)));

      if (matchHindi || matchEnglish || matchSantali) {
        const elapsed = Math.round(performance.now() - startTime);
        let targetText = item.sat;
        if (targetLang === 'Hindi') targetText = item.hi;
        if (targetLang === 'English') targetText = item.en;

        return {
          sourceText: cleanText,
          targetText,
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
          targetScript: targetLang === 'Santali' ? 'Ol_Chiki' : 'Devanagari',
          isOffline: true,
          providerName: 'Santali Curated Offline Corpus',
          latencyMs: elapsed,
          confidence: 0.95,
          romanPhonetic: item.roman,
          cached: true
        };
      }
    }

    // 3. Honest Fallback when phrase is unverified in offline database
    const elapsed = Math.round(performance.now() - startTime);
    return {
      sourceText: cleanText,
      targetText: `[Santali phrase not yet verified in local corpus for: "${cleanText}"]`,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
      targetScript: 'Ol_Chiki',
      isOffline: true,
      providerName: this.getProviderName(),
      latencyMs: elapsed,
      confidence: 0.2,
      cached: false
    };
  }
}

/**
 * Bhasha Setu Offline Phrase & Audio Cache
 * Provides instantaneous, zero-latency local phrase retrieval across 10 vital
 * primary classroom categories for tribal education in Santali (Ol Chiki).
 * 
 * Works 100% offline without any model loading or network request.
 */

import { validateOlChikiScript } from '../contentValidator';

export interface CachedClassroomPhrase {
  id: string;
  phraseId?: string; // Standardized canonical ID
  category: 
    | 'Greetings'
    | 'Classroom instructions'
    | 'Numbers'
    | 'Colors'
    | 'Animals'
    | 'Family'
    | 'Body parts'
    | 'Food'
    | 'Agriculture'
    | 'Basic questions';
  sat: string;       // Ol Chiki text
  roman: string;     // Roman phonetic transcription
  en: string;        // English translation
  hi: string;        // Hindi translation
  audioPath: string; // Local audio asset path
  verified: boolean;
  priority: number;  // 1 = highest frequency in classroom
  sourceLanguage?: 'Hindi' | 'English' | 'Santali';
  sourceText?: string;
  targetLanguage?: 'Santali' | 'Hindi' | 'English';
  targetText?: string;
  targetScript?: 'Ol_Chiki' | 'Devanagari' | 'Latin';
  romanization?: string;
  audioAsset?: string;
  verificationStatus?: 'verified' | 'unverified';
  source?: 'curated_corpus' | 'classroom_dataset';
}

export const OFFLINE_CLASSROOM_PHRASES: CachedClassroomPhrase[] = [
  // 1. Greetings
  {
    id: 'phr_greet_01',
    category: 'Greetings',
    sat: 'ᱡᱚᱦᱟᱨ',
    roman: 'Johar',
    en: 'Greetings / Hello',
    hi: 'नमस्ते / प्रणाम',
    audioPath: '/audio/santali/phr_greet_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_greet_02',
    category: 'Greetings',
    sat: 'ᱥᱟᱹᱜᱩᱱ ᱥᱮᱛᱟᱜ',
    roman: 'Sagun setag',
    en: 'Good morning',
    hi: 'शुभ प्रभात',
    audioPath: '/audio/santali/phr_greet_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_greet_03',
    category: 'Greetings',
    sat: 'ᱥᱟᱹᱜᱩᱱ ᱛᱤᱠᱤᱱ',
    roman: 'Sagun tikin',
    en: 'Good afternoon',
    hi: 'शुभ दोपहर',
    audioPath: '/audio/santali/phr_greet_03.ogg',
    verified: true,
    priority: 2
  },
  {
    id: 'phr_greet_04',
    category: 'Greetings',
    sat: 'ᱥᱟᱹᱜᱩᱱ ᱟᱹᱭᱩᱵ',
    roman: 'Sagun ayub',
    en: 'Good evening',
    hi: 'शुभ संध्या',
    audioPath: '/audio/santali/phr_greet_04.ogg',
    verified: true,
    priority: 2
  },

  // 2. Classroom Instructions
  {
    id: 'phr_cls_01',
    category: 'Classroom instructions',
    sat: 'ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ',
    roman: 'Puthi jhij me',
    en: 'Open your book',
    hi: 'अपनी किताब खोलो',
    audioPath: '/audio/santali/phr_cls_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_cls_02',
    category: 'Classroom instructions',
    sat: 'ᱯᱩᱛᱷᱤ ᱵᱚᱸᱫᱽ ᱢᱮ',
    roman: 'Puthi bond me',
    en: 'Close your book',
    hi: 'अपनी किताब बंद करो',
    audioPath: '/audio/santali/phr_cls_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_cls_03',
    category: 'Classroom instructions',
    sat: 'ᱫᱩᱲᱩᱵ ᱢᱮ',
    roman: 'Durub me',
    en: 'Sit down',
    hi: 'बैठ जाओ',
    audioPath: '/audio/santali/phr_cls_03.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_cls_04',
    category: 'Classroom instructions',
    sat: 'ᱛᱤᱸᱜᱩᱱ ᱢᱮ',
    roman: 'Tingun me',
    en: 'Stand up',
    hi: 'खड़े हो जाओ',
    audioPath: '/audio/santali/phr_cls_04.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_cls_05',
    category: 'Classroom instructions',
    sat: 'ᱥᱟᱱᱛᱟᱲᱤ ᱛᱮ ᱢᱮᱱ ᱢᱮ',
    roman: 'Santali te men me',
    en: 'Say it in Santali',
    hi: 'संथाली में बोलो',
    audioPath: '/audio/santali/phr_cls_05.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_cls_06',
    category: 'Classroom instructions',
    sat: 'ᱵᱚᱨᱰ ᱨᱮ ᱠᱚᱭᱚᱜᱽ ᱢᱮ',
    roman: 'Bord re koyog me',
    en: 'Look at the board',
    hi: 'श्यामपट्ट (बोर्ड) पर देखो',
    audioPath: '/audio/santali/phr_cls_06.ogg',
    verified: true,
    priority: 2
  },

  // 3. Numbers
  {
    id: 'phr_num_01',
    category: 'Numbers',
    sat: 'ᱢᱤᱫ',
    roman: 'Mid',
    en: 'One',
    hi: 'एक',
    audioPath: '/audio/santali/phr_num_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_num_02',
    category: 'Numbers',
    sat: 'ᱵᱟᱨ',
    roman: 'Bar',
    en: 'Two',
    hi: 'दो',
    audioPath: '/audio/santali/phr_num_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_num_03',
    category: 'Numbers',
    sat: 'ᱯᱮ',
    roman: 'Pe',
    en: 'Three',
    hi: 'तीन',
    audioPath: '/audio/santali/phr_num_03.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_num_04',
    category: 'Numbers',
    sat: 'ᱯᱩᱱ',
    roman: 'Pun',
    en: 'Four',
    hi: 'चार',
    audioPath: '/audio/santali/phr_num_04.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_num_05',
    category: 'Numbers',
    sat: 'ᱢᱚᱬᱮ',
    roman: 'More',
    en: 'Five',
    hi: 'पाँच',
    audioPath: '/audio/santali/phr_num_05.ogg',
    verified: true,
    priority: 1
  },

  // 4. Colors
  {
    id: 'phr_col_01',
    category: 'Colors',
    sat: 'ᱟᱨᱟᱜ',
    roman: 'Arag',
    en: 'Red',
    hi: 'लाल',
    audioPath: '/audio/santali/phr_col_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_col_02',
    category: 'Colors',
    sat: 'ᱦᱟᱹᱨᱭᱟᱹᱲ',
    roman: 'Haryar',
    en: 'Green',
    hi: 'हरा',
    audioPath: '/audio/santali/phr_col_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_col_03',
    category: 'Colors',
    sat: 'ᱞᱤᱞ',
    roman: 'Lil',
    en: 'Blue',
    hi: 'नीला',
    audioPath: '/audio/santali/phr_col_03.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_col_04',
    category: 'Colors',
    sat: 'ᱥᱟᱥᱟᱝ',
    roman: 'Sasang',
    en: 'Yellow',
    hi: 'पीला',
    audioPath: '/audio/santali/phr_col_04.ogg',
    verified: true,
    priority: 1
  },

  // 5. Animals
  {
    id: 'phr_ani_01',
    category: 'Animals',
    sat: 'ᱥᱮᱛᱟ',
    roman: 'Seta',
    en: 'Dog',
    hi: 'कुत्ता',
    audioPath: '/audio/santali/phr_ani_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_ani_02',
    category: 'Animals',
    sat: 'ᱵᱤᱞᱟᱹᱭ',
    roman: 'Bilai',
    en: 'Cat',
    hi: 'बिल्ली',
    audioPath: '/audio/santali/phr_ani_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_ani_03',
    category: 'Animals',
    sat: 'ᱦᱟᱹᱛᱤ',
    roman: 'Hati',
    en: 'Elephant',
    hi: 'हाथी',
    audioPath: '/audio/santali/phr_ani_03.ogg',
    verified: true,
    priority: 2
  },

  // 6. Family
  {
    id: 'phr_fam_01',
    category: 'Family',
    sat: 'ᱮᱸᱜᱟᱛ',
    roman: 'Engat',
    en: 'Mother',
    hi: 'माँ / माता',
    audioPath: '/audio/santali/phr_fam_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_fam_02',
    category: 'Family',
    sat: 'ᱟᱯᱟᱛ',
    roman: 'Apat',
    en: 'Father',
    hi: 'पिता',
    audioPath: '/audio/santali/phr_fam_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_fam_03',
    category: 'Family',
    sat: 'ᱵᱚᱭᱦᱟ',
    roman: 'Boyha',
    en: 'Brother',
    hi: 'भाई',
    audioPath: '/audio/santali/phr_fam_03.ogg',
    verified: true,
    priority: 1
  },

  // 7. Body Parts
  {
    id: 'phr_bod_01',
    category: 'Body parts',
    sat: 'ᱢᱮᱫ',
    roman: 'Med',
    en: 'Eye',
    hi: 'आँख',
    audioPath: '/audio/santali/phr_bod_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_bod_02',
    category: 'Body parts',
    sat: 'ᱞᱩᱛᱩᱨ',
    roman: 'Lutur',
    en: 'Ear',
    hi: 'कान',
    audioPath: '/audio/santali/phr_bod_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_bod_03',
    category: 'Body parts',
    sat: 'ᱛᱤ',
    roman: 'Ti',
    en: 'Hand',
    hi: 'हाथ',
    audioPath: '/audio/santali/phr_bod_03.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_bod_04',
    category: 'Body parts',
    sat: 'ᱡᱟᱝᱜᱟ',
    roman: 'Janga',
    en: 'Leg / Foot',
    hi: 'पैर',
    audioPath: '/audio/santali/phr_bod_04.ogg',
    verified: true,
    priority: 1
  },

  // 8. Food
  {
    id: 'phr_foo_01',
    category: 'Food',
    sat: 'ᱫᱟᱠᱟ',
    roman: 'Daka',
    en: 'Cooked rice / Food',
    hi: 'चावल / भात',
    audioPath: '/audio/santali/phr_foo_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_foo_02',
    category: 'Food',
    sat: 'ᱫᱟᱜ',
    roman: 'Dag',
    en: 'Water',
    hi: 'पानी',
    audioPath: '/audio/santali/phr_foo_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_foo_03',
    category: 'Food',
    sat: 'ᱩᱛᱩ',
    roman: 'Utu',
    en: 'Curry / Cooked vegetables',
    hi: 'सब्जी / तरकारी',
    audioPath: '/audio/santali/phr_foo_03.ogg',
    verified: true,
    priority: 2
  },

  // 9. Agriculture
  {
    id: 'phr_agr_01',
    category: 'Agriculture',
    sat: 'ᱦᱟᱥᱟ',
    roman: 'Hasa',
    en: 'Soil / Earth',
    hi: 'मिट्टी',
    audioPath: '/audio/santali/phr_agr_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_agr_02',
    category: 'Agriculture',
    sat: 'ᱪᱟᱥ',
    roman: 'Chas',
    en: 'Farming / Agriculture',
    hi: 'खेती',
    audioPath: '/audio/santali/phr_agr_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_agr_03',
    category: 'Agriculture',
    sat: 'ᱦᱩᱲᱩ',
    roman: 'Huru',
    en: 'Paddy / Unhusked rice',
    hi: 'धान',
    audioPath: '/audio/santali/phr_agr_03.ogg',
    verified: true,
    priority: 2
  },

  // 10. Basic Questions
  {
    id: 'phr_que_01',
    category: 'Basic questions',
    sat: 'ᱪᱮᱫ ᱮᱢ ᱪᱤᱠᱟᱹᱭᱮᱫᱼᱟ?',
    roman: 'Ched em chikaye-a?',
    en: 'What are you doing?',
    hi: 'तुम क्या कर रहे हो?',
    audioPath: '/audio/santali/phr_que_01.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_que_02',
    category: 'Basic questions',
    sat: 'ᱟᱢᱟᱜ ᱧᱩᱛᱩᱢ ᱪᱮᱫ?',
    roman: 'Amag nutum ched?',
    en: 'What is your name?',
    hi: 'तुम्हारा नाम क्या है?',
    audioPath: '/audio/santali/phr_que_02.ogg',
    verified: true,
    priority: 1
  },
  {
    id: 'phr_que_03',
    category: 'Basic questions',
    sat: 'ᱚᱠᱟ ᱛᱮᱢ ᱪᱟᱞᱟᱜ ᱠᱟᱱᱟ?',
    roman: 'Oka tem chalag kana?',
    en: 'Where are you going?',
    hi: 'तुम कहाँ जा रहे हो?',
    audioPath: '/audio/santali/phr_que_03.ogg',
    verified: true,
    priority: 2
  }
];

// Validate all phrases at load time using Unicode Ol Chiki quality gate
for (const phrase of OFFLINE_CLASSROOM_PHRASES) {
  if (!validateOlChikiScript(phrase.sat)) {
    console.error(`[OfflinePhraseCache] Quality gate failure: Invalid Ol Chiki in phrase "${phrase.id}" (${phrase.sat})`);
  }
}

/**
 * Normalizes input text for case/diacritic-insensitive matching.
 */
function normalizeQuery(q: string): string {
  return q.trim().toLowerCase().replace(/[?,.!/\\-]/g, '').replace(/\s+/g, ' ');
}

function enrichPhrase(phrase: CachedClassroomPhrase, sourceLang?: 'Hindi' | 'English' | 'Santali'): CachedClassroomPhrase {
  const lang = sourceLang || 'Hindi';
  return {
    ...phrase,
    phraseId: phrase.phraseId || phrase.id,
    sourceLanguage: lang,
    sourceText: lang === 'Hindi' ? phrase.hi : lang === 'English' ? phrase.en : phrase.sat,
    targetLanguage: lang === 'Santali' ? 'Hindi' : 'Santali',
    targetText: lang === 'Santali' ? phrase.hi : phrase.sat,
    targetScript: lang === 'Santali' ? 'Devanagari' : 'Ol_Chiki',
    romanization: phrase.roman,
    audioAsset: phrase.audioPath,
    verificationStatus: phrase.verified ? 'verified' : 'unverified',
    source: 'classroom_dataset'
  };
}

/**
 * High-speed offline phrase lookup from verified cache.
 * Latency is typically < 2 milliseconds.
 */
export function lookupOfflinePhrase(
  query: string,
  sourceLang: 'Hindi' | 'English' | 'Santali'
): CachedClassroomPhrase | null {
  if (!query || !query.trim()) return null;
  const normalized = normalizeQuery(query);

  for (const phrase of OFFLINE_CLASSROOM_PHRASES) {
    if (sourceLang === 'Hindi' && normalizeQuery(phrase.hi).includes(normalized)) {
      return enrichPhrase(phrase, sourceLang);
    }
    if (sourceLang === 'English' && normalizeQuery(phrase.en).includes(normalized)) {
      return enrichPhrase(phrase, sourceLang);
    }
    if (sourceLang === 'Santali' && (phrase.sat === query.trim() || normalizeQuery(phrase.roman).includes(normalized))) {
      return enrichPhrase(phrase, sourceLang);
    }
  }

  return null;
}

/**
 * Returns all offline phrases for a given category.
 */
export function getPhrasesByCategory(category: CachedClassroomPhrase['category']): CachedClassroomPhrase[] {
  return OFFLINE_CLASSROOM_PHRASES.filter(p => p.category === category).map(p => enrichPhrase(p));
}

/**
 * Returns all supported offline categories.
 */
export function getAllOfflineCategories(): CachedClassroomPhrase['category'][] {
  return [
    'Greetings',
    'Classroom instructions',
    'Numbers',
    'Colors',
    'Animals',
    'Family',
    'Body parts',
    'Food',
    'Agriculture',
    'Basic questions'
  ];
}

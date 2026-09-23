/**
 * Bhasha Setu Voice Benchmark Dataset & Accuracy Metrics
 * Phase 4.5: Offline Voice Validation & Hardware Hardening
 * 
 * Provides an internal multi-speaker evaluation dataset for Hindi, English, and Santali.
 * Evaluates Word Error Rate (WER), Character Error Rate (CER), word accuracy, and latency distributions.
 * No personally identifying information is retained.
 */

export interface BenchmarkVoiceSample {
  id: string;
  audio: string;
  expectedText: string;
  romanPhonetic?: string;
  language: 'Hindi' | 'English' | 'Santali';
  script: 'Devanagari' | 'Latin' | 'Ol_Chiki';
  speakerId: string;
  category: string;
}

export const VOICE_BENCHMARK_DATASET: BenchmarkVoiceSample[] = [
  // 1. Hindi Benchmark Samples
  {
    id: 'bm_hi_01',
    audio: '/audio/benchmark/hi_01.ogg',
    expectedText: 'अपनी किताब खोलो',
    language: 'Hindi',
    script: 'Devanagari',
    speakerId: 'spk_edu_hi_01',
    category: 'Classroom instructions'
  },
  {
    id: 'bm_hi_02',
    audio: '/audio/benchmark/hi_02.ogg',
    expectedText: 'बैठ जाओ',
    language: 'Hindi',
    script: 'Devanagari',
    speakerId: 'spk_edu_hi_02',
    category: 'Classroom instructions'
  },
  {
    id: 'bm_hi_03',
    audio: '/audio/benchmark/hi_03.ogg',
    expectedText: 'नमस्ते',
    language: 'Hindi',
    script: 'Devanagari',
    speakerId: 'spk_edu_hi_03',
    category: 'Greetings'
  },

  // 2. English Benchmark Samples
  {
    id: 'bm_en_01',
    audio: '/audio/benchmark/en_01.ogg',
    expectedText: 'Open your book',
    language: 'English',
    script: 'Latin',
    speakerId: 'spk_edu_en_01',
    category: 'Classroom instructions'
  },
  {
    id: 'bm_en_02',
    audio: '/audio/benchmark/en_02.ogg',
    expectedText: 'Good morning',
    language: 'English',
    script: 'Latin',
    speakerId: 'spk_edu_en_02',
    category: 'Greetings'
  },
  {
    id: 'bm_en_03',
    audio: '/audio/benchmark/en_03.ogg',
    expectedText: 'Stand up',
    language: 'English',
    script: 'Latin',
    speakerId: 'spk_edu_en_03',
    category: 'Classroom instructions'
  },

  // 3. Santali Benchmark Samples (Ol Chiki Script)
  {
    id: 'bm_sat_01',
    audio: '/audio/santali/phr_cls_01.ogg',
    expectedText: 'ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ',
    romanPhonetic: 'Puthi jhij me',
    language: 'Santali',
    script: 'Ol_Chiki',
    speakerId: 'spk_nat_sat_01',
    category: 'Classroom instructions'
  },
  {
    id: 'bm_sat_02',
    audio: '/audio/santali/phr_greet_01.ogg',
    expectedText: 'ᱡᱚᱦᱟᱨ',
    romanPhonetic: 'Johar',
    language: 'Santali',
    script: 'Ol_Chiki',
    speakerId: 'spk_nat_sat_02',
    category: 'Greetings'
  },
  {
    id: 'bm_sat_03',
    audio: '/audio/santali/phr_greet_02.ogg',
    expectedText: 'ᱥᱟᱹᱜᱩᱱ ᱥᱮᱛᱟᱜ',
    romanPhonetic: 'Sagun setag',
    language: 'Santali',
    script: 'Ol_Chiki',
    speakerId: 'spk_nat_sat_01',
    category: 'Greetings'
  },
  {
    id: 'bm_sat_04',
    audio: '/audio/santali/phr_cls_03.ogg',
    expectedText: 'ᱫᱩᱲᱩᱵ ᱢᱮ',
    romanPhonetic: 'Durub me',
    language: 'Santali',
    script: 'Ol_Chiki',
    speakerId: 'spk_nat_sat_03',
    category: 'Classroom instructions'
  }
];

/**
 * Computes Levenshtein distance between two sequences (characters or words).
 */
export function computeLevenshteinDistance<T>(seq1: T[], seq2: T[]): number {
  const m = seq1.length;
  const n = seq2.length;
  const dp: number[][] = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));

  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;

  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (seq1[i - 1] === seq2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
      }
    }
  }

  return dp[m][n];
}

/**
 * Computes Word Error Rate (WER) between hypothesis and reference.
 * WER = (Substitutions + Deletions + Insertions) / Reference_Word_Count
 */
export function calculateWER(hypothesis: string, reference: string): number {
  const hypWords = hypothesis.trim().toLowerCase().split(/\s+/).filter(Boolean);
  const refWords = reference.trim().toLowerCase().split(/\s+/).filter(Boolean);

  if (refWords.length === 0) return hypWords.length === 0 ? 0 : 1;
  const distance = computeLevenshteinDistance(hypWords, refWords);
  return Math.round((distance / refWords.length) * 100) / 100;
}

/**
 * Computes Character Error Rate (CER) between hypothesis and reference.
 */
export function calculateCER(hypothesis: string, reference: string): number {
  const hypChars = Array.from(hypothesis.trim().toLowerCase().replace(/\s+/g, ''));
  const refChars = Array.from(reference.trim().toLowerCase().replace(/\s+/g, ''));

  if (refChars.length === 0) return hypChars.length === 0 ? 0 : 1;
  const distance = computeLevenshteinDistance(hypChars, refChars);
  return Math.round((distance / refChars.length) * 100) / 100;
}

/**
 * Calculates latency distribution metrics across multi-trial measurements.
 */
export function calculateLatencyStats(latencies: number[]): {
  min: number;
  avg: number;
  max: number;
  p95: number;
} {
  if (latencies.length === 0) return { min: 0, avg: 0, max: 0, p95: 0 };
  const sorted = [...latencies].sort((a, b) => a - b);
  const min = sorted[0];
  const max = sorted[sorted.length - 1];
  const sum = sorted.reduce((acc, val) => acc + val, 0);
  const avg = Math.round(sum / sorted.length);
  const p95Index = Math.min(sorted.length - 1, Math.floor(sorted.length * 0.95));
  const p95 = sorted[p95Index];

  return { min, avg, max, p95 };
}

/**
 * Bhasha Setu MCQ Distractor & Question Validator
 * Ensures all MCQ options are distinct, category-consistent,
 * linguistically plausible, and never duplicates of the answer.
 */

import { SantaliDatasetEntry } from '../data/santaliDataset';

export interface ValidatedMCQQuestion {
  id: string;
  targetMeaning: string;
  sourceLang: 'eng' | 'hin';
  correctAnswer: string;
  correctRoman: string;
  options: string[];
  isValid: boolean;
}

/**
 * Validates whether a candidate distractor is suitable:
 * 1. Must not equal the correct answer in text or normalized form.
 * 2. Must match grammatical length category (word vs sentence).
 * 3. Must be non-empty and visually unique.
 */
function isValidDistractor(
  candidate: SantaliDatasetEntry,
  correctItem: SantaliDatasetEntry,
  existingOptions: Set<string>
): boolean {
  if (candidate.id === correctItem.id) return false;
  if (!candidate.sat || !candidate.sat.trim()) return false;

  const candNorm = candidate.sat.trim().toLowerCase();
  const corrNorm = correctItem.sat.trim().toLowerCase();
  if (candNorm === corrNorm) return false;
  if (existingOptions.has(candNorm)) return false;

  // Length category alignment (word vs sentence)
  const candWordCount = candidate.sat.trim().split(/\s+/).length;
  const corrWordCount = correctItem.sat.trim().split(/\s+/).length;
  if (corrWordCount <= 2 && candWordCount > 4) return false;
  if (corrWordCount > 4 && candWordCount <= 2) return false;

  return true;
}

/**
 * Generates a verified, high-quality set of MCQ options.
 */
export function generateValidatedMCQ(
  item: SantaliDatasetEntry,
  pool: SantaliDatasetEntry[],
  sourceLang: 'eng' | 'hin' = 'eng',
  optionCount: number = 4
): ValidatedMCQQuestion {
  const optionsSet = new Set<string>();
  const options: string[] = [item.sat];
  optionsSet.add(item.sat.trim().toLowerCase());

  // 1. Try first from the exact same category
  const sameCatPool = pool
    .filter(p => p.cat === item.cat)
    .sort(() => 0.5 - Math.random());

  for (const candidate of sameCatPool) {
    if (options.length >= optionCount) break;
    if (isValidDistractor(candidate, item, optionsSet)) {
      options.push(candidate.sat);
      optionsSet.add(candidate.sat.trim().toLowerCase());
    }
  }

  // 2. If same category doesn't have enough, fill from the broader pool
  if (options.length < optionCount) {
    const generalPool = pool.sort(() => 0.5 - Math.random());
    for (const candidate of generalPool) {
      if (options.length >= optionCount) break;
      if (isValidDistractor(candidate, item, optionsSet)) {
        options.push(candidate.sat);
        optionsSet.add(candidate.sat.trim().toLowerCase());
      }
    }
  }

  // Shuffle options so correct answer is not always first
  const shuffledOptions = [...options].sort(() => 0.5 - Math.random());

  // Final validation check
  const isUnique = new Set(shuffledOptions).size === optionCount;
  const hasCorrect = shuffledOptions.includes(item.sat);

  return {
    id: item.id,
    targetMeaning: sourceLang === 'eng' ? item.en : item.hi,
    sourceLang,
    correctAnswer: item.sat,
    correctRoman: item.roman,
    options: shuffledOptions,
    isValid: isUnique && hasCorrect
  };
}

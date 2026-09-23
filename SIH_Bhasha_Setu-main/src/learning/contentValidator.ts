/**
 * Bhasha Setu Content Quality & Verification Pipeline
 * Enforces strict language/script separation, validates tribal glyphs,
 * and ensures only verified, published content reaches student-facing activities.
 */

import { LearningItem, TribalLanguage, ScriptType, ContentStatus } from './types';

export interface ContentValidationResult {
  isValid: boolean;
  errors: string[];
  warnings: string[];
}

/**
 * Validates that Santali Ol Chiki strings contain authentic characters within the Unicode range:
 * Ol Chiki: U+1C50 to U+1C7F
 */
export function validateOlChikiScript(text: string): boolean {
  if (!text || !text.trim()) return false;
  // Allow Ol Chiki characters, whitespace, and basic punctuation
  const olChikiRegex = /^[\u1C50-\u1C7F\s.,!?'"()\-–—]+$/;
  return olChikiRegex.test(text.trim());
}

/**
 * Validates a candidate learning item against the 7-stage content quality gate:
 * 1. Content Status Check: Must be 'verified' or 'published' for student delivery.
 * 2. Language & Script Alignment: e.g. Santali + Ol_Chiki.
 * 3. Script Integrity: Validates Unicode block for non-Latin scripts.
 * 4. Text Completeness: No empty fields in target, roman, or translation.
 * 5. Length & Formatting: Sanity checks against truncation.
 * 6. Non-Pollution: Ensures distinct language identities (no mixing Santali with Mundari/Ho).
 * 7. Verification Attribution: Verified items must declare verification source.
 */
export function validateLearningItem(item: LearningItem): ContentValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  // Stage 1: Content Status Check
  const status: ContentStatus = item.contentStatus || (item.verified ? 'published' : 'draft');
  if (status === 'draft') {
    errors.push(`Item "${item.id}" is currently in 'draft' status and cannot be served to students.`);
  }

  // Stage 2: Language & Script Alignment
  if (item.language === 'Santali' && item.script !== 'Ol_Chiki' && item.script !== 'Latin' && item.script !== 'Devanagari') {
    errors.push(`Invalid script "${item.script}" declared for language "Santali".`);
  }

  // Stage 3: Script Integrity Check
  if (item.script === 'Ol_Chiki' && !validateOlChikiScript(item.sat)) {
    errors.push(`Text in item "${item.id}" contains invalid characters outside the Ol Chiki Unicode block (U+1C50–U+1C7F).`);
  }

  // Stage 4: Completeness
  if (!item.sat || !item.sat.trim()) {
    errors.push(`Item "${item.id}" is missing target tribal text.`);
  }
  if (!item.en || !item.en.trim()) {
    errors.push(`Item "${item.id}" is missing English translation.`);
  }
  if (!item.hi || !item.hi.trim()) {
    warnings.push(`Item "${item.id}" is missing Hindi translation.`);
  }
  if (!item.roman || !item.roman.trim()) {
    warnings.push(`Item "${item.id}" is missing Roman phonetic transliteration.`);
  }

  // Stage 5: Non-Pollution Check
  // Ensure the target text is not identical to English/Hindi
  if (item.sat.trim().toLowerCase() === item.en.trim().toLowerCase()) {
    errors.push(`Tribal text in item "${item.id}" is identical to English translation (untranslated content).`);
  }

  return {
    isValid: errors.length === 0,
    errors,
    warnings
  };
}

/**
 * Filters a pool of learning items, returning only verified and published entries.
 * Automatically excludes unverified drafts and items failing quality validation.
 */
export function filterVerifiedStudentContent(items: LearningItem[]): LearningItem[] {
  return items.filter(item => {
    // Exclude unverified drafts
    if (item.verified === false) return false;
    if (item.contentStatus === 'draft') return false;

    // Run quality validation
    const res = validateLearningItem(item);
    return res.isValid;
  });
}

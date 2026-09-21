/**
 * Bhasha Setu FLN Curriculum Mapping & Content Enrichment
 * Maps foundational learning competencies (Literacy & Numeracy)
 * to existing verified tribal language datasets.
 */

import { SantaliDatasetEntry, SANTALI_DATASET } from '../data/santaliDataset';
import { LearningItem, FLNDomain, FLNSkill, DifficultyLevel } from './types';

export interface FLNOutcome {
  id: string;
  grade: number;
  domain: FLNDomain;
  skill: FLNSkill;
  description: string;
  targetCategories: string[];
}

export const FLN_CURRICULUM_MAP: FLNOutcome[] = [
  {
    id: 'FLN-LIT-VOC-G1',
    grade: 1,
    domain: 'literacy',
    skill: 'vocabulary',
    description: 'Recognizes and names familiar animals, body parts, and classroom objects in Ol Chiki and regional language.',
    targetCategories: ['Animal', 'Body Parts', 'Normally Used Words in Classroom']
  },
  {
    id: 'FLN-LIT-SCR-G1',
    grade: 1,
    domain: 'literacy',
    skill: 'script_recognition',
    description: 'Traces and forms foundational Ol Chiki graphemes with accurate stroke orientation.',
    targetCategories: ['Normally Used Words in Classroom', 'Animal']
  },
  {
    id: 'FLN-NUM-CNT-G1',
    grade: 1,
    domain: 'numeracy',
    skill: 'numeracy',
    description: 'Identifies, matches, and reads numerals and quantity terms 1–100 in tribal and state languages.',
    targetCategories: ['Numbers']
  },
  {
    id: 'FLN-LIT-SEN-G2',
    grade: 2,
    domain: 'literacy',
    skill: 'sentence_building',
    description: 'Reconstructs basic Subject-Object-Verb (SOV) sentences using familiar tribal vocabulary tiles.',
    targetCategories: ['Normally Used Words in Classroom', 'Animal', 'Food']
  },
  {
    id: 'FLN-LIT-RDG-G3',
    grade: 3,
    domain: 'literacy',
    skill: 'reading',
    description: 'Reads connected sentences and matches contextual meaning across tribal and instructional languages.',
    targetCategories: ['General', 'Food', 'Normally Used Words in Classroom']
  }
];

/**
 * Enriches a standard SantaliDatasetEntry with curriculum metadata
 * without mutating the underlying corpus.
 */
export function enrichLearningItem(entry: SantaliDatasetEntry): LearningItem {
  const cat = entry.cat || 'General';
  const wordCount = entry.sat.trim().split(/\s+/).length;

  // Domain & Skill determination
  let fln_domain: FLNDomain = 'literacy';
  let skill: FLNSkill = 'vocabulary';
  let grade = 1;
  let difficulty: DifficultyLevel = 1;

  if (cat.toLowerCase().includes('number')) {
    fln_domain = 'numeracy';
    skill = 'numeracy';
    difficulty = wordCount > 2 ? 2 : 1;
    grade = 1;
  } else if (wordCount > 3) {
    fln_domain = 'literacy';
    skill = 'sentence_building';
    difficulty = wordCount > 6 ? 4 : (wordCount > 4 ? 3 : 2);
    grade = difficulty >= 3 ? 3 : 2;
  } else if (wordCount > 1) {
    fln_domain = 'literacy';
    skill = 'reading';
    difficulty = 2;
    grade = 2;
  } else {
    fln_domain = 'literacy';
    skill = 'vocabulary';
    difficulty = 1;
    grade = 1;
  }

  return {
    ...entry,
    language: 'Santali',
    script: 'Ol_Chiki',
    topic: cat,
    grade,
    skill,
    difficulty,
    fln_domain,
    learning_outcome: `Master ${skill} in ${cat} (${entry.roman})`,
    verified: entry.verified !== false
  };
}

/**
 * Cached enriched dataset for efficient in-memory adaptive filtering
 */
let _cachedEnrichedItems: LearningItem[] | null = null;

export function getEnrichedLearningItems(): LearningItem[] {
  if (!_cachedEnrichedItems) {
    _cachedEnrichedItems = SANTALI_DATASET.map(enrichLearningItem);
  }
  return _cachedEnrichedItems;
}

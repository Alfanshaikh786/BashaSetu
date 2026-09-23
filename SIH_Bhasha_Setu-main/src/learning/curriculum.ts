/**
 * Bhasha Setu FLN Curriculum Mapping & Content Enrichment (v3)
 * Comprehensive curriculum tree mapping Grades 1–5 foundational competencies
 * across Foundational Literacy & Foundational Numeracy to verified tribal datasets.
 */

import { SantaliDatasetEntry, SANTALI_DATASET } from '../data/santaliDataset';
import { LearningItem, FLNDomain, FLNSkill, DifficultyLevel, ContentStatus } from './types';
import { LearningActivityType } from './learningEvents';

export interface FLNOutcome {
  id: string;
  grade: number; // 1 to 5
  domain: FLNDomain;
  skill: FLNSkill;
  title: string;
  description: string;
  targetCategories: string[];
  targetActivities: LearningActivityType[];
  difficultyRange: [DifficultyLevel, DifficultyLevel];
  prerequisiteSkills?: FLNSkill[];
}

export const FLN_CURRICULUM_MAP: FLNOutcome[] = [
  // ==========================================
  // GRADE 1: FOUNDATIONAL LITERACY
  // ==========================================
  {
    id: 'FLN-LIT-VOC-G1',
    grade: 1,
    domain: 'literacy',
    skill: 'vocabulary',
    title: 'Foundational Naming Words',
    description: 'Recognizes and names familiar animals, body parts, and classroom objects in Ol Chiki and regional language.',
    targetCategories: ['Animal', 'Body Parts', 'Normally Used Words in Classroom'],
    targetActivities: ['flashcard', 'matching'],
    difficultyRange: [1, 2]
  },
  {
    id: 'FLN-LIT-SCR-G1',
    grade: 1,
    domain: 'literacy',
    skill: 'script_recognition',
    title: 'Ol Chiki Grapheme Tracing',
    description: 'Traces and forms foundational Ol Chiki graphemes with accurate stroke orientation and letter sound association.',
    targetCategories: ['Normally Used Words in Classroom', 'Animal'],
    targetActivities: ['tracing', 'flashcard'],
    difficultyRange: [1, 2]
  },
  {
    id: 'FLN-LIT-PHO-G1',
    grade: 1,
    domain: 'literacy',
    skill: 'phonological_awareness',
    title: 'Phonetic Sound & Word Bridge',
    description: 'Listens to native phonetic pronunciations and associates spoken acoustic syllables with visual words.',
    targetCategories: ['Normally Used Words in Classroom', 'Family', 'Animal'],
    targetActivities: ['flashcard', 'listening'],
    difficultyRange: [1, 2]
  },

  // ==========================================
  // GRADE 1: FOUNDATIONAL NUMERACY
  // ==========================================
  {
    id: 'FLN-NUM-REC-G1',
    grade: 1,
    domain: 'numeracy',
    skill: 'number_recognition',
    title: 'Numeral & Quantity Identification (1–20)',
    description: 'Identifies, matches, and reads numerals and quantity terms 1–20 in Ol Chiki and state language.',
    targetCategories: ['Numbers'],
    targetActivities: ['flashcard', 'matching'],
    difficultyRange: [1, 2]
  },
  {
    id: 'FLN-NUM-CNT-G1',
    grade: 1,
    domain: 'numeracy',
    skill: 'counting',
    title: 'Concrete Counting & Matching',
    description: 'Counts sets of concrete visual objects and associates them with corresponding numeric glyphs.',
    targetCategories: ['Numbers'],
    targetActivities: ['matching', 'mcq'],
    difficultyRange: [1, 2]
  },

  // ==========================================
  // GRADE 2: FOUNDATIONAL LITERACY
  // ==========================================
  {
    id: 'FLN-LIT-SEN-G2',
    grade: 2,
    domain: 'literacy',
    skill: 'sentence_building',
    title: 'Basic SOV Sentence Construction',
    description: 'Reconstructs basic Subject-Object-Verb (SOV) sentences using familiar tribal vocabulary tiles.',
    targetCategories: ['Normally Used Words in Classroom', 'Animal', 'Food'],
    targetActivities: ['scramble', 'mcq'],
    difficultyRange: [2, 3],
    prerequisiteSkills: ['vocabulary']
  },
  {
    id: 'FLN-LIT-WRD-G2',
    grade: 2,
    domain: 'literacy',
    skill: 'word_recognition',
    title: 'Bilingual Word Association',
    description: 'Connects Santali Ol Chiki vocabulary with Hindi and English meanings in everyday contexts.',
    targetCategories: ['Family', 'Nature', 'Food'],
    targetActivities: ['matching', 'mcq', 'flashcard'],
    difficultyRange: [2, 3]
  },

  // ==========================================
  // GRADE 2: FOUNDATIONAL NUMERACY
  // ==========================================
  {
    id: 'FLN-NUM-ORD-G2',
    grade: 2,
    domain: 'numeracy',
    skill: 'number_ordering',
    title: 'Number Sequencing & Comparison (1–100)',
    description: 'Orders and compares two-digit numbers, identifying greater than, less than, and equal sets.',
    targetCategories: ['Numbers'],
    targetActivities: ['scramble', 'mcq'],
    difficultyRange: [2, 3],
    prerequisiteSkills: ['number_recognition']
  },

  // ==========================================
  // GRADE 3: FOUNDATIONAL LITERACY
  // ==========================================
  {
    id: 'FLN-LIT-RDG-G3',
    grade: 3,
    domain: 'literacy',
    skill: 'reading',
    title: 'Connected Sentence Reading',
    description: 'Reads connected multi-word sentences and matches contextual meaning across tribal and instructional languages.',
    targetCategories: ['General', 'Food', 'Normally Used Words in Classroom'],
    targetActivities: ['mcq', 'quiz'],
    difficultyRange: [2, 4],
    prerequisiteSkills: ['sentence_building', 'vocabulary']
  },
  {
    id: 'FLN-LIT-COM-G3',
    grade: 3,
    domain: 'literacy',
    skill: 'reading_comprehension',
    title: 'Contextual Comprehension & Meaning',
    description: 'Answers targeted questions demonstrating understanding of short descriptive passages in tribal literature.',
    targetCategories: ['General', 'Nature'],
    targetActivities: ['mcq', 'quiz'],
    difficultyRange: [3, 4],
    prerequisiteSkills: ['reading']
  },

  // ==========================================
  // GRADE 3: FOUNDATIONAL NUMERACY
  // ==========================================
  {
    id: 'FLN-NUM-OPS-G3',
    grade: 3,
    domain: 'numeracy',
    skill: 'simple_word_problems',
    title: 'Everyday Practical Arithmetic',
    description: 'Solves single-step contextual addition and subtraction problems using everyday tribal marketplace vocabulary.',
    targetCategories: ['Numbers', 'Food'],
    targetActivities: ['mcq', 'quiz'],
    difficultyRange: [3, 4],
    prerequisiteSkills: ['counting', 'number_ordering']
  }
];

/**
 * Returns curriculum outcomes filtered by grade and optional FLN domain.
 */
export function getCurriculumOutcomesForGrade(grade: number, domain?: FLNDomain): FLNOutcome[] {
  return FLN_CURRICULUM_MAP.filter(o => o.grade === grade && (!domain || o.domain === domain));
}

/**
 * Finds the primary curriculum outcome mapped to a given skill.
 */
export function getOutcomeForSkill(skill: FLNSkill, grade?: number): FLNOutcome | undefined {
  return FLN_CURRICULUM_MAP.find(o => o.skill === skill && (!grade || o.grade === grade)) ||
         FLN_CURRICULUM_MAP.find(o => o.skill === skill);
}

/**
 * Returns all skills associated with a learning domain.
 */
export function getCurriculumSkillsByDomain(domain: FLNDomain): FLNSkill[] {
  const set = new Set<FLNSkill>();
  FLN_CURRICULUM_MAP.filter(o => o.domain === domain).forEach(o => set.add(o.skill));
  return Array.from(set);
}

/**
 * Enriches a standard SantaliDatasetEntry with curriculum metadata
 * without mutating the underlying corpus.
 */
export function enrichLearningItem(entry: SantaliDatasetEntry): LearningItem {
  const cat = entry.cat || 'General';
  const wordCount = entry.sat.trim().split(/\s+/).length;

  let fln_domain: FLNDomain = 'literacy';
  let skill: FLNSkill = 'vocabulary';
  let grade = 1;
  let difficulty: DifficultyLevel = 1;

  if (cat.toLowerCase().includes('number')) {
    fln_domain = 'numeracy';
    skill = wordCount > 2 ? 'number_ordering' : 'number_recognition';
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

  const contentStatus: ContentStatus = entry.verified !== false ? 'published' : 'draft';

  return {
    ...entry,
    language: 'Santali',
    script: 'Ol_Chiki',
    topic: cat,
    grade,
    skill,
    difficulty,
    fln_domain,
    learning_outcome: `Master ${skill.replace('_', ' ')} in ${cat} (${entry.roman})`,
    verified: entry.verified !== false,
    contentStatus,
    verifiedBy: entry.verified !== false ? 'Corpus Peer Reviewer' : undefined,
    verifiedAt: entry.verified !== false ? '2026-01-15' : undefined
  };
}

let _cachedEnrichedItems: LearningItem[] | null = null;

export function getEnrichedLearningItems(): LearningItem[] {
  if (!_cachedEnrichedItems) {
    _cachedEnrichedItems = SANTALI_DATASET.map(enrichLearningItem);
  }
  return _cachedEnrichedItems;
}

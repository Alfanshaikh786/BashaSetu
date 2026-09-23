/**
 * Bhasha Setu Extensible Activity Registry
 * Catalogs all interactive FLN activity modules, their pedagogical skill targets,
 * difficulty boundaries, and language/script compatibility.
 */

import { FLNSkill, FLNDomain, DifficultyLevel, TribalLanguage, ScriptType } from './types';
import { LearningActivityType } from './learningEvents';

export interface ActivityMetadata {
  activityType: LearningActivityType;
  title: string;
  description: string;
  domain: FLNDomain;
  skillsTested: FLNSkill[];
  difficultyRange: [DifficultyLevel, DifficultyLevel];
  supportedLanguages: TribalLanguage[];
  supportedScripts: ScriptType[];
  offlineAvailable: boolean;
  requiresAudio: boolean;
}

export const ACTIVITY_REGISTRY: Record<LearningActivityType, ActivityMetadata> = {
  flashcard: {
    activityType: 'flashcard',
    title: '3D Audio Flashcards',
    description: 'Bilingual 3D interactive flashcards with native human audio and spaced repetition tracking.',
    domain: 'literacy',
    skillsTested: ['vocabulary', 'script_recognition', 'phonological_awareness', 'number_recognition'],
    difficultyRange: [1, 3],
    supportedLanguages: ['Santali', 'Mundari', 'Ho'],
    supportedScripts: ['Ol_Chiki', 'Devanagari', 'Latin'],
    offlineAvailable: true,
    requiresAudio: true
  },
  matching: {
    activityType: 'matching',
    title: 'Match the Pairs Puzzle',
    description: 'Drag or tap to connect Ol Chiki terms with matching pictorial or Hindi/English definitions.',
    domain: 'literacy',
    skillsTested: ['vocabulary', 'word_recognition', 'counting', 'number_recognition'],
    difficultyRange: [1, 2],
    supportedLanguages: ['Santali', 'Mundari', 'Ho'],
    supportedScripts: ['Ol_Chiki', 'Devanagari', 'Latin'],
    offlineAvailable: true,
    requiresAudio: false
  },
  scramble: {
    activityType: 'scramble',
    title: 'Sentence Builder Scramble',
    description: 'Reconstruct Subject-Object-Verb tribal sentences from scrambled vocabulary word tiles.',
    domain: 'literacy',
    skillsTested: ['sentence_building', 'number_ordering'],
    difficultyRange: [2, 4],
    supportedLanguages: ['Santali', 'Mundari', 'Ho'],
    supportedScripts: ['Ol_Chiki', 'Devanagari', 'Latin'],
    offlineAvailable: true,
    requiresAudio: false
  },
  tracing: {
    activityType: 'tracing',
    title: 'Ol Chiki Calligraphy Tracing Pad',
    description: 'Digital canvas for practicing stroke direction and glyph formation for Ol Chiki characters.',
    domain: 'literacy',
    skillsTested: ['script_recognition', 'letter_recognition'],
    difficultyRange: [1, 2],
    supportedLanguages: ['Santali'],
    supportedScripts: ['Ol_Chiki'],
    offlineAvailable: true,
    requiresAudio: false
  },
  mcq: {
    activityType: 'mcq',
    title: 'Validated Multiple Choice Check',
    description: 'Curriculum-aligned multiple choice questions with verified distractors.',
    domain: 'literacy',
    skillsTested: ['reading', 'reading_comprehension', 'number_comparison', 'simple_word_problems'],
    difficultyRange: [1, 4],
    supportedLanguages: ['Santali', 'Mundari', 'Ho'],
    supportedScripts: ['Ol_Chiki', 'Devanagari', 'Latin'],
    offlineAvailable: true,
    requiresAudio: false
  },
  quiz: {
    activityType: 'quiz',
    title: 'Summative FLN Assessment Quiz',
    description: 'Comprehensive 10-question evaluation combining translation and listening comprehension.',
    domain: 'literacy',
    skillsTested: ['reading', 'listening_comprehension', 'vocabulary'],
    difficultyRange: [2, 4],
    supportedLanguages: ['Santali'],
    supportedScripts: ['Ol_Chiki'],
    offlineAvailable: true,
    requiresAudio: true
  },
  listening: {
    activityType: 'listening',
    title: 'Spoken Audio Comprehension',
    description: 'Auditory discrimination exercises verifying comprehension of spoken tribal phonemes.',
    domain: 'literacy',
    skillsTested: ['listening_comprehension', 'oral_language', 'phonological_awareness'],
    difficultyRange: [1, 3],
    supportedLanguages: ['Santali'],
    supportedScripts: ['Ol_Chiki'],
    offlineAvailable: true,
    requiresAudio: true
  },
  voice: {
    activityType: 'voice',
    title: 'Multilingual Voice Studio',
    description: 'Oral language practice, speech recognition evaluation, and bilingual classroom assistant.',
    domain: 'literacy',
    skillsTested: ['oral_language', 'listening_comprehension', 'pronunciation', 'translation', 'spoken_sentence'],
    difficultyRange: [1, 4],
    supportedLanguages: ['Santali', 'Mundari', 'Ho'],
    supportedScripts: ['Ol_Chiki', 'Devanagari', 'Latin'],
    offlineAvailable: true,
    requiresAudio: true
  }
};

export function getActivityMetadata(type: LearningActivityType): ActivityMetadata {
  return ACTIVITY_REGISTRY[type];
}

export function getActivitiesForSkill(skill: FLNSkill): ActivityMetadata[] {
  return Object.values(ACTIVITY_REGISTRY).filter(act => act.skillsTested.includes(skill));
}

export function getAllRegisteredActivities(): ActivityMetadata[] {
  return Object.values(ACTIVITY_REGISTRY);
}

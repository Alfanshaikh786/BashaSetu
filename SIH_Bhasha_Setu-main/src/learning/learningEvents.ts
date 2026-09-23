/**
 * Bhasha Setu Generic Learning Event Abstraction
 * Unified event telemetry for Flashcards, Worksheets, MCQs, Tracing,
 * Sentence Builders, and Quizzes across the entire learning loop.
 */

import { FLNSkill, DifficultyLevel, TribalLanguage, ScriptType } from './types';
import { ReviewRating } from './flashcardTypes';

export type LearningActivityType = 
  | 'flashcard'
  | 'matching'
  | 'tracing'
  | 'scramble'
  | 'mcq'
  | 'quiz'
  | 'listening'
  | 'voice';

export interface LearningEvent {
  id: string;
  studentId: string;
  activityId: string;
  activityType: LearningActivityType;
  skillId: FLNSkill;
  topic: string;
  language: TribalLanguage | 'Hindi' | 'English';
  script: ScriptType;
  difficulty: DifficultyLevel;
  correct: boolean;
  score: number; // 0 to 100
  responseTimeMs?: number;
  timestamp: number;
  metadata?: Record<string, any>;
}

/**
 * Maps an activity type to its primary FLN skill competency.
 */
export function mapActivityToSkill(activityType: LearningActivityType): FLNSkill {
  switch (activityType) {
    case 'flashcard':
    case 'matching':
      return 'vocabulary';
    case 'scramble':
      return 'sentence_building';
    case 'tracing':
      return 'script_recognition';
    case 'mcq':
    case 'quiz':
      return 'reading';
    case 'listening':
      return 'listening_comprehension';
    case 'voice':
      return 'oral_language';
    default:
      return 'vocabulary';
  }
}

/**
 * Converts a flashcard recall rating into a 0-100 numerical score.
 */
export function mapRatingToScore(rating: ReviewRating): number {
  switch (rating) {
    case 'again': return 0;
    case 'hard': return 50;
    case 'good': return 80;
    case 'easy': return 100;
  }
}

/**
 * Factory for creating immutable learning events.
 */
export function createLearningEvent(
  params: Omit<LearningEvent, 'id' | 'timestamp'> & { id?: string; timestamp?: number }
): LearningEvent {
  return {
    id: params.id || `ev_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
    studentId: params.studentId,
    activityId: params.activityId,
    activityType: params.activityType,
    skillId: params.skillId,
    topic: params.topic || 'General',
    language: params.language || 'Santali',
    script: params.script || 'Ol_Chiki',
    difficulty: params.difficulty || 1,
    correct: params.correct,
    score: Math.max(0, Math.min(100, Math.round(params.score))),
    responseTimeMs: params.responseTimeMs,
    timestamp: params.timestamp || Date.now(),
    metadata: params.metadata || {}
  };
}

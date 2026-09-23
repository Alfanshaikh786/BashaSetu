/**
 * Bhasha Setu 3D Audio Flashcards — Core Data Types & Models
 * Defines Flashcard metadata, child-friendly spaced repetition progress,
 * review ratings, history records, and shared learner progress.
 */

import { SantaliDatasetEntry } from '../data/santaliDataset';

export type ReviewRating = 'again' | 'hard' | 'good' | 'easy';

export type CardReviewStatus = 
  | 'new'        // Never reviewed by student
  | 'learning'   // First attempts, short review window
  | 'familiar'   // 1-2 successful reviews
  | 'review'     // Due for regular review
  | 'mastered';  // Met mastery threshold (>= 85% accuracy across >= 3 reviews)

export interface FlashcardAudioMetadata {
  src?: string;
  speaker?: string;
  native?: boolean;
  verified?: boolean;
  phoneticFallback?: boolean;
}

export interface FlashcardValidation {
  translationVerified: boolean;
  audioVerified: boolean;
  teacherVerified: boolean;
  curriculumVerified: boolean;
}

/**
 * Extended Flashcard content model.
 * Enforces strict separation between Language, Script, and Romanization.
 */
export interface Flashcard extends SantaliDatasetEntry {
  language: 'Santali' | 'Hindi' | 'English';
  script: 'Ol_Chiki' | 'Devanagari' | 'Latin';
  grade?: number[];
  difficulty?: number; // 1 to 4
  flnSkill?: string;
  audio?: FlashcardAudioMetadata;
  validation?: FlashcardValidation;
}

/**
 * Child-Friendly Spaced Repetition Progress Record.
 * Stored durably in IndexedDB with localStorage fallback.
 */
export interface CardProgress {
  cardId: string;
  studentId: string;
  attempts: number;
  correct: number;
  incorrect: number;
  masteryScore: number; // 0 to 100
  intervalDays: number;
  nextReviewAt: number; // Unix timestamp (ms)
  lastReviewedAt: number; // Unix timestamp (ms)
  streak: number;
  easeFactor: number; // Default 2.5
  status: CardReviewStatus;
}

export interface ReviewHistoryEntry {
  id: string;
  cardId: string;
  studentId: string;
  rating: ReviewRating;
  reviewedAt: number;
  previousIntervalDays: number;
  newIntervalDays: number;
  previousStatus: CardReviewStatus;
  newStatus: CardReviewStatus;
}

export interface SharedLearnerProgress {
  studentId: string;
  cardsSeen: number;
  cardsMastered: number;
  cardsDue: number;
  overallMastery: number; // 0 to 100
  categoryProgress: Record<string, { total: number; mastered: number; accuracy: number }>;
  lastStudyAt: number;
}

/**
 * Bhasha Setu Review Scheduler & Mastery Engine
 * Child-friendly spaced repetition scheduling with configurable intervals
 * and evidence-based mastery verification.
 */

import { CardProgress, ReviewRating, CardReviewStatus } from './flashcardTypes';

export const REVIEW_INTERVALS = {
  AGAIN_DAYS: 1,
  HARD_DAYS: 2,
  GOOD_DAYS: 4,
  EASY_DAYS: 8,
} as const;

export const MASTERED_THRESHOLD = 85; // 85% mastery score required
export const MIN_SUCCESSFUL_REVIEWS = 3; // Minimum consecutive successful reviews

export function createInitialCardProgress(cardId: string, studentId: string): CardProgress {
  return {
    cardId,
    studentId,
    attempts: 0,
    correct: 0,
    incorrect: 0,
    masteryScore: 0,
    intervalDays: 0,
    nextReviewAt: 0,
    lastReviewedAt: 0,
    streak: 0,
    easeFactor: 2.5,
    status: 'new'
  };
}

export function isCardMastered(progress: CardProgress): boolean {
  return progress.masteryScore >= MASTERED_THRESHOLD && progress.streak >= MIN_SUCCESSFUL_REVIEWS;
}

/**
 * Calculates the updated progress and next review timestamp based on student recall rating.
 */
export function calculateNextReview(
  current: CardProgress,
  rating: ReviewRating,
  now: number = Date.now()
): CardProgress {
  const isCorrect = rating !== 'again';
  const newAttempts = current.attempts + 1;
  const newCorrect = current.correct + (isCorrect ? 1 : 0);
  const newIncorrect = current.incorrect + (isCorrect ? 0 : 1);

  // Update streak
  const newStreak = isCorrect ? current.streak + 1 : 0;

  // Calculate moving mastery score (0 - 100)
  // Higher weight for recent performance (70% existing, 30% current session)
  const sessionScore = rating === 'easy' ? 100 : rating === 'good' ? 85 : rating === 'hard' ? 60 : 20;
  const newMasteryScore = current.attempts === 0
    ? sessionScore
    : Math.round(current.masteryScore * 0.65 + sessionScore * 0.35);

  // Determine interval
  let intervalDays: number;
  let newEaseFactor = current.easeFactor;

  switch (rating) {
    case 'again':
      intervalDays = REVIEW_INTERVALS.AGAIN_DAYS;
      newEaseFactor = Math.max(1.3, current.easeFactor - 0.2);
      break;
    case 'hard':
      intervalDays = REVIEW_INTERVALS.HARD_DAYS;
      newEaseFactor = Math.max(1.3, current.easeFactor - 0.1);
      break;
    case 'good':
      intervalDays = current.streak === 0 ? REVIEW_INTERVALS.GOOD_DAYS : Math.round(REVIEW_INTERVALS.GOOD_DAYS * current.easeFactor);
      break;
    case 'easy':
      intervalDays = Math.round(REVIEW_INTERVALS.EASY_DAYS * current.easeFactor * 1.2);
      newEaseFactor = Math.min(3.0, current.easeFactor + 0.15);
      break;
  }

  // Determine status progression: NEW -> LEARNING -> FAMILIAR -> REVIEW -> MASTERED
  let newStatus: CardReviewStatus;
  if (newMasteryScore >= MASTERED_THRESHOLD && newStreak >= MIN_SUCCESSFUL_REVIEWS) {
    newStatus = 'mastered';
  } else if (!isCorrect) {
    newStatus = 'learning';
  } else if (newStreak >= 2) {
    newStatus = 'familiar';
  } else {
    newStatus = 'learning';
  }

  const nextReviewAt = now + intervalDays * 24 * 60 * 60 * 1000;

  return {
    ...current,
    attempts: newAttempts,
    correct: newCorrect,
    incorrect: newIncorrect,
    masteryScore: newMasteryScore,
    intervalDays,
    nextReviewAt,
    lastReviewedAt: now,
    streak: newStreak,
    easeFactor: Number(newEaseFactor.toFixed(2)),
    status: newStatus
  };
}

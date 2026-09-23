/**
 * Bhasha Setu Intelligent Review Queue
 * Prioritizes due reviews, recently incorrect cards, and new vocabulary.
 * Separates true spaced repetition queue from simple random shuffle.
 */

import { SantaliDatasetEntry } from '../data/santaliDataset';
import { CardProgress } from './flashcardTypes';

export interface QueueBuildOptions {
  now?: number;
  maxNewPerSession?: number;
  maxTotalQueue?: number;
}

/**
 * Builds an adaptive review queue prioritizing:
 * 1. Overdue / Due cards (nextReviewAt <= now)
 * 2. Recently incorrect / Learning cards (status === 'learning')
 * 3. Unseen / New cards (attempts === 0)
 * 4. Familiar / Approaching cards
 */
export function buildReviewQueue(
  cards: SantaliDatasetEntry[],
  progressMap: Map<string, CardProgress>,
  options: QueueBuildOptions = {}
): SantaliDatasetEntry[] {
  const now = options.now ?? Date.now();
  const maxNew = options.maxNewPerSession ?? 15;
  const maxTotal = options.maxTotalQueue ?? 300;

  const dueCards: SantaliDatasetEntry[] = [];
  const learningCards: SantaliDatasetEntry[] = [];
  const newCards: SantaliDatasetEntry[] = [];
  const otherCards: SantaliDatasetEntry[] = [];

  for (const card of cards) {
    const progress = progressMap.get(card.id);

    if (!progress || progress.attempts === 0) {
      newCards.push(card);
    } else if (progress.nextReviewAt <= now) {
      dueCards.push(card);
    } else if (progress.status === 'learning') {
      learningCards.push(card);
    } else {
      otherCards.push(card);
    }
  }

  // Sort due cards by most overdue first
  dueCards.sort((a, b) => {
    const pA = progressMap.get(a.id);
    const pB = progressMap.get(b.id);
    return (pA?.nextReviewAt ?? 0) - (pB?.nextReviewAt ?? 0);
  });

  // Sort other cards by next review time ascending
  otherCards.sort((a, b) => {
    const pA = progressMap.get(a.id);
    const pB = progressMap.get(b.id);
    return (pA?.nextReviewAt ?? 0) - (pB?.nextReviewAt ?? 0);
  });

  const queue: SantaliDatasetEntry[] = [
    ...dueCards,
    ...learningCards,
    ...newCards.slice(0, maxNew),
    ...otherCards
  ];

  return queue.slice(0, maxTotal);
}

/**
 * Pure deck randomizer.
 * Preserved for learner autonomy, explicitly NOT labeled as spaced repetition.
 */
export function shuffleDeck<T>(items: T[]): T[] {
  const shuffled = [...items];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

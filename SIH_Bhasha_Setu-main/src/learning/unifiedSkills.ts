/**
 * Bhasha Setu Unified Skill Mastery Engine (v3)
 * Computes cross-activity skill mastery by deterministically aggregating
 * performance from Flashcards, Worksheets, Tracing, Scramble, and Quizzes.
 * Features normalized weighting over attempted activities, evidence-level determination,
 * and Bayesian evidence damping to prevent premature claims of mastery.
 */

import { FLNSkill, MasteryState, EvidenceLevel } from './types';
import { CardProgress } from './flashcardTypes';
import { LearningEvent, LearningActivityType } from './learningEvents';
import { getMasteryState } from './masteryEngine';

export interface ActivityPerformance {
  attempts: number;
  accuracy: number; // 0 to 100
  weight: number;
  lastPracticedAt: number;
}

export interface FlashcardSkillMetrics {
  totalCards: number;
  masteredCards: number;
  dueCards: number;
  averageScore: number;
}

export interface UnifiedSkillMastery {
  studentId: string;
  skillId: FLNSkill;
  aggregateScore: number; // 0 to 100
  masteryState: MasteryState;
  evidenceLevel: EvidenceLevel;
  totalAttempts: number;
  activityBreakdown: Partial<Record<LearningActivityType, ActivityPerformance>>;
  flashcardMastery?: FlashcardSkillMetrics;
  lastUpdatedAt: number;
}

/**
 * Default activity weight distributions per FLN skill competency.
 * Weights determine the relative pedagogical importance of each activity type.
 */
export const DEFAULT_ACTIVITY_WEIGHTS: Record<string, Partial<Record<LearningActivityType, number>>> = {
  // Foundational Literacy
  vocabulary: { flashcard: 0.40, matching: 0.30, mcq: 0.15, voice: 0.15 },
  sentence_building: { scramble: 0.50, mcq: 0.25, voice: 0.25 },
  script_recognition: { tracing: 0.60, flashcard: 0.40 },
  reading: { mcq: 0.60, quiz: 0.40 },
  oral_language: { voice: 0.50, flashcard: 0.30, listening: 0.20 },
  listening_comprehension: { voice: 0.50, listening: 0.30, quiz: 0.20 },
  phonological_awareness: { flashcard: 0.40, voice: 0.30, matching: 0.30 },
  letter_recognition: { tracing: 0.50, flashcard: 0.50 },
  letter_sound: { flashcard: 0.40, voice: 0.40, quiz: 0.20 },
  word_recognition: { matching: 0.50, flashcard: 0.50 },
  reading_fluency: { mcq: 0.50, voice: 0.30, quiz: 0.20 },
  reading_comprehension: { mcq: 0.60, quiz: 0.40 },
  pronunciation: { voice: 0.70, flashcard: 0.30 },
  translation: { voice: 0.60, mcq: 0.40 },
  spoken_sentence: { voice: 0.70, scramble: 0.30 },

  // Foundational Numeracy (Strictly isolated from literacy)
  numeracy: { matching: 0.50, mcq: 0.50 },
  number_recognition: { flashcard: 0.50, matching: 0.50 },
  counting: { matching: 0.60, mcq: 0.40 },
  number_comparison: { mcq: 0.60, matching: 0.40 },
  number_ordering: { scramble: 0.60, mcq: 0.40 },
  addition: { mcq: 0.60, matching: 0.40 },
  subtraction: { mcq: 0.60, matching: 0.40 },
  patterns: { matching: 0.60, mcq: 0.40 },
  shapes: { tracing: 0.50, matching: 0.50 },
  measurement: { matching: 0.50, mcq: 0.50 },
  simple_word_problems: { mcq: 0.70, quiz: 0.30 }
};

/**
 * Computes the Evidence Level based on total attempts and activity variety.
 */
export function calculateEvidenceLevel(totalAttempts: number, distinctActivities: number): EvidenceLevel {
  if (totalAttempts <= 1) return 'insufficient';
  if (totalAttempts <= 4) return 'limited';
  if (totalAttempts <= 9) return 'moderate';
  // Strong evidence requires at least 10 attempts across >= 2 activities OR >= 15 attempts
  return (distinctActivities >= 2 || totalAttempts >= 15) ? 'strong' : 'moderate';
}

/**
 * Creates a baseline unattempted skill mastery record.
 */
export function createInitialSkillMastery(studentId: string, skillId: FLNSkill): UnifiedSkillMastery {
  return {
    studentId,
    skillId,
    aggregateScore: 30, // Baseline diagnostic starting score
    masteryState: 'needs_support',
    evidenceLevel: 'insufficient',
    totalAttempts: 0,
    activityBreakdown: {},
    lastUpdatedAt: Date.now()
  };
}

/**
 * Updates a UnifiedSkillMastery record with a new LearningEvent.
 * Uses an exponential moving average (0.7 prior + 0.3 new) for activity accuracy,
 * then computes the normalized weighted aggregate across all attempted activities.
 */
export function updateSkillWithEvent(
  current: UnifiedSkillMastery,
  event: LearningEvent
): UnifiedSkillMastery {
  const breakdown = { ...current.activityBreakdown };
  const existing = breakdown[event.activityType];

  const defaultWeights = DEFAULT_ACTIVITY_WEIGHTS[current.skillId] || {};
  const weight = defaultWeights[event.activityType] || 0.30;

  if (!existing || existing.attempts === 0) {
    breakdown[event.activityType] = {
      attempts: 1,
      accuracy: event.score,
      weight,
      lastPracticedAt: event.timestamp
    };
  } else {
    const updatedAccuracy = Math.round(existing.accuracy * 0.7 + event.score * 0.3);
    breakdown[event.activityType] = {
      attempts: existing.attempts + 1,
      accuracy: Math.max(0, Math.min(100, updatedAccuracy)),
      weight,
      lastPracticedAt: event.timestamp
    };
  }

  // Calculate total attempts and distinct activity types
  let totalAttempts = 0;
  let distinctActivities = 0;
  for (const perf of Object.values(breakdown)) {
    if (perf && perf.attempts > 0) {
      totalAttempts += perf.attempts;
      distinctActivities++;
    }
  }

  const evidenceLevel = calculateEvidenceLevel(totalAttempts, distinctActivities);
  const aggregateScore = computeAggregateScore(current.skillId, breakdown, current.flashcardMastery, evidenceLevel);

  // Apply evidence-capped mastery state (cannot declare mastery with insufficient evidence)
  let masteryState = getMasteryState(aggregateScore);
  if (evidenceLevel === 'insufficient') {
    if (masteryState === 'mastered' || masteryState === 'proficient') {
      masteryState = 'developing';
    }
  } else if (evidenceLevel === 'limited') {
    if (masteryState === 'mastered') {
      masteryState = 'proficient';
    }
  }

  return {
    ...current,
    aggregateScore,
    masteryState,
    evidenceLevel,
    totalAttempts,
    activityBreakdown: breakdown,
    lastUpdatedAt: event.timestamp
  };
}

/**
 * Incorporates active flashcard spaced repetition deck statistics into the skill mastery.
 */
export function incorporateFlashcardMetrics(
  current: UnifiedSkillMastery,
  cardProgressList: CardProgress[]
): UnifiedSkillMastery {
  if (cardProgressList.length === 0) return current;

  const totalCards = cardProgressList.length;
  const now = Date.now();
  let masteredCards = 0;
  let dueCards = 0;
  let totalScore = 0;
  let totalReviews = 0;

  for (const card of cardProgressList) {
    if (card.status === 'mastered') masteredCards++;
    if (card.nextReviewAt <= now) dueCards++;
    totalScore += card.masteryScore;
    totalReviews += (card.attempts || 1);
  }

  const averageScore = Math.round(totalScore / totalCards);
  const flashcardMastery: FlashcardSkillMetrics = {
    totalCards,
    masteredCards,
    dueCards,
    averageScore
  };

  const breakdown = { ...current.activityBreakdown };
  const existing = breakdown.flashcard;
  const defaultWeights = DEFAULT_ACTIVITY_WEIGHTS[current.skillId] || {};
  const weight = defaultWeights.flashcard || 0.50;

  breakdown.flashcard = {
    attempts: existing ? existing.attempts + totalReviews : totalReviews,
    accuracy: averageScore,
    weight,
    lastPracticedAt: Date.now()
  };

  let totalAttempts = 0;
  let distinctActivities = 0;
  for (const perf of Object.values(breakdown)) {
    if (perf && perf.attempts > 0) {
      totalAttempts += perf.attempts;
      distinctActivities++;
    }
  }

  const evidenceLevel = calculateEvidenceLevel(totalAttempts, distinctActivities);
  const aggregateScore = computeAggregateScore(current.skillId, breakdown, flashcardMastery, evidenceLevel);

  let masteryState = getMasteryState(aggregateScore);
  if (evidenceLevel === 'insufficient') {
    if (masteryState === 'mastered' || masteryState === 'proficient') masteryState = 'developing';
  } else if (evidenceLevel === 'limited') {
    if (masteryState === 'mastered') masteryState = 'proficient';
  }

  return {
    ...current,
    aggregateScore,
    masteryState,
    evidenceLevel,
    totalAttempts,
    activityBreakdown: breakdown,
    flashcardMastery,
    lastUpdatedAt: Date.now()
  };
}

/**
 * Deterministic aggregation formula:
 * Normalizes weights across ONLY the practiced activities (unattempted activities are NOT treated as 0).
 * 
 * Formula:
 *   NormalizedWeight_i = Weight_i / sum(Weight_j for all attempted j)
 *   RawScore = sum(Accuracy_i * NormalizedWeight_i)
 * 
 * Evidence Damping:
 *   If evidence is 'insufficient' (<= 1 attempt):
 *     Score is damped: DampedScore = round(30 * 0.6 + RawScore * 0.4)
 *   If evidence is 'limited' (2-4 attempts):
 *     Score is damped: DampedScore = round(30 * 0.3 + RawScore * 0.7)
 *   If evidence is 'moderate' or 'strong':
 *     Full RawScore is utilized.
 */
export function computeAggregateScore(
  skillId: FLNSkill,
  breakdown: Partial<Record<LearningActivityType, ActivityPerformance>>,
  flashcardMetrics?: FlashcardSkillMetrics,
  evidenceLevel: EvidenceLevel = 'insufficient'
): number {
  const entries = Object.entries(breakdown) as [LearningActivityType, ActivityPerformance][];
  if (entries.length === 0) {
    return flashcardMetrics ? flashcardMetrics.averageScore : 30;
  }

  let totalWeight = 0;
  let weightedSum = 0;

  for (const [_, perf] of entries) {
    totalWeight += perf.weight;
    weightedSum += perf.accuracy * perf.weight;
  }

  if (totalWeight <= 0) return 30;

  let rawScore = Math.round(weightedSum / totalWeight);

  // Apply flashcard retention adjustments
  if (flashcardMetrics && flashcardMetrics.totalCards > 0) {
    const masteryRatio = flashcardMetrics.masteredCards / flashcardMetrics.totalCards;
    if (masteryRatio >= 0.5) {
      rawScore = Math.min(100, rawScore + Math.round(masteryRatio * 5));
    }
    const overdueRatio = flashcardMetrics.dueCards / flashcardMetrics.totalCards;
    if (overdueRatio > 0.4) {
      rawScore = Math.max(10, rawScore - Math.round(overdueRatio * 5));
    }
  }

  // Evidence damping
  let finalScore = rawScore;
  if (evidenceLevel === 'insufficient') {
    finalScore = Math.round(30 * 0.6 + rawScore * 0.4);
  } else if (evidenceLevel === 'limited') {
    finalScore = Math.round(30 * 0.3 + rawScore * 0.7);
  }

  return Math.max(0, Math.min(100, finalScore));
}

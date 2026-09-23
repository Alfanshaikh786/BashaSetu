/**
 * Bhasha Setu Pedagogical Recommendation Engine (v2)
 * Analyzes student mastery trends, overdue flashcards, and cross-activity diagnostics
 * to determine the highest-impact next activity in accordance with the 7-tier priority hierarchy.
 */

import { getStudentProgress } from './storage';
import { RecommendedActivity, DifficultyLevel, FLNSkill } from './types';
import { UnifiedSkillMastery } from './unifiedSkills';
import { LearningEvent } from './learningEvents';
import { WeakSkillDiagnostic, detectWeakSkills } from './weakSkillDetector';

export interface RecommendationContext {
  lastActivityType?: 'matching' | 'tracing' | 'scramble' | 'mcq' | 'flashcard' | 'voice';
  lastAccuracy?: number;
  dueFlashcardsCount?: number;
  unifiedSkills?: UnifiedSkillMastery[];
  recentEvents?: LearningEvent[];
  weakDiagnostic?: WeakSkillDiagnostic | null;
}

/**
 * Computes the recommended next activity using the 7-tier pedagogical priority hierarchy:
 * 1. Overdue flashcards
 * 2. Critical weak skill (<40%)
 * 3. Recently failed skill (<50% accuracy)
 * 4. Due revision / moderate weak skill (<60%)
 * 5. New learning / unexplored FLN competencies
 * 6. Reinforcement / step-up difficulty (>=80%)
 * 7. Mastered content maintenance
 */
export function getRecommendedNextActivity(
  studentId: string,
  contextOrLastActivity?: RecommendationContext | 'matching' | 'tracing' | 'scramble' | 'mcq' | 'flashcard' | 'voice',
  legacyLastAccuracy?: number
): RecommendedActivity {
  // Normalize parameters for backward compatibility
  let context: RecommendationContext = {};
  if (typeof contextOrLastActivity === 'string') {
    context = {
      lastActivityType: contextOrLastActivity,
      lastAccuracy: legacyLastAccuracy
    };
  } else if (contextOrLastActivity) {
    context = contextOrLastActivity;
  }

  const {
    lastActivityType,
    lastAccuracy,
    dueFlashcardsCount = 0,
    unifiedSkills,
    recentEvents = []
  } = context;

  // PRIORITY 1: Overdue Flashcards (Spaced Repetition Retention Gate)
  if (dueFlashcardsCount > 0) {
    return {
      studentId,
      skillId: 'vocabulary',
      topic: 'Daily Review Queue',
      activityType: 'flashcard',
      difficulty: 1,
      reason: `You have ${dueFlashcardsCount} flashcard${dueFlashcardsCount > 1 ? 's' : ''} due for spaced repetition review today. Keep your memory streak alive!`,
      currentMastery: 75,
      priority: 'high'
    };
  }

  // Determine weak skills if unifiedSkills provided, or fall back to legacy storage
  let weakDiag = context.weakDiagnostic;
  if (!weakDiag && unifiedSkills && unifiedSkills.length > 0) {
    weakDiag = detectWeakSkills(unifiedSkills, recentEvents, dueFlashcardsCount);
  }

  // PRIORITY 2: Critical Weak Skill (<40% or high failure rate)
  if (weakDiag && weakDiag.severity === 'critical') {
    return {
      studentId,
      skillId: weakDiag.primaryWeakSkill,
      topic: weakDiag.weakestTopic,
      activityType: weakDiag.recommendedFocusActivity,
      difficulty: 1,
      reason: `Critical intervention: ${weakDiag.reason} Focus on foundational exercises first.`,
      currentMastery: weakDiag.primaryScore,
      priority: 'critical'
    };
  }

  // PRIORITY 3: Recently Failed Activity (<50% on last attempt)
  if (lastAccuracy !== undefined && lastAccuracy < 50 && lastActivityType) {
    let fallbackActivity: 'matching' | 'tracing' | 'scramble' | 'mcq' | 'flashcard' | 'voice' = 'matching';
    if (lastActivityType === 'scramble') fallbackActivity = 'matching';
    else if (lastActivityType === 'matching') fallbackActivity = 'tracing';
    else if (lastActivityType === 'mcq') fallbackActivity = 'matching';
    else if (lastActivityType === 'flashcard') fallbackActivity = 'matching';
    else if (lastActivityType === 'voice') fallbackActivity = 'flashcard';

    const currentScore = weakDiag ? weakDiag.primaryScore : (lastAccuracy || 30);
    return {
      studentId,
      skillId: weakDiag ? weakDiag.primaryWeakSkill : 'vocabulary',
      topic: weakDiag ? weakDiag.weakestTopic : 'Classroom',
      activityType: fallbackActivity,
      difficulty: 1,
      reason: `Recent exercise indicated difficulty (${lastAccuracy}%). Reinforce foundational recognition before advancing.`,
      currentMastery: currentScore,
      priority: 'high'
    };
  }

  // PRIORITY 4: Due Revision / Moderate Weak Skill (<60%)
  if (weakDiag && weakDiag.primaryScore < 60) {
    return {
      studentId,
      skillId: weakDiag.primaryWeakSkill,
      topic: weakDiag.weakestTopic,
      activityType: weakDiag.recommendedFocusActivity,
      difficulty: 1,
      reason: weakDiag.reason,
      currentMastery: weakDiag.primaryScore,
      priority: 'medium'
    };
  }

  // Check legacy records if no unified skills available
  const legacyRecords = getStudentProgress(studentId);
  if (legacyRecords.length === 0 && (!unifiedSkills || unifiedSkills.length === 0)) {
    // PRIORITY 5: New Learning (First-time onboarded student)
    return {
      studentId,
      skillId: 'vocabulary',
      topic: 'Normally Used Words in Classroom',
      activityType: 'matching',
      difficulty: 1,
      reason: 'Welcome! Start by building foundational vocabulary in everyday classroom expressions.',
      currentMastery: 30,
      priority: 'medium'
    };
  }

  // Evaluate highest/lowest from legacy records if unifiedSkills wasn't provided
  if (!weakDiag && legacyRecords.length > 0) {
    const sorted = [...legacyRecords].sort((a, b) => a.masteryScore - b.masteryScore);
    const weakest = sorted[0];
    if (weakest && weakest.masteryScore < 60) {
      let act: 'matching' | 'tracing' | 'scramble' | 'mcq' = 'matching';
      if (weakest.skillId === 'script_recognition') act = 'tracing';
      else if (weakest.skillId === 'sentence_building') act = 'scramble';
      else if (weakest.skillId === 'reading') act = 'mcq';

      return {
        studentId,
        skillId: weakest.skillId,
        topic: weakest.topic,
        activityType: act,
        difficulty: weakest.difficulty,
        reason: `Low mastery detected in ${weakest.topic} (${weakest.masteryScore}%). Focused practice recommended.`,
        currentMastery: weakest.masteryScore,
        priority: 'medium'
      };
    }
  }

  // PRIORITY 6 & 7: Reinforcement & Advanced Step-Up
  const bestScore = weakDiag ? weakDiag.primaryScore : 85;
  const targetDiff: DifficultyLevel = bestScore >= 80 ? 2 : 1;

  return {
    studentId,
    skillId: 'sentence_building',
    topic: weakDiag?.weakestTopic || 'Phrases',
    activityType: 'scramble',
    difficulty: targetDiff,
    reason: `Great progress! Step up to connected sentence construction at Difficulty ${targetDiff}.`,
    currentMastery: bestScore,
    priority: 'low'
  };
}

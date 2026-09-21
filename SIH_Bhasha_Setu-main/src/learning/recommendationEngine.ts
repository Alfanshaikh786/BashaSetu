/**
 * Bhasha Setu Pedagogical Recommendation Engine
 * Analyzes student mastery trends and determines the highest-impact
 * next activity for continuous learning progression.
 */

import { getStudentProgress } from './storage';
import { RecommendedActivity, DifficultyLevel, FLNSkill } from './types';

export function getRecommendedNextActivity(
  studentId: string,
  lastActivityType?: 'matching' | 'tracing' | 'scramble' | 'mcq',
  lastAccuracy?: number
): RecommendedActivity {
  const records = getStudentProgress(studentId);

  // Default recommendation for new students
  if (records.length === 0) {
    return {
      studentId,
      skillId: 'vocabulary',
      topic: 'Normally Used Words in Classroom',
      activityType: 'matching',
      difficulty: 1,
      reason: 'Build foundational vocabulary in everyday classroom expressions.',
      currentMastery: 30
    };
  }

  // Find the skill with the lowest mastery
  const sortedByMastery = [...records].sort((a, b) => a.masteryScore - b.masteryScore);
  const weakest = sortedByMastery[0];

  // Case 1: If the student just scored poorly (<50%) on current activity
  if (lastAccuracy !== undefined && lastAccuracy < 50 && lastActivityType) {
    let fallbackActivity: 'matching' | 'tracing' | 'scramble' | 'mcq' = 'matching';
    if (lastActivityType === 'scramble') fallbackActivity = 'matching';
    else if (lastActivityType === 'matching') fallbackActivity = 'tracing';
    else if (lastActivityType === 'mcq') fallbackActivity = 'matching';

    return {
      studentId,
      skillId: weakest.skillId,
      topic: weakest.topic,
      activityType: fallbackActivity,
      difficulty: 1,
      reason: `Recent attempt indicated difficulty (${lastAccuracy}%). Reinforce foundational recognition first.`,
      currentMastery: weakest.masteryScore
    };
  }

  // Case 2: Target the weakest tracked skill
  if (weakest.masteryScore < 60) {
    let activityType: 'matching' | 'tracing' | 'scramble' | 'mcq' = 'matching';
    if (weakest.skillId === 'script_recognition') activityType = 'tracing';
    else if (weakest.skillId === 'sentence_building') activityType = 'scramble';
    else if (weakest.skillId === 'vocabulary') activityType = 'matching';
    else activityType = 'mcq';

    return {
      studentId,
      skillId: weakest.skillId,
      topic: weakest.topic,
      activityType,
      difficulty: weakest.difficulty,
      reason: `Low mastery detected in ${weakest.topic} (${weakest.masteryScore}%). Focused practice recommended.`,
      currentMastery: weakest.masteryScore
    };
  }

  // Case 3: Student has high mastery (>= 80%) across all attempted areas - advance difficulty
  const targetDiff = Math.min(4, weakest.difficulty + 1) as DifficultyLevel;
  return {
    studentId,
    skillId: 'sentence_building',
    topic: weakest.topic || 'General',
    activityType: 'scramble',
    difficulty: targetDiff,
    reason: `Great progress! Step up to advanced sentence construction at Difficulty ${targetDiff}.`,
    currentMastery: weakest.masteryScore
  };
}

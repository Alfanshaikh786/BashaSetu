/**
 * Bhasha Setu Weak Skill Detector
 * Inspects cross-activity unified skill mastery and recent telemetry events
 * to deterministically identify areas requiring targeted pedagogical intervention.
 */

import { FLNSkill } from './types';
import { UnifiedSkillMastery } from './unifiedSkills';
import { LearningEvent, LearningActivityType } from './learningEvents';

export interface WeakSkillDiagnostic {
  primaryWeakSkill: FLNSkill;
  primaryScore: number;
  secondaryWeakSkill?: FLNSkill;
  secondaryScore?: number;
  severity: 'critical' | 'moderate' | 'mild';
  weakestTopic: string;
  recentErrorRate: number; // 0 to 1
  reason: string;
  recommendedFocusActivity: 'matching' | 'tracing' | 'scramble' | 'mcq' | 'flashcard' | 'voice';
}

/**
 * Detects the primary and secondary weak skills based on empirical mastery scores and error rates.
 */
export function detectWeakSkills(
  skills: UnifiedSkillMastery[],
  recentEvents: LearningEvent[] = [],
  dueFlashcardsCount: number = 0
): WeakSkillDiagnostic | null {
  if (skills.length === 0 && recentEvents.length === 0) {
    return null;
  }

  // Calculate recent error rate from last 10 events
  const last10Events = recentEvents.slice(-10);
  const errorEvents = last10Events.filter(e => !e.correct || e.score < 50);
  const recentErrorRate = last10Events.length > 0 ? errorEvents.length / last10Events.length : 0;

  // Identify topic with most errors
  const topicErrorCounts: Record<string, number> = {};
  for (const err of errorEvents) {
    topicErrorCounts[err.topic] = (topicErrorCounts[err.topic] || 0) + 1;
  }
  const weakestTopic = Object.entries(topicErrorCounts).sort((a, b) => b[1] - a[1])[0]?.[0] || 'General';

  // Sort skills by aggregateScore ascending
  const sortedSkills = [...skills].sort((a, b) => a.aggregateScore - b.aggregateScore);
  const primary = sortedSkills[0];
  const secondary = sortedSkills.length > 1 ? sortedSkills[1] : undefined;

  if (!primary) {
    return null;
  }

  // Determine severity
  let severity: 'critical' | 'moderate' | 'mild' = 'mild';
  if (primary.aggregateScore < 40 || recentErrorRate >= 0.6) {
    severity = 'critical';
  } else if (primary.aggregateScore < 60 || recentErrorRate >= 0.3) {
    severity = 'moderate';
  }

  // Select optimal activity to remediate this skill
  let recommendedFocusActivity: 'matching' | 'tracing' | 'scramble' | 'mcq' | 'flashcard' | 'voice' = 'matching';
  switch (primary.skillId) {
    case 'vocabulary':
      // If student has many overdue flashcards, prioritize flashcards; otherwise matching pairs
      recommendedFocusActivity = dueFlashcardsCount > 3 ? 'flashcard' : 'matching';
      break;
    case 'sentence_building':
      recommendedFocusActivity = 'scramble';
      break;
    case 'script_recognition':
      recommendedFocusActivity = 'tracing';
      break;
    case 'reading':
      recommendedFocusActivity = 'mcq';
      break;
    case 'numeracy':
      recommendedFocusActivity = 'matching';
      break;
    case 'listening_comprehension':
    case 'oral_language':
    case 'pronunciation':
    case 'translation':
    case 'spoken_sentence':
      recommendedFocusActivity = 'voice';
      break;
    default:
      recommendedFocusActivity = 'matching';
  }

  // Construct human-readable diagnostic reason
  const skillName = primary.skillId.replace('_', ' ');
  let reason = `Mastery in ${skillName} is currently at ${primary.aggregateScore}%.`;
  if (severity === 'critical') {
    reason += ` Immediate foundational reinforcement needed in ${weakestTopic}.`;
  } else if (severity === 'moderate') {
    reason += ` Targeted practice in ${weakestTopic} will accelerate proficiency.`;
  } else {
    reason += ` Steady progress. Routine practice will maintain retention.`;
  }

  return {
    primaryWeakSkill: primary.skillId,
    primaryScore: primary.aggregateScore,
    secondaryWeakSkill: secondary?.skillId,
    secondaryScore: secondary?.aggregateScore,
    severity,
    weakestTopic,
    recentErrorRate,
    reason,
    recommendedFocusActivity
  };
}

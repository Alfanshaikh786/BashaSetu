/**
 * Bhasha Setu Adaptive Worksheet Generator
 * Generates tailored question sets by diagnosing student weaknesses,
 * prior performance, and current difficulty level.
 */

import { SantaliDatasetEntry, SANTALI_DATASET } from '../data/santaliDataset';
import { getStudentProgress } from './storage';
import { getEnrichedLearningItems } from './curriculum';
import { FLNSkill, DifficultyLevel, LearningItem } from './types';

export interface AdaptiveGenerationResult {
  items: SantaliDatasetEntry[];
  targetDifficulty: DifficultyLevel;
  focusSkill: FLNSkill;
  weakTopicsCovered: string[];
  reason: string;
}

/**
 * Samples a personalized set of worksheet items based on student performance.
 */
export function generateAdaptiveWorksheet(
  studentId: string,
  targetCount: number = 6,
  preferredCategory: string = 'All'
): AdaptiveGenerationResult {
  const allItems = getEnrichedLearningItems();
  const progressRecords = getStudentProgress(studentId);

  // 1. Identify weak skills and topics (mastery < 60%)
  const weakRecords = progressRecords.filter(p => p.masteryScore < 60);
  const weakTopics = Array.from(new Set(weakRecords.map(r => r.topic)));

  // 2. Determine target difficulty
  let targetDifficulty: DifficultyLevel = 1;
  if (progressRecords.length > 0) {
    const avgDiff = progressRecords.reduce((sum, r) => sum + r.difficulty, 0) / progressRecords.length;
    targetDifficulty = Math.min(4, Math.max(1, Math.round(avgDiff))) as DifficultyLevel;
  }

  // 3. Determine focus skill
  let focusSkill: FLNSkill = 'vocabulary';
  if (weakRecords.length > 0) {
    // Pick the skill with lowest mastery
    const sorted = [...weakRecords].sort((a, b) => a.masteryScore - b.masteryScore);
    focusSkill = sorted[0].skillId;
  }

  // 4. Candidate pool filtered by category if specified
  let candidatePool = allItems;
  if (preferredCategory !== 'All') {
    candidatePool = allItems.filter(item => item.topic === preferredCategory);
    if (candidatePool.length < targetCount) {
      candidatePool = allItems; // fallback if category is too small
    }
  }

  // 5. Partition candidate pool into Weak and Reinforcement pools
  const weakPool: LearningItem[] = [];
  const reinforcementPool: LearningItem[] = [];

  for (const item of candidatePool) {
    const isWeak = weakTopics.includes(item.topic) || item.skill === focusSkill;
    if (isWeak) {
      weakPool.push(item);
    } else {
      reinforcementPool.push(item);
    }
  }

  // Calculate allocation: ~60% weak, ~40% reinforcement
  const weakQuota = Math.min(weakPool.length, Math.ceil(targetCount * 0.6));
  const reinforcementQuota = targetCount - weakQuota;

  // Shuffle and slice
  const selectedWeak = [...weakPool]
    .sort(() => 0.5 - Math.random())
    .slice(0, weakQuota);

  const selectedReinforce = [...reinforcementPool]
    .sort(() => 0.5 - Math.random())
    .slice(0, reinforcementQuota);

  let combined: LearningItem[] = [...selectedWeak, ...selectedReinforce];

  // If we still need more items, backfill from candidatePool
  if (combined.length < targetCount) {
    const remaining = candidatePool
      .filter(item => !combined.some(c => c.id === item.id))
      .sort(() => 0.5 - Math.random())
      .slice(0, targetCount - combined.length);
    combined = [...combined, ...remaining];
  }

  // Final shuffle of combined items
  const finalItems = combined
    .sort(() => 0.5 - Math.random())
    .map(item => ({
      id: item.id,
      en: item.en,
      hi: item.hi,
      sat: item.sat,
      roman: item.roman,
      cat: item.cat,
      verified: item.verified
    }));

  const reason = weakTopics.length > 0
    ? `Targeting weak topics (${weakTopics.slice(0, 2).join(', ')}) with ${Math.round((weakQuota / targetCount) * 100)}% focused remediation.`
    : `Balanced foundational set tailored to Grade ${targetDifficulty} proficiency.`;

  return {
    items: finalItems,
    targetDifficulty,
    focusSkill,
    weakTopicsCovered: weakTopics,
    reason
  };
}

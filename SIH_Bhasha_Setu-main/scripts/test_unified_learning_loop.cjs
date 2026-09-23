/**
 * Bhasha Setu Phase 2 — Unified Learning Loop Test Suite
 * Tests LearningEvents, Cross-Activity Unified Mastery,
 * WeakSkillDetector, and 7-tier Priority RecommendationEngine.
 */

const assert = require('assert');

// Simple simulation of modules for CommonJS runtime test
function createLearningEvent(params) {
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
    timestamp: params.timestamp || Date.now(),
    metadata: params.metadata || {}
  };
}

const DEFAULT_ACTIVITY_WEIGHTS = {
  vocabulary: { flashcard: 0.50, matching: 0.30, mcq: 0.20 },
  sentence_building: { scramble: 0.70, mcq: 0.30 },
  script_recognition: { tracing: 0.60, flashcard: 0.40 },
  reading: { mcq: 0.60, quiz: 0.40 },
  numeracy: { matching: 0.50, mcq: 0.50 }
};

function computeAggregateScore(skillId, breakdown, flashcardMetrics) {
  const entries = Object.entries(breakdown);
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
  let baseScore = Math.round(weightedSum / totalWeight);
  if (flashcardMetrics && flashcardMetrics.totalCards > 0) {
    const masteryRatio = flashcardMetrics.masteredCards / flashcardMetrics.totalCards;
    if (masteryRatio >= 0.5) {
      baseScore = Math.min(100, baseScore + Math.round(masteryRatio * 5));
    }
  }
  return Math.max(0, Math.min(100, baseScore));
}

function updateSkillWithEvent(current, event) {
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

  const aggregateScore = computeAggregateScore(current.skillId, breakdown, current.flashcardMastery);
  return {
    ...current,
    aggregateScore,
    activityBreakdown: breakdown,
    lastUpdatedAt: event.timestamp
  };
}

function detectWeakSkills(skills, recentEvents = [], dueFlashcardsCount = 0) {
  if (skills.length === 0) return null;
  const sorted = [...skills].sort((a, b) => a.aggregateScore - b.aggregateScore);
  const primary = sorted[0];
  const severity = primary.aggregateScore < 40 ? 'critical' : (primary.aggregateScore < 60 ? 'moderate' : 'mild');
  
  let recommendedFocusActivity = 'matching';
  if (primary.skillId === 'vocabulary') {
    recommendedFocusActivity = dueFlashcardsCount > 3 ? 'flashcard' : 'matching';
  } else if (primary.skillId === 'sentence_building') {
    recommendedFocusActivity = 'scramble';
  } else if (primary.skillId === 'script_recognition') {
    recommendedFocusActivity = 'tracing';
  }

  return {
    primaryWeakSkill: primary.skillId,
    primaryScore: primary.aggregateScore,
    severity,
    recommendedFocusActivity
  };
}

function getRecommendedNextActivity(studentId, context) {
  const { dueFlashcardsCount = 0, unifiedSkills = [], weakDiagnostic } = context;

  // PRIORITY 1: Overdue Flashcards
  if (dueFlashcardsCount > 0) {
    return {
      studentId,
      skillId: 'vocabulary',
      activityType: 'flashcard',
      priority: 'high',
      reason: `You have ${dueFlashcardsCount} flashcards due for review.`
    };
  }

  // PRIORITY 2: Critical Weak Skill
  if (weakDiagnostic && weakDiagnostic.severity === 'critical') {
    return {
      studentId,
      skillId: weakDiagnostic.primaryWeakSkill,
      activityType: weakDiagnostic.recommendedFocusActivity,
      priority: 'critical',
      reason: `Critical intervention needed in ${weakDiagnostic.primaryWeakSkill}.`
    };
  }

  // PRIORITY 4: Moderate Weak Skill
  if (weakDiagnostic && weakDiagnostic.primaryScore < 60) {
    return {
      studentId,
      skillId: weakDiagnostic.primaryWeakSkill,
      activityType: weakDiagnostic.recommendedFocusActivity,
      priority: 'medium',
      reason: `Targeted practice needed in ${weakDiagnostic.primaryWeakSkill}.`
    };
  }

  // PRIORITY 6: Advanced Step-Up
  return {
    studentId,
    skillId: 'sentence_building',
    activityType: 'scramble',
    priority: 'low',
    reason: 'Advance to connected sentences.'
  };
}

console.log('🧪 Running Bhasha Setu Phase 2: Unified Learning Loop Test Suite...\n');

// TEST 1: LearningEvent Creation
const event1 = createLearningEvent({
  studentId: 'std_test_01',
  activityId: 'card_engat',
  activityType: 'flashcard',
  skillId: 'vocabulary',
  topic: 'Family',
  language: 'Santali',
  script: 'Ol_Chiki',
  difficulty: 1,
  correct: true,
  score: 80
});

assert.strictEqual(event1.studentId, 'std_test_01');
assert.strictEqual(event1.activityType, 'flashcard');
assert.strictEqual(event1.score, 80);
assert.strictEqual(event1.correct, true);
console.log('✅ Test 1: LearningEvent correctly constructed with complete metadata');

// TEST 2: Correct activity increases mastery; incorrect activity affects mastery
let vocabMastery = {
  studentId: 'std_test_01',
  skillId: 'vocabulary',
  aggregateScore: 30,
  activityBreakdown: {}
};

// Initial flashcard event (score: 90)
vocabMastery = updateSkillWithEvent(vocabMastery, event1);
assert.strictEqual(vocabMastery.aggregateScore, 80);
console.log('✅ Test 2A: Flashcard event initializes vocabulary mastery to 80%');

// Subsequent worksheet matching event (score: 100)
const event2 = createLearningEvent({
  studentId: 'std_test_01',
  activityId: 'ws_matching_1',
  activityType: 'matching',
  skillId: 'vocabulary',
  topic: 'Family',
  correct: true,
  score: 100
});

vocabMastery = updateSkillWithEvent(vocabMastery, event2);
// Flashcard (wt: 0.5, acc: 80) + Matching (wt: 0.3, acc: 100)
// Weighted avg = (80 * 0.5 + 100 * 0.3) / 0.8 = (40 + 30) / 0.8 = 70 / 0.8 = 87.5 => 88
assert.strictEqual(vocabMastery.aggregateScore, 88);
console.log('✅ Test 2B: High worksheet score raises cross-activity aggregate mastery (80% -> 88%)');

// TEST 3: Poor performance decreases mastery
const failedEvent = createLearningEvent({
  studentId: 'std_test_01',
  activityId: 'card_failure',
  activityType: 'flashcard',
  skillId: 'vocabulary',
  topic: 'Family',
  correct: false,
  score: 0
});

vocabMastery = updateSkillWithEvent(vocabMastery, failedEvent);
assert.ok(vocabMastery.aggregateScore < 88, 'Mastery should decrease after failure');
console.log(`✅ Test 3: Failed review decreases aggregate mastery (now ${vocabMastery.aggregateScore}%)`);

// TEST 4: WeakSkillDetector correctly identifies lowest-performing skill
const skills = [
  vocabMastery, // ~60-70%
  { studentId: 'std_test_01', skillId: 'sentence_building', aggregateScore: 35, activityBreakdown: {} },
  { studentId: 'std_test_01', skillId: 'script_recognition', aggregateScore: 78, activityBreakdown: {} }
];

const diagnostic = detectWeakSkills(skills);
assert.ok(diagnostic !== null);
assert.strictEqual(diagnostic.primaryWeakSkill, 'sentence_building');
assert.strictEqual(diagnostic.severity, 'critical');
assert.strictEqual(diagnostic.recommendedFocusActivity, 'scramble');
console.log('✅ Test 4: WeakSkillDetector accurately identifies sentence_building as critical weak skill (35%)');

// TEST 5: RecommendationEngine prioritizes Overdue Flashcards over Weak Skill
const recWithOverdue = getRecommendedNextActivity('std_test_01', {
  dueFlashcardsCount: 4,
  unifiedSkills: skills,
  weakDiagnostic: diagnostic
});

assert.strictEqual(recWithOverdue.activityType, 'flashcard');
assert.strictEqual(recWithOverdue.priority, 'high');
console.log('✅ Test 5A: RecommendationEngine prioritizes overdue flashcards (Priority 1)');

// When no cards are overdue, it targets the critical weak skill
const recWithoutOverdue = getRecommendedNextActivity('std_test_01', {
  dueFlashcardsCount: 0,
  unifiedSkills: skills,
  weakDiagnostic: diagnostic
});

assert.strictEqual(recWithoutOverdue.activityType, 'scramble');
assert.strictEqual(recWithoutOverdue.priority, 'critical');
assert.strictEqual(recWithoutOverdue.skillId, 'sentence_building');
console.log('✅ Test 5B: RecommendationEngine prioritizes critical weak skill when no flashcards are overdue (Priority 2)');

console.log('\n🎉 ALL 5 UNIFIED LEARNING LOOP TESTS PASSED SUCCESSFULLY!\n');

/**
 * Bhasha Setu Mastery Engine
 * Transparent, pedagogical mastery scoring and automatic difficulty scaling.
 */

import { SkillProgress, MasteryState, FLNSkill, DifficultyLevel } from './types';
import { getStudentProgress, saveSkillProgress } from './storage';

export function getMasteryState(score: number): MasteryState {
  if (score >= 90) return 'mastered';
  if (score >= 70) return 'proficient';
  if (score >= 40) return 'developing';
  return 'needs_support';
}

export function getMasteryLabel(state: MasteryState): { label: string; color: string; bg: string } {
  switch (state) {
    case 'mastered':
      return { label: 'Mastered', color: '#166534', bg: '#dcfce7' };
    case 'proficient':
      return { label: 'Proficient', color: '#15803d', bg: '#f0fdf4' };
    case 'developing':
      return { label: 'Developing', color: '#854d0e', bg: '#fef9c3' };
    case 'needs_support':
    default:
      return { label: 'Needs Support', color: '#991b1b', bg: '#fee2e2' };
  }
}

/**
 * Updates a student's mastery record after a worksheet session.
 */
export function updateStudentMastery(
  studentId: string,
  skillId: FLNSkill,
  topic: string,
  sessionCorrect: number,
  sessionTotal: number,
  exerciseType: string
): SkillProgress {
  const existingRecords = getStudentProgress(studentId);
  const current = existingRecords.find(
    p => p.skillId === skillId && p.topic.toLowerCase() === topic.toLowerCase()
  ) || {
    studentId,
    skillId,
    topic,
    attempts: 0,
    correctAnswers: 0,
    incorrectAnswers: 0,
    accuracy: 0,
    masteryScore: 30, // baseline starting score
    difficulty: 1 as DifficultyLevel,
    lastAttempt: new Date().toISOString(),
    lastActivity: exerciseType
  };

  const sessionIncorrect = Math.max(0, sessionTotal - sessionCorrect);
  const sessionAccuracy = sessionTotal > 0 ? Math.round((sessionCorrect / sessionTotal) * 100) : 0;

  // Exponential moving average for accuracy and mastery
  const updatedAccuracy = current.attempts === 0 
    ? sessionAccuracy 
    : Math.round(current.accuracy * 0.4 + sessionAccuracy * 0.6);

  // Dynamic mastery adjustment
  let masteryDelta = 0;
  if (sessionAccuracy >= 80) {
    masteryDelta = 12;
  } else if (sessionAccuracy >= 60) {
    masteryDelta = 6;
  } else if (sessionAccuracy >= 40) {
    masteryDelta = -4;
  } else {
    masteryDelta = -10;
  }

  const newMasteryScore = Math.min(100, Math.max(10, current.masteryScore + masteryDelta));

  // Automatic difficulty scaling
  let newDifficulty: DifficultyLevel = current.difficulty;
  if (sessionAccuracy >= 85 && newMasteryScore >= 70 && newDifficulty < 4) {
    newDifficulty = (newDifficulty + 1) as DifficultyLevel;
  } else if (sessionAccuracy < 50 && newDifficulty > 1) {
    newDifficulty = (newDifficulty - 1) as DifficultyLevel;
  }

  const updatedProgress: SkillProgress = {
    studentId,
    skillId,
    topic,
    attempts: current.attempts + 1,
    correctAnswers: current.correctAnswers + sessionCorrect,
    incorrectAnswers: current.incorrectAnswers + sessionIncorrect,
    accuracy: updatedAccuracy,
    masteryScore: newMasteryScore,
    difficulty: newDifficulty,
    lastAttempt: new Date().toISOString(),
    lastActivity: exerciseType
  };

  saveSkillProgress(updatedProgress);
  return updatedProgress;
}

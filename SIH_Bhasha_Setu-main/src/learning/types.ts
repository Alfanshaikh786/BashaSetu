/**
 * Bhasha Setu Adaptive Learning Studio — Data Types & Models
 * Defines verified content models, FLN curriculum structures,
 * student profiles, progress tracking, and mastery states.
 */

import { SantaliDatasetEntry } from '../data/santaliDataset';

export type TribalLanguage = 'Santali' | 'Mundari' | 'Ho';
export type ScriptType = 'Ol_Chiki' | 'Devanagari' | 'Latin';
export type FLNDomain = 'literacy' | 'numeracy';
export type FLNSkill = 
  | 'vocabulary' 
  | 'reading' 
  | 'sentence_building' 
  | 'script_recognition' 
  | 'numeracy';

export type DifficultyLevel = 1 | 2 | 3 | 4;

export type MasteryState = 
  | 'needs_support'  // 0–39%
  | 'developing'     // 40–69%
  | 'proficient'     // 70–89%
  | 'mastered';      // 90–100%

export interface LearningItem extends SantaliDatasetEntry {
  language: TribalLanguage;
  script: ScriptType;
  topic: string;
  grade: number; // 1, 2, 3, 4, 5
  skill: FLNSkill;
  difficulty: DifficultyLevel;
  fln_domain: FLNDomain;
  learning_outcome: string;
  verified: boolean;
}

export interface StudentProfile {
  studentId: string;
  name: string;
  grade: number;
  preferredLanguage: TribalLanguage;
  preferredScript: ScriptType;
  createdAt: string;
  lastActive: string;
}

export interface SkillProgress {
  studentId: string;
  skillId: FLNSkill;
  topic: string;
  attempts: number;
  correctAnswers: number;
  incorrectAnswers: number;
  accuracy: number; // 0–100%
  masteryScore: number; // 0–100
  difficulty: DifficultyLevel; // 1–4
  lastAttempt: string;
  lastActivity: string;
}

export interface RecommendedActivity {
  studentId: string;
  skillId: FLNSkill;
  topic: string;
  activityType: 'matching' | 'tracing' | 'scramble' | 'mcq';
  difficulty: DifficultyLevel;
  reason: string;
  currentMastery: number;
}

export interface TeacherAnalyticsSummary {
  totalStudents: number;
  domainMastery: {
    literacy: number;
    numeracy: number;
    vocabulary: number;
    ol_chiki: number;
  };
  studentsNeedingSupport: {
    studentId: string;
    studentName: string;
    weakSkill: FLNSkill;
    weakTopic: string;
    masteryScore: number;
    recommendedActivity: RecommendedActivity;
  }[];
}

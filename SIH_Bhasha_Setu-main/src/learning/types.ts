/**
 * Bhasha Setu Adaptive Learning Studio — Data Types & Models
 * Defines verified content models, FLN curriculum structures,
 * student profiles, progress tracking, and mastery states.
 */

import { SantaliDatasetEntry } from '../data/santaliDataset';

export type TribalLanguage = 'Santali' | 'Mundari' | 'Ho';
export type ScriptType = 'Ol_Chiki' | 'Devanagari' | 'Latin';
export type FLNDomain = 'literacy' | 'numeracy';

/**
 * Comprehensive Foundational Literacy and Numeracy (FLN) Skill Taxonomy.
 * Strict domain isolation is enforced between Literacy and Numeracy competencies.
 */
export type FLNSkill = 
  // Literacy Competencies
  | 'vocabulary' 
  | 'reading' 
  | 'sentence_building' 
  | 'script_recognition' 
  | 'oral_language'
  | 'listening_comprehension'
  | 'phonological_awareness'
  | 'letter_recognition'
  | 'letter_sound'
  | 'word_recognition'
  | 'reading_fluency'
  | 'reading_comprehension'
  | 'pronunciation'
  | 'translation'
  | 'spoken_sentence'
  // Numeracy Competencies
  | 'numeracy'
  | 'number_recognition'
  | 'counting'
  | 'number_comparison'
  | 'number_ordering'
  | 'addition'
  | 'subtraction'
  | 'patterns'
  | 'shapes'
  | 'measurement'
  | 'simple_word_problems';

export type DifficultyLevel = 1 | 2 | 3 | 4;

export type MasteryState = 
  | 'needs_support'  // 0–39%
  | 'developing'     // 40–69%
  | 'proficient'     // 70–89%
  | 'mastered';      // 90–100%

export type EvidenceLevel = 
  | 'insufficient'  // 0–1 attempt: statistical noise, cannot declare mastery
  | 'limited'       // 2–4 attempts: early indication
  | 'moderate'      // 5–9 attempts: reliable trend
  | 'strong';       // >= 10 attempts across multiple activities: empirical verification

export type ContentStatus = 
  | 'draft'       // Newly authored / raw extraction
  | 'reviewed'    // Linguistically reviewed by educator
  | 'verified'    // Fully verified against tribal corpus
  | 'published';  // Approved for student-facing practice

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
  contentStatus?: ContentStatus;
  verifiedBy?: string;
  verifiedAt?: string;
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
  evidenceLevel?: EvidenceLevel;
}

export interface RecommendedActivity {
  studentId: string;
  skillId: FLNSkill;
  topic: string;
  activityType: 'matching' | 'tracing' | 'scramble' | 'mcq' | 'flashcard' | 'voice';
  difficulty: DifficultyLevel;
  reason: string;
  currentMastery: number;
  priority?: 'critical' | 'high' | 'medium' | 'low';
}

export interface StudentLearningProfile extends StudentProfile {
  skills: Record<string, {
    skillId: FLNSkill;
    score: number;
    masteryState: MasteryState;
    evidenceLevel: EvidenceLevel;
    totalAttempts: number;
    lastPracticedAt: number;
  }>;
  overallLiteracy: number;
  overallNumeracy: number;
  weakSkills: FLNSkill[];
  activeRecommendations: RecommendedActivity[];
}

export interface ClassSkillRanking {
  skillId: FLNSkill;
  domain: FLNDomain;
  averageScore: number;
  studentCountNeedingSupport: number;
  severity: 'critical' | 'moderate' | 'mild';
}

export interface TeacherAnalyticsSummary {
  totalStudents: number;
  domainMastery: {
    literacy: number;
    numeracy: number;
    vocabulary: number;
    ol_chiki: number;
    sentence_building?: number;
    reading?: number;
  };
  topWeakSkills?: ClassSkillRanking[];
  studentsNeedingSupport: {
    studentId: string;
    studentName: string;
    weakSkill: FLNSkill;
    weakTopic: string;
    masteryScore: number;
    evidenceLevel?: EvidenceLevel;
    recommendedActivity: RecommendedActivity;
  }[];
}

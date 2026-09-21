/**
 * Bhasha Setu Offline Student Profile & Progress Tracking
 * Pure client-side localStorage persistence with zero cloud dependency.
 */

import { StudentProfile, SkillProgress, FLNSkill, DifficultyLevel } from './types';

const ACTIVE_STUDENT_KEY = 'bhasha_setu_active_student_v1';
const STUDENTS_KEY = 'bhasha_setu_students_v1';
const PROGRESS_KEY_PREFIX = 'bhasha_setu_progress_v1_';

const DEFAULT_STUDENTS: StudentProfile[] = [
  {
    studentId: 'std_aarav_01',
    name: 'Aarav Marandi',
    grade: 2,
    preferredLanguage: 'Santali',
    preferredScript: 'Ol_Chiki',
    createdAt: new Date().toISOString(),
    lastActive: new Date().toISOString()
  },
  {
    studentId: 'std_sunita_02',
    name: 'Sunita Hansda',
    grade: 1,
    preferredLanguage: 'Santali',
    preferredScript: 'Ol_Chiki',
    createdAt: new Date().toISOString(),
    lastActive: new Date().toISOString()
  },
  {
    studentId: 'std_ravi_03',
    name: 'Ravi Murmu',
    grade: 3,
    preferredLanguage: 'Santali',
    preferredScript: 'Ol_Chiki',
    createdAt: new Date().toISOString(),
    lastActive: new Date().toISOString()
  }
];

const SEED_FLAG_KEY = 'bhasha_setu_seeded_v1';

function seedInitialProgressIfEmpty(): void {
  if (typeof window === 'undefined' || !window.localStorage) return;
  if (localStorage.getItem(SEED_FLAG_KEY)) return;

  const defaultProgress: Record<string, SkillProgress[]> = {
    'std_aarav_01': [
      {
        studentId: 'std_aarav_01',
        skillId: 'vocabulary',
        topic: 'Classroom',
        attempts: 12,
        correctAnswers: 10,
        incorrectAnswers: 2,
        accuracy: 83,
        masteryScore: 84,
        difficulty: 2,
        lastAttempt: new Date(Date.now() - 3600000 * 2).toISOString(),
        lastActivity: 'matching'
      },
      {
        studentId: 'std_aarav_01',
        skillId: 'reading',
        topic: 'General',
        attempts: 8,
        correctAnswers: 6,
        incorrectAnswers: 2,
        accuracy: 75,
        masteryScore: 76,
        difficulty: 2,
        lastAttempt: new Date(Date.now() - 3600000 * 5).toISOString(),
        lastActivity: 'mcq'
      }
    ],
    'std_sunita_02': [
      {
        studentId: 'std_sunita_02',
        skillId: 'numeracy',
        topic: 'Numbers',
        attempts: 7,
        correctAnswers: 3,
        incorrectAnswers: 4,
        accuracy: 42,
        masteryScore: 44,
        difficulty: 1,
        lastAttempt: new Date(Date.now() - 3600000 * 1).toISOString(),
        lastActivity: 'matching'
      },
      {
        studentId: 'std_sunita_02',
        skillId: 'script_recognition',
        topic: 'Letters',
        attempts: 6,
        correctAnswers: 3,
        incorrectAnswers: 3,
        accuracy: 50,
        masteryScore: 52,
        difficulty: 1,
        lastAttempt: new Date(Date.now() - 3600000 * 4).toISOString(),
        lastActivity: 'tracing'
      }
    ],
    'std_ravi_03': [
      {
        studentId: 'std_ravi_03',
        skillId: 'sentence_building',
        topic: 'Phrases',
        attempts: 14,
        correctAnswers: 10,
        incorrectAnswers: 4,
        accuracy: 71,
        masteryScore: 73,
        difficulty: 3,
        lastAttempt: new Date(Date.now() - 3600000 * 12).toISOString(),
        lastActivity: 'scramble'
      }
    ]
  };

  try {
    for (const [studentId, records] of Object.entries(defaultProgress)) {
      localStorage.setItem(`${PROGRESS_KEY_PREFIX}${studentId}`, JSON.stringify(records));
    }
    localStorage.setItem(SEED_FLAG_KEY, 'true');
  } catch (err) {
    console.warn('[LearningStorage] Error seeding initial progress:', err);
  }
}

export function getAllStudents(): StudentProfile[] {
  if (typeof window === 'undefined' || !window.localStorage) return DEFAULT_STUDENTS;
  try {
    seedInitialProgressIfEmpty();
    const raw = localStorage.getItem(STUDENTS_KEY);
    if (!raw) {
      localStorage.setItem(STUDENTS_KEY, JSON.stringify(DEFAULT_STUDENTS));
      return DEFAULT_STUDENTS;
    }
    return JSON.parse(raw);
  } catch (err) {
    console.warn('[LearningStorage] Error loading students:', err);
    return DEFAULT_STUDENTS;
  }
}

export function getActiveStudent(): StudentProfile {
  if (typeof window === 'undefined' || !window.localStorage) return DEFAULT_STUDENTS[0];
  try {
    const raw = localStorage.getItem(ACTIVE_STUDENT_KEY);
    if (raw) {
      return JSON.parse(raw);
    }
    const all = getAllStudents();
    const defaultStudent = all[0] || DEFAULT_STUDENTS[0];
    localStorage.setItem(ACTIVE_STUDENT_KEY, JSON.stringify(defaultStudent));
    return defaultStudent;
  } catch (err) {
    return DEFAULT_STUDENTS[0];
  }
}

export function setActiveStudent(student: StudentProfile): void {
  if (typeof window === 'undefined' || !window.localStorage) return;
  try {
    const updated = { ...student, lastActive: new Date().toISOString() };
    localStorage.setItem(ACTIVE_STUDENT_KEY, JSON.stringify(updated));

    // Update in students list as well
    const all = getAllStudents().map(s => s.studentId === student.studentId ? updated : s);
    localStorage.setItem(STUDENTS_KEY, JSON.stringify(all));
  } catch (err) {
    console.warn('[LearningStorage] Error setting active student:', err);
  }
}

export function createStudent(name: string, grade: number = 2): StudentProfile {
  const newStudent: StudentProfile = {
    studentId: `std_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
    name: name.trim() || 'New Learner',
    grade,
    preferredLanguage: 'Santali',
    preferredScript: 'Ol_Chiki',
    createdAt: new Date().toISOString(),
    lastActive: new Date().toISOString()
  };

  if (typeof window !== 'undefined' && window.localStorage) {
    try {
      const all = getAllStudents();
      all.push(newStudent);
      localStorage.setItem(STUDENTS_KEY, JSON.stringify(all));
      setActiveStudent(newStudent);
    } catch (err) {
      console.warn('[LearningStorage] Error creating student:', err);
    }
  }

  return newStudent;
}

export function getStudentProgress(studentId: string): SkillProgress[] {
  if (typeof window === 'undefined' || !window.localStorage) return [];
  try {
    const raw = localStorage.getItem(`${PROGRESS_KEY_PREFIX}${studentId}`);
    return raw ? JSON.parse(raw) : [];
  } catch (err) {
    console.warn('[LearningStorage] Error fetching progress:', err);
    return [];
  }
}

export function saveSkillProgress(progress: SkillProgress): void {
  if (typeof window === 'undefined' || !window.localStorage) return;
  try {
    const existing = getStudentProgress(progress.studentId);
    const index = existing.findIndex(
      p => p.skillId === progress.skillId && p.topic.toLowerCase() === progress.topic.toLowerCase()
    );

    if (index >= 0) {
      existing[index] = progress;
    } else {
      existing.push(progress);
    }

    localStorage.setItem(`${PROGRESS_KEY_PREFIX}${progress.studentId}`, JSON.stringify(existing));
  } catch (err) {
    console.warn('[LearningStorage] Error saving skill progress:', err);
  }
}

/**
 * Bhasha Setu IndexedDB Structured Repository (v3)
 * Pure client-side IndexedDB persistence with zero cloud/network dependency
 * and automatic, graceful fallback to localStorage when IndexedDB is blocked.
 * 
 * Version 3 adds stores for curriculum_nodes, student_learning_profiles, and class_analytics.
 */

import { CardProgress, ReviewHistoryEntry } from './flashcardTypes';
import { LearningEvent } from './learningEvents';
import { UnifiedSkillMastery } from './unifiedSkills';
import { FLNSkill, StudentLearningProfile, TeacherAnalyticsSummary } from './types';

const DB_NAME = 'bhasha_setu_learning_db';
const DB_VERSION = 3;

const STORES = {
  CARD_PROGRESS: 'card_progress',
  REVIEW_HISTORY: 'review_history',
  LEARNER_PROGRESS: 'learner_progress',
  LEARNING_EVENTS: 'learning_events',
  UNIFIED_SKILLS: 'unified_skills',
  CURRICULUM_NODES: 'curriculum_nodes',
  STUDENT_PROFILES: 'student_profiles',
  CLASS_ANALYTICS: 'class_analytics'
} as const;

class IndexedDBRepository {
  private dbPromise: Promise<IDBDatabase> | null = null;
  private isIndexedDBAvailable: boolean = typeof window !== 'undefined' && 'indexedDB' in window;

  private async getDB(): Promise<IDBDatabase> {
    if (!this.isIndexedDBAvailable) {
      throw new Error('IndexedDB unavailable in this environment');
    }

    if (this.dbPromise) return this.dbPromise;

    this.dbPromise = new Promise<IDBDatabase>((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;

        // V1 Stores
        if (!db.objectStoreNames.contains(STORES.CARD_PROGRESS)) {
          const store = db.createObjectStore(STORES.CARD_PROGRESS, { keyPath: 'compositeKey' });
          store.createIndex('studentId', 'studentId', { unique: false });
          store.createIndex('nextReviewAt', 'nextReviewAt', { unique: false });
          store.createIndex('status', 'status', { unique: false });
        }

        if (!db.objectStoreNames.contains(STORES.REVIEW_HISTORY)) {
          const store = db.createObjectStore(STORES.REVIEW_HISTORY, { keyPath: 'id' });
          store.createIndex('studentId', 'studentId', { unique: false });
          store.createIndex('cardId', 'cardId', { unique: false });
          store.createIndex('reviewedAt', 'reviewedAt', { unique: false });
        }

        if (!db.objectStoreNames.contains(STORES.LEARNER_PROGRESS)) {
          db.createObjectStore(STORES.LEARNER_PROGRESS, { keyPath: 'studentId' });
        }

        // V2 Stores
        if (!db.objectStoreNames.contains(STORES.LEARNING_EVENTS)) {
          const store = db.createObjectStore(STORES.LEARNING_EVENTS, { keyPath: 'id' });
          store.createIndex('studentId', 'studentId', { unique: false });
          store.createIndex('skillId', 'skillId', { unique: false });
          store.createIndex('timestamp', 'timestamp', { unique: false });
          store.createIndex('activityType', 'activityType', { unique: false });
        }

        if (!db.objectStoreNames.contains(STORES.UNIFIED_SKILLS)) {
          const store = db.createObjectStore(STORES.UNIFIED_SKILLS, { keyPath: 'compositeKey' });
          store.createIndex('studentId', 'studentId', { unique: false });
          store.createIndex('skillId', 'skillId', { unique: false });
        }

        // V3 Stores: Curriculum, Profiles, Class Analytics
        if (!db.objectStoreNames.contains(STORES.CURRICULUM_NODES)) {
          const store = db.createObjectStore(STORES.CURRICULUM_NODES, { keyPath: 'id' });
          store.createIndex('grade', 'grade', { unique: false });
          store.createIndex('domain', 'domain', { unique: false });
          store.createIndex('skill', 'skill', { unique: false });
        }

        if (!db.objectStoreNames.contains(STORES.STUDENT_PROFILES)) {
          db.createObjectStore(STORES.STUDENT_PROFILES, { keyPath: 'studentId' });
        }

        if (!db.objectStoreNames.contains(STORES.CLASS_ANALYTICS)) {
          db.createObjectStore(STORES.CLASS_ANALYTICS, { keyPath: 'classId' });
        }
      };

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => {
        console.warn('[LearningIDB] Failed to open IndexedDB, falling back to localStorage');
        this.isIndexedDBAvailable = false;
        reject(request.error);
      };
    });

    return this.dbPromise;
  }

  private getCompositeKey(studentId: string, itemKey: string): string {
    return `${studentId}:::${itemKey}`;
  }

  // =========================================================================
  // 1. CARD PROGRESS (Preserved from Phase 1)
  // =========================================================================

  async getCardProgress(studentId: string, cardId: string): Promise<CardProgress | null> {
    const key = this.getCompositeKey(studentId, cardId);
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.CARD_PROGRESS, 'readonly');
        const store = tx.objectStore(STORES.CARD_PROGRESS);
        const req = store.get(key);
        req.onsuccess = () => resolve(req.result ? req.result.progress : null);
        req.onerror = () => resolve(this.getCardProgressLocalStorage(key));
      });
    } catch {
      return this.getCardProgressLocalStorage(key);
    }
  }

  async getAllCardProgress(studentId: string): Promise<Map<string, CardProgress>> {
    const map = new Map<string, CardProgress>();
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.CARD_PROGRESS, 'readonly');
        const store = tx.objectStore(STORES.CARD_PROGRESS);
        const index = store.index('studentId');
        const req = index.getAll(studentId);

        req.onsuccess = () => {
          if (req.result) {
            for (const item of req.result) {
              map.set(item.progress.cardId, item.progress);
            }
          }
          resolve(map);
        };
        req.onerror = () => resolve(this.getAllCardProgressLocalStorage(studentId));
      });
    } catch {
      return this.getAllCardProgressLocalStorage(studentId);
    }
  }

  async saveCardProgress(progress: CardProgress): Promise<void> {
    const key = this.getCompositeKey(progress.studentId, progress.cardId);
    const record = {
      compositeKey: key,
      studentId: progress.studentId,
      cardId: progress.cardId,
      nextReviewAt: progress.nextReviewAt,
      status: progress.status,
      progress
    };

    try {
      const db = await this.getDB();
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(STORES.CARD_PROGRESS, 'readwrite');
        const store = tx.objectStore(STORES.CARD_PROGRESS);
        const req = store.put(record);
        req.onsuccess = () => resolve();
        req.onerror = () => reject(req.error);
      });
    } catch {
      this.saveCardProgressLocalStorage(key, progress);
    }
  }

  // =========================================================================
  // 2. REVIEW HISTORY (Preserved from Phase 1)
  // =========================================================================

  async recordReview(entry: ReviewHistoryEntry): Promise<void> {
    try {
      const db = await this.getDB();
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(STORES.REVIEW_HISTORY, 'readwrite');
        const store = tx.objectStore(STORES.REVIEW_HISTORY);
        const req = store.add(entry);
        req.onsuccess = () => resolve();
        req.onerror = () => reject(req.error);
      });
    } catch {
      try {
        const raw = localStorage.getItem(`bhasha_setu_history_${entry.studentId}`);
        const list: ReviewHistoryEntry[] = raw ? JSON.parse(raw) : [];
        list.push(entry);
        if (list.length > 200) list.shift();
        localStorage.setItem(`bhasha_setu_history_${entry.studentId}`, JSON.stringify(list));
      } catch (e) {
        console.warn('[LearningIDB] History write failed:', e);
      }
    }
  }

  // =========================================================================
  // 3. LEARNING EVENTS (Preserved from Phase 2)
  // =========================================================================

  async recordLearningEvent(event: LearningEvent): Promise<void> {
    try {
      const db = await this.getDB();
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(STORES.LEARNING_EVENTS, 'readwrite');
        const store = tx.objectStore(STORES.LEARNING_EVENTS);
        const req = store.add(event);
        req.onsuccess = () => resolve();
        req.onerror = () => reject(req.error);
      });
    } catch {
      try {
        const raw = localStorage.getItem(`bhasha_setu_le_${event.studentId}`);
        const list: LearningEvent[] = raw ? JSON.parse(raw) : [];
        list.push(event);
        if (list.length > 200) list.shift();
        localStorage.setItem(`bhasha_setu_le_${event.studentId}`, JSON.stringify(list));
      } catch (e) {
        console.warn('[LearningIDB] Event fallback write failed:', e);
      }
    }
  }

  async getRecentEvents(studentId: string, limit: number = 20): Promise<LearningEvent[]> {
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.LEARNING_EVENTS, 'readonly');
        const store = tx.objectStore(STORES.LEARNING_EVENTS);
        const index = store.index('studentId');
        const req = index.getAll(studentId);

        req.onsuccess = () => {
          const events: LearningEvent[] = req.result || [];
          events.sort((a, b) => b.timestamp - a.timestamp);
          resolve(events.slice(0, limit));
        };
        req.onerror = () => resolve(this.getRecentEventsLocalStorage(studentId, limit));
      });
    } catch {
      return this.getRecentEventsLocalStorage(studentId, limit);
    }
  }

  // =========================================================================
  // 4. UNIFIED SKILLS (Preserved from Phase 2)
  // =========================================================================

  async saveUnifiedSkill(skill: UnifiedSkillMastery): Promise<void> {
    const key = this.getCompositeKey(skill.studentId, skill.skillId);
    const record = {
      compositeKey: key,
      studentId: skill.studentId,
      skillId: skill.skillId,
      skill
    };

    try {
      const db = await this.getDB();
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(STORES.UNIFIED_SKILLS, 'readwrite');
        const store = tx.objectStore(STORES.UNIFIED_SKILLS);
        const req = store.put(record);
        req.onsuccess = () => resolve();
        req.onerror = () => reject(req.error);
      });
    } catch {
      this.saveUnifiedSkillLocalStorage(key, skill);
    }
  }

  async getUnifiedSkill(studentId: string, skillId: FLNSkill): Promise<UnifiedSkillMastery | null> {
    const key = this.getCompositeKey(studentId, skillId);
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.UNIFIED_SKILLS, 'readonly');
        const store = tx.objectStore(STORES.UNIFIED_SKILLS);
        const req = store.get(key);
        req.onsuccess = () => resolve(req.result ? req.result.skill : null);
        req.onerror = () => resolve(this.getUnifiedSkillLocalStorage(key));
      });
    } catch {
      return this.getUnifiedSkillLocalStorage(key);
    }
  }

  async getAllUnifiedSkills(studentId: string): Promise<Map<FLNSkill, UnifiedSkillMastery>> {
    const map = new Map<FLNSkill, UnifiedSkillMastery>();
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.UNIFIED_SKILLS, 'readonly');
        const store = tx.objectStore(STORES.UNIFIED_SKILLS);
        const index = store.index('studentId');
        const req = index.getAll(studentId);

        req.onsuccess = () => {
          if (req.result) {
            for (const item of req.result) {
              map.set(item.skill.skillId, item.skill);
            }
          }
          resolve(map);
        };
        req.onerror = () => resolve(this.getAllUnifiedSkillsLocalStorage(studentId));
      });
    } catch {
      return this.getAllUnifiedSkillsLocalStorage(studentId);
    }
  }

  // =========================================================================
  // 5. STUDENT LEARNING PROFILES & CLASS ANALYTICS (Phase 3 Additions)
  // =========================================================================

  async saveStudentLearningProfile(profile: StudentLearningProfile): Promise<void> {
    try {
      const db = await this.getDB();
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(STORES.STUDENT_PROFILES, 'readwrite');
        const store = tx.objectStore(STORES.STUDENT_PROFILES);
        const req = store.put(profile);
        req.onsuccess = () => resolve();
        req.onerror = () => reject(req.error);
      });
    } catch {
      if (typeof window !== 'undefined' && window.localStorage) {
        localStorage.setItem(`bhasha_setu_slp_${profile.studentId}`, JSON.stringify(profile));
      }
    }
  }

  async getStudentLearningProfile(studentId: string): Promise<StudentLearningProfile | null> {
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.STUDENT_PROFILES, 'readonly');
        const store = tx.objectStore(STORES.STUDENT_PROFILES);
        const req = store.get(studentId);
        req.onsuccess = () => resolve(req.result || null);
        req.onerror = () => resolve(this.getStudentLearningProfileLocalStorage(studentId));
      });
    } catch {
      return this.getStudentLearningProfileLocalStorage(studentId);
    }
  }

  async getAllStudentLearningProfiles(): Promise<StudentLearningProfile[]> {
    try {
      const db = await this.getDB();
      return new Promise((resolve) => {
        const tx = db.transaction(STORES.STUDENT_PROFILES, 'readonly');
        const store = tx.objectStore(STORES.STUDENT_PROFILES);
        const req = store.getAll();
        req.onsuccess = () => resolve(req.result || []);
        req.onerror = () => resolve(this.getAllStudentLearningProfilesLocalStorage());
      });
    } catch {
      return this.getAllStudentLearningProfilesLocalStorage();
    }
  }

  // =========================================================================
  // 6. LOCALSTORAGE FALLBACKS
  // =========================================================================

  private getCardProgressLocalStorage(key: string): CardProgress | null {
    if (typeof window === 'undefined' || !window.localStorage) return null;
    try {
      const raw = localStorage.getItem(`bhasha_setu_cp_${key}`);
      return raw ? JSON.parse(raw) : null;
    } catch {
      return null;
    }
  }

  private getAllCardProgressLocalStorage(studentId: string): Map<string, CardProgress> {
    const map = new Map<string, CardProgress>();
    if (typeof window === 'undefined' || !window.localStorage) return map;
    try {
      const prefix = `bhasha_setu_cp_${studentId}:::`;
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(prefix)) {
          const raw = localStorage.getItem(key);
          if (raw) {
            const p: CardProgress = JSON.parse(raw);
            map.set(p.cardId, p);
          }
        }
      }
    } catch (e) {
      console.warn('[LearningIDB] LocalStorage getAll error:', e);
    }
    return map;
  }

  private saveCardProgressLocalStorage(key: string, progress: CardProgress): void {
    if (typeof window === 'undefined' || !window.localStorage) return;
    try {
      localStorage.setItem(`bhasha_setu_cp_${key}`, JSON.stringify(progress));
    } catch (e) {
      console.warn('[LearningIDB] LocalStorage write error:', e);
    }
  }

  private getRecentEventsLocalStorage(studentId: string, limit: number): LearningEvent[] {
    if (typeof window === 'undefined' || !window.localStorage) return [];
    try {
      const raw = localStorage.getItem(`bhasha_setu_le_${studentId}`);
      const list: LearningEvent[] = raw ? JSON.parse(raw) : [];
      list.sort((a, b) => b.timestamp - a.timestamp);
      return list.slice(0, limit);
    } catch {
      return [];
    }
  }

  private saveUnifiedSkillLocalStorage(key: string, skill: UnifiedSkillMastery): void {
    if (typeof window === 'undefined' || !window.localStorage) return;
    try {
      localStorage.setItem(`bhasha_setu_us_${key}`, JSON.stringify(skill));
    } catch (e) {
      console.warn('[LearningIDB] LocalStorage skill write error:', e);
    }
  }

  private getUnifiedSkillLocalStorage(key: string): UnifiedSkillMastery | null {
    if (typeof window === 'undefined' || !window.localStorage) return null;
    try {
      const raw = localStorage.getItem(`bhasha_setu_us_${key}`);
      return raw ? JSON.parse(raw) : null;
    } catch {
      return null;
    }
  }

  private getAllUnifiedSkillsLocalStorage(studentId: string): Map<FLNSkill, UnifiedSkillMastery> {
    const map = new Map<FLNSkill, UnifiedSkillMastery>();
    if (typeof window === 'undefined' || !window.localStorage) return map;
    try {
      const prefix = `bhasha_setu_us_${studentId}:::`;
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(prefix)) {
          const raw = localStorage.getItem(key);
          if (raw) {
            const s: UnifiedSkillMastery = JSON.parse(raw);
            map.set(s.skillId, s);
          }
        }
      }
    } catch (e) {
      console.warn('[LearningIDB] LocalStorage getAllSkills error:', e);
    }
    return map;
  }

  private getStudentLearningProfileLocalStorage(studentId: string): StudentLearningProfile | null {
    if (typeof window === 'undefined' || !window.localStorage) return null;
    try {
      const raw = localStorage.getItem(`bhasha_setu_slp_${studentId}`);
      return raw ? JSON.parse(raw) : null;
    } catch {
      return null;
    }
  }

  private getAllStudentLearningProfilesLocalStorage(): StudentLearningProfile[] {
    const list: StudentLearningProfile[] = [];
    if (typeof window === 'undefined' || !window.localStorage) return list;
    try {
      const prefix = 'bhasha_setu_slp_';
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(prefix)) {
          const raw = localStorage.getItem(key);
          if (raw) list.push(JSON.parse(raw));
        }
      }
    } catch (e) {
      console.warn('[LearningIDB] LocalStorage getProfiles error:', e);
    }
    return list;
  }
}

export const learningRepository = new IndexedDBRepository();

/**
 * Bhasha Setu Voice Activity Model & Factory
 * Implements creation, generation, and validation of VoiceActivity instances
 * across the 4 core modes (Listen, Speak, Teacher Translate, Student Response).
 * 
 * Enforces strict separation of Language ('Santali') and Script ('Ol_Chiki').
 */

import { VoiceActivity, VoiceActivityMode, VoiceAudioSourceType, VoiceEvaluationResult } from './types';
import { FLNSkill, DifficultyLevel } from '../types';
import { LearningEvent, createLearningEvent } from '../learningEvents';
import { SANTALI_DATASET, SantaliDatasetEntry } from '../../data/santaliDataset';
import { validateOlChikiScript } from '../contentValidator';

export interface CreateVoiceActivityParams {
  id?: string;
  studentId: string;
  mode: VoiceActivityMode;
  sourceLanguage?: 'English' | 'Hindi' | 'Santali';
  targetLanguage?: 'Santali';
  targetScript?: 'Ol_Chiki';
  skill: FLNSkill;
  topic?: string;
  difficulty?: DifficultyLevel;
  promptText: string;
  expectedText: string;
  expectedMeaning?: string;
  romanPhonetic?: string;
  audioSource?: VoiceAudioSourceType;
  audioUrl?: string;
  verified?: boolean;
  metadata?: Record<string, unknown>;
}

/**
 * Creates and validates a VoiceActivity instance.
 */
export function createVoiceActivity(params: CreateVoiceActivityParams): VoiceActivity {
  // Enforce language vs script separation
  const targetLanguage = params.targetLanguage || 'Santali';
  const targetScript = params.targetScript || 'Ol_Chiki';

  // Enforce Unicode Ol Chiki integrity on expected Santali text
  if (targetScript === 'Ol_Chiki' && params.expectedText) {
    const isValid = validateOlChikiScript(params.expectedText);
    if (!isValid) {
      console.warn(`[VoiceActivity] Expected text "${params.expectedText}" contains characters outside Ol Chiki block.`);
    }
  }

  return {
    id: params.id || `voice_${params.mode}_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
    studentId: params.studentId,
    mode: params.mode,
    sourceLanguage: params.sourceLanguage || (params.mode === 'speak' ? 'English' : 'Hindi'),
    targetLanguage,
    targetScript,
    skill: params.skill,
    topic: params.topic || 'General',
    difficulty: params.difficulty || 1,
    promptText: params.promptText,
    expectedText: params.expectedText,
    expectedMeaning: params.expectedMeaning,
    romanPhonetic: params.romanPhonetic,
    audioSource: params.audioSource || 'verified_native',
    audioUrl: params.audioUrl,
    verified: params.verified ?? true,
    metadata: params.metadata || {}
  };
}

/**
 * Generates an adaptive voice activity from the verified dataset for a student.
 */
export function generateAdaptiveVoiceActivity(
  studentId: string,
  mode: VoiceActivityMode,
  skill: FLNSkill,
  topic: string = 'General',
  difficulty: DifficultyLevel = 1
): VoiceActivity {
  // Select matching items from verified dataset
  let candidates = SANTALI_DATASET.filter(item => {
    if (!item.sat || !validateOlChikiScript(item.sat)) return false;
    if (topic !== 'General' && item.cat && item.cat !== topic) return false;
    return true;
  });

  if (candidates.length === 0) {
    candidates = SANTALI_DATASET.filter(item => item.sat && validateOlChikiScript(item.sat));
  }

  const selected = candidates[Math.floor(Math.random() * candidates.length)] || SANTALI_DATASET[0];

  switch (mode) {
    case 'listen':
      // Mode 1: Listen to Santali audio -> Identify Hindi/English meaning
      return createVoiceActivity({
        studentId,
        mode: 'listen',
        sourceLanguage: 'Santali',
        targetLanguage: 'Santali',
        targetScript: 'Ol_Chiki',
        skill: skill || 'listening_comprehension',
        topic: selected.cat || topic,
        difficulty,
        promptText: 'Listen to the spoken Santali phrase and select the correct meaning:',
        expectedText: selected.sat,
        expectedMeaning: selected.en,
        romanPhonetic: selected.roman,
        audioSource: 'verified_native',
        audioUrl: `/audio/santali/${selected.id}.ogg`,
        verified: true,
        metadata: { datasetId: selected.id, hindiMeaning: selected.hi }
      });

    case 'speak':
      // Mode 2: Given prompt -> Student speaks Santali -> Evaluated
      return createVoiceActivity({
        studentId,
        mode: 'speak',
        sourceLanguage: 'Hindi',
        targetLanguage: 'Santali',
        targetScript: 'Ol_Chiki',
        skill: skill || 'pronunciation',
        topic: selected.cat || topic,
        difficulty,
        promptText: `Speak the Santali translation for: "${selected.hi}" (${selected.en})`,
        expectedText: selected.sat,
        expectedMeaning: selected.en,
        romanPhonetic: selected.roman,
        audioSource: 'verified_native',
        audioUrl: `/audio/santali/${selected.id}.ogg`,
        verified: true,
        metadata: { datasetId: selected.id }
      });

    case 'teacher_translate':
      // Mode 3: Teacher speaks Hindi/English -> Translates to Santali Ol Chiki + Audio
      return createVoiceActivity({
        studentId,
        mode: 'teacher_translate',
        sourceLanguage: 'Hindi',
        targetLanguage: 'Santali',
        targetScript: 'Ol_Chiki',
        skill: skill || 'translation',
        topic: topic || 'Classroom',
        difficulty,
        promptText: 'Teacher speaks instructional phrase in Hindi or English:',
        expectedText: selected.sat,
        expectedMeaning: selected.hi,
        romanPhonetic: selected.roman,
        audioSource: 'verified_native',
        verified: true
      });

    case 'student_response':
    default:
      // Mode 4: Teacher prompt -> Student responds in spoken Santali -> Evaluated
      return createVoiceActivity({
        studentId,
        mode: 'student_response',
        sourceLanguage: 'Hindi',
        targetLanguage: 'Santali',
        targetScript: 'Ol_Chiki',
        skill: skill || 'spoken_sentence',
        topic: selected.cat || topic,
        difficulty,
        promptText: `Teacher Prompt: "${selected.hi}" — Student responds in Santali:`,
        expectedText: selected.sat,
        expectedMeaning: selected.en,
        romanPhonetic: selected.roman,
        audioSource: 'verified_native',
        audioUrl: `/audio/santali/${selected.id}.ogg`,
        verified: true,
        metadata: { datasetId: selected.id }
      });
  }
}

/**
 * Transforms a completed VoiceActivity evaluation into a canonical LearningEvent.
 * Fully integrates into the unified cross-activity learning telemetry.
 */
export function createVoiceLearningEvent(
  activity: VoiceActivity,
  evaluation: VoiceEvaluationResult,
  studentId: string
): LearningEvent {
  return createLearningEvent({
    studentId,
    activityId: activity.id,
    activityType: 'voice',
    skillId: activity.skill,
    topic: activity.topic,
    language: activity.targetLanguage,
    script: activity.targetScript,
    difficulty: activity.difficulty,
    correct: evaluation.isCorrect,
    score: evaluation.score,
    responseTimeMs: evaluation.latencyMs.totalLatencyMs,
    metadata: {
      mode: activity.mode,
      wordAccuracy: evaluation.wordAccuracy,
      confidence: evaluation.confidence,
      recognizedText: evaluation.recognizedText,
      expectedText: evaluation.expectedText,
      evaluationMethod: evaluation.evaluationMethod,
      audioSource: activity.audioSource,
      latencyBreakdown: evaluation.latencyMs
    }
  });
}

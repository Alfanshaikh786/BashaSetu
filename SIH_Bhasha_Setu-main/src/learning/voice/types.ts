/**
 * Bhasha Setu Phase 4: Voice Learning Studio Types
 * Defines data structures for multimodal voice learning activities,
 * audio sources, modes, evaluation results, and telemetry contexts.
 */

import { FLNSkill, DifficultyLevel, TribalLanguage, ScriptType } from '../types';
import { LearningActivityType } from '../learningEvents';

export type VoiceActivityMode = 
  | 'listen'            // Mode 1: Listen to spoken audio, identify meaning
  | 'speak'             // Mode 2: Prompt given, student speaks, evaluated by ASR
  | 'teacher_translate' // Mode 3: Teacher speaks Hindi/English -> translates to Santali Ol Chiki + Audio
  | 'student_response'; // Mode 4: Teacher prompt -> Student responds in Santali -> Evaluated

export type VoiceAudioSourceType = 
  | 'verified_native'    // Authentic human recording
  | 'local_phrase_cache' // Verified cached audio
  | 'cached_audio'       // Preloaded audio asset
  | 'synthetic_tts'      // Local neural synthesis
  | 'browser_tts'        // Browser speech synthesis
  | 'phonetic_fallback'  // Browser speech synthesis via phonetic bridge
  | 'unavailable';

export interface VoiceActivity {
  id: string;
  studentId: string;
  mode: VoiceActivityMode;
  sourceLanguage: 'English' | 'Hindi' | 'Santali';
  targetLanguage: TribalLanguage;
  targetScript: ScriptType;
  skill: FLNSkill;
  topic: string;
  difficulty: DifficultyLevel;
  promptText: string;
  expectedText: string;
  expectedMeaning?: string;
  romanPhonetic?: string;
  audioSource?: VoiceAudioSourceType;
  audioUrl?: string;
  verified: boolean;
  metadata?: Record<string, unknown>;
}

export interface VoiceEvaluationResult {
  recognizedText: string;
  expectedText: string;
  isCorrect: boolean;
  confidence: number; // 0.0 to 1.0
  wordAccuracy: number; // 0 to 100%
  score: number; // 0 to 100
  feedback: string;
  evaluationMethod: 'normalized_token_match' | 'fuzzy_levenshtein' | 'semantic_fallback';
  latencyMs: {
    asrLatencyMs: number;
    evaluationLatencyMs: number;
    totalLatencyMs: number;
  };
  diagnostics?: {
    teacherSummary?: string;
    missingWords?: string[];
    extraWords?: string[];
    wrongWords?: string[];
    charSimilarity?: number;
    rawScore?: number;
  };
}

export interface TeacherVoiceInputState {
  isListening: boolean;
  sourceText: string;
  sourceLang: 'Hindi' | 'English';
  translatedText: string;
  targetScript: 'Ol_Chiki';
  targetLang: 'Santali';
  audioPlaying: boolean;
  error?: string;
  timings: {
    asrMs?: number;
    translationMs?: number;
    ttsMs?: number;
    totalMs?: number;
  };
}

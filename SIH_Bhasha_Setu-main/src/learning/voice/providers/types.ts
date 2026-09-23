/**
 * Bhasha Setu Voice Engine Provider Interfaces
 * Establishes clean, swap-ready architectural contracts for Speech Recognition (ASR),
 * Local Translation, Speech Synthesis (TTS), and Voice Evaluation.
 * 
 * Crucial: No fake/simulated AI inference. All providers must clearly declare their
 * mode, offline capabilities, and actual execution path.
 */

import { VoiceAudioSourceType, VoiceEvaluationResult } from '../types';

export interface RecognitionEvent {
  transcript: string;
  isFinal: boolean;
  confidence: number;
}

export interface RecognitionOptions {
  language: string; // e.g. 'hi-IN', 'en-IN', 'sat'
  continuous?: boolean;
  interimResults?: boolean;
  onResult: (event: RecognitionEvent) => void;
  onError?: (error: Error | string) => void;
  onEnd?: () => void;
}

export type ProcessingMode = 'ON_DEVICE' | 'REMOTE' | 'UNKNOWN';
export type OfflineCapabilityStatus = 'OFFLINE_VERIFIED' | 'OFFLINE_CAPABLE' | 'ONLINE_ONLY' | 'UNSUPPORTED';

export interface VoiceRuntimeStatus {
  provider: string;
  processingMode: ProcessingMode;
  offlineStatus: OfflineCapabilityStatus;
  supportedLanguages: string[];
  confidenceAvailable: boolean;
  measuredLatencyMs?: number;
  details?: string;
}

export interface ISpeechRecognizer {
  getProviderName(): string;
  isSupported(): boolean;
  isOfflineCapable(): boolean;
  getRuntimeStatus(): Promise<VoiceRuntimeStatus> | VoiceRuntimeStatus;
  startListening(options: RecognitionOptions): Promise<void>;
  stopListening(): void;
  abort(): void;
}

export interface VoiceTranslationResult {
  sourceText: string;
  targetText: string;
  sourceLanguage: string;
  targetLanguage: string;
  targetScript: string;
  isOffline: boolean;
  providerName: string;
  latencyMs: number;
  confidence: number;
  romanPhonetic?: string;
  cached: boolean;
}

export interface ITranslationProvider {
  getProviderName(): string;
  isOfflineAvailable(): boolean;
  translate(
    text: string, 
    sourceLang: 'Hindi' | 'English' | 'Santali', 
    targetLang: 'Santali' | 'Hindi' | 'English'
  ): Promise<VoiceTranslationResult>;
}

export interface SynthesisOptions {
  rate?: number;
  pitch?: number;
  audioUrl?: string;
  onStart?: () => void;
  onEnd?: () => void;
  onError?: (err: unknown) => void;
}

export interface SynthesisResult {
  source: VoiceAudioSourceType;
  playing: boolean;
  latencyMs: number;
  providerName: string;
}

export interface ISpeechSynthesizer {
  getProviderName(): string;
  isSupported(): boolean;
  play(text: string, language: string, options?: SynthesisOptions): Promise<SynthesisResult>;
  stop(): void;
}

export interface EvaluationOptions {
  skillId?: string;
  difficulty?: number;
  allowPhoneticTolerance?: boolean;
}

export interface IVoiceEvaluator {
  evaluate(
    recognizedText: string,
    expectedText: string,
    options?: EvaluationOptions
  ): Promise<VoiceEvaluationResult>;
}

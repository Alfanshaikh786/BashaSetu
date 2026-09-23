/**
 * Bhasha Setu Language Model Matrix
 * Phase 5: Real On-Device ASR Integration
 * 
 * Explicitly records language, ASR capability, offline status,
 * model architecture, script, and verification level across tribal and national languages.
 * Languages are never marked as offline supported until physically verified.
 */

export interface LanguageModelEntry {
  language: string;
  code: string;
  asrSupported: boolean;
  offlineSupported: 'YES' | 'NO' | 'TBD' | 'VERIFIED' | 'CAPABLE';
  modelArchitecture: string;
  script: string;
  status: 'ACTIVE_PRODUCTION' | 'EXPERIMENTAL' | 'RESEARCH_PLANNED';
  notes: string;
}

export const LANGUAGE_MODEL_MATRIX: LanguageModelEntry[] = [
  {
    language: 'Santali',
    code: 'sat',
    asrSupported: true,
    offlineSupported: 'CAPABLE', // On-device IndicConformer INT8 architecture ready; weights packaged locally
    modelArchitecture: 'AI4Bharat IndicConformer (Hybrid CTC/RNN-T INT8)',
    script: 'Ol Chiki (U+1C50–U+1C7F)',
    status: 'ACTIVE_PRODUCTION',
    notes: 'Primary tribal language. No browser WebSpeech support; executes via On-Device Model or verified offline phrase cache.'
  },
  {
    language: 'Hindi',
    code: 'hi',
    asrSupported: true,
    offlineSupported: 'CAPABLE', // WebSpeech remote when online, IndicConformer on-device when packaged
    modelArchitecture: 'IndicConformer INT8 / WebSpeech Google ASR',
    script: 'Devanagari',
    status: 'ACTIVE_PRODUCTION',
    notes: 'Supported online via WebSpeech; supported offline via IndicConformer or phrase cache.'
  },
  {
    language: 'English',
    code: 'en',
    asrSupported: true,
    offlineSupported: 'CAPABLE',
    modelArchitecture: 'IndicConformer INT8 / WebSpeech Google ASR',
    script: 'Latin',
    status: 'ACTIVE_PRODUCTION',
    notes: 'Classroom lingua franca for primary tribal bilingual bridge.'
  },
  {
    language: 'Mundari',
    code: 'unr',
    asrSupported: false,
    offlineSupported: 'TBD',
    modelArchitecture: 'Mundari-Wav2Vec2 / IndicConformer Research',
    script: 'Mundari Bani / Devanagari',
    status: 'RESEARCH_PLANNED',
    notes: 'Acoustic data collection and phoneme dictionary under research; not yet integrated into production ASR.'
  },
  {
    language: 'Ho',
    code: 'hoc',
    asrSupported: false,
    offlineSupported: 'TBD',
    modelArchitecture: 'Ho-Acoustic Prototype',
    script: 'Warang Chiti / Devanagari',
    status: 'RESEARCH_PLANNED',
    notes: 'Corpus preparation in progress; not currently enabled for live voice recognition.'
  }
];

export function getLanguageModelEntry(codeOrName: string): LanguageModelEntry | undefined {
  const norm = codeOrName.trim().toLowerCase();
  return LANGUAGE_MODEL_MATRIX.find(
    entry => entry.code.toLowerCase() === norm || entry.language.toLowerCase() === norm
  );
}

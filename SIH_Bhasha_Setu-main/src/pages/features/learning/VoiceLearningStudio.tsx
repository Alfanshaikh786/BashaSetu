/**
 * Bhasha Setu Voice Learning Studio
 * Phase 4: Multilingual Voice Learning Engine for Primary Tribal Education.
 * 
 * Implements 4 Pedagogical Modes:
 * 1. Listen & Understand (Auditory comprehension + meaning selection)
 * 2. Speak & Pronounce (Student speaks -> ASR -> Pedagogical evaluation)
 * 3. Teacher Voice Assistant (Teacher speaks Hindi/English -> Ol Chiki + Audio output)
 * 4. Student Response (Teacher prompt -> Student spoken response -> Evaluated LearningEvent)
 * 
 * Preserves 100% of Bhasha Setu visual styling, color palette (#249144 / #14532d),
 * and integrates directly into the unified cross-activity learning loop.
 */

import React, { useState, useEffect, useMemo, useRef } from 'react';
import { 
  Mic, 
  MicOff, 
  Volume2, 
  Square, 
  RotateCw, 
  CheckCircle2, 
  AlertCircle, 
  Sparkles, 
  BookOpen, 
  ArrowRight, 
  Languages, 
  Clock, 
  Layers, 
  HelpCircle,
  Award
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { 
  VoiceActivity, 
  VoiceActivityMode, 
  VoiceEvaluationResult, 
  CachedClassroomPhrase,
  OFFLINE_CLASSROOM_PHRASES,
  lookupOfflinePhrase,
  getAllOfflineCategories,
  getPhrasesByCategory,
  createVoiceActivity,
  createVoiceLearningEvent,
  WebSpeechRecognizer,
  OfflineTranslationProvider,
  HybridSpeechSynthesizer,
  PedagogicalVoiceEvaluator,
  VoiceRuntimeDiagnostics,
  VoiceDiagnosticReport,
  VoiceProviderSelector
} from '../../../learning/voice';
import { StudentProfile, FLNSkill } from '../../../learning/types';
import { learningRepository } from '../../../learning/indexedDBRepository';
import { updateSkillWithEvent } from '../../../learning/unifiedSkills';

interface VoiceLearningStudioProps {
  activeStudent: StudentProfile;
  onRefreshUnifiedLoop: () => void;
  onOpenWorksheets?: () => void;
}

export const VoiceLearningStudio: React.FC<VoiceLearningStudioProps> = ({
  activeStudent,
  onRefreshUnifiedLoop
}) => {
  // Provider singletons
  const recognizer = useMemo(() => new WebSpeechRecognizer(), []);
  const translator = useMemo(() => new OfflineTranslationProvider(), []);
  const synthesizer = useMemo(() => new HybridSpeechSynthesizer(), []);
  const evaluator = useMemo(() => new PedagogicalVoiceEvaluator(), []);

  // Diagnostics & Offline Safety State
  const [runtimeDiag, setRuntimeDiag] = useState<VoiceDiagnosticReport | null>(null);
  const [audioSourceLabel, setAudioSourceLabel] = useState<string>('Authentic Native Audio');
  const [showTeacherDiagnostics, setShowTeacherDiagnostics] = useState<boolean>(false);
  const [offlineNotice, setOfflineNotice] = useState<string | null>(null);

  useEffect(() => {
    VoiceRuntimeDiagnostics.diagnose('Santali', recognizer).then(setRuntimeDiag);
  }, [recognizer]);

  // Mode state
  const [activeMode, setActiveMode] = useState<VoiceActivityMode>('listen');
  const [selectedCategory, setSelectedCategory] = useState<string>('Greetings');

  // Phrases for selected category
  const categoryPhrases = useMemo(() => {
    return getPhrasesByCategory(selectedCategory as CachedClassroomPhrase['category']);
  }, [selectedCategory]);

  const [phraseIndex, setPhraseIndex] = useState(0);
  const currentPhrase: CachedClassroomPhrase | undefined = categoryPhrases[phraseIndex] || categoryPhrases[0];

  // ==========================================
  // AUDIO & SPEECH PLAYBACK STATE
  // ==========================================
  const [isPlayingAudio, setIsPlayingAudio] = useState(false);
  const [audioSourceNote, setAudioSourceNote] = useState<string>('Local Verified Audio');

  const handlePlayCurrentAudio = async () => {
    if (!currentPhrase) return;
    setIsPlayingAudio(true);
    setAudioSourceNote('Playing audio...');

    const res = await synthesizer.play(currentPhrase.sat, 'Santali', {
      audioUrl: currentPhrase.audioPath,
      onEnd: () => setIsPlayingAudio(false),
      onError: () => setIsPlayingAudio(false)
    });

    if (res.source === 'verified_native') {
      setAudioSourceLabel('🔊 Authentic Native Audio');
      setAudioSourceNote('Authentic native speaker recording');
    } else {
      setAudioSourceLabel('🔊 Synthesized Audio');
      setAudioSourceNote('Browser phonetic synthesis');
    }
  };

  const handleStopAudio = () => {
    synthesizer.stop();
    setIsPlayingAudio(false);
  };

  // ==========================================
  // MODE 1: LISTEN & UNDERSTAND STATE
  // ==========================================
  const [listenSelectedOption, setListenSelectedOption] = useState<string | null>(null);
  const [listenEvaluated, setListenEvaluated] = useState(false);

  // Generate 4 randomized options for Mode 1
  const listenOptions = useMemo(() => {
    if (!currentPhrase) return [];
    const correct = currentPhrase.hi;
    const others = OFFLINE_CLASSROOM_PHRASES
      .filter(p => p.id !== currentPhrase.id)
      .sort(() => 0.5 - Math.random())
      .slice(0, 3)
      .map(p => p.hi);
    return [...others, correct].sort(() => 0.5 - Math.random());
  }, [currentPhrase]);

  const handleSelectListenOption = async (opt: string) => {
    if (listenEvaluated || !currentPhrase) return;
    setListenSelectedOption(opt);
    setListenEvaluated(true);

    const isCorrect = opt === currentPhrase.hi;
    const score = isCorrect ? 100 : 0;

    if (isCorrect) {
      confetti({ particleCount: 35, spread: 50, origin: { y: 0.7 } });
    }

    // Build Voice Activity
    const activity = createVoiceActivity({
      studentId: activeStudent.studentId,
      mode: 'listen',
      sourceLanguage: 'Santali',
      skill: 'listening_comprehension',
      topic: currentPhrase.category,
      difficulty: 1,
      promptText: 'Listen to the Santali audio and identify the meaning',
      expectedText: currentPhrase.sat,
      expectedMeaning: currentPhrase.hi,
      romanPhonetic: currentPhrase.roman
    });

    // Record Event & Update Unified Mastery
    const event = createVoiceLearningEvent(activity, {
      recognizedText: opt,
      expectedText: currentPhrase.hi,
      isCorrect,
      confidence: 1.0,
      wordAccuracy: isCorrect ? 100 : 0,
      score,
      feedback: isCorrect ? 'Correct meaning identified!' : 'Incorrect meaning chosen.',
      evaluationMethod: 'normalized_token_match',
      latencyMs: { asrLatencyMs: 0, evaluationLatencyMs: 10, totalLatencyMs: 10 }
    }, activeStudent.studentId);

    await learningRepository.recordLearningEvent(event);
    const currentSkill = await learningRepository.getUnifiedSkill(activeStudent.studentId, 'listening_comprehension');
    if (currentSkill) {
      const updated = updateSkillWithEvent(currentSkill, event);
      await learningRepository.saveUnifiedSkill(updated);
    }
    onRefreshUnifiedLoop();
  };

  const handleNextListenPhrase = () => {
    setListenSelectedOption(null);
    setListenEvaluated(false);
    setPhraseIndex(prev => (prev + 1) % categoryPhrases.length);
  };

  // ==========================================
  // MODE 2: SPEAK & PRONOUNCE STATE
  // ==========================================
  const [isRecording, setIsRecording] = useState(false);
  const [spokenTranscript, setSpokenTranscript] = useState('');
  const [evaluationResult, setEvaluationResult] = useState<VoiceEvaluationResult | null>(null);
  const [showPhoneticGuide, setShowPhoneticGuide] = useState(true);

  const handleStartRecording = async () => {
    if (!currentPhrase) return;
    setSpokenTranscript('');
    setEvaluationResult(null);
    setOfflineNotice(null);

    const selection = VoiceProviderSelector.selectProvider({
      requireOffline: false,
      language: 'Santali',
      allowOnlineFallback: true
    });

    if (selection.mode === 'OFFLINE_PHRASE_FALLBACK' && typeof window !== 'undefined' && !navigator.onLine) {
      setOfflineNotice('Offline speech recognition is unavailable on this device for Santali. Use verified phrase practice.');
      return;
    }

    setIsRecording(true);

    await recognizer.startListening({
      language: 'hi-IN', // Browser ASR bridge
      interimResults: true,
      onResult: (event) => {
        setSpokenTranscript(event.transcript);
        if (event.isFinal) {
          setIsRecording(false);
          handleEvaluateSpeech(event.transcript);
        }
      },
      onError: (err) => {
        setIsRecording(false);
        const errMsg = typeof err === 'string' ? err : (err as Error).message;
        if (errMsg && errMsg.includes('Offline speech recognition is unavailable')) {
          setOfflineNotice(errMsg);
        }
        console.warn('[VoiceStudio] ASR error:', err);
      },
      onEnd: () => {
        setIsRecording(false);
      }
    });
  };

  const handleStopRecording = () => {
    recognizer.stopListening();
    setIsRecording(false);
    if (spokenTranscript) {
      handleEvaluateSpeech(spokenTranscript);
    }
  };

  const handleEvaluateSpeech = async (transcriptToEval: string) => {
    if (!currentPhrase) return;
    // Compare spoken response with expected target (or Roman phonetic bridge)
    const result = await evaluator.evaluate(transcriptToEval, currentPhrase.roman);
    setEvaluationResult(result);

    if (result.isCorrect) {
      confetti({ particleCount: 40, spread: 60, origin: { y: 0.7 } });
    }

    // Build Voice Activity
    const activity = createVoiceActivity({
      studentId: activeStudent.studentId,
      mode: 'speak',
      sourceLanguage: 'Hindi',
      skill: 'pronunciation',
      topic: currentPhrase.category,
      difficulty: 1,
      promptText: `Speak the Santali phrase for: "${currentPhrase.hi}"`,
      expectedText: currentPhrase.sat,
      expectedMeaning: currentPhrase.hi,
      romanPhonetic: currentPhrase.roman
    });

    const event = createVoiceLearningEvent(activity, result, activeStudent.studentId);
    await learningRepository.recordLearningEvent(event);

    const currentSkill = await learningRepository.getUnifiedSkill(activeStudent.studentId, 'pronunciation');
    if (currentSkill) {
      const updated = updateSkillWithEvent(currentSkill, event);
      await learningRepository.saveUnifiedSkill(updated);
    }
    onRefreshUnifiedLoop();
  };

  // ==========================================
  // MODE 3: TEACHER VOICE ASSISTANT STATE
  // ==========================================
  const [teacherInputLang, setTeacherInputLang] = useState<'Hindi' | 'English'>('Hindi');
  const [teacherSpokenText, setTeacherSpokenText] = useState('');
  const [teacherTranslation, setTeacherTranslation] = useState<{
    targetText: string;
    romanPhonetic?: string;
    latencyMs: number;
    source: string;
  } | null>(null);

  const handleTeacherRecord = async () => {
    setTeacherSpokenText('');
    setTeacherTranslation(null);
    setIsRecording(true);

    const langCode = teacherInputLang === 'Hindi' ? 'hi-IN' : 'en-IN';
    await recognizer.startListening({
      language: langCode,
      interimResults: true,
      onResult: async (event) => {
        setTeacherSpokenText(event.transcript);
        if (event.isFinal) {
          setIsRecording(false);
          // Perform zero-latency offline translation
          const res = await translator.translate(event.transcript, teacherInputLang, 'Santali');
          setTeacherTranslation({
            targetText: res.targetText,
            romanPhonetic: res.romanPhonetic,
            latencyMs: res.latencyMs,
            source: res.providerName
          });
          // Auto-play translated speech
          synthesizer.play(res.targetText, 'Santali');
        }
      },
      onError: (err) => {
        setIsRecording(false);
        console.warn('[TeacherAssistant] ASR error:', err);
      },
      onEnd: () => setIsRecording(false)
    });
  };

  // ==========================================
  // MODE 4: STUDENT RESPONSE STATE
  // ==========================================
  const [studentResponseTranscript, setStudentResponseTranscript] = useState('');
  const [studentResponseResult, setStudentResponseResult] = useState<VoiceEvaluationResult | null>(null);

  const handleStudentResponseRecord = async () => {
    if (!currentPhrase) return;
    setStudentResponseTranscript('');
    setStudentResponseResult(null);
    setOfflineNotice(null);

    const selection = VoiceProviderSelector.selectProvider({
      requireOffline: false,
      language: 'Santali',
      allowOnlineFallback: true
    });

    if (selection.mode === 'OFFLINE_PHRASE_FALLBACK' && typeof window !== 'undefined' && !navigator.onLine) {
      setOfflineNotice('Offline speech recognition is unavailable on this device for Santali. Use verified phrase practice.');
      return;
    }

    setIsRecording(true);

    await recognizer.startListening({
      language: 'hi-IN',
      interimResults: true,
      onResult: async (recEvent) => {
        setStudentResponseTranscript(recEvent.transcript);
        if (recEvent.isFinal) {
          setIsRecording(false);
          const evalRes = await evaluator.evaluate(recEvent.transcript, currentPhrase.roman);
          setStudentResponseResult(evalRes);

          if (evalRes.isCorrect) {
            confetti({ particleCount: 35, spread: 55, origin: { y: 0.7 } });
          }

          // Emit LearningEvent
          const activity = createVoiceActivity({
            studentId: activeStudent.studentId,
            mode: 'student_response',
            sourceLanguage: 'Hindi',
            skill: 'spoken_sentence',
            topic: currentPhrase.category,
            difficulty: 1,
            promptText: `Teacher Prompt: "${currentPhrase.hi}"`,
            expectedText: currentPhrase.sat,
            expectedMeaning: currentPhrase.en,
            romanPhonetic: currentPhrase.roman
          });

          const voiceEv = createVoiceLearningEvent(activity, evalRes, activeStudent.studentId);
          await learningRepository.recordLearningEvent(voiceEv);

          const currentSkill = await learningRepository.getUnifiedSkill(activeStudent.studentId, 'spoken_sentence');
          if (currentSkill) {
            const updated = updateSkillWithEvent(currentSkill, voiceEv);
            await learningRepository.saveUnifiedSkill(updated);
          }
          onRefreshUnifiedLoop();
        }
      },
      onError: () => setIsRecording(false),
      onEnd: () => setIsRecording(false)
    });
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      recognizer.abort();
      synthesizer.stop();
    };
  }, [recognizer, synthesizer]);

  return (
    <div className="space-y-8 animate-in fade-in duration-200">
      
      {/* ========================================================================= */}
      {/* 1. HEADER & PEDAGOGICAL MODE SWITCHER                                    */}
      {/* ========================================================================= */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div className="space-y-1.5">
            <div className="flex flex-wrap items-center gap-2">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-xs font-bold text-[#14532d]">
                <Mic className="w-3.5 h-3.5 text-[#249144]" />
                <span>
                  {typeof window !== 'undefined' && !navigator.onLine
                    ? 'Verified Local Phrase Cache • 100% Offline'
                    : 'WebSpeech ASR • Remote Cloud Engine'}
                </span>
              </div>
              <button
                onClick={() => setShowTeacherDiagnostics(prev => !prev)}
                className="text-[11px] font-bold text-slate-500 hover:text-slate-800 bg-slate-100 hover:bg-slate-200 px-2.5 py-1 rounded-full border border-slate-200 transition cursor-pointer"
                title="Toggle Voice Diagnostics"
              >
                {showTeacherDiagnostics ? 'Hide Diagnostics' : 'Voice Diagnostics'}
              </button>
            </div>

            {/* Diagnostics Panel for Teachers & Evaluators */}
            {showTeacherDiagnostics && runtimeDiag && (
              <div className="p-3.5 bg-slate-900 text-slate-200 rounded-2xl text-xs font-mono space-y-1 animate-in fade-in">
                <div className="text-emerald-400 font-bold uppercase tracking-wider text-[10px]">Hardware & Voice Runtime Diagnostics</div>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 pt-1 text-[11px]">
                  <div>ASR: <strong className="text-white">{runtimeDiag.asrProvider}</strong></div>
                  <div>Processing: <strong className="text-white">{runtimeDiag.processing}</strong></div>
                  <div>Internet: <strong className="text-white">{runtimeDiag.internet}</strong></div>
                  <div>Language: <strong className="text-white">{runtimeDiag.language}</strong></div>
                  <div>Offline ASR: <strong className="text-white">{runtimeDiag.offlineAsr}</strong></div>
                  <div>Language Pack: <strong className="text-white">{runtimeDiag.localLanguagePack}</strong></div>
                  <div>Microphone: <strong className="text-white">{runtimeDiag.microphone}</strong></div>
                  <div>RAM Heap: <strong className="text-white">{runtimeDiag.memoryUsageMb ? `${runtimeDiag.memoryUsageMb} MB` : 'NOT MEASURED'}</strong></div>
                  <div>Model Target: <strong className="text-white">IndicConformer INT8 (~38.4 MB)</strong></div>
                  <div>Sample Rate: <strong className="text-white">16 kHz Mono PCM</strong></div>
                </div>
                {runtimeDiag.notes.length > 0 && (
                  <div className="text-[10px] text-amber-300 pt-1 border-t border-slate-800">
                    Note: {runtimeDiag.notes[0]}
                  </div>
                )}
              </div>
            )}

            {offlineNotice && (
              <div className="p-3 rounded-2xl bg-amber-50 border border-amber-200 text-amber-900 text-xs font-semibold flex items-center justify-between gap-3 animate-in fade-in">
                <div className="flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-amber-600 shrink-0" />
                  <span>{offlineNotice}</span>
                </div>
                <button
                  onClick={() => setOfflineNotice(null)}
                  className="px-2.5 py-0.5 bg-amber-200 hover:bg-amber-300 rounded-lg text-xs font-bold transition cursor-pointer"
                >
                  Dismiss
                </button>
              </div>
            )}
            <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 domine-bold">
              Voice Learning & Oral Fluency Studio
            </h2>
            <p className="text-slate-600 text-sm max-w-2xl">
              Multimodal spoken exercises with real-time speech evaluation, authentic tribal pronunciation, and classroom teacher assistance in Santali (Ol Chiki).
            </p>
          </div>

          <div className="flex items-center gap-2 text-xs font-semibold text-slate-500 bg-slate-50 px-3 py-2 rounded-2xl border border-slate-200">
            <Clock className="w-4 h-4 text-emerald-600" />
            <span>Target Latency: &le; 3s Cycle</span>
          </div>
        </div>

        {/* 4 Pedagogical Modes Tabs */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2 pt-2">
          <button
            onClick={() => setActiveMode('listen')}
            className={`py-3 px-4 rounded-2xl text-xs sm:text-sm font-bold border transition flex items-center justify-center gap-2 cursor-pointer ${
              activeMode === 'listen'
                ? 'bg-[#249144] text-white border-[#249144] shadow-xs'
                : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
            }`}
          >
            <Volume2 className="w-4 h-4" />
            <span>1. Listen & Understand</span>
          </button>

          <button
            onClick={() => setActiveMode('speak')}
            className={`py-3 px-4 rounded-2xl text-xs sm:text-sm font-bold border transition flex items-center justify-center gap-2 cursor-pointer ${
              activeMode === 'speak'
                ? 'bg-[#249144] text-white border-[#249144] shadow-xs'
                : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
            }`}
          >
            <Mic className="w-4 h-4" />
            <span>2. Speak & Pronounce</span>
          </button>

          <button
            onClick={() => setActiveMode('teacher_translate')}
            className={`py-3 px-4 rounded-2xl text-xs sm:text-sm font-bold border transition flex items-center justify-center gap-2 cursor-pointer ${
              activeMode === 'teacher_translate'
                ? 'bg-[#249144] text-white border-[#249144] shadow-xs'
                : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
            }`}
          >
            <Languages className="w-4 h-4" />
            <span>3. Teacher Assistant</span>
          </button>

          <button
            onClick={() => setActiveMode('student_response')}
            className={`py-3 px-4 rounded-2xl text-xs sm:text-sm font-bold border transition flex items-center justify-center gap-2 cursor-pointer ${
              activeMode === 'student_response'
                ? 'bg-[#249144] text-white border-[#249144] shadow-xs'
                : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
            }`}
          >
            <Sparkles className="w-4 h-4" />
            <span>4. Student Response</span>
          </button>
        </div>
      </div>

      {/* ========================================================================= */}
      {/* 2. CATEGORY SELECTOR (10 Classroom Themes)                                */}
      {/* ========================================================================= */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-5 space-y-3">
        <div className="flex items-center justify-between text-xs font-bold text-slate-500 uppercase tracking-wider">
          <span>Curriculum Theme ({categoryPhrases.length} Verified Phrases)</span>
          <span className="text-[#14532d] lowercase font-normal text-xs">
            Ol Chiki Unicode (U+1C50–U+1C7F)
          </span>
        </div>

        <div className="flex flex-wrap gap-2">
          {getAllOfflineCategories().map((cat) => (
            <button
              key={cat}
              onClick={() => {
                setSelectedCategory(cat);
                setPhraseIndex(0);
                setListenSelectedOption(null);
                setListenEvaluated(false);
                setEvaluationResult(null);
                setSpokenTranscript('');
              }}
              className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition border cursor-pointer ${
                selectedCategory === cat
                  ? 'bg-emerald-100 text-[#14532d] border-emerald-300 shadow-2xs'
                  : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* ========================================================================= */}
      {/* 3. ACTIVE MODE INTERFACE                                                  */}
      {/* ========================================================================= */}

      {/* ---------------------------------------------------- */}
      {/* MODE 1: LISTEN & UNDERSTAND                         */}
      {/* ---------------------------------------------------- */}
      {activeMode === 'listen' && currentPhrase && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 sm:p-10 space-y-8 text-center max-w-3xl mx-auto">
          <div className="space-y-2">
            <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-3 py-1 rounded-full uppercase tracking-wider">
              Mode 1: Auditory Discrimination & Comprehension
            </span>
            <h3 className="text-xl sm:text-2xl font-bold text-slate-900 domine-bold">
              Listen and Select the Correct Meaning
            </h3>
            <p className="text-xs text-slate-500">
              Tap the speaker button to hear the authentic Santali pronunciation, then select the matching Hindi/English phrase.
            </p>
          </div>

          {/* Central Audio Playback Bubble */}
          <div className="p-8 rounded-3xl bg-gradient-to-br from-emerald-50 via-white to-green-50/40 border border-emerald-200 space-y-4 max-w-md mx-auto">
            <div className="flex items-center justify-center">
              <button
                onClick={isPlayingAudio ? handleStopAudio : handlePlayCurrentAudio}
                className={`w-20 h-20 rounded-full flex items-center justify-center text-white shadow-lg transition active:scale-95 cursor-pointer ${
                  isPlayingAudio ? 'bg-amber-500 animate-pulse' : 'bg-[#249144] hover:bg-[#1a7536]'
                }`}
                title="Play Spoken Audio"
              >
                {isPlayingAudio ? <Square className="w-8 h-8" /> : <Volume2 className="w-8 h-8" />}
              </button>
            </div>

            <div className="space-y-1">
              <p className="text-3xl font-extrabold text-slate-900 font-mono tracking-wide">
                {currentPhrase.sat}
              </p>
              <p className="text-xs text-slate-500 italic">
                Phonetic Guide: [{currentPhrase.roman}]
              </p>
            </div>

            <p className="text-[11px] font-semibold text-emerald-800">
              {audioSourceNote}
            </p>
          </div>

          {/* Options Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 max-w-xl mx-auto text-left">
            {listenOptions.map((opt, idx) => {
              const isSelected = listenSelectedOption === opt;
              const isCorrectOpt = opt === currentPhrase.hi;
              let btnStyle = 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-800';

              if (listenEvaluated) {
                if (isCorrectOpt) {
                  btnStyle = 'bg-emerald-50 border-emerald-400 text-emerald-900 font-bold';
                } else if (isSelected && !isCorrectOpt) {
                  btnStyle = 'bg-rose-50 border-rose-300 text-rose-800';
                }
              }

              return (
                <button
                  key={idx}
                  onClick={() => handleSelectListenOption(opt)}
                  disabled={listenEvaluated}
                  className={`p-4 rounded-2xl border transition text-sm flex items-center justify-between cursor-pointer ${btnStyle}`}
                >
                  <span>{opt}</span>
                  {listenEvaluated && isCorrectOpt && <CheckCircle2 className="w-4 h-4 text-emerald-600" />}
                </button>
              );
            })}
          </div>

          {/* Next Button */}
          {listenEvaluated && (
            <div className="pt-2 animate-in fade-in">
              <button
                onClick={handleNextListenPhrase}
                className="px-6 py-3 rounded-2xl bg-[#249144] hover:bg-[#1a7536] text-white text-xs sm:text-sm font-bold inline-flex items-center gap-2 shadow-md transition active:scale-95 cursor-pointer"
              >
                <span>Next Spoken Phrase</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          )}
        </div>
      )}

      {/* ---------------------------------------------------- */}
      {/* MODE 2: SPEAK & PRONOUNCE                           */}
      {/* ---------------------------------------------------- */}
      {activeMode === 'speak' && currentPhrase && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 sm:p-10 space-y-8 text-center max-w-3xl mx-auto">
          <div className="space-y-2">
            <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-3 py-1 rounded-full uppercase tracking-wider">
              Mode 2: Oral Articulation & Pronunciation
            </span>
            <h3 className="text-xl sm:text-2xl font-bold text-slate-900 domine-bold">
              Speak the Santali Phrase Aloud
            </h3>
            <p className="text-xs text-slate-500">
              Read the target phrase, tap the microphone, speak clearly into your device, and receive instant pedagogical feedback.
            </p>
          </div>

          {/* Target Prompt Display */}
          <div className="p-8 rounded-3xl bg-slate-50 border border-slate-200 space-y-3 max-w-md mx-auto">
            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Target Phrase (Ol Chiki)</span>
            <h2 className="text-4xl font-extrabold text-slate-900 font-mono tracking-wide">
              {currentPhrase.sat}
            </h2>
            <p className="text-sm font-bold text-slate-700">
              Hindi: "{currentPhrase.hi}" • English: "{currentPhrase.en}"
            </p>

            {showPhoneticGuide && (
              <div className="pt-1 text-xs text-[#14532d] font-semibold bg-emerald-50/70 p-2 rounded-xl border border-emerald-100">
                Phonetic Guide: <strong>{currentPhrase.roman}</strong>
              </div>
            )}

            <button
              onClick={handlePlayCurrentAudio}
              className="text-xs font-bold text-[#249144] hover:underline flex items-center justify-center gap-1 mx-auto pt-1 cursor-pointer"
            >
              <Volume2 className="w-3.5 h-3.5" />
              <span>{isPlayingAudio ? 'Playing...' : audioSourceLabel}</span>
            </button>
          </div>

          {/* Microphone Control Button */}
          <div className="space-y-3">
            <button
              onClick={isRecording ? handleStopRecording : handleStartRecording}
              className={`w-24 h-24 rounded-full flex items-center justify-center text-white shadow-xl mx-auto transition active:scale-95 cursor-pointer ${
                isRecording 
                  ? 'bg-rose-500 animate-pulse ring-8 ring-rose-100' 
                  : 'bg-[#249144] hover:bg-[#1a7536] ring-8 ring-emerald-50'
              }`}
              title={isRecording ? 'Stop Speaking' : 'Start Speaking'}
            >
              {isRecording ? <Square className="w-10 h-10" /> : <Mic className="w-10 h-10" />}
            </button>

            <p className="text-xs font-semibold text-slate-600">
              {isRecording ? 'Listening... Speak now into your device' : 'Tap to Speak'}
            </p>
          </div>

          {/* Real-time Recognition Box */}
          {spokenTranscript && (
            <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 max-w-md mx-auto text-left space-y-1">
              <span className="text-[10px] font-bold text-slate-400 uppercase">Recognized Utterance:</span>
              <p className="text-sm font-bold text-slate-900 font-mono">{spokenTranscript}</p>
            </div>
          )}

          {/* Evaluation Result Feedback */}
          {evaluationResult && (
            <div className={`p-6 rounded-2xl border max-w-md mx-auto text-left space-y-3 animate-in fade-in ${
              evaluationResult.isCorrect ? 'bg-emerald-50/70 border-emerald-300' : 'bg-amber-50/70 border-amber-300'
            }`}>
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold uppercase tracking-wider text-slate-700">
                  Pronunciation Diagnostic
                </span>
                <span className={`text-xs font-extrabold px-2.5 py-0.5 rounded-full ${
                  evaluationResult.isCorrect ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                }`}>
                  Score: {evaluationResult.score}%
                </span>
              </div>

              {/* Student View (Friendly & Constructive) */}
              <p className="text-xs font-semibold text-slate-800">
                {evaluationResult.feedback}
              </p>

              {/* Teacher Diagnostic View */}
              {evaluationResult.diagnostics?.teacherSummary && (
                <div className="p-2.5 rounded-xl bg-white/80 border border-slate-200/80 text-[11px] text-slate-600 space-y-1">
                  <div className="font-bold text-[10px] text-slate-500 uppercase tracking-wider">Teacher Diagnostic:</div>
                  <div>{evaluationResult.diagnostics.teacherSummary}</div>
                </div>
              )}

              <div className="grid grid-cols-2 gap-2 text-[11px] text-slate-600 pt-2 border-t border-slate-200/60">
                <div>Word Accuracy: <strong>{evaluationResult.wordAccuracy}%</strong></div>
                <div>Confidence: <strong>{Math.round(evaluationResult.confidence * 100)}%</strong></div>
              </div>
            </div>
          )}

          {/* Navigation */}
          <div className="flex items-center justify-center gap-3 pt-2">
            <button
              onClick={() => {
                setEvaluationResult(null);
                setSpokenTranscript('');
                setPhraseIndex(prev => (prev + 1) % categoryPhrases.length);
              }}
              className="px-6 py-2.5 rounded-2xl bg-[#249144] hover:bg-[#1a7536] text-white text-xs sm:text-sm font-bold flex items-center gap-2 shadow-xs transition active:scale-95 cursor-pointer"
            >
              <span>Next Practice Phrase</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* ---------------------------------------------------- */}
      {/* MODE 3: TEACHER VOICE ASSISTANT                     */}
      {/* ---------------------------------------------------- */}
      {activeMode === 'teacher_translate' && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 sm:p-10 space-y-8 max-w-3xl mx-auto">
          <div className="space-y-2 text-center">
            <span className="text-xs font-bold text-blue-800 bg-blue-50 px-3 py-1 rounded-full uppercase tracking-wider">
              Mode 3: Teacher Spoken Instruction Assistant
            </span>
            <h3 className="text-xl sm:text-2xl font-bold text-slate-900 domine-bold">
              Speak in Hindi or English &rarr; Converts to Santali (Ol Chiki)
            </h3>
            <p className="text-xs text-slate-500">
              Designed for migrant educators to communicate routine classroom instructions immediately in the learners' mother tongue.
            </p>
          </div>

          {/* Language Selector */}
          <div className="flex justify-center gap-2">
            <button
              onClick={() => setTeacherInputLang('Hindi')}
              className={`px-4 py-2 rounded-xl text-xs font-bold border transition cursor-pointer ${
                teacherInputLang === 'Hindi'
                  ? 'bg-blue-600 text-white border-blue-600 shadow-xs'
                  : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
              }`}
            >
              Spoken Input: Hindi (हिन्दी)
            </button>
            <button
              onClick={() => setTeacherInputLang('English')}
              className={`px-4 py-2 rounded-xl text-xs font-bold border transition cursor-pointer ${
                teacherInputLang === 'English'
                  ? 'bg-blue-600 text-white border-blue-600 shadow-xs'
                  : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
              }`}
            >
              Spoken Input: English
            </button>
          </div>

          {/* Teacher Mic Trigger */}
          <div className="text-center space-y-3">
            <button
              onClick={isRecording ? handleStopRecording : handleTeacherRecord}
              className={`w-24 h-24 rounded-full flex items-center justify-center text-white shadow-xl mx-auto transition active:scale-95 cursor-pointer ${
                isRecording 
                  ? 'bg-rose-500 animate-pulse ring-8 ring-rose-100' 
                  : 'bg-blue-600 hover:bg-blue-700 ring-8 ring-blue-50'
              }`}
              title={isRecording ? 'Stop Speaking' : 'Press to Speak Instruction'}
            >
              {isRecording ? <Square className="w-10 h-10" /> : <Mic className="w-10 h-10" />}
            </button>

            <p className="text-xs font-semibold text-slate-600">
              {isRecording ? 'Teacher Speaking... Say e.g. "अपनी किताब खोलो" or "बैठ जाओ"' : 'Press Mic to Speak Classroom Instruction'}
            </p>
          </div>

          {/* Recognized Input */}
          {teacherSpokenText && (
            <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 space-y-1 text-left">
              <span className="text-[10px] font-bold text-slate-400 uppercase">Teacher Spoke ({teacherInputLang}):</span>
              <p className="text-base font-bold text-slate-900">{teacherSpokenText}</p>
            </div>
          )}

          {/* Output Card */}
          {teacherTranslation && (
            <div className="p-6 rounded-3xl bg-gradient-to-br from-emerald-50/60 via-white to-green-50/30 border border-emerald-200 space-y-4 text-left animate-in fade-in">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider">
                  Santali Translation (Ol Chiki Script)
                </span>
                <span className="text-[11px] font-bold text-slate-400 bg-white px-2 py-0.5 rounded-full border border-slate-200">
                  Latency: {teacherTranslation.latencyMs}ms • {teacherTranslation.source}
                </span>
              </div>

              <div className="space-y-1">
                <h3 className="text-3xl font-extrabold text-slate-900 font-mono tracking-wide">
                  {teacherTranslation.targetText}
                </h3>
                {teacherTranslation.romanPhonetic && (
                  <p className="text-xs text-slate-500 italic">
                    Phonetic Guide: [{teacherTranslation.romanPhonetic}]
                  </p>
                )}
              </div>

              <div className="flex items-center gap-3 pt-2">
                <button
                  onClick={() => synthesizer.play(teacherTranslation.targetText, 'Santali')}
                  className="px-5 py-2.5 rounded-xl bg-[#249144] hover:bg-[#1a7536] text-white text-xs font-bold flex items-center gap-2 shadow-xs transition active:scale-95 cursor-pointer"
                >
                  <Volume2 className="w-4 h-4" />
                  <span>Replay Santali Audio</span>
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ---------------------------------------------------- */}
      {/* MODE 4: STUDENT RESPONSE                            */}
      {/* ---------------------------------------------------- */}
      {activeMode === 'student_response' && currentPhrase && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 sm:p-10 space-y-8 max-w-3xl mx-auto text-center">
          <div className="space-y-2">
            <span className="text-xs font-bold text-purple-800 bg-purple-50 px-3 py-1 rounded-full uppercase tracking-wider">
              Mode 4: Teacher Prompt &rarr; Student Spoken Response
            </span>
            <h3 className="text-xl sm:text-2xl font-bold text-slate-900 domine-bold">
              Classroom Dialogue & Response Practice
            </h3>
            <p className="text-xs text-slate-500">
              Teacher gives a verbal or written prompt. The student speaks the reply in Santali, evaluated by the system.
            </p>
          </div>

          {/* Prompt Dialogue Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-left max-w-xl mx-auto">
            {/* Teacher Prompt */}
            <div className="p-5 rounded-2xl bg-blue-50/60 border border-blue-200 space-y-2">
              <span className="text-[10px] font-bold text-blue-700 uppercase tracking-wider">Teacher Prompt (Hindi/English)</span>
              <p className="text-base font-bold text-slate-900">"{currentPhrase.hi}"</p>
              <p className="text-xs text-slate-500">English: "{currentPhrase.en}"</p>
            </div>

            {/* Expected Student Response */}
            <div className="p-5 rounded-2xl bg-emerald-50/60 border border-emerald-200 space-y-2">
              <span className="text-[10px] font-bold text-emerald-700 uppercase tracking-wider">Expected Student Response</span>
              <p className="text-xl font-bold text-slate-900 font-mono">{currentPhrase.sat}</p>
              <p className="text-xs text-slate-500 italic">[{currentPhrase.roman}]</p>
            </div>
          </div>

          {/* Student Mic Trigger */}
          <div className="space-y-3">
            <button
              onClick={isRecording ? handleStopRecording : handleStudentResponseRecord}
              className={`w-24 h-24 rounded-full flex items-center justify-center text-white shadow-xl mx-auto transition active:scale-95 cursor-pointer ${
                isRecording 
                  ? 'bg-rose-500 animate-pulse ring-8 ring-rose-100' 
                  : 'bg-purple-600 hover:bg-purple-700 ring-8 ring-purple-50'
              }`}
              title={isRecording ? 'Stop Recording' : 'Student Speaks Response'}
            >
              {isRecording ? <Square className="w-10 h-10" /> : <Mic className="w-10 h-10" />}
            </button>

            <p className="text-xs font-semibold text-slate-600">
              {isRecording ? 'Recording student answer...' : 'Tap for Student to Speak Answer'}
            </p>
          </div>

          {/* Student Transcript */}
          {studentResponseTranscript && (
            <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 max-w-md mx-auto text-left space-y-1">
              <span className="text-[10px] font-bold text-slate-400 uppercase">Student Utterance:</span>
              <p className="text-sm font-bold text-slate-900 font-mono">{studentResponseTranscript}</p>
            </div>
          )}

          {/* Evaluation Result */}
          {studentResponseResult && (
            <div className={`p-6 rounded-2xl border max-w-md mx-auto text-left space-y-3 animate-in fade-in ${
              studentResponseResult.isCorrect ? 'bg-emerald-50/70 border-emerald-300' : 'bg-amber-50/70 border-amber-300'
            }`}>
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold uppercase tracking-wider text-slate-700">
                  Dialogue Evaluation
                </span>
                <span className={`text-xs font-extrabold px-2.5 py-0.5 rounded-full ${
                  studentResponseResult.isCorrect ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                }`}>
                  {studentResponseResult.isCorrect ? 'Correct Response' : 'Needs Practice'} ({studentResponseResult.score}%)
                </span>
              </div>

              <p className="text-xs font-semibold text-slate-800">
                {studentResponseResult.feedback}
              </p>
            </div>
          )}

          {/* Next Button */}
          <div className="pt-2">
            <button
              onClick={() => {
                setStudentResponseResult(null);
                setStudentResponseTranscript('');
                setPhraseIndex(prev => (prev + 1) % categoryPhrases.length);
              }}
              className="px-6 py-2.5 rounded-2xl bg-purple-600 hover:bg-purple-700 text-white text-xs sm:text-sm font-bold inline-flex items-center gap-2 shadow-xs transition active:scale-95 cursor-pointer"
            >
              <span>Next Dialogue Prompt</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

    </div>
  );
};

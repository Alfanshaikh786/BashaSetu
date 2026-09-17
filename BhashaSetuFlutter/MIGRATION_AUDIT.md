# 🔍 BHASHA SETU — React to Flutter Migration Audit (Phase 0)

> **Document Type**: Full Project Audit & Architecture Mapping  
> **Source Repository**: `D:/BASHA SETU/SIH_Bhasha_Setu-main` (React 18 + Vite + TypeScript PWA)  
> **Target Repository**: `D:/BASHA SETU/BhashaSetuFlutter` (Flutter + Dart + Android)  
> **Status**: Completed & Verified  

---

## 1. Executive Migration Overview

The purpose of this audit is to conduct an exhaustive, component-by-component, service-by-service, and data-by-data inspection of the existing **Bhasha Setu** codebase prior to implementing the native Android version in Flutter.

### Core Principle
**Zero Product Redesign. Zero Feature Removal.**  
The Flutter Android application is a faithful, production-grade migration of the existing React platform. All existing features, datasets, linguistic rules, state machines, offline capabilities, safety mechanisms, and color tokens are preserved.

---

## 2. Feature Inventory & Mapping

| Feature | React Source Component | React Source Services | Flutter Replacement Target | Status |
|---|---|---|---|---|
| **Text-to-Text Translation** | `src/pages/features/TextToTextPage.tsx` | `translationService.ts`, `sqliteService.ts`, `languageService.ts` | `lib/features/translation/screens/text_to_text_screen.dart` | Planned |
| **Neural Document OCR** | `src/pages/features/OCRPage.tsx` | `ocrService.ts`, `tesseractWorkerPool.ts` | `lib/features/ocr/screens/ocr_screen.dart` | Planned |
| **Speech-to-Text (ASR)** | `src/pages/features/SpeechToTextPage.tsx` | `asrService.ts`, `audioQualityService.ts` | `lib/features/speech_to_text/screens/stt_screen.dart` | Planned |
| **Voice-to-Voice (S2S)** | `src/pages/features/SpeechToSpeechPage.tsx` | `s2s/turnController.ts`, `s2s/autoStopController.ts`, `s2s/ttsEngine.ts` | `lib/features/speech_to_speech/screens/s2s_screen.dart` | Planned |
| **Text-to-Speech (TTS)** | `src/pages/features/TextToSpeechPage.tsx` | `tts/voiceRouter.ts`, `tts/pronunciation/` | `lib/features/text_to_speech/screens/tts_screen.dart` | Planned |
| **Video Subtitle Studio** | `src/pages/features/VideoSubtitlePage.tsx` | `videoSubtitleService.ts`, `subtitleUtils.ts` | `lib/features/video_subtitle/screens/video_subtitle_screen.dart` | Planned |
| **Learning Studio: Flashcards** | `src/pages/features/LearningStudioPage.tsx` | `santaliDataset.ts`, `translationService.ts` | `lib/features/learning_studio/screens/learning_studio_screen.dart` | Planned |
| **Learning Studio: Worksheets** | `src/pages/features/LearningStudioPage.tsx` | `santaliDataset.ts` | `lib/features/learning_studio/widgets/worksheet_tab.dart` | Planned |
| **Learning Studio: Assessment** | `src/pages/features/LearningStudioPage.tsx` | `santaliDataset.ts` | `lib/features/learning_studio/widgets/assessment_tab.dart` | Planned |
| **Field Mode** | `src/pages/features/FieldModePage.tsx` | `asrService.ts`, `audioQualityService.ts`, `s2s/` | `lib/features/field_mode/screens/field_mode_screen.dart` | Planned |
| **Teacher Mode** | `src/pages/features/TeacherModePage.tsx` | `asrService.ts`, `santaliDataset.ts` | `lib/features/teacher_mode/screens/teacher_mode_screen.dart` | Planned |
| **Emergency Mode** | `src/pages/features/EmergencyModePage.tsx` | `translationService.ts` | `lib/features/emergency_mode/screens/emergency_mode_screen.dart` | Planned |
| **Multilingual Dictionary** | `src/pages/resources/DictionaryPage.tsx` | `dictionaryData.ts`, `sqliteService.ts` | `lib/features/dictionary/screens/dictionary_screen.dart` | Planned |
| **Verified Knowledge Base** | `src/pages/resources/KnowledgeBasePage.tsx` | `knowledgeBaseData.ts`, `sqliteService.ts` | `lib/features/knowledge_base/screens/knowledge_base_screen.dart` | Planned |
| **Homepage & Hero** | `src/pages/HomePage.tsx`, `HeroSection.tsx` | `InteractiveHeroPhone.tsx`, `FeaturesSection.tsx` | `lib/features/home/screens/home_screen.dart` | Planned |
| **About Page** | `src/pages/AboutPage.tsx` | Static content & team info | `lib/features/about/screens/about_screen.dart` | Planned |
| **Contact Page** | `src/pages/ContactPage.tsx` | Static contact & feedback | `lib/features/contact/screens/contact_screen.dart` | Planned |
| **Login & Auth** | `src/pages/LoginPage.tsx` | `authService.ts` | `lib/features/auth/screens/login_screen.dart` | Planned |
| **Privacy Policy** | `src/pages/PrivacyPolicyPage.tsx` | Static legal & ethical statement | `lib/features/privacy/screens/privacy_screen.dart` | Planned |
| **Vaani Stream** | `src/pages/VaaniStreamPage.tsx` | Community broadcast feed | `lib/features/vaani_stream/screens/vaani_stream_screen.dart` | Planned |

---

## 3. Dependency Inventory & Flutter Replacements

| Current Web / React Dependency | Version | Purpose in Web App | Flutter / Android Replacement |
|---|---|---|---|
| `react` & `react-dom` | 18.3.1 | UI Framework | `flutter` SDK (Material 3 + Custom Brand Components) |
| `react-router-dom` | 6.28.0 | Client-side routing | Flutter Navigator 2.0 / `go_router` or declarative route table |
| `sql.js` | 1.14.2 | In-browser SQLite WASM | `sqflite` (Native Android C SQLite library, high performance) |
| `tesseract.js` | 7.0.0 | Client-side Optical Character Recognition | `google_mlkit_text_recognition` / `flutter_tesseract_ocr` |
| `lucide-react` | 1.16.0 | Modern SVG iconography | Native Flutter Material & Cupertino Icons + custom SVGs |
| `canvas-confetti` | 1.9.4 | Quiz completion celebration particles | `confetti` package in Flutter |
| `tailwindcss` | 3.4.16 | CSS styling tokens | Central Dart `AppTheme` & `AppColors` tokens |
| Browser Web Audio API | Native | 16kHz PCM downsampling & mic stream | `record` package / Android native AudioRecord |
| WebSpeech SpeechRecognition | Native | Interim speech token recognition | `speech_to_text` package / Android SpeechRecognizer |
| WebSpeech SpeechSynthesis | Native | Browser TTS speech generation | `flutter_tts` package with phonetic bridge |
| HTML5 `<video>` / File API | Native | Video preview & track handling | `video_player` & `file_picker` packages |
| Browser `localStorage` / `IndexedDB` | Native | Local persistence & turn caching | `shared_preferences` & `sqflite` |

---

## 4. Linguistic Data & Database Assets (Verified Schema & Counts)

- **`translations.db` (Verified via SQLite probe)**:
  - Table `translations`: **6,780 rows**
    - Columns: `id INTEGER PRIMARY KEY`, `english TEXT NOT NULL`, `hindi TEXT NOT NULL`, `santali TEXT NOT NULL`, `santali_roman TEXT`, `ho TEXT`, `mundari TEXT`, `category TEXT`, `verified TEXT`.
    - Indexes: `idx_english`, `idx_hindi`, `idx_santali`, `idx_category`.
  - Table `domain_glossary`: **5,114 rows**
    - Columns: `id INTEGER PRIMARY KEY AUTOINCREMENT`, `source_text TEXT NOT NULL`, `target_text TEXT NOT NULL`, `source_language TEXT NOT NULL`, `target_language TEXT NOT NULL`, `domain TEXT NOT NULL`, `verification_status TEXT NOT NULL`, `provenance TEXT NOT NULL`, `notes TEXT`, `created_at TIMESTAMP`.
    - Indexes: `idx_dg_lookup`, `idx_dg_src`.
- **`Santhali-Words.csv`**: Master curated lexicon.
- **`santaliDataset.ts`**: 2.19 MB pre-parsed JSON with rich thematic categories.
- **`dictionaryData.ts`**: Curated lexicon records.
- **`knowledgeBaseData.ts`**: 12 categorized semantic domains.
- **`languages.ts`**: Language metadata and script definitions.

---

## 5. Browser APIs vs. Android Native Replacements

### 5.1 SQLite Execution
- **React**: WebAssembly binary (`sql-wasm.wasm`) loaded via `sql.js`.
- **Flutter**: Native Android SQLite C-engine via `sqflite`. Database asset is extracted to application sandbox and queried with indexed lookups (`SELECT id, english, hindi, ... FROM translations WHERE ...`).

### 5.2 Speech Recognition (ASR) & State Machine
- **React**: Web Speech API with formal state machine in `s2sStateMachine.ts`:
  `'IDLE' | 'LISTENING' | 'PROCESSING_AUDIO' | 'ASR_PROCESSING' | 'TRANSLATING' | 'SAFETY_CHECK' | 'TTS_PROCESSING' | 'PLAYING' | 'ERROR' | 'CANCELLED'`
  Watchdog timeouts: `LISTENING (30s)`, `PROCESSING_AUDIO (8s)`, `ASR_PROCESSING (10s)`, `TRANSLATING (8s)`, `SAFETY_CHECK (3s)`, `TTS_PROCESSING (5s)`, `PLAYING (15s)`.
- **Flutter**: Reimplemented with identical states, transitions, timeouts, and dynamic silence auto-stop thresholds (1400ms / 800ms / 10000ms initial).

### 5.3 Speech Synthesis (TTS)
- **React**: Browser `window.speechSynthesis` with Indian phonetic acoustic bridge.
- **Flutter**: `flutter_tts` with identical transliteration phonetic acoustic bridge.

### 5.4 Document OCR (Single Vetted Native Engine)
- **React**: Tesseract.js WebAssembly worker pool.
- **Flutter**: `google_mlkit_text_recognition` configured with Devanagari and Latin script packs for fast, on-device neural recognition without duplicate dependencies.

### 5.5 Backend Configuration (Local-First, Configurable URL)
- **React**: Hardcoded `http://127.0.0.1:5000/api`.
- **Flutter**: Configurable `ApiConfig` supporting Android emulator (`http://10.0.2.2:5000/api`), physical LAN IP (`http://<LAN_IP>:5000/api`), and 100% offline fallback where backend is never required.

---

## 6. Migration Risks & Mitigation Strategy

1. **Ol Chiki Glyph Rendering on Older Android Devices**:
   - *Risk*: Standard Android system fonts prior to Android 12 may lack complete Unicode support for Ol Chiki (`U+1C50–U+1C7F`).
   - *Mitigation*: Bundle verified open-source Ol Chiki TrueType fonts (`assets/fonts/OlChiki-Regular.ttf`) directly inside the Flutter asset bundle, declaring them in `pubspec.yaml` as the fallback font family.

2. **Memory Consumption on Low-RAM Tribal School Tablets**:
   - *Risk*: Bundling large datasets in RAM could cause out-of-memory errors on 1GB/2GB Android Go devices.
   - *Mitigation*: Rely primarily on disk-backed native SQLite queries with indexed lookups (`sqflite`), keeping in-memory structures limited to active cache and essential vocabularies.

3. **Background Audio & Permission Denials**:
   - *Risk*: Microphone or camera permissions denied by user causing crashes.
   - *Mitigation*: Safe permission handling wrappers displaying friendly, vernacular educational modals before requesting Android permissions.

---

*Phase 0 Audit Document Complete and Verified against Codebase.*

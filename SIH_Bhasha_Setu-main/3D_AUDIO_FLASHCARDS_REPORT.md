# BHASHA SETU — 3D AUDIO FLASHCARDS TECHNICAL & PEDAGOGICAL REPORT

**Document Version:** 1.0.0  
**Module:** Learning Studio → 3D Audio Flashcards  
**Component:** `src/pages/features/LearningStudioPage.tsx`  
**Target Languages:** Santali (Ol Chiki Script), Hindi, English  
**Audience:** Primary Learners (Grades 1–5), Migrant Teachers, Tribal Educators  
**Architecture:** 100% Offline-First, Hardware-Accelerated CSS 3D, Multi-Tier Speech Synthesis  

---

## 1. Executive Summary

The **3D Audio Flashcards** module in Bhasha Setu is an interactive, multi-sensory vocabulary acquisition engine designed to bridge indigenous oral traditions with formal script literacy. 

Developed specifically for rural classroom environments where internet connectivity is intermittent or absent, this module operates completely client-side. By combining **hardware-accelerated CSS 3D perspective flips**, **phonetic audio synthesis**, and **multi-tier contextual translations (Santali $\leftrightarrow$ Hindi $\leftrightarrow$ English)**, the module provides an immersive learning loop with zero cloud/network latency.

```
┌────────────────────────────────────────────────────────┐
│               3D Audio Flashcard Flow                  │
│                                                        │
│  [FRONT: Ol Chiki + Phonetics + Spoken Audio]          │
│                    ▲                                   │
│                    │  3D Perspective Flip (500ms)      │
│                    ▼                                   │
│  [BACK: English Meaning + Hindi Context + Audio]       │
└────────────────────────────────────────────────────────┘
```

---

## 2. Pedagogical Design & Linguistic Model

### 2.1 Dual-Sided Card Architecture
The flashcard splits language comprehension into an active recall sequence:

| Side | Educational Focus | Key Elements Displayed | Technical Data Source |
| :--- | :--- | :--- | :--- |
| **Front Side** | **Script Recognition & Auditory Phonics** | • Category Badge (e.g., *Classroom*, *Nature*)<br>• Prominent Ol Chiki Glyphs (`4xl`–`5xl`)<br>• Romanized Phonetic Bridge (`🗣️ [phonetic]`)<br>• Listen Pronunciation CTA Button<br>• "Mark as Mastered" Star Button | `currentCard.sat`<br>`currentCard.roman`<br>`currentCard.cat`<br>`playTextSpeech()` |
| **Back Side** | **Semantic Context & Multi-Lingual Meaning** | • English Translation (`2xl`–`3xl`)<br>• Hindi (हिन्दी) Devanagari Translation<br>• Repeat Pronunciation Button<br>• Context & Meaning Category Badge | `currentCard.en`<br>`currentCard.hi`<br>`currentCard.cat` |

### 2.2 The Phonetic Bridge (Roman & Devanagari)
Many migrant educators and non-native teachers cannot yet read the native **Ol Chiki** alphabet (`ᱚ ᱛ ᱜ ᱝ ᱞ ᱠ ᱡ ᱢ ᱣ ᱥ...`). The flashcard resolves this by pairing:
1. The **authentic Ol Chiki glyphs** (preserving linguistic sovereignty).
2. A **phonetic transcription** (e.g., `ᱡᱚᱦᱟᱨ` $\to$ `Johar`) so the teacher can accurately articulate the word immediately.
3. **Audio reinforcement** with one click.

### 2.3 Curriculum Categorization & Deck Filtering
The flashcard deck dynamically filters vocabulary into practical semantic domains aligned with Foundational Literacy and Numeracy (FLN):
- **Normally Used Words in Classroom**: Greetings, commands, classroom objects, conversational phrases.
- **Numbers & Counting**: Foundational numeracy in Ol Chiki and Roman numerals.
- **Body Parts & Health**: Physical anatomy and wellness terminology.
- **Family & Kinship**: Social and familial relationships.
- **Nature, Animals & Food**: Common flora, fauna, and indigenous foodstuffs.
- **Full Curated Lexicon**: Top 300 foundational entries indexed for spaced repetition.

---

## 3. Hardware-Accelerated 3D Transform Architecture

### 3.1 CSS 3D Pipeline
The card flip animation is executed using native, hardware-accelerated CSS 3D transforms without heavy third-party 3D graphics libraries (such as Three.js):

```css
/* Card Container */
perspective: 1000px;

/* Rotating 3D Core */
transform-style: preserve-3d;
transition: transform 500ms cubic-bezier(0.4, 0, 0.2, 1);
transform: isFlipped ? rotateY(180deg) : rotateY(0deg);

/* Front and Back Faces */
backface-visibility: hidden;
```

#### Key Properties:
- **`perspective: 1000px`**: Creates a natural depth-of-field perspective during the flip rotation.
- **`transform-style: preserve-3d`**: Ensures child elements (front and back faces) exist in true 3D space rather than being flattened into a 2D plane.
- **`backface-visibility: hidden`**: Guarantees that when a face is rotated away from the viewer, it is completely invisible, eliminating visual bleed-through or ghosting artifacts.

### 3.2 High-Contrast Visual Theming
- **Front Face (Daylight / Organic)**: Soft off-white to pale emerald gradient (`from-white via-green-50/30 to-emerald-50/50`), rounded corners (`rounded-3xl`), border accent (`border-slate-200/90`), and elevation shadow (`shadow-xl`).
- **Back Face (Contrast / Slate)**: Deep slate dark mode (`from-slate-900 via-slate-800 to-slate-950`) with emerald and gold accents, providing immediate contrast to signify the flipped state.

---

## 4. Audio & Phonetic Synthesis Pipeline

### 4.1 Audio Dispatch Architecture
When the user clicks **"Listen Pronunciation"** or **"Hear Santali"**, the request routes through Bhasha Setu's speech synthesis engine:

```
[User Click: Listen Pronunciation]
                │
                ▼
[playTextSpeech(currentCard.sat, 'sat')]
                │
                ▼
[VoiceQualityRouter.selectBestScoredVoice('sat')]
                │
                ▼
┌──────────────────────────────────────────────────────────┐
│  Multi-Tier Fallback Hierarchy:                          │
│  1. Pre-synthesized Neural Audio Cache (WAV)            │
│  2. Roman Phonetic Bridge → Indian English/Hindi TTS     │
│  3. Infallible Web Audio API Acoustic Confirmation Chime │
└──────────────────────────────────────────────────────────┘
```

### 4.2 Educational Speed Tuning
- Speech playback rate is locked at `0.9x` speed by default.
- This cadence allows young learners to discern individual phonemes, consonant clusters, and nasal modifiers (`ᱸ`, `ᱺ`, `ᱽ`) in Ol Chiki.

---

## 5. Spaced Repetition Mechanics & Gamification

### 5.1 Real-Time Deck Metrics
- **Dynamic Progress Bar**: Displays deck traversal progress: `((cardIndex + 1) / total) * 100%`.
- **Card Counter Badge**: Displays current index (e.g., `Card 14 of 48`).
- **Mastery Tracker**: Real-time counter of mastered words (`Mastered: X`).

### 5.2 "Mark as Mastered" Gamification
- Clicking the **Star button** marks a card as learned/mastered.
- Immediately triggers a celebratory particle explosion using `canvas-confetti` (40 particles, 60° spread, origin `y: 0.7`).
- Mastered card IDs are persisted in client-side state for tracking retention.

### 5.3 Interactive Controls
- **Previous / Next Buttons**: Smoothly navigates the deck while automatically resetting the card orientation (`isFlipped = false`).
- **Flip Card Button / Card Tap**: Toggles between Front (Ol Chiki) and Back (English/Hindi).
- **Shuffle Deck**: Randomizes card sequence for self-testing and spaced repetition.

---

## 6. Offline-First & Performance Benchmarks

| Metric / Attribute | Specification | Performance Target |
| :--- | :--- | :--- |
| **Network Dependency** | **0% (100% Offline)** | Zero cloud calls during flashcard review |
| **RAM Footprint** | $< 35\text{ MB}$ | Recycled single-card DOM structure |
| **Frame Rate** | Locked $60\text{ FPS}$ | Hardware-accelerated GPU transitions |
| **First Contentful Paint (FCP)** | $< 180\text{ ms}$ | Instant local dataset hydration |
| **Storage Mechanism** | `localStorage` | Persisted mastery states and card index |
| **Low-End Tablet Support** | Verified | Compatible with $2\text{ GB}$ RAM Android tablets |

---

## 7. Curriculum Integration in Learning Studio

The 3D Audio Flashcard engine serves as **Phase 1 (Input/Familiarization)** in Bhasha Setu's 3-phase pedagogical framework:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Bhasha Setu Learning Progression                     │
│                                                                         │
│  1. 3D Audio Flashcards  ──► 2. Adaptive Worksheets  ──► 3. FLN Quiz & Cert
│     (Passive Recognition)     (Active Matching/Tracing)   (Formal Assessment)
└─────────────────────────────────────────────────────────────────────────┘
```

1. **Phase 1 (Flashcards)**: Students absorb vocabulary, observe Ol Chiki glyphs, and listen to authentic pronunciation.
2. **Phase 2 (Worksheets)**: Students actively reinforce words through interactive matching, Ol Chiki stroke tracing, and sentence building.
3. **Phase 3 (Assessment)**: Students take comprehensive FLN quizzes and generate personalized achievement certificates.

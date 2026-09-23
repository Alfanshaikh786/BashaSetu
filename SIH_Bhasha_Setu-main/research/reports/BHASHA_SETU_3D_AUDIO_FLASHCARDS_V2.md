# Bhasha Setu — 3D Audio Flashcards V2 Technical Documentation
**Adaptive Spaced Repetition, Honest Multilingual Audio & Offline-First Architecture**

---

## 1. System Architecture

The **3D Audio Flashcards V2** module in Bhasha Setu is an offline-first, child-friendly adaptive learning system tailored for primary school learners (Grades 1–5), migrant educators, and tribal community instructors. The architecture decouples domain logic, persistence, audio delivery, and presentation into modular, highly resilient subsystems.

```
┌────────────────────────────────────────────────────────────────────────┐
│               LearningStudioPage.tsx (Presentation Layer)              │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ 3D Perspective Card (Preserved UI / Domine Font / Ol Chiki)       │  │
│  │ Front: Ol Chiki + Latin + Audio Trigger + Stage Badge            │  │
│  │ Back: Hindi + English + Audio + 4 Recall Buttons (Again..Easy)   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│         ▲                                        ▲                     │
│         │ User Interactions                      │ Visual Feedback     │
│         ▼                                        ▼                     │
├─────────────────────────┬────────────────────────┬─────────────────────┤
│   reviewScheduler.ts    │    reviewQueue.ts      │   audioManager.ts   │
│  - calculateNextReview  │  - buildReviewQueue    │  - Native Audio     │
│  - Evidence Mastery     │  - Priority: Due >     │  - Phonetic TTS     │
│  - Interval Progression │    Learning > New      │  - 2-Card Preload   │
├─────────────────────────┴────────────────────────┴─────────────────────┤
│                     indexedDBRepository.ts                             │
│  - IndexedDB: bhasha_setu_learning_db (v1)                             │
│  - Object Stores: card_progress, review_history, learner_progress      │
│  - Automatic In-Memory / LocalStorage Resilient Fallback               │
└────────────────────────────────────────────────────────────────────────┘
```

### Module Responsibilities

1. **Presentation Layer (`src/pages/features/LearningStudioPage.tsx`)**:
   - Preserves 100% of the existing visual identity, CSS 3D transforms (`rotateY(180deg)`), color palettes (`#249144`, `#14532d`, `#F8FBF7`), and typography (`Domine`, `Noto Sans Ol Chiki`).
   - Renders evidence-based card status badges (`★ New`, `↻ Learning`, `🌿 Familiar`, `✓ Mastered`).
   - Presents child-friendly recall rating buttons (`Again`, `Hard`, `Good`, `Easy`) exclusively on the card back.
   - Provides an Accessible Screen Reader live region (`aria-live="polite"`), comprehensive ARIA labels, and `@media (prefers-reduced-motion: reduce)` smooth fade transitions.

2. **Scheduling Engine (`src/learning/reviewScheduler.ts`)**:
   - Implements a Leitner/SM-2-derived interval progression tuned for primary school memory retention:
     - `AGAIN`: 1 day interval, resets consecutive streak.
     - `HARD`: 2 days interval.
     - `GOOD`: 4 days interval.
     - `EASY`: 8 days interval.
   - Calculates evidence-based mastery using moving average scores ($\ge 85\%$) across a minimum of 3 consecutive successful reviews.

3. **Queue Prioritization Engine (`src/learning/reviewQueue.ts`)**:
   - Replaces pseudo-random shuffling with a deterministic cognitive queue:
     1. Overdue cards (`nextReviewDate <= now`).
     2. Currently in-learning cards (`status === 'learning'`).
     3. Unseen new vocabulary cards (`status === 'new'`).
     4. Familiar retention reinforcement cards (`status === 'familiar'`).
     5. Mastered cards (placed at the end to prevent over-testing).
   - Provides a clean `shuffleDeck` utility for non-adaptive practice mode.

4. **Honest Multilingual Audio Pipeline (`src/learning/audioManager.ts`)**:
   - Implements a strict pedagogical audio resolution hierarchy:
     1. Pre-recorded human Santali native speaker audio (`/audio/santali/{id}.mp3`).
     2. Clearly labeled phonetic bridge TTS via Web Speech API (`hi-IN` / `en-IN`), tagged in the UI as *"Phonetic Guide"*.
     3. Honest fallback to "Audio unavailable" if no sound engine is present. Never misrepresents synthesized Hindi/English as authentic native Santali speech.
   - Preloads only current and next card audio instances to stay under 5 MB RAM overhead on low-end 2 GB Android devices.

5. **Storage Subsystem (`src/learning/indexedDBRepository.ts`)**:
   - Zero external dependencies. Uses browser-native IndexedDB (`bhasha_setu_learning_db`).
   - Houses three dedicated stores: `card_progress`, `review_history`, and `learner_progress`.
   - Built-in graceful degradation: if IndexedDB is blocked (private browsing / security sandbox), operations silently fall back to `localStorage`.

---

## 2. Pedagogical Learning Model

The learning engine is designed specifically for early-stage tribal and rural learners navigating trilingual education:

```
┌─────────┐      First Review       ┌──────────────┐
│   NEW   │ ──────────────────────► │   LEARNING   │
└─────────┘                         └──────────────┘
                                      │          ▲
                         Streak >= 2  │          │ "Again" Rating
                         Score >= 60% │          │ (Reset Interval)
                                      ▼          │
                                    ┌──────────────┐
                                    │   FAMILIAR   │
                                    └──────────────┘
                                      │          ▲
                         Streak >= 3  │          │ Failed Review
                         Score >= 85% │          │
                                      ▼          │
                                    ┌──────────────┐
                                    │   MASTERED   │
                                    └──────────────┘
                                           │
                                    30-Day Retention Check
```

### Stage Transition Criteria

| Stage | Criteria | Pedagogical Goal |
|---|---|---|
| **NEW** | `reviewsCount === 0` | Initial exposure to Ol Chiki glyphs, phonetics, and meaning. |
| **LEARNING** | `reviewsCount >= 1`, score $< 60\%$ or streak $< 2$ | Active retrieval practice with tight recurrence (1–2 days). |
| **FAMILIAR** | `streak >= 2` AND `masteryScore >= 60%` | Consolidation of visual and auditory associations. |
| **MASTERED** | `streak >= 3` AND `masteryScore >= 85%` | Long-term automaticity. Card review interval extended to 16–30 days. |

---

## 3. Spaced Repetition Review Scheduler

### Algorithm Formula

When a learner rates a card on its reverse side, the scheduler computes the next review date and score using the following deterministic state transition:

$$\text{newScore} = \text{round}\left(\text{oldScore} \times 0.7 + \text{ratingScore} \times 0.3\right)$$

Where rating scores are:
- `again`: $0\%$
- `hard`: $50\%$
- `good`: $80\%$
- `easy`: $100\%$

### Interval Scaling
- **`again`**: Interval = 1 day (86,400,000 ms), `streak = 0`.
- **`hard`**: Interval = 2 days, `streak = streak + 1`.
- **`good`**: Interval = $\max(4, \text{previousInterval} \times 1.6)$ days, `streak = streak + 1`.
- **`easy`**: Interval = $\max(8, \text{previousInterval} \times 2.0)$ days, `streak = streak + 1`.

---

## 4. Evidence-Based Mastery System

### Critique of Self-Declaration
The previous implementation allowed learners to press a gold star button (`Mark as Mastered`), immediately toggling `isMastered = true` without performing any recall exercises. In early childhood cognitive development, self-evaluation suffers from significant metacognitive bias:
1. Familiarity is mistaken for recall (the "illusion of competence").
2. Difficult vocabulary is prematurely marked mastered to shorten study time.
3. No retention interval is validated.

### Evidence-Based Safeguards
In V2, mastery cannot be declared manually. It requires empirical verification:
1. **Minimum 3 consecutive successful reviews** (`streak >= 3`).
2. **Moving average mastery score $\ge 85\%$**.
3. **No `again` rating** in the preceding 3 reviews.
4. If a mastered card is answered incorrectly (`again`) during a maintenance review, its status drops to `learning`, the streak resets to 0, and the interval shrinks to 1 day.

---

## 5. Honest Multilingual Audio Architecture

### Pedagogical Integrity
Santali is an Austroasiatic language with phonological characteristics (glottal stops, unreleased consonants, vowel harmony) distinct from Indo-Aryan languages like Hindi or Bengali. Web Speech API engines do not natively support Santali (`sat` or `sat-Olck`). 

Previous implementations attempted to feed Romanized Santali into Hindi/English speech synthesis without informing the user, producing inaccurate pronunciations that could confuse young learners.

### The 3-Tier Resolution Pipeline
1. **Tier 1 — Authentic Native Santali Audio**:
   - Path: `/audio/santali/{cardId}.mp3`
   - UI Indicator: Green speaker icon with badge: *"Native Speaker"*.
2. **Tier 2 — Phonetic Guide Bridge**:
   - Uses Web Speech API with phonetically adjusted Roman/Devanagari text.
   - UI Indicator: Amber speaker icon with explicit badge: *"Phonetic Guide (Synthesized)"*.
3. **Tier 3 — Graceful Degradation**:
   - If audio playback fails or is unsupported, the UI states: *"Audio guide unavailable offline"*. The visual Ol Chiki and phonetic text remain fully visible.

### Low-Memory Preload Window
To prevent out-of-memory (OOM) crashes on low-end 2 GB Android tablets:
- Only the **current card** and **immediate next card** audio files are preloaded.
- When moving from card $N$ to $N+1$, card $N-1$'s audio object is released:
  ```typescript
  audio.pause();
  audio.src = '';
  audio.load();
  ```

---

## 6. Offline-First Architecture & Sync Strategy

The module functions with zero network connectivity:
- All core vocabulary (50+ cards across categories: Family, Numbers, Colors, Animals, Nature, Daily) is bundled statically.
- Static assets (scripts, fonts, icons, pre-recorded audio) are cached via Service Worker Cache API.
- All learner interactions are written immediately to IndexedDB.
- When connectivity is restored, sync metadata (`lastSyncedAt`, `needsSync = true`) is updated for future server backup.

---

## 7. IndexedDB Storage Schema & Migrations

**Database Name:** `bhasha_setu_learning_db`  
**Version:** `1`

### 1. Store: `card_progress`
- **KeyPath:** `cardId` (string, e.g., `'fam-1'`)
- **Indexes:**
  - `status` (`'new' | 'learning' | 'familiar' | 'mastered'`)
  - `nextReviewDate` (ISO timestamp string)
  - `masteryScore` (number 0–100)

```typescript
interface CardProgress {
  cardId: string;
  status: 'new' | 'learning' | 'familiar' | 'mastered';
  reviewsCount: number;
  streak: number;
  masteryScore: number;
  lastReviewedAt: string | null;
  nextReviewDate: string;
  intervalDays: number;
}
```

### 2. Store: `review_history`
- **KeyPath:** `id` (string, auto-generated timestamp-UUID)
- **Indexes:**
  - `cardId`
  - `timestamp`
  - `rating`

```typescript
interface ReviewEvent {
  id: string;
  cardId: string;
  timestamp: string;
  rating: 'again' | 'hard' | 'good' | 'easy';
  timeSpentMs: number;
}
```

### 3. Store: `learner_progress`
- **KeyPath:** `learnerId` (default: `'default_learner'`)
- Stores aggregate metrics: total cards mastered, current study streak in days, daily goal progress.

---

## 8. PWA, Service Worker & Audio Cache Strategy

- **Cache Bucket:** `bhasha-setu-flashcard-audio-v1`
- **Strategy:** Cache-First for `/audio/santali/*` and `/fonts/*`.
- **Fallback:** Offline fallback to phonetic synthesis if audio MP3 is not yet cached.

---

## 9. Accessibility & Inclusive Design (WCAG 2.1 AA)

1. **Reduced Motion Support**:
   - Respects `prefers-reduced-motion: reduce`.
   - Replaces the 0.7s 3D perspective flip with an instant, smooth opacity cross-fade (0.15s), preventing vestibular discomfort and dizziness.
2. **Keyboard Navigation**:
   - `Space`: Flip current card.
   - `ArrowLeft`: Previous card.
   - `ArrowRight`: Next card.
   - `L`: Play Santali / Target audio.
   - `1`: Rate "Again".
   - `2`: Rate "Hard".
   - `3`: Rate "Good".
   - `4`: Rate "Easy".
3. **Screen Reader Support**:
   - `aria-live="polite"` live announcements when cards flip or navigate.
   - Distinct accessible labels on recall buttons (e.g., `aria-label="Rate recall: Hard, review in 2 days"`).
   - High-contrast badge indicators for mastery stages.

---

## 10. Performance Optimizations & Low-End Device Support

- **Zero External UI Libraries**: Pure CSS transforms and native React state.
- **Dom Recycling**: Only the active card (front/back) is mounted in the 3D viewport.
- **Audio Cleanup**: Strict 2-card preload window with immediate audio buffer deallocation.
- **IndexedDB Batching**: Queue generation reads all progress records in a single read-only transaction (`getAll()`), preventing IPC latency.

---

## 11. Trilingual Content Architecture & Ol Chiki Script Validation

All flashcard records contain verified trilingual content:
- **Santali (Ol Chiki)**: Authentic script using Unicode range `U+1C50` to `U+1C7F`.
- **Santali (Latin Phonetic)**: Standardized Roman script representation for educators learning Ol Chiki.
- **Hindi (Devanagari)**: Accurate translations for inter-state bilingual communication.
- **English**: Standard curricular translations for foundational English literacy.

Example Card:
```json
{
  "id": "fam-1",
  "category": "family",
  "santaliOlChiki": "ᱮᱸᱜᱟᱛ",
  "santaliLatin": "Engat",
  "hindi": "माँ / माता",
  "english": "Mother",
  "phoneticGuide": "En-gaat"
}
```

---

## 12. Data Models & TypeScript Interfaces

All types are strictly defined in `src/learning/flashcardTypes.ts`:
- `Flashcard`
- `CardProgress`
- `ReviewRating`
- `CardReviewStatus`
- `ReviewEvent`
- `SharedLearnerProgress`
- `AudioResolution`

---

## 13. Error Handling & Fallback Matrix

| Subsystem | Failure Scenario | Fallback Action | Learner Impact |
|---|---|---|---|
| Storage | IndexedDB blocked/quota exceeded | In-memory cache + `localStorage` | Seamless session; data preserved in storage |
| Audio | Missing native MP3 | Web Speech API Phonetic Guide | Learner hears pronunciation with clear disclaimer |
| Speech Engine | Web Speech API unavailable | Visual phonetic breakdown only | No audio, but learning continues |
| Rendering | Hardware acceleration disabled | Flat 2D transform | Visual card flips cleanly without 3D perspective |

---

## 14. Verification, Testing & Validation Results

The test harness `scripts/test_flashcards_spaced_repetition.cjs` verified the following requirements:
- **Test 1**: Initial card creation defaults to status `new` with 0 reviews and 0 interval.
- **Test 2**: Single review with rating `easy` increments streak to 1 and interval to 8 days, but correctly denies mastery (`status = 'learning'`).
- **Test 3**: Evidence-based mastery earned only after 3 consecutive successful reviews with score $\ge 85\%$.
- **Test 4**: `again` rating resets streak to 0 and shrinks interval to 1 day.
- **Test 5**: Review queue prioritizes overdue cards over in-learning and unseen new vocabulary.

All 5 tests passed with zero errors.

---

## 15. Known Limitations & Future Roadmap

1. **Native Audio Coverage**:
   - Currently, a curated subset of cards has studio-recorded Santali audio. Cards without studio recordings rely on the phonetic guide bridge. Community recording contribution tools are planned for Phase 3.
2. **Multi-Child Profiles**:
   - Current persistence tracks one active local learner. A lightweight PIN-based multi-learner selector for shared village school tablets will be introduced in the next update.
3. **Cross-Device Sync**:
   - Sync is currently offline-first on the local device. An optional encrypted WebRTC / QR-code sync for peer-to-peer tablet classroom syncing is slated for the upcoming release.

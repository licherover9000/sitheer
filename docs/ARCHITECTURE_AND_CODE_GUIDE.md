# Sitheer (myTayari) — Architecture & Code Guide

A complete walkthrough of how the app is built and works: the architecture, every
layer, and a per-file / per-function breakdown that separates the **functional**
role (what the code does) from the **non-functional** concerns (persistence,
async/lifecycle, error handling, security, performance).

> Sitheer is a Flutter + Firebase GATE-exam prep app. It supports an AI study
> mentor, a roadmap tracker, a resource vault, real PYQ practice (MCQ / MSQ /
> NAT) by topic or by year, full mock exams, wrong-answer review, flag-and-learn
> with AI, progress analytics, and a planner (tasks, focus timer, schedule).

---

## Table of Contents

1. [Tech stack](#1-tech-stack)
2. [High-level architecture](#2-high-level-architecture)
3. [Startup / bootstrap flow](#3-startup--bootstrap-flow)
4. [Directory map](#4-directory-map)
5. [Core layer](#5-core-layer)
6. [Model layer](#6-model-layer)
7. [Data layer](#7-data-layer)
8. [Providers (state management)](#8-providers-state-management)
9. [Services](#9-services)
10. [The AI mentor subsystem](#10-the-ai-mentor-subsystem)
11. [Screens (UI)](#11-screens-ui)
12. [Utilities](#12-utilities)
13. [Backend (Firebase)](#13-backend-firebase)
14. [Key end-to-end flows](#14-key-end-to-end-flows)
15. [The question-bank pipeline](#15-the-question-bank-pipeline)
16. [Cross-cutting non-functional concerns](#16-cross-cutting-non-functional-concerns)
17. [Testing](#17-testing)
18. [Running & building](#18-running--building)

---

## 1. Tech stack

| Concern | Choice |
|---|---|
| UI framework | Flutter (Material 3) |
| State management | `provider` (ChangeNotifier) |
| Auth | Firebase Anonymous Auth |
| Cloud data | Cloud Firestore |
| File storage | Firebase Storage (PYQ PDFs) |
| Serverless | Cloud Functions (Node) — secure AI proxy |
| Local persistence | `shared_preferences`, `flutter_secure_storage` |
| Notifications | `flutter_local_notifications` + `timezone` |
| AI providers | Google Gemini + OpenAI (direct or via cloud proxy) |
| Bundled content | JSON assets (`assets/questions/*.json`) |

---

## 2. High-level architecture

The app is **layered**, with a unidirectional data flow: UI watches providers,
providers call repositories/services, repositories talk to Firestore / local
storage, and a content layer feeds catalog + question data into providers.

```
┌───────────────────────────────────────────────────────────────┐
│                       UI (lib/screens)                         │
│  6-tab shell → Ask · Roadmap · Vault · Mocks · Progress · Plan │
│  watch() providers, call provider methods, push routes         │
└───────────────▲───────────────────────────────┬───────────────┘
                │ notifyListeners()              │ method calls
┌───────────────┴───────────────────────────────▼───────────────┐
│                  Providers (lib/providers)                     │
│  PrepProvider, MentorKeysProvider, Task/Timer/Schedule,        │
│  Settings, MainNav  — ChangeNotifier state holders             │
└──────┬───────────────────────┬────────────────────┬───────────┘
       │                       │                     │
┌──────▼─────────┐   ┌─────────▼─────────┐   ┌───────▼──────────┐
│  Repositories  │   │     Services      │   │   Data layer     │
│ prep_repository│   │ auth, notif,      │   │ catalog, codec,  │
│ (Firestore +   │   │ mentor subsystem  │   │ question_bank,   │
│  SharedPrefs   │   │ (cloud/Gemini/    │   │ registry, config │
│  cache)        │   │  OpenAI/offline)  │   │ + JSON assets    │
└──────┬─────────┘   └─────────┬─────────┘   └───────┬──────────┘
       │                       │                     │
┌──────▼───────────────────────▼─────────────────────▼──────────┐
│        Firebase: Auth · Firestore · Storage · Functions        │
└────────────────────────────────────────────────────────────────┘
```

**Design principles baked in**
- **Offline-first.** Everything has a local fallback: catalog seed in code, JSON
  question assets bundled in the app, SharedPreferences cache of content + user
  state. Firebase is an *enhancement* (sync, cloud questions, AI proxy), never a
  hard dependency — the app runs fully if Firebase is unavailable.
- **Read-only client content.** Catalog/question writes happen only via Admin SDK
  scripts; the client reads. Firestore rules enforce this.
- **Graceful degradation.** Network/Firebase/AI failures are caught and fall back
  to cached or offline behavior rather than throwing to the UI.

---

## 3. Startup / bootstrap flow

`lib/main.dart` → `main()` runs before `runApp`:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `Firebase.initializeApp(...)` (wrapped in try/catch; logs and continues).
3. `AuthService.instance.signInAnonymously()` — gives every user a stable UID for
   sync (try/catch; offline still works).
4. `NotificationService.init()` — timezone + local-notification channels.
5. `PrepRepository.instance.bootstrapContent()` → `PrepContentRegistry.setBundles(...)`
   — loads exam catalogs (Firestore-first, local-seed fallback, SharedPreferences
   cache).
6. `QuestionBank.instance.load()` then `mergeRemote(...)` per exam — loads the
   in-code seed + JSON question assets, then layers any Admin-imported Firestore
   questions on top. Runs **after** the registry so chapter→subject→exam grouping
   resolves.
7. `runApp(MyApp())` — builds a `MultiProvider` over all 7 providers and the
   `MaterialApp` (theme driven by `SettingsProvider`).

**Non-functional:** every bootstrap step is independently try/caught and only
`debugPrint`s on failure, so a single failing dependency never blocks app launch.

---

## 4. Directory map

```
lib/
  main.dart                     App entry, Firebase init, provider tree
  core/                         constants.dart (colors/sizes), themes.dart
  model/                        Plain data classes + codecs
  data/                         Catalog, question bank, registry, codec, config
  repositories/                 prep_repository.dart (Firestore + cache)
  providers/                    ChangeNotifier state holders
  services/                     auth, notification, mentor/ (AI subsystem)
  screens/                      UI (home/, prep/, settings/, tasks/, timer/, schedule/)
  utils/                        prep_task_helper.dart
assets/questions/               gate-cs.json, gate-da.json (curated PYQs)
functions/                      Cloud Functions (mentorChat) + Admin import scripts
test/                           Unit + widget tests
firestore.rules, storage.rules  Security rules
```

---

## 5. Core layer

### `lib/core/constants.dart`
**Functional:** Two static-only utility classes.
- `AppColors` — brand palette (`primary`, `mint`, `cyan`, `warning`, `danger`,
  `ink`), backgrounds, surfaces, `border`/`textPrimary`/`textMuted`, plus semantic
  aliases (`secondary`, `high`/`medium`/`low`).
- `AppSizes` — spacing (`paddingS/M/L` = 8/16/24) and radii (`radiusM/L` = 8/14).

**Non-functional:** Pure compile-time constants; centralizes theming so colors
aren't hard-coded across widgets.

### `lib/core/themes.dart`
**Functional:** `lightTheme` and `darkTheme` getters returning `ThemeData` built
from `ColorScheme.fromSeed(AppColors.primary)`, with custom AppBar, Card,
NavigationBar, Chip, and (light-only) InputDecoration styling.

**Non-functional:** Material 3. Dark theme raises the nav-indicator opacity
(22% vs 12%) for contrast and drops the card border.

---

## 6. Model layer

Plain immutable data classes. Most carry codecs (`fromMap`/`toMap` for Firestore +
SharedPreferences, `fromJson`/`toJson` for assets). Codecs are defensively coded
with type coercion and sensible defaults.

### `model/prep_question.dart`
**Functional:** The canonical question.
- `enum QuestionType { mcq, msq, nat }` + `questionTypeFromString(...)`.
- `PrepQuestion` fields: `id`, `chapterId`, `prompt`, `options`, `correctIndex`
  (MCQ), `correctIndexes` (MSQ), `numericAnswer` + `numericTolerance` (NAT),
  `type`, `explanation`, `year`, `session`, `marks`, `negativeMarks`, `tags`,
  `source`.
- Getter `penalty` — actual negative mark; if `negativeMarks` is 0 it applies the
  GATE default (−1/3 for 1-mark MCQ, −2/3 for 2-mark MCQ, 0 for NAT/MSQ).
- `isIndexCorrect`, `areIndexesCorrect` (set equality), `isNumericCorrect`
  (tolerance band) — type-aware correctness checks.
- `correctAnswerText` — human-readable answer for review UIs.
- `fromJson` / `toJson`.

**Non-functional:** The single source of truth for scoring rules; tolerant JSON
parsing (missing fields default safely).

### `model/question_attempt.dart`
**Functional:** Captures a user's response and powers review/flag/AI flows.
- `QuestionAttempt` — denormalized snapshot of the question + the user's response
  (`selectedIndex`, `selectedIndexes`, `numericResponse`), plus `marks`, `penalty`,
  `markedForReview`, `attemptedAt`.
  - Factory `fromQuestion(PrepQuestion, ...)` builds a snapshot from a question +
    response.
  - Getters `isSkipped`/`isCorrect`/`isWrong` (type-aware), `earnedMarks` (GATE
    score), `responseText`/`correctText` (review strings), `copyWith`,
    `toMap`/`fromMap`.
- `PracticeSession` — a completed attempt: `id`, `source` (`mock`|`pyq`), `refId`,
  `title`, `attempts`, `completedAt`. Getters: `total`, `correctCount`,
  `incorrectCount`, `skippedCount`, `accuracy`, `marks` (sum of `earnedMarks`),
  `wrongAttempts`; `toMap`/`fromMap`.

**Non-functional:** Snapshotting (rather than referencing live questions) means a
review stays correct even if the bank changes; `fromMap` falls back to
`DateTime.now()` on a bad timestamp.

### `model/prep_progress.dart`
**Functional:**
- `ChapterProgress` — `accuracy`, `completedResourceIds`, `attemptedPyqs`,
  `incorrectCount`; `copyWith`, codecs.
- `MockAttemptRecord` — per-paper summary: `score`, `accuracy`, counts,
  `marksObtained`, `completedAt`; codecs.

**Non-functional:** `MockAttemptRecord.fromMap` parses the date defensively
(`tryParse` → `now()`).

### `model/prep_content.dart`
**Functional:** Catalog structure.
- `enum PrepResourceType { pyq, notes, formula, lecture, mock, article }`.
- `PrepResource` (title/type/source/description/timeLabel/url/storagePath/isPremium),
  `PrepChapter` (weightage/difficulty/pyqCount/accuracy/resources), `PrepSubject`
  (code/title/icon/accent/progress/chapters), `RoadmapWeek` (week/phase/hours/
  focus/outcomes/checkpoints/subjectCodes), `MockPaper` (stream/year/duration/
  questions/score/status/focusAreas), `PredictorCollege`.

### Other models
- `model/prep_exam_bundle.dart` — `PrepExamBundle` (examId/examLabel/version +
  subjects/roadmapWeeks/mockPapers): the unit fetched/cached per exam.
- `model/mock_question.dart` — lightweight DTO for rendering a mock question
  (`questionId/prompt/options/correctIndex/chapterId/explanation`).
- `model/mentor_reply.dart` — `enum MentorIntent { plan, concept, mock, pyq,
  general }` + `MentorReply` (`answer`, `sources`, `intent`).
- `model/pyq_volume.dart` — PYQ PDF metadata with robust parsing helpers
  (`_readInt`, `_readDateTime` handling Firestore `Timestamp`) and
  `displaySubtitle` formatting.
- `model/task.dart` — `enum Priority` + `Task` (Firestore-backed) with codecs.
- `model/event.dart` — `AppEvent` (calendar event; stores time as hour/minute,
  color as ARGB int).
- `model/session.dart` — currently empty (placeholder).

---

## 7. Data layer

### `data/prep_catalog.dart` + `data/gate_da_catalog.dart`
**Functional:** In-code curriculum seed. `prep_catalog.dart` defines
`supportedExams = ['GATE CS', 'GATE DA']`, the 8 GATE-CS subjects with chapters
and real resource links (GFG, NPTEL, PW, YouTube, …), an 8-week roadmap, mock
papers, predictor colleges, and helper builders (`prepArticle`, `prepPyq`,
`prepNotes`, `prepFormula`, `prepLecture`, `prepMock`, `prepChapter`).
`gate_da_catalog.dart` adds the 3 DA-only subjects and a 6-week DA roadmap.

**Non-functional:** Large literal data; serves as the offline fallback for the
content registry.

### `data/prep_exam_config.dart`
**Functional:** Subject-code sets per exam (`gateCsSubjectCodes`,
`gateDaSubjectCodes`, plus the *only* sets) and predicates
`subjectMatchesExam`, `weekMatchesExam`, `mockMatchesExam`. Shared subjects
(`math`, `apt`, `ds`, `algo`) appear in both exams.

### `data/prep_questions.dart`
**Functional:** `prepQuestionsByChapter: Map<String, List<PrepQuestion>>` — the
in-code seed question set keyed by chapter.

### `data/question_bank.dart` ★ central question registry
**Functional:** `QuestionBank` singleton.
- `load()` — merges the in-code seed with the JSON assets (`gate-cs.json`,
  `gate-da.json` via `rootBundle`), keyed by `id` (JSON overrides seed), then
  indexes by chapter / exam / year. Idempotent.
- `mergeRemote(List<Map>)` — overlays Admin-imported Firestore questions (override
  by id) and re-indexes.
- Accessors: `forChapter`, `forExam`, `availableYears` (newest first), `forYear`,
  `countForYear`, `allQuestions`.
- Top-level `questionsForChapter(chapterId)` — bank → seed → placeholder fallback
  (so a drill never crashes on an empty chapter).

**Non-functional:** Triple in-memory index (`_byId`, `_byChapter`, `_byExam`);
exam grouping resolves via `findChapterContext` + `subjectMatchesExam`, which is
why `load()` must run after the registry. Asset/parse failures are caught and
logged, leaving the seed intact.

### `data/prep_content_registry.dart`
**Functional:** `PrepContentRegistry` singleton holding `PrepExamBundle`s keyed by
examId. `setBundle(s)`, `bundleForExam(label)`, and `subjectsForExam` /
`weeksForExam` / `mocksForExam` / `allSubjects` that prefer the loaded (remote)
bundle and fall back to the local seed.

### `data/prep_catalog_accessors.dart`
**Functional:** Thin query API over the registry: `subjectsForExam`,
`weeksForExam`, `mocksForExam`, `totalPyqsForExam`, `totalChaptersForExam`,
`findSubject`, `findChapter`, `findResource`, `findChapterContext` (returns
`(subjectCode, chapter)`).

### `data/prep_content_codec.dart` + `data/prep_icon_map.dart`
**Functional:** Bidirectional Map codecs for every catalog model (bundle/subject/
chapter/resource/week/mock) plus `examIdFromLabel` / `examLabelFromId`. Icons
serialize via a string-key map (`prepIconKey` / `prepIconFromKey`) and colors via
ARGB ints — so catalog content round-trips through Firestore.

### `data/prep_content_local.dart`
**Functional:** Assembles `PrepExamBundle`s from the in-code catalog
(`localBundleForExam`, `allLocalBundles`) and defines local PYQ-volume metadata
(`allLocalPyqVolumes`). `prepContentVersion` constant.

### `repositories/prep_repository.dart` ★ data access
**Functional:** `PrepRepository` singleton — the only place that talks to
Firestore/SharedPreferences for prep.
- Content: `bootstrapContent()`, `fetchExamBundle(examId)` (Firestore →
  SharedPreferences cache), `_cacheContentBundle` / `_loadCachedBundle`.
- Cloud questions: `fetchExamQuestions(examId)` from
  `content/exams/items/{examId}/questions`.
- PYQ volumes: `fetchPyqVolumes(examId)` (Firestore → local fallback, sorted).
- User state: `loadLocalState` / `saveLocalState` (SharedPreferences key
  `prep_state_v1`), `loadRemoteProfile` / `saveRemoteProfile` /
  `watchRemoteProfile` (Firestore `users/{uid}.prepProfile`, merge writes).
- Helpers: `parseChapterProgress` / `chapterProgressToMap`.

**Non-functional:** `_db` returns null when Firebase isn't initialized, so every
method degrades to cache/local instead of throwing. Content is Firestore-read /
Admin-write only.

### `assets/questions/*.json`
**Functional:** Curated real PYQs. Each object follows the `PrepQuestion` JSON
schema (`id`, `chapterId`, `type`, `prompt`, `options`, `correctIndex` /
`correctIndexes` / `numericAnswer`+`numericTolerance`, `explanation`, `year`,
`marks`, `negativeMarks`, `tags`, `source`). Currently ~246 curated questions
(CS + DA) and designed to grow by editing the files — no code change needed.

---

## 8. Providers (state management)

All extend `ChangeNotifier`; the UI `watch()`es them and calls their methods.

### `providers/prep_provider.dart` ★ the heart of the app
**Functional:** Owns exam selection, week, completed checkpoints, per-chapter
progress, mock attempts, recent practice sessions, flagged questions, and PYQ
volumes. Key API:
- Selection/roadmap: `setExam`, `setCurrentWeek`, `toggleCheckpoint`,
  `isCheckpointDone`, `currentRoadmapWeek`.
- Derived: `subjects`/`weeks`/`mocks` (from registry), `overallProgress`,
  `subjectProgress`, `chapterAccuracy`, `totalIncorrect`,
  `weakestChaptersByMistakes`, `allWrongAttempts`.
- Recording: `recordQuizResult`, `recordMockAttempt`, `recordPracticeSession`
  (keeps the 10 most recent, newest first), `markResourceComplete`,
  `isResourceDone`.
- Review/flag: `recentSessions`, `latestSessionFor`, `flaggedQuestions`,
  `toggleFlag`, `unflag`.
- Content: `refreshContent`, `refreshPyqVolumes`.

**Non-functional — persistence & sync:** `_toState()` serializes everything
(exam, week, checkpoints, chapterProgress, mockAttempts, sessions,
flaggedQuestions) and `_persist()` writes it to **both** SharedPreferences (local)
and `users/{uid}.prepProfile` (Firestore). `_init()` loads local first, then syncs
remote and attaches a `watchRemoteProfile` listener for live cross-device updates.
Remote failures are swallowed (offline keeps working). Sessions are capped to 10
to keep the synced doc small.

### Other providers
- `providers/main_nav_provider.dart` — current tab index; `setIndex` (no-ops if
  unchanged). No persistence.
- `providers/settings_provider.dart` — `themeMode`; persisted to SharedPreferences
  (`themeMode`).
- `providers/mentor_keys_provider.dart` — Gemini/OpenAI keys + `useCloudMentor`.
  Keys live in `FlutterSecureStorage` (encrypted), with `String.fromEnvironment`
  fallback and one-time migration from legacy SharedPreferences. Getters
  `hasGemini`/`hasOpenai`/`hasAnyKey`; setters persist immediately.
- `providers/task_providers.dart` — tasks via a Firestore listener on
  `users/{uid}/tasks` (ordered by `createAt`); `startListening`, `addTask`,
  `toggleTask`, `deleteTask`. `pendingTasks`/`completedTasks` getters.
- `providers/timer_providers.dart` — Pomodoro state machine (`TimerMode`,
  `TimerState`) with `Timer.periodic`; durations persisted to SharedPreferences;
  `start`/`pause`/`reset`/`setMode`; fires a local notification + increments the
  focus-session count on finish.
- `providers/schedule_providers.dart` — calendar events via a Firestore listener
  on `users/{uid}/events`; `eventsForDay`, `nextUpcomingEvent`, `addEvent`
  (schedules a reminder notification).

**Non-functional (providers generally):** constructors kick off async `_load()`
(fire-and-forget) and `notifyListeners()` after; `dispose()` cancels timers/stream
subscriptions. Task/Schedule listeners are started explicitly from
`PlannerScreen.initState` once the UID is known.

---

## 9. Services

### `services/auth_service.dart`
**Functional:** `AuthService` singleton — `signInAnonymously()`, `currentUser`,
`userId`. **Non-functional:** lazily resolves `FirebaseAuth.instance`; no-ops if
Firebase is uninitialized or already signed in.

### `services/notification_service.dart`
**Functional:** `NotificationService` — `init()` (timezone + Android/iOS/macOS
channels + permissions), `scheduleEventReminder(...)` (zoned, ~10 min before),
`showSessionComplete(label)`. **Non-functional:** idempotent via a `_ready` flag;
DST-aware via `TZDateTime`; stable per-event notification IDs so re-scheduling
replaces rather than duplicates.

---

## 10. The AI mentor subsystem

A resilient, layered chain: **cloud proxy → Gemini/OpenAI (device keys) →
offline rules**. Each layer falls back to the next on failure, so the user always
gets an answer.

```
MentorService (facade)
   ├─ replyAsync(question)         → CombinedMentorService.reply(...)
   └─ explainQuestion(attempt)     → buildExplainPrompt(...) → CombinedMentorService.reply(...)
                                          │
                CombinedMentorService.reply()
                   1. trim + key check (empty → offline)
                   2. classifyMentorIntent() → plan/concept/mock/pyq/general
                   3. buildMentorSystemPrompt(prep) + buildMentorUserPrompt(q, intent)
                   4. MentorCloudClient.tryReply()  ── success ──▶ return
                   5. else device keys: dual (Gemini+OpenAI) | single
                   6. else OfflineMentorService.reply()
```

- `services/mentor_service.dart` — `MentorService` facade. `replyAsync(...)` for
  Ask-Tayari questions; `explainQuestion(attempt, simpler)` builds an explain
  prompt and routes it through the same chain; synchronous `reply(...)` for
  offline/tests.
- `services/mentor/combined_mentor_service.dart` — orchestrates the fallback
  chain, intent-based routing, and the dual-model mode (Gemini "study plan" +
  OpenAI "concept coaching" merged). Catches all errors and degrades to offline,
  **without leaking raw API error text** to the user.
- `services/mentor/gemini_client.dart` / `openai_client.dart` — thin HTTPS clients
  (45 s timeout) returning trimmed completion text; throw on non-200 so the
  combiner can fall back.
- `services/mentor/mentor_cloud_client.dart` — calls the `mentorChat` callable;
  maps intent → provider (`gemini`/`openai`/`both`); returns `null` on any error
  (silent fallback to device keys).
- `services/mentor/mentor_context.dart` — `buildMentorSystemPrompt(prep)`
  (injects exam, progress %, weak subjects, recent mocks, checkpoints),
  `buildMentorUserPrompt(question, intent)` (intent-specific focus line), and
  `buildExplainPrompt(attempt, simpler)` (question + options + your answer vs
  correct + a "core concept / why correct / likely mistake / memory tip"
  checklist).
- `services/mentor/mentor_intent_classifier.dart` — keyword classifier
  (`classifyMentorIntent`) + `shouldUseBothModels`.
- `services/mentor/offline_mentor_service.dart` — rule-based fallback that uses
  live `prep` state (weakest subject, roadmap week, latest mock) so even the
  no-network path is personalized. Guards against empty subjects/chapters/mocks.

**Non-functional — security:** in production, keys live in **Firebase Functions
secrets** (server-side) and the device never sees them; device keys are an
encrypted dev fallback. The callable requires auth. Errors are logged server-side
(`console.error` with status only), never surfaced verbatim.

---

## 11. Screens (UI)

`lib/screens/home/main_scaffold.dart` is the responsive 6-tab shell
(`NavigationBar` < 980 px, `NavigationRail` ≥ 980 px), driven by `MainNavProvider`.
`screens/home/home_screen.dart` is the planner overview (today's tasks / timer /
next event summary cards).

### Prep tabs & flows (`lib/screens/prep`)

| Screen | Tab / flow | Type | What it does |
|---|---|---|---|
| `ask_tayari_screen.dart` | 0 Ask | Stateless (+ stateful mentor panel) | Cockpit: exam selector, metrics, weak subjects, toolkit, and the Ask-Tayari input → `MentorService.replyAsync` → `MentorReplySheet`. Flag badge → `FlaggedQuestionsScreen`. |
| `roadmap_screen.dart` | 1 Roadmap | Stateless | Phase rail + weekly cards; toggle checkpoints, set current week, "add to planner". |
| `vault_screen.dart` | 2 Vault | Stateful | Searchable/filterable resource library + PYQ-PDF volumes (open via `url_launcher` / Firebase Storage URL). |
| `mock_tests_screen.dart` | 3 Mocks | Stateless | Mock catalog (`_MockPaperCard`) + **PYQ-by-year** (`_PyqByYear`, reads `QuestionBank`) → `PracticeRunnerScreen`. |
| `mock_attempt_screen.dart` | 3 sub | Stateful | Full 65-Q exam: palette, mark-for-review, countdown timer, GATE scoring; on submit records a `MockAttemptRecord` + `PracticeSession` → `PracticeReviewScreen`. |
| `practice_runner_screen.dart` | generic | Stateful | One runner for chapter drills **and** by-year practice; handles **MCQ/MSQ/NAT** input; `.chapter(id)` factory; records a session → review. |
| `practice_review_screen.dart` | post-attempt | Stateful | Shared wrong-answer review: summary, accuracy-by-chapter, All/Wrong/Flagged filter, retake CTA, `StudyTopicSection`; per-card flag + "Explain with AI". |
| `explain_question_screen.dart` | post-review | Stateful | Dedicated AI explain flow: question + your/correct answer, "Explain with AI" / "Explain differently", flag toggle, topic resources. |
| `flagged_questions_screen.dart` | from Ask | Stateless | List of flagged questions → `ExplainQuestionScreen`; unflag. |
| `progress_screen.dart` | 4 Progress | Stateless | Analytics: overall progress, strongest/weakest, mock trend, **real** wrong-answers-by-chapter (`_ReviewWrongPanel`) + recent sessions, college predictor. |
| `planner_screen.dart` | 5 Planner | Stateful | Tab container [Overview, Tasks, Focus, Schedule]; starts the Task/Schedule Firestore listeners in `initState`. |
| `subject_detail_screen.dart` | detail | Stateless | Subject → chapters (expansion) → resources. |
| `resource_detail_screen.dart` | detail | Stateless | Resource page: open link, mark complete, start drill/mock, preview questions. |
| `mentor_reply_sheet.dart` | modal | Stateless | Bottom sheet rendering a `MentorReply` with source chips. |
| `prep_widgets.dart` | shared | Stateless | Reusable widgets: `PrepHeader`, `SectionTitle`, `MetricCard`, `SubjectProgressTile`, `ResourceTypeBadge`, `ResourceCard`, `EmptyState`, `StudyTopicSection`. |

### Settings & planner sub-screens
- `screens/settings/settings_screen.dart` — appearance (theme), mentor keys
  (`mentor_api_keys_section.dart`), "refresh content from cloud", timer durations.
- `screens/tasks/` — `tasks_screen.dart` (list + FAB), `add_task_sheet.dart`,
  `task_tile.dart` (swipe-delete + checkbox), `tasks.dart`.
- `screens/timer/timer_screen.dart` — Pomodoro UI (mode buttons + progress ring),
  all state in `TimerProviders`.
- `screens/schedule/` — `schedule_screen.dart` (`table_calendar` + day events),
  `add_event_schedule.dart`.

**Non-functional (UI):** The two timer-bearing screens (mock attempt, focus timer)
manage `Timer` lifecycles carefully — cancel on dispose, `mounted` guards before
`setState`, and (mock) cancel/resume around the submit dialog. The largest build
methods are `mock_attempt_screen` and `progress_screen`; no measured perf issues.
`vault_screen` combines three filters (subject + type + query) in `build`.

---

## 12. Utilities

### `utils/prep_task_helper.dart`
**Functional:** `addRoadmapTask(context, title)` — creates a `Task` tagged
`roadmap` from a checkpoint and saves it via `TaskProviders`, then shows a
confirmation SnackBar. Used by the roadmap "add to planner" button.

---

## 13. Backend (Firebase)

### `functions/index.js` — `mentorChat` callable
**Functional:** Auth-gated callable that proxies to Gemini and/or OpenAI using
**Firebase secrets** (`GEMINI_API_KEY`, `OPENAI_API_KEY`). Validates the question
(≤ 2000 chars), routes by `provider` (`gemini` | `openai` | `both`), and returns
`{ answer, sources }`.

**Non-functional:** keeps keys off the device; logs upstream API failures
server-side with status only; throws `HttpsError('internal', ...)` (generic) on
failure.

### `functions/scripts/` — Admin import tooling
- `import-content.js` — seeds exam bundles to `content/exams/items/{examId}`.
- `import-questions.js` — pushes the same question JSON to
  `content/exams/items/{examId}/questions` (validation + `--dry-run`).
- `upload-pyq-volumes.js` — uploads PYQ PDFs to Storage + metadata to Firestore.

### Rules
- `firestore.rules` — users can read/write only their own `users/{uid}/**`; the
  content catalog, the questions subcollection, and PYQ-volume metadata are
  **read-only** to signed-in users (writes are Admin-SDK only).
- `storage.rules` — authenticated read of `content/{examId}/...`; client writes
  blocked.

---

## 14. Key end-to-end flows

**Practice a topic / year → review → flag → learn**
1. Mocks tab → "PYQ by year" (or a chapter drill) opens `PracticeRunnerScreen`
   over questions from `QuestionBank`.
2. User answers MCQ/MSQ/NAT; on finish the runner builds `QuestionAttempt`s, a
   `PracticeSession`, and calls `prep.recordPracticeSession` + `recordQuizResult`.
3. "Review answers" → `PracticeReviewScreen` (All/Wrong/Flagged). Each wrong card
   offers **flag** (`prep.toggleFlag`) and **Explain with AI**.
4. `ExplainQuestionScreen` → `MentorService.explainQuestion` runs the mentor chain
   with the question pre-loaded; `StudyTopicSection` links the chapter's resources.
5. Flagged questions accumulate (Ask-tab badge → `FlaggedQuestionsScreen`) for
   spaced revision.

**Mock exam** — `MockAttemptScreen` (timer + palette + GATE scoring) → records a
`MockAttemptRecord` *and* a `PracticeSession` → `PracticeReviewScreen`. The Mocks
tab "Analysis" button reopens the stored session.

**Progress sync** — any record/flag/checkpoint change → `prep._persist()` →
SharedPreferences + `users/{uid}.prepProfile`; a Firestore listener applies remote
changes back into state for cross-device continuity.

---

## 15. The question-bank pipeline

The app reads questions from three layered sources, merged by `id`:

```
in-code seed (prep_questions.dart)
        ▼ overridden by
JSON assets (assets/questions/*.json)   ← bundled, offline, the curated PYQ bank
        ▼ overridden by
Firestore  content/exams/items/{examId}/questions   ← optional, Admin-imported
```

- **Add questions** by editing the JSON files (same schema) — they appear
  automatically under PYQ-by-year and chapter drills, no code change.
- **Scale to the cloud** by running `npm run seed:questions` (Admin SDK) to push
  the JSON to Firestore; the app merges those on top at startup via
  `PrepRepository.fetchExamQuestions` + `QuestionBank.mergeRemote`.
- A test (`test/question_assets_test.dart`) enforces well-formedness (unique ids,
  answer key matching the declared type).

---

## 16. Cross-cutting non-functional concerns

| Concern | How it's handled |
|---|---|
| **Persistence** | Local: SharedPreferences (user state, content cache, settings, timer) + FlutterSecureStorage (API keys). Cloud: Firestore (`users/{uid}` for state/tasks/events; `content/**` read-only). |
| **Sync** | `PrepProvider` writes local+remote on every change and listens to the remote profile for live updates. Tasks/events are pure Firestore listeners. |
| **Offline-first** | Catalog seed in code, questions bundled as assets, content cached in SharedPreferences. Firebase-less launch is fully functional. |
| **Error handling** | Repositories/services catch failures and fall back (cache → local → offline) instead of throwing to the UI. Bootstrap steps are independently try/caught. |
| **Security** | Anonymous auth per user; per-user Firestore rules; content/questions read-only on the client; AI keys preferably in Functions secrets, else encrypted on device; no raw API errors shown to users. |
| **Theming** | Centralized `AppColors`/`AppSizes` + Material 3 light/dark themes; theme mode persisted. |
| **Performance** | In-memory question indexes; capped session history (10); responsive layout; careful timer lifecycles. |

---

## 17. Testing

`test/` holds:
- `prep_question_test.dart` — `PrepQuestion` JSON round-trip + correctness for
  MCQ/MSQ/NAT.
- `question_attempt_test.dart` — attempt classification and `PracticeSession`
  scoring/round-trip (per-type marks/penalty).
- `explain_prompt_test.dart` — `buildExplainPrompt` output shape.
- `question_assets_test.dart` — both JSON banks are well-formed (unique ids,
  type-consistent answer keys).
- `pyq_volume_test.dart` — `PyqVolume` metadata parsing.
- `widget_test.dart` — the prep dashboard loads the main workflows.

---

## 18. Running & building

```bash
flutter pub get
dart format lib test          # formatting
flutter analyze               # static analysis (kept at zero issues)
flutter test                  # unit + widget tests
flutter run                   # run on a device/emulator
flutter build web             # web build (bundles assets/questions/*.json)

# Optional cloud question import (Admin SDK, needs a service-account key):
cd functions
npm install
GOOGLE_APPLICATION_CREDENTIALS=service-account.local.json npm run seed:questions
firebase deploy --only firestore:rules
```

---

*This guide reflects the codebase as of the current `main` branch. When you add a
screen, provider, model, or data source, slot it into the matching layer section
above and note its functional role plus any non-functional concerns (persistence,
async lifecycle, error handling, security).*

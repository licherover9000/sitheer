# myTayari-Style App: Development Status and Continuation Prompt

Last updated: 2026-05-28

## Objective

Build `sitheer` into a myTayari-style GATE prep web/mobile app with original UI and data structures:

- AI mentor entry point
- GATE CS and GATE DA roadmap tracking
- Resource vault for PYQs, notes, formulas, playlists, and mocks
- PYQ drills and mock attempts
- Progress analytics and planner workflows
- Firebase-backed sync, content storage, and secure AI proxying

Important copyright boundary: do not copy protected third-party website content or course material unless the user owns it or has permission. The two local PDFs supplied by the user should be treated as user-provided source material and stored outside git.

## Current Implementation Status

### Implemented In Flutter

- Six-tab app shell in `lib/screens/home/main_scaffold.dart`:
  - `Ask`
  - `Roadmap`
  - `Vault`
  - `Mocks`
  - `Progress`
  - `Planner`
- Responsive navigation:
  - Bottom `NavigationBar` on mobile/narrow layouts
  - `NavigationRail` on wide layouts
- Theming:
  - Updated app palette and Material 3 theme in `lib/core/constants.dart` and `lib/core/themes.dart`
  - Light/dark mode still uses `SettingsProvider`
- Prep content model:
  - `PrepSubject`, `PrepChapter`, `PrepResource`, `RoadmapWeek`, `MockPaper`
  - `PrepExamBundle` for Firestore/importable exam bundles
  - `PrepQuestion` for in-app quiz questions
- GATE content scaffold:
  - GATE CS subject/chapter/resource catalog in `lib/data/prep_catalog.dart`
  - GATE DA expansion in `lib/data/gate_da_catalog.dart`
  - Registry/accessor layer in `lib/data/prep_content_registry.dart` and `lib/data/prep_catalog_accessors.dart`
- Prep progress:
  - `PrepProvider` stores selected exam, current week, completed checkpoints, chapter progress, resource completions, and mock attempts
  - Local persistence via `SharedPreferences`
  - Remote sync via user document `users/{uid}.prepProfile`
- User workflows:
  - Ask Tayari dashboard in `ask_tayari_screen.dart`
  - Subject detail flow
  - Resource detail flow
  - PYQ drill screen
  - Mock attempt screen
  - Progress and predictor-style panels
  - Planner tab reuses Tasks, Timer, Schedule, and Home overview
- AI mentor scaffold:
  - Offline fallback mentor
  - Intent classifier
  - Gemini client
  - OpenAI client
  - Combined local client
  - Firebase callable cloud proxy client
  - Settings UI for local device keys and cloud mentor preference
- Firebase:
  - Anonymous auth bootstrap
  - Firestore rules for per-user data and read-only content catalog
  - Storage rules for uploaded content PDFs
  - Cloud Function `mentorChat`
- Web metadata:
  - Web title and manifest updated for myTayari branding

### Implemented For Content/Upload Infrastructure

- Admin SDK content seed script:
  - `functions/scripts/import-content.js`
  - Intended to write exam bundles to `content/exams/items/{examId}`
- Admin SDK PYQ PDF upload script:
  - `functions/scripts/upload-pyq-volumes.js`
  - Uploads PDFs to Cloud Storage under `content/{examId}/pyq/`
  - Writes metadata to `content/pyqVolumes/items/{volumeId}`
- Storage rules:
  - Authenticated users can read `content/{examId}/...`
  - Client writes are blocked
- Firestore rules:
  - Authenticated users can read `content/exams/items/{examId}`
  - Authenticated users can read `content/pyqVolumes/items/{volumeId}`
  - Client writes are blocked; Admin SDK must seed/import
- `.gitignore` protects:
  - `.env`
  - local secret JSON files
  - `node_modules`
  - build artifacts

## User-Provided PYQ PDFs

These files are local source files and should not be committed:

- `C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume1.pdf`
  - Size: 20,166,045 bytes
- `C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume2.pdf`
  - Size: 28,924,112 bytes

Planned upload command from `C:\flutter projects\sitheer\functions`:

```powershell
npm run upload:pyq -- --exam=gate-cs "C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume1.pdf" "C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume2.pdf"
```

Dry run command:

```powershell
npm run upload:pyq -- --dry-run --exam=gate-cs "C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume1.pdf" "C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume2.pdf"
```

Before actual upload, configure Admin SDK credentials:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account.local.json"
```

Do not commit service account files.

## Current Gaps / Not Yet Production-Ready

- Real PYQ extraction is not complete.
  - The app has sample `PrepQuestion` items only.
  - The two PDFs can be uploaded as PDF volumes, but they are not yet parsed into per-year/per-chapter quiz records.
- Uploaded PYQ PDF metadata is not yet displayed in the Flutter Vault.
  - Need `PyqVolume` model/repository query.
  - Need Vault section for PDF volumes.
  - Need Firebase Storage download URL/open flow.
- `PrepResource.storagePath` has been added to the model and codec but the UI still needs to use it.
- `PrepProvider.createRoadmapTask` is still a no-op.
  - Roadmap checkpoints should eventually create Planner tasks.
- Firestore catalog seeding from the client has been disabled conceptually, but `forceRefreshContent` still exists.
  - Keep client content refresh read-only.
  - Use Admin SDK scripts for writes.
- Mock engine is a simplified shell.
  - It samples a small question pool and does not yet implement full 65-question GATE rules.
- PYQ drill engine is functional but sample-only.
  - Needs real question bank structure and import tooling.
- AI cloud proxy exists but needs deployed secrets and emulator/prod verification.
- App Check is not implemented.
- No automated tests yet for:
  - PrepProvider persistence and sync
  - Mentor intent routing
  - Resource/Storage PDF open flow
  - Mock scoring
  - Firestore content decoding

## Recommended Next Engineering Steps

### Step 1: Finish PYQ PDF Upload Flow

1. Run the dry-run upload script.
2. Configure Admin SDK credentials.
3. Upload both PDFs to Firebase Storage.
4. Confirm Firestore metadata documents exist at:
   - `content/pyqVolumes/items/gate-cs-pyq-volume-1`
   - `content/pyqVolumes/items/gate-cs-pyq-volume-2`
5. Deploy storage and Firestore rules.

### Step 2: Surface Uploaded PDFs In Vault

Implement:

- `lib/model/pyq_volume.dart`
- `PrepRepository.fetchPyqVolumes(String examId)`
- `PrepProvider.pyqVolumes`
- A `PYQ Volumes` section in `VaultScreen`
- A detail/open action using `FirebaseStorage.instance.ref(storagePath).getDownloadURL()`
- Optionally link PDF volumes to every GATE CS PYQ resource until granular parsing exists

### Step 3: Add Import Schema For Real Questions

Define a canonical JSON/CSV schema:

- `id`
- `exam`
- `year`
- `session`
- `subjectCode`
- `chapterId`
- `questionNumber`
- `prompt`
- `options`
- `correctIndex`
- `answer`
- `explanation`
- `marks`
- `negativeMarks`
- `sourceVolumeId`
- `sourcePage`

Then build an Admin SDK import script that writes to:

- `content/questions/items/{questionId}`

or, for scalable queries:

- `content/exams/items/{examId}/questions/{questionId}`

### Step 4: Improve Exam Engine

- Implement 65-question paper attempts.
- Add section navigation and question palette states:
  - not visited
  - answered
  - not answered
  - marked
  - marked and answered
- Add timer lock behavior.
- Add result analysis by subject/chapter/mistake reason.

### Step 5: Make Planner Integration Real

- Implement `PrepProvider.createRoadmapTask`.
- Add "Create task" buttons from roadmap checkpoints and weak-subject recommendations.
- Store generated task tags such as:
  - `roadmap`
  - `pyq`
  - `mock-review`
  - `weak-topic`

### Step 6: Secure AI And Content

- Deploy `mentorChat` with secrets:
  - `GEMINI_API_KEY`
  - `OPENAI_API_KEY`
- Verify cloud mentor calls from app settings.
- Add Firebase App Check before opening production content broadly.
- Keep user API-key fallback for development only.

## Verification Status

Recent verification before the upload/documentation work:

- `flutter analyze`: passed
- `flutter test`: passed
- `flutter build web`: passed
- Runtime web screenshots verified via Chrome DevTools Protocol

After this documentation/upload-infra pass, run again:

```powershell
dart format lib test
flutter analyze
flutter test
```

## Continuation Prompt

Use this prompt to continue development in a new Codex/Gemini session:

```text
You are continuing development of the Flutter/Firebase app at:
C:\flutter projects\sitheer

Goal: continue building the myTayari-style GATE prep app, with emphasis on Phase 3 content scale and PYQ upload integration.

Read these first:
- docs/PROJECT_STATUS_AND_CONTINUATION_PROMPT.md
- lib/main.dart
- lib/providers/prep_provider.dart
- lib/repositories/prep_repository.dart
- lib/model/prep_content.dart
- lib/data/prep_content_codec.dart
- lib/screens/prep/vault_screen.dart
- lib/screens/prep/resource_detail_screen.dart
- functions/scripts/upload-pyq-volumes.js
- firestore.rules
- storage.rules

Current state:
- Six-tab Flutter shell exists: Ask, Roadmap, Vault, Mocks, Progress, Planner.
- GATE CS and GATE DA catalog scaffolds exist.
- Prep progress persists locally and syncs to Firebase user docs.
- AI mentor routing exists with offline fallback, local Gemini/OpenAI clients, and Firebase callable proxy.
- Admin SDK upload script exists for user-provided GATE CSE PYQ PDFs.
- User PDFs are:
  - C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume1.pdf
  - C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume2.pdf

Next task:
1. Run and verify the PYQ upload dry run:
   npm run upload:pyq -- --dry-run --exam=gate-cs "C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume1.pdf" "C:\Users\abhay\OneDrive\Documents\cse gate 2027 prep\volume2.pdf"
2. Add app-side support for uploaded PYQ volumes:
   - create PyqVolume model
   - add codec/fromMap/toMap helpers if useful
   - add PrepRepository.fetchPyqVolumes(examId)
   - add PrepProvider state/getter/refresh method for pyqVolumes
   - show a PYQ Volumes section in VaultScreen
   - open PDFs through Firebase Storage download URLs
3. Keep PDFs and service account files out of git.
4. Run dart format, flutter analyze, and flutter test.
5. Report exactly what is implemented, what is verified, and what remains.

Constraints:
- Do not copy protected third-party content.
- Treat the PDFs as user-provided material.
- Do not commit node_modules, PDFs, service account JSON files, or secrets.
- Prefer Admin SDK scripts for content writes; client should read content only.
```

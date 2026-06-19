# Release & Security Guide

Operational guide for shipping Sitheer to other users and hardening it. Pair
this with the security posture already in the repo:

- `firestore.rules` — per-user isolation (`users/{uid}` only by owner), content
  read-only, default-deny catch-all.
- `storage.rules` — content read-only, default-deny.
- `functions/index.js` — `mentorChat` is auth-gated, input-validated (<= 2000
  chars), per-user **rate limited**, and leaks no upstream error detail.
- Secrets: none in the repo. `.gitignore` covers `.env`, `*.local.json`,
  `service-account*.json`, `key.properties`, `*.jks`, `*.keystore`.

---

## 1. Distribute the app

### Web (easiest — no install for users)
```bash
flutter build web
firebase deploy --only hosting,firestore,storage
```
Publishes to `https://sitheer.web.app` (and updates the security rules). Each
visitor gets anonymous auth and their own synced progress. All PYQs are bundled
as assets, so practice works fully offline.

### Android APK (sideload / GitHub Release)
```bash
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```
Share the APK directly, or attach it to a GitHub Release:
```bash
gh release create v1.0.0 build/app/outputs/flutter-apk/app-release.apk \
  --title "Sitheer v1.0.0" --notes "GATE PYQ practice app"
```

### Google Play
Use an app bundle and a **release keystore** (see §3):
```bash
flutter build appbundle --release
```

---

## 2. AI mentor cost protection

The `mentorChat` cloud function proxies Gemini/OpenAI so users never need their
own keys. Two protections are in place / available:

- **Rate limit (active in code):** `RATE_LIMIT = 20` calls per 60s per user,
  enforced via a transaction on `rateLimits/{uid}`. Tune in `functions/index.js`.
- **App Check (scaffolded, off by default):** the function reads
  `enforceAppCheck: process.env.ENFORCE_APP_CHECK === 'true'`. Turn it on only
  after completing the client + console setup below, or every call is rejected.

Also set a **hard budget cap / quota** on the Gemini and OpenAI keys in their
respective consoles as a final backstop.

Deploy the function with secrets:
```bash
firebase functions:secrets:set GEMINI_API_KEY
firebase functions:secrets:set OPENAI_API_KEY
firebase deploy --only functions
```

### Enabling App Check (optional hardening)
1. Firebase console -> App Check: register the Android app (**Play Integrity**)
   and the web app (**reCAPTCHA Enterprise**).
2. Add the client dependency and activate it in `main.dart` after
   `Firebase.initializeApp(...)`:
   ```dart
   // pubspec.yaml: firebase_app_check: <version compatible with firebase_core>
   await FirebaseAppCheck.instance.activate(
     androidProvider: AndroidProvider.playIntegrity,
     webProvider: ReCaptchaV3Provider('<your-recaptcha-site-key>'),
   );
   ```
3. Redeploy the function with `ENFORCE_APP_CHECK=true` so non-app clients are
   rejected (also enforce App Check on Firestore/Storage in the console).

---

## 3. Release signing (Google Play)

`android/app/build.gradle.kts` already loads signing from
`android/key.properties` (gitignored) and falls back to debug signing when it
is absent. To produce a Play-ready signed build:

1. Generate a keystore **once** and back it up safely (losing it means you can
   never update the app on Play):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and fill in
   the passwords, alias, and absolute `storeFile` path.
3. Build: `flutter build appbundle --release` (or `apk`). It is now signed with
   the release key.

> The current `app-release.apk` in `build/` is signed with the **debug** key —
> fine for sideloading, not accepted by Google Play.

---

## 4. Optional: host the question bank in Firestore

The 499 questions ship as bundled assets and work offline. To also host them in
Firestore (so the bank can grow without re-releasing the app):
```bash
cd functions
GOOGLE_APPLICATION_CREDENTIALS=service-account.local.json npm run seed:questions
```
The app merges cloud questions over the bundled set at startup.

---

## 5. Pre-release checklist

- [ ] `dart format lib test` && `flutter analyze` (zero issues) && `flutter test`
- [ ] `cd functions && npm audit` — current findings are transitive deps of
      `firebase-admin` (server-side only). `npm audit fix --force` clears them
      but bumps `firebase-admin`/`firebase-functions` majors — test the function
      and import scripts afterward.
- [ ] Budget caps set on Gemini/OpenAI keys.
- [ ] Release keystore generated and backed up (for Play).
- [ ] App Check enabled if releasing broadly.

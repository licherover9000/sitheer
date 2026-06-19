const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

const geminiKey = defineSecret('GEMINI_API_KEY');
const openaiKey = defineSecret('OPENAI_API_KEY');

// Per-user rate limit: at most RATE_LIMIT calls per RATE_WINDOW_MS window.
// Prevents a single (even anonymous) user from running up Gemini/OpenAI cost.
const RATE_LIMIT = 20;
const RATE_WINDOW_MS = 60 * 1000;

// App Check: keep enforcement OFF until the app is registered for App Check in
// the Firebase console (Play Integrity for Android, reCAPTCHA for web) and the
// client calls FirebaseAppCheck.activate(...). Turn it on by deploying with
//   firebase functions:config / env  ENFORCE_APP_CHECK=true
// Enabling it before registration would reject every call.
const ENFORCE_APP_CHECK = process.env.ENFORCE_APP_CHECK === 'true';

/**
 * Enforces a fixed-window per-user rate limit using a transaction on
 * rateLimits/{uid}. Throws 'resource-exhausted' when the limit is exceeded.
 */
async function enforceRateLimit(uid) {
  const ref = db.collection('rateLimits').doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const now = Date.now();
    const data = snap.exists ? snap.data() : null;
    if (!data || now - data.windowStart >= RATE_WINDOW_MS) {
      tx.set(ref, { count: 1, windowStart: now });
      return;
    }
    if (data.count >= RATE_LIMIT) {
      throw new HttpsError(
        'resource-exhausted',
        'Too many requests. Please wait a moment and try again.'
      );
    }
    tx.update(ref, { count: data.count + 1 });
  });
}

/**
 * Callable: mentorChat
 * data: { question, systemPrompt, userPrompt, provider: 'gemini'|'openai'|'both' }
 *
 * Deploy secrets:
 *   firebase functions:secrets:set GEMINI_API_KEY
 *   firebase functions:secrets:set OPENAI_API_KEY
 */
exports.mentorChat = onCall(
  { secrets: [geminiKey, openaiKey], cors: true, enforceAppCheck: ENFORCE_APP_CHECK },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    // Cost-abuse protection: throttle per authenticated user.
    await enforceRateLimit(request.auth.uid);

    const { question, systemPrompt, userPrompt, provider = 'gemini' } =
      request.data || {};
    if (!question || typeof question !== 'string' || question.length > 2000) {
      throw new HttpsError('invalid-argument', 'Question required (max 2000 chars).');
    }
    if (!['gemini', 'openai', 'both'].includes(provider)) {
      throw new HttpsError('invalid-argument', 'Invalid provider.');
    }

    const system =
      typeof systemPrompt === 'string' && systemPrompt.length <= 4000
        ? systemPrompt
        : 'You are a GATE exam mentor.';
    const user =
      typeof userPrompt === 'string' && userPrompt.length <= 4000
        ? userPrompt
        : question;

    async function callGemini() {
      const key = geminiKey.value();
      const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' +
        key;
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: system }] },
          contents: [{ role: 'user', parts: [{ text: user }] }],
          generationConfig: { temperature: 0.65, maxOutputTokens: 1200 },
        }),
      });
      if (!res.ok) {
        console.error('Gemini API error', res.status, await res.text());
        throw new Error('Gemini request failed (' + res.status + ')');
      }
      const json = await res.json();
      return json.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || '';
    }

    async function callOpenai() {
      const key = openaiKey.value();
      const res = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer ' + key,
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          temperature: 0.65,
          max_tokens: 1200,
          messages: [
            { role: 'system', content: system },
            { role: 'user', content: user },
          ],
        }),
      });
      if (!res.ok) {
        console.error('OpenAI API error', res.status, await res.text());
        throw new Error('OpenAI request failed (' + res.status + ')');
      }
      const json = await res.json();
      return json.choices?.[0]?.message?.content?.trim() || '';
    }

    try {
      if (provider === 'both') {
        const [g, o] = await Promise.all([
          callGemini().catch((e) => ({ error: e.message })),
          callOpenai().catch((e) => ({ error: e.message })),
        ]);
        const sections = [];
        const sources = [];
        if (typeof g === 'string' && g) {
          sources.push('gemini');
          sections.push('**Study plan (Gemini)**\n' + g);
        }
        if (typeof o === 'string' && o) {
          sources.push('openai');
          sections.push('**Concept coaching (OpenAI)**\n' + o);
        }
        return { answer: sections.join('\n\n'), sources };
      }
      if (provider === 'openai') {
        return { answer: await callOpenai(), sources: ['openai'] };
      }
      return { answer: await callGemini(), sources: ['gemini'] };
    } catch (e) {
      if (e instanceof HttpsError) throw e;
      throw new HttpsError('internal', e.message || 'Mentor request failed');
    }
  },
);

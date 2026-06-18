const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');

const geminiKey = defineSecret('GEMINI_API_KEY');
const openaiKey = defineSecret('OPENAI_API_KEY');

/**
 * Callable: mentorChat
 * data: { question, systemPrompt, userPrompt, provider: 'gemini'|'openai'|'both' }
 *
 * Deploy secrets:
 *   firebase functions:secrets:set GEMINI_API_KEY
 *   firebase functions:secrets:set OPENAI_API_KEY
 */
exports.mentorChat = onCall(
  { secrets: [geminiKey, openaiKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const { question, systemPrompt, userPrompt, provider = 'gemini' } =
      request.data || {};
    if (!question || typeof question !== 'string' || question.length > 2000) {
      throw new HttpsError('invalid-argument', 'Question required (max 2000 chars).');
    }

    const system = systemPrompt || 'You are a GATE exam mentor.';
    const user = userPrompt || question;

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
      throw new HttpsError('internal', e.message || 'Mentor request failed');
    }
  },
);

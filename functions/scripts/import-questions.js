#!/usr/bin/env node

// Imports curated PYQ question JSON into Firestore under
//   content/exams/items/{examId}/questions/{questionId}
//
// The same JSON files ship as app assets, so the cloud copy is optional and
// only needed when you want a bank larger than what is bundled. The app merges
// cloud questions on top of the bundled set at startup.
//
// Usage (from functions/):
//   npm run seed:questions -- --dry-run
//   GOOGLE_APPLICATION_CREDENTIALS=service-account.local.json npm run seed:questions
//
// Optional: pass a directory to override the default asset folder:
//   node scripts/import-questions.js ../assets/questions

const fs = require('node:fs');
const path = require('node:path');
const admin = require('firebase-admin');

const positional = process.argv.slice(2).filter((a) => !a.startsWith('--'));
const dryRun = process.argv.includes('--dry-run');
const target = positional[0] || '../assets/questions';
const dir = path.resolve(__dirname, '..', target);

// Map asset filename -> Firestore examId (must match examIdFromLabel in app).
const EXAM_BY_FILE = {
  'gate-cs.json': 'gate-cs',
  'gate-da.json': 'gate-da',
};

function loadFiles() {
  if (!fs.existsSync(dir)) {
    throw new Error(`Questions path not found: ${dir}`);
  }
  return fs
    .readdirSync(dir)
    .filter((name) => name.endsWith('.json'))
    .map((name) => ({
      name,
      examId: EXAM_BY_FILE[name],
      questions: JSON.parse(fs.readFileSync(path.join(dir, name), 'utf8')),
    }));
}

function validate(examId, questions, name) {
  if (!examId) {
    throw new Error(`${name}: no examId mapping (add it to EXAM_BY_FILE).`);
  }
  if (!Array.isArray(questions)) {
    throw new Error(`${name}: top-level JSON must be an array.`);
  }
  const ids = new Set();
  for (const q of questions) {
    if (!q.id || !q.chapterId || !q.prompt) {
      throw new Error(`${name}: a question is missing id/chapterId/prompt.`);
    }
    if (ids.has(q.id)) throw new Error(`${name}: duplicate id ${q.id}.`);
    ids.add(q.id);
    const type = q.type || 'mcq';
    if (type === 'mcq' && !(Array.isArray(q.options) && q.options.length >= 2)) {
      throw new Error(`${name}: MCQ ${q.id} needs >=2 options.`);
    }
    if (type === 'msq' && !(Array.isArray(q.correctIndexes) && q.correctIndexes.length)) {
      throw new Error(`${name}: MSQ ${q.id} needs correctIndexes.`);
    }
    if (type === 'nat' && typeof q.numericAnswer !== 'number') {
      throw new Error(`${name}: NAT ${q.id} needs a numericAnswer.`);
    }
  }
}

async function main() {
  const files = loadFiles();
  for (const { name, examId, questions } of files) {
    validate(examId, questions, name);
  }

  const total = files.reduce((n, f) => n + f.questions.length, 0);
  if (dryRun) {
    for (const { name, examId, questions } of files) {
      console.log(`[dry-run] ${examId}: ${questions.length} questions from ${name}`);
    }
    console.log(`[dry-run] ${total} question(s) would be imported.`);
    return;
  }

  admin.initializeApp();
  const db = admin.firestore();

  for (const { examId, questions } of files) {
    const col = db
      .collection('content')
      .doc('exams')
      .collection('items')
      .doc(examId)
      .collection('questions');

    // Firestore batches are limited to 500 writes.
    for (let i = 0; i < questions.length; i += 450) {
      const batch = db.batch();
      for (const q of questions.slice(i, i + 450)) {
        batch.set(col.doc(q.id), {
          ...q,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
    console.log(`Imported ${questions.length} questions for ${examId}.`);
  }
  console.log(`Done: ${total} question(s).`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

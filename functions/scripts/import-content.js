#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const admin = require('firebase-admin');

const target = process.argv[2] || '../content/seed';
const dryRun = process.argv.includes('--dry-run');
const resolved = path.resolve(__dirname, '..', target);

function readJsonFiles(inputPath) {
  if (!fs.existsSync(inputPath)) {
    throw new Error(`Seed path not found: ${inputPath}`);
  }

  const stat = fs.statSync(inputPath);
  const files = stat.isDirectory()
    ? fs
        .readdirSync(inputPath)
        .filter((name) => name.endsWith('.json'))
        .map((name) => path.join(inputPath, name))
    : [inputPath];

  if (files.length === 0) {
    throw new Error(`No .json seed files found in ${inputPath}`);
  }

  return files.map((filePath) => ({
    filePath,
    data: JSON.parse(fs.readFileSync(filePath, 'utf8')),
  }));
}

function validateBundle(bundle, filePath) {
  const required = ['examId', 'examLabel', 'version', 'subjects', 'roadmapWeeks', 'mockPapers'];
  for (const key of required) {
    if (!(key in bundle)) {
      throw new Error(`${filePath}: missing required key "${key}"`);
    }
  }
  if (!Array.isArray(bundle.subjects) || bundle.subjects.length === 0) {
    throw new Error(`${filePath}: subjects must be a non-empty array`);
  }
  if (!Array.isArray(bundle.roadmapWeeks)) {
    throw new Error(`${filePath}: roadmapWeeks must be an array`);
  }
  if (!Array.isArray(bundle.mockPapers)) {
    throw new Error(`${filePath}: mockPapers must be an array`);
  }
}

async function main() {
  const bundles = readJsonFiles(resolved);

  for (const { filePath, data } of bundles) {
    validateBundle(data, filePath);
  }

  if (dryRun) {
    for (const { filePath, data } of bundles) {
      console.log(`[dry-run] ${data.examId}: ${data.subjects.length} subjects from ${filePath}`);
    }
    return;
  }

  admin.initializeApp();
  const db = admin.firestore();
  const batch = db.batch();

  for (const { filePath, data } of bundles) {
    const ref = db.collection('content').doc('exams').collection('items').doc(data.examId);
    batch.set(ref, {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      importedFrom: path.basename(filePath),
    });
    console.log(`Queued ${data.examId}: ${data.subjects.length} subjects`);
  }

  await batch.commit();
  console.log(`Imported ${bundles.length} exam bundle(s).`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const admin = require('firebase-admin');

function parseArgs(argv) {
  const out = {
    examId: 'gate-cs',
    bucket: process.env.FIREBASE_STORAGE_BUCKET || 'sitheer.firebasestorage.app',
    dryRun: false,
    files: [],
  };

  for (const arg of argv) {
    if (arg === '--dry-run') {
      out.dryRun = true;
    } else if (arg.startsWith('--exam=')) {
      out.examId = arg.slice('--exam='.length);
    } else if (arg.startsWith('--bucket=')) {
      out.bucket = arg.slice('--bucket='.length);
    } else {
      out.files.push(arg);
    }
  }

  return out;
}

function sha256(filePath) {
  const hash = crypto.createHash('sha256');
  const bytes = fs.readFileSync(filePath);
  hash.update(bytes);
  return hash.digest('hex');
}

function volumeMetadata(filePath, index, examId) {
  const resolved = path.resolve(filePath);
  if (!fs.existsSync(resolved)) {
    throw new Error(`PDF not found: ${resolved}`);
  }
  const stat = fs.statSync(resolved);
  if (!stat.isFile()) {
    throw new Error(`Not a file: ${resolved}`);
  }
  if (path.extname(resolved).toLowerCase() !== '.pdf') {
    throw new Error(`Only PDF files are supported: ${resolved}`);
  }

  const volumeNumber = index + 1;
  const id = `${examId}-pyq-volume-${volumeNumber}`;
  const fileName = `volume-${volumeNumber}.pdf`;
  const storagePath = `content/${examId}/pyq/${fileName}`;

  return {
    id,
    examId,
    title: `GATE CSE PYQ Volume ${volumeNumber}`,
    description: `Uploaded PYQ source PDF volume ${volumeNumber}.`,
    sourceKind: 'pdf-volume',
    order: volumeNumber,
    fileName,
    localPath: resolved,
    storagePath,
    contentType: 'application/pdf',
    sizeBytes: stat.size,
    sha256: sha256(resolved),
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.files.length === 0) {
    throw new Error(
      'Usage: npm run upload:pyq -- --exam=gate-cs "C:\\path\\volume1.pdf" "C:\\path\\volume2.pdf"',
    );
  }

  const volumes = args.files.map((file, index) =>
    volumeMetadata(file, index, args.examId),
  );

  if (args.dryRun) {
    for (const volume of volumes) {
      console.log(
        `[dry-run] ${volume.id} -> gs://${args.bucket}/${volume.storagePath} (${volume.sizeBytes} bytes, sha256 ${volume.sha256})`,
      );
    }
    return;
  }

  admin.initializeApp({ storageBucket: args.bucket });
  const db = admin.firestore();
  const bucket = admin.storage().bucket(args.bucket);

  const batch = db.batch();
  for (const volume of volumes) {
    await bucket.upload(volume.localPath, {
      destination: volume.storagePath,
      resumable: true,
      metadata: {
        contentType: volume.contentType,
        cacheControl: 'private, max-age=3600',
        metadata: {
          examId: volume.examId,
          volumeId: volume.id,
          sha256: volume.sha256,
        },
      },
    });

    const { localPath, ...doc } = volume;
    const ref = db
      .collection('content')
      .doc('pyqVolumes')
      .collection('items')
      .doc(volume.id);
    batch.set(ref, {
      ...doc,
      uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`Uploaded ${volume.id} -> gs://${args.bucket}/${volume.storagePath}`);
  }

  await batch.commit();
  console.log(`Saved ${volumes.length} PYQ volume metadata document(s).`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

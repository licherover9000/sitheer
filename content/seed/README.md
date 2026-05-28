# Content Seed Imports

Put production exam catalog JSON files in this directory, one file per exam
bundle. The Admin SDK importer writes each file to:

`content/exams/items/{examId}`

Run from the `functions` directory:

```bash
npm run seed:content -- --dry-run
npm run seed:content
```

The importer expects Firebase Admin credentials from the environment. For local
testing, use the Firebase emulator or set `GOOGLE_APPLICATION_CREDENTIALS` to a
service-account JSON file that is not committed to git.

Do not paste copyrighted notes, PDFs, or full question banks here unless you own
the rights or have permission to distribute them.

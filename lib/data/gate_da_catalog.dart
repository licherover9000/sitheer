import 'package:flutter/material.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/model/prep_content.dart';

/// GATE DA-specific subjects (shared math/apt live in [prepSubjects]).
final gateDaSubjects = <PrepSubject>[
  PrepSubject(
    code: 'prog-da',
    title: 'Programming & DS',
    subtitle: 'Python, complexity, basic structures',
    icon: Icons.code_outlined,
    accent: const Color(0xFF7C3AED),
    progress: 0.58,
    chapters: [
      prepChapter(
        'prog-da-python',
        'Python for data science',
        'High',
        'Medium',
        40,
        0.62,
        [
          prepPyq(
            'Programming PYQs',
            'Lists, dicts, comprehensions',
            '40 questions',
            id: 'prog-da-pyq-1',
            url: 'https://gate2024.iisc.ac.in/',
          ),
          prepLecture(
            'Python revision playlist',
            'NumPy-friendly patterns for DA',
            id: 'prog-da-lec-1',
            url: 'https://www.youtube.com/results?search_query=gate+da+python',
          ),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'stats',
    title: 'Statistics',
    subtitle: 'Distributions, estimation, hypothesis tests',
    icon: Icons.bar_chart_outlined,
    accent: const Color(0xFFDB2777),
    progress: 0.49,
    chapters: [
      prepChapter(
        'stats-core',
        'Probability & statistics core',
        'Very high',
        'Hard',
        55,
        0.51,
        [
          prepPyq(
            'Statistics PYQ pack',
            'Mean, variance, distributions',
            '55 questions',
            id: 'stats-pyq-1',
          ),
          prepFormula(
            'Distribution cheat sheet',
            'PDF, CDF, common formulas',
            id: 'stats-form-1',
          ),
          prepNotes(
            'Hypothesis testing notes',
            'p-value, t-test, chi-square',
            id: 'stats-notes-1',
          ),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'ml',
    title: 'Machine Learning',
    subtitle: 'Supervised learning, evaluation, basics',
    icon: Icons.model_training_outlined,
    accent: const Color(0xFFEA580C),
    progress: 0.44,
    chapters: [
      prepChapter(
        'ml-supervised',
        'Supervised learning',
        'High',
        'Medium',
        35,
        0.46,
        [
          prepPyq(
            'ML concept PYQs',
            'Regression, classification, metrics',
            '35 questions',
            id: 'ml-pyq-1',
          ),
          prepLecture(
            'ML fundamentals playlist',
            'Bias-variance, cross-validation',
            id: 'ml-lec-1',
            url:
                'https://www.youtube.com/results?search_query=gate+da+machine+learning',
          ),
        ],
      ),
    ],
  ),
];

final gateDaRoadmapWeeks = <RoadmapWeek>[
  const RoadmapWeek(
    week: 1,
    title: 'DA diagnostic & math refresh',
    phase: 'Diagnostic',
    hours: 16,
    focus: 'Baseline DA mock, tag weak stats and programming areas.',
    outcomes: [
      'Stream locked to GATE DA',
      'Math accuracy baseline recorded',
      'First 80 PYQs attempted',
    ],
    checkpoints: [
      'Attempt one previous DA paper',
      'Review linear algebra mistakes',
      'Set daily study slots',
    ],
    subjectCodes: ['math', 'apt'],
  ),
  const RoadmapWeek(
    week: 2,
    title: 'Statistics foundation',
    phase: 'Math base',
    hours: 20,
    focus: 'Distributions and hypothesis testing for DA weightage.',
    outcomes: [
      'Stats PYQ accuracy above 60%',
      'Formula cards for distributions',
    ],
    checkpoints: ['Finish statistics PYQ pack', 'Revise probability bridges'],
    subjectCodes: ['stats', 'math'],
  ),
  const RoadmapWeek(
    week: 3,
    title: 'Programming for DA',
    phase: 'Core CS',
    hours: 22,
    focus: 'Python patterns and complexity for exam-style questions.',
    outcomes: [
      'Programming PYQs grouped by pattern',
      'Complexity traps documented',
    ],
    checkpoints: [
      'Complete programming PYQ set',
      'Timed 30-minute programming sprint',
    ],
    subjectCodes: ['prog-da', 'ds'],
  ),
  const RoadmapWeek(
    week: 4,
    title: 'Machine learning block',
    phase: 'Core CS',
    hours: 24,
    focus: 'Supervised models, metrics, and evaluation loops.',
    outcomes: ['ML concept PYQs attempted', 'Evaluation metrics memorized'],
    checkpoints: [
      'Finish ML PYQ pack',
      'Write one-page model comparison sheet',
    ],
    subjectCodes: ['ml'],
  ),
  const RoadmapWeek(
    week: 5,
    title: 'Mixed DA PYQ loop',
    phase: 'PYQ loops',
    hours: 28,
    focus: 'Cross-subject previous-year practice.',
    outcomes: ['200 mixed PYQs tracked', 'Weak chapters ranked'],
    checkpoints: [
      'Tag every wrong answer',
      'Retake failed questions after 48h',
    ],
    subjectCodes: ['math', 'stats', 'prog-da', 'ml', 'apt'],
  ),
  const RoadmapWeek(
    week: 6,
    title: 'DA mock week',
    phase: 'Mock analysis',
    hours: 30,
    focus: 'Full DA papers and score-band college shortlist.',
    outcomes: ['Two full mocks completed', 'Time-per-section plan set'],
    checkpoints: [
      'Attempt two full-length DA papers',
      'Review incorrect and skipped items',
      'Run college predictor bands',
    ],
    subjectCodes: ['math', 'stats', 'prog-da', 'ml', 'apt'],
  ),
];

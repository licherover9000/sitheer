import 'package:flutter/material.dart';
import 'package:sitheer/model/prep_content.dart';

const supportedExams = ['GATE CS', 'GATE DA'];

const mentorPrompts = [
  'Explain why my Operating Systems answer is wrong.',
  'Build a 7 day plan for DBMS normalization and transactions.',
  'Pick 20 must-do PYQs from Computer Networks.',
  'Estimate my rank if I score 52 in a full mock.',
];

const studyMapPhases = [
  'Diagnostic',
  'Math base',
  'Core CS',
  'Systems',
  'PYQ loops',
  'Mock analysis',
  'Admission shortlist',
];

final prepSubjects = <PrepSubject>[
  PrepSubject(
    code: 'algo',
    title: 'Algorithms',
    subtitle: 'Sorting, graphs, greedy, dynamic programming',
    icon: Icons.account_tree_outlined,
    accent: const Color(0xFF2563EB),
    progress: 0.72,
    chapters: [
      prepChapter(
        'algo-sorting',
        'Sorting and asymptotic analysis',
        'High',
        'Medium',
        68,
        0.78,
        [
          prepPyq(
            'Sorting PYQ drill',
            '2005 to 2025 mixed set',
            '68 questions',
          ),
          prepFormula(
            'Asymptotic cheat sheet',
            'Growth rules and common traps',
          ),
          prepNotes(
            'Divide and conquer notes',
            'Recurrences, mergesort, quicksort',
          ),
        ],
      ),
      prepChapter(
        'algo-graphs',
        'Graph algorithms',
        'Very high',
        'Hard',
        96,
        0.61,
        [
          prepPyq(
            'Graph PYQ pack',
            'Traversal, MST, shortest paths',
            '96 questions',
          ),
          prepLecture(
            'Graph revision playlist',
            'Concept order for exam practice',
          ),
          prepFormula(
            'Shortest path quick cards',
            'Dijkstra, Bellman Ford, Floyd Warshall',
          ),
        ],
      ),
      prepChapter(
        'algo-dp',
        'Greedy and dynamic programming',
        'High',
        'Hard',
        72,
        0.54,
        [
          prepPyq(
            'DP and greedy must-practice',
            'Knapsack, LIS, activity selection',
            '72 questions',
          ),
          prepNotes('State design notebook', 'How to model recurrence states'),
          prepMock('Algorithm section test', 'Timed 45 minute chapter test'),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'ds',
    title: 'Data Structures',
    subtitle: 'Arrays, trees, hashing, heaps',
    icon: Icons.storage_outlined,
    accent: const Color(0xFF0891B2),
    progress: 0.81,
    chapters: [
      prepChapter(
        'ds-linear',
        'Stacks, queues, linked lists',
        'Medium',
        'Easy',
        48,
        0.84,
        [
          prepPyq(
            'Linear structures set',
            'Implementation and dry-run questions',
            '48 questions',
          ),
          prepNotes(
            'Pointer operation notes',
            'Insert, delete, reverse, detect cycle',
          ),
        ],
      ),
      prepChapter(
        'ds-trees',
        'Trees and binary search trees',
        'High',
        'Medium',
        74,
        0.69,
        [
          prepPyq(
            'Tree traversal PYQs',
            'BST, AVL, heaps, expression trees',
            '74 questions',
          ),
          prepFormula(
            'Tree property cards',
            'Height, leaves, nodes, balance rules',
          ),
          prepMock('Trees speed test', '30 questions with explanations'),
        ],
      ),
      prepChapter(
        'ds-hashing',
        'Hashing and collision handling',
        'Medium',
        'Medium',
        38,
        0.74,
        [
          prepPyq(
            'Hashing PYQ pack',
            'Open addressing and chaining',
            '38 questions',
          ),
          prepNotes('Load factor guide', 'Probe sequences and clustering'),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'os',
    title: 'Operating Systems',
    subtitle: 'Processes, memory, scheduling, files',
    icon: Icons.memory_outlined,
    accent: const Color(0xFF7C3AED),
    progress: 0.58,
    chapters: [
      prepChapter(
        'os-process',
        'Processes, threads, scheduling',
        'Very high',
        'Medium',
        82,
        0.57,
        [
          prepPyq(
            'Scheduling PYQ lab',
            'Gantt charts, CPU utilization, waiting time',
            '82 questions',
          ),
          prepFormula(
            'Scheduling formula cards',
            'TAT, WT, response time, throughput',
          ),
          prepLecture(
            'OS scheduling map',
            'Concept order with practice checkpoints',
          ),
        ],
      ),
      prepChapter('os-memory', 'Memory management', 'High', 'Hard', 77, 0.49, [
        prepPyq(
          'Paging and segmentation PYQs',
          'Address translation and replacement',
          '77 questions',
        ),
        prepNotes('Virtual memory notebook', 'TLB, page faults, working set'),
        prepMock('Memory management test', 'Exam-style timed practice'),
      ]),
      prepChapter(
        'os-sync',
        'Synchronization and deadlocks',
        'High',
        'Hard',
        55,
        0.52,
        [
          prepPyq(
            'Deadlock and semaphore PYQs',
            'RAG, bankers, monitors',
            '55 questions',
          ),
          prepFormula(
            'Synchronization quick cards',
            'Mutex, semaphore, conditions',
          ),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'dbms',
    title: 'DBMS',
    subtitle: 'ER model, SQL, normalization, transactions',
    icon: Icons.table_chart_outlined,
    accent: const Color(0xFF059669),
    progress: 0.66,
    chapters: [
      prepChapter(
        'dbms-sql',
        'Relational algebra and SQL',
        'Very high',
        'Medium',
        88,
        0.67,
        [
          prepPyq(
            'SQL and RA PYQ pack',
            'Queries, joins, division, aggregation',
            '88 questions',
          ),
          prepNotes(
            'Relational algebra guide',
            'Operator patterns and conversions',
          ),
          prepMock('SQL mini mock', 'Timed query reasoning test'),
        ],
      ),
      prepChapter(
        'dbms-normal',
        'Functional dependency and normalization',
        'High',
        'Hard',
        64,
        0.58,
        [
          prepPyq(
            'Normalization PYQs',
            'Closures, keys, 2NF, 3NF, BCNF',
            '64 questions',
          ),
          prepFormula(
            'FD closure cards',
            'Attribute closure and decomposition rules',
          ),
        ],
      ),
      prepChapter(
        'dbms-txn',
        'Transactions and concurrency',
        'High',
        'Hard',
        59,
        0.55,
        [
          prepPyq(
            'Transaction schedule lab',
            'Serializability and recoverability',
            '59 questions',
          ),
          prepNotes('Concurrency notebook', 'Locks, timestamps, deadlocks'),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'cn',
    title: 'Computer Networks',
    subtitle: 'Layering, routing, TCP, DNS',
    icon: Icons.hub_outlined,
    accent: const Color(0xFFEA580C),
    progress: 0.46,
    chapters: [
      prepChapter(
        'cn-physical',
        'Signals, encoding, data link',
        'Medium',
        'Medium',
        45,
        0.62,
        [
          prepPyq(
            'Data link PYQs',
            'CRC, sliding window, framing',
            '45 questions',
          ),
          prepFormula(
            'Networking formula cards',
            'Bandwidth, delay, throughput',
          ),
        ],
      ),
      prepChapter(
        'cn-routing',
        'IP, routing, subnetting',
        'Very high',
        'Hard',
        83,
        0.41,
        [
          prepPyq(
            'Subnetting and routing pack',
            'CIDR, routing tables, Dijkstra',
            '83 questions',
          ),
          prepNotes('Subnet practice sheet', 'Fast binary-to-prefix workflow'),
          prepMock('Networks section test', 'Full chapter assessment'),
        ],
      ),
      prepChapter(
        'cn-transport',
        'TCP, UDP, application layer',
        'High',
        'Medium',
        61,
        0.48,
        [
          prepPyq(
            'TCP and DNS PYQs',
            'Congestion, flow control, name lookup',
            '61 questions',
          ),
          prepLecture(
            'Transport layer revision',
            'High-yield explanation playlist',
          ),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'toc',
    title: 'Theory of Computation',
    subtitle: 'Automata, grammars, decidability',
    icon: Icons.schema_outlined,
    accent: const Color(0xFFDC2626),
    progress: 0.39,
    chapters: [
      prepChapter(
        'toc-fa',
        'Finite automata and regular languages',
        'High',
        'Medium',
        73,
        0.44,
        [
          prepPyq(
            'Automata PYQ pack',
            'DFA, NFA, regex, minimization',
            '73 questions',
          ),
          prepNotes(
            'Language closure map',
            'Closure and pumping lemma patterns',
          ),
        ],
      ),
      prepChapter(
        'toc-cfg',
        'Context free grammar and PDA',
        'High',
        'Hard',
        62,
        0.36,
        [
          prepPyq(
            'CFG and PDA PYQs',
            'Ambiguity, CNF, stack machines',
            '62 questions',
          ),
          prepMock('TOC timed drill', 'Exam-style 60 minute set'),
        ],
      ),
      prepChapter(
        'toc-tm',
        'Turing machines and decidability',
        'Medium',
        'Hard',
        41,
        0.33,
        [
          prepPyq(
            'Decidability PYQs',
            'Recursive, RE, reductions',
            '41 questions',
          ),
          prepFormula('Undecidability cards', 'Common reduction templates'),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'math',
    title: 'Engineering Mathematics',
    subtitle: 'Linear algebra, calculus, probability',
    icon: Icons.functions,
    accent: const Color(0xFFB45309),
    progress: 0.63,
    chapters: [
      prepChapter('math-la', 'Linear algebra', 'High', 'Medium', 69, 0.71, [
        prepPyq(
          'Matrix and vector spaces',
          'Eigenvalues, rank, systems',
          '69 questions',
        ),
        prepFormula(
          'Linear algebra cards',
          'Rank, determinant, eigen properties',
        ),
      ]),
      prepChapter(
        'math-prob',
        'Probability and statistics',
        'High',
        'Medium',
        58,
        0.59,
        [
          prepPyq(
            'Probability PYQ pack',
            'Bayes, random variables, distributions',
            '58 questions',
          ),
          prepNotes(
            'Distribution notebook',
            'Mean, variance, standard distributions',
          ),
        ],
      ),
      prepChapter(
        'math-calc',
        'Calculus and optimization',
        'Medium',
        'Medium',
        42,
        0.56,
        [
          prepPyq(
            'Calculus PYQs',
            'Limits, derivatives, integration, maxima',
            '42 questions',
          ),
          prepMock('Math mixed test', 'High-frequency concepts together'),
        ],
      ),
    ],
  ),
  PrepSubject(
    code: 'apt',
    title: 'General Aptitude',
    subtitle: 'Verbal, quantitative, reasoning',
    icon: Icons.psychology_alt_outlined,
    accent: const Color(0xFF0F766E),
    progress: 0.86,
    chapters: [
      prepChapter('apt-verbal', 'Verbal ability', 'Medium', 'Easy', 52, 0.88, [
        prepPyq(
          'Verbal PYQ pack',
          'Grammar, sentence completion, reading',
          '52 questions',
        ),
        prepNotes(
          'Common traps list',
          'Elimination rules and vocabulary patterns',
        ),
      ]),
      prepChapter(
        'apt-quant',
        'Quantitative aptitude',
        'High',
        'Medium',
        71,
        0.79,
        [
          prepPyq(
            'Quant PYQ pack',
            'Percentages, ratios, time, work',
            '71 questions',
          ),
          prepFormula(
            'Quant formula cards',
            'Fast arithmetic and common identities',
          ),
        ],
      ),
      prepChapter(
        'apt-reason',
        'Logical reasoning',
        'Medium',
        'Medium',
        39,
        0.82,
        [
          prepPyq(
            'Reasoning PYQs',
            'Arrangements, inference, data interpretation',
            '39 questions',
          ),
          prepMock('Aptitude sprint', '30 minute mixed practice'),
        ],
      ),
    ],
  ),
];

final roadmapWeeks = <RoadmapWeek>[
  const RoadmapWeek(
    week: 1,
    title: 'Diagnostic and study setup',
    phase: 'Diagnostic',
    hours: 18,
    focus: 'Take a baseline mock, choose exam stream, and tag weak chapters.',
    outcomes: [
      'Baseline score recorded',
      'Daily study slot fixed',
      'First 120 PYQs attempted',
    ],
    checkpoints: [
      'Attempt one previous paper as a mock',
      'Create chapter backlog from wrong answers',
      'Start formula notebook',
    ],
    subjectCodes: ['apt', 'math'],
  ),
  const RoadmapWeek(
    week: 2,
    title: 'Mathematics foundation',
    phase: 'Math base',
    hours: 22,
    focus:
        'Build scoring stability in linear algebra, probability, and aptitude.',
    outcomes: [
      'Math accuracy above 65 percent',
      'Aptitude warm-up habit built',
      'Formula cards reviewed twice',
    ],
    checkpoints: [
      'Finish linear algebra PYQs',
      'Run two aptitude sprints',
      'Mark formulas that still need derivation',
    ],
    subjectCodes: ['math', 'apt'],
  ),
  const RoadmapWeek(
    week: 3,
    title: 'Data structures plus algorithms',
    phase: 'Core CS',
    hours: 26,
    focus: 'Cover high-return implementation and graph patterns first.',
    outcomes: [
      'Graph mistakes grouped by pattern',
      'Tree and heap basics refreshed',
      'One timed algorithm section complete',
    ],
    checkpoints: [
      'Solve graph PYQs by subtopic',
      'Revise sorting and asymptotic analysis',
      'Attempt the algorithm section test',
    ],
    subjectCodes: ['ds', 'algo'],
  ),
  const RoadmapWeek(
    week: 4,
    title: 'DBMS scoring block',
    phase: 'Core CS',
    hours: 24,
    focus: 'Use SQL and normalization as a reliable score base.',
    outcomes: [
      'SQL joins and division stable',
      'Closures and keys solved without notes',
      'Transaction schedule errors reviewed',
    ],
    checkpoints: [
      'Finish SQL and RA PYQ pack',
      'Do 30 normalization questions',
      'Review serializability mistakes',
    ],
    subjectCodes: ['dbms'],
  ),
  const RoadmapWeek(
    week: 5,
    title: 'Operating systems deep practice',
    phase: 'Systems',
    hours: 25,
    focus: 'Attack memory, scheduling, and synchronization with timed drills.',
    outcomes: [
      'Scheduling calculations under time',
      'Address translation errors reduced',
      'Deadlock rules memorized through practice',
    ],
    checkpoints: [
      'Complete scheduling lab',
      'Attempt paging and segmentation set',
      'Write one-page deadlock summary',
    ],
    subjectCodes: ['os'],
  ),
  const RoadmapWeek(
    week: 6,
    title: 'Networks and TOC repair loop',
    phase: 'Systems',
    hours: 27,
    focus: 'Fix the two subjects where small misconceptions cost marks.',
    outcomes: [
      'Subnetting steps become automatic',
      'Automata conversions become repeatable',
      'CFG and PDA weak spots listed',
    ],
    checkpoints: [
      'Complete routing and TCP sets',
      'Minimize 10 DFA questions',
      'Attempt one TOC timed drill',
    ],
    subjectCodes: ['cn', 'toc'],
  ),
  const RoadmapWeek(
    week: 7,
    title: 'Full PYQ loop',
    phase: 'PYQ loops',
    hours: 30,
    focus: 'Move from chapter practice to mixed previous-year practice.',
    outcomes: [
      'Mixed PYQ accuracy tracked',
      'Most-failed chapters ranked',
      'Revision queue updated daily',
    ],
    checkpoints: [
      'Do 250 mixed PYQs',
      'Tag every wrong answer with one mistake reason',
      'Retake failed questions after 48 hours',
    ],
    subjectCodes: ['algo', 'ds', 'os', 'dbms', 'cn', 'toc'],
  ),
  const RoadmapWeek(
    week: 8,
    title: 'Mock week and admissions shortlist',
    phase: 'Mock analysis',
    hours: 32,
    focus:
        'Simulate exam conditions, analyze score leaks, and shortlist colleges.',
    outcomes: [
      'Two full mocks completed',
      'Time-per-section plan finalized',
      'College shortlist prepared by rank band',
    ],
    checkpoints: [
      'Attempt two full-length papers',
      'Review every incorrect and skipped question',
      'Run predictor with target score bands',
    ],
    subjectCodes: ['apt', 'math', 'algo', 'os', 'dbms', 'cn'],
  ),
];

final mockPapers = <MockPaper>[
  const MockPaper(
    id: 'mock-gate-cs-2025',
    title: 'GATE CS full paper',
    stream: 'GATE CS',
    year: 2025,
    duration: '180 min',
    questions: 65,
    score: 51,
    accuracy: 0.68,
    status: 'Analysis ready',
    focusAreas: ['Computer Networks', 'TOC', 'Memory management'],
  ),
  const MockPaper(
    id: 'mock-gate-cs-2024',
    title: 'GATE CS previous paper',
    stream: 'GATE CS',
    year: 2024,
    duration: '180 min',
    questions: 65,
    score: 46,
    accuracy: 0.62,
    status: 'Retake suggested',
    focusAreas: ['SQL', 'Graph algorithms', 'Probability'],
  ),
  const MockPaper(
    id: 'mock-gate-da-2025',
    title: 'GATE DA aptitude bridge',
    stream: 'GATE DA',
    year: 2025,
    duration: '120 min',
    questions: 45,
    score: 38,
    accuracy: 0.71,
    status: 'New',
    focusAreas: ['Linear algebra', 'Probability', 'Reasoning'],
  ),
  const MockPaper(
    id: 'mock-sprint-os-dbms',
    title: 'Subject sprint: OS + DBMS',
    stream: 'Mixed',
    year: 2026,
    duration: '90 min',
    questions: 40,
    score: 29,
    accuracy: 0.64,
    status: 'In progress',
    focusAreas: ['Transactions', 'Deadlocks', 'Paging'],
  ),
];

final predictorColleges = <PredictorCollege>[
  const PredictorCollege(
    name: 'IISc Bangalore',
    program: 'M.Tech Computer Science',
    route: 'COAP',
    rankBand: 'Top 100',
    fit: 'Reach',
  ),
  const PredictorCollege(
    name: 'IIT Bombay',
    program: 'M.Tech CSE',
    route: 'COAP',
    rankBand: 'Top 250',
    fit: 'Reach',
  ),
  const PredictorCollege(
    name: 'NIT Trichy',
    program: 'M.Tech CSE',
    route: 'CCMT',
    rankBand: 'Top 1200',
    fit: 'Target',
  ),
  const PredictorCollege(
    name: 'IIIT Hyderabad',
    program: 'M.Tech CSE',
    route: 'Institute portal',
    rankBand: 'Score-based shortlist',
    fit: 'Track separately',
  ),
];

List<PrepResource> get allResources => [
  for (final subject in prepSubjects)
    for (final chapter in subject.chapters) ...chapter.resources,
];

PrepChapter prepChapter(
  String id,
  String title,
  String weightage,
  String difficulty,
  int pyqCount,
  double accuracy,
  List<PrepResource> resources,
) {
  return PrepChapter(
    id: id,
    title: title,
    weightage: weightage,
    difficulty: difficulty,
    pyqCount: pyqCount,
    accuracy: accuracy,
    resources: resources,
  );
}

String _resourceId(String title) =>
    title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

PrepResource prepPyq(
  String title,
  String description,
  String timeLabel, {
  String? id,
  String? url,
  String? storagePath,
}) {
  return PrepResource(
    id: id ?? _resourceId(title),
    title: title,
    type: PrepResourceType.pyq,
    source: 'Question bank',
    description: description,
    timeLabel: timeLabel,
    url: url ?? 'https://gate2024.iisc.ac.in/',
    storagePath: storagePath,
  );
}

PrepResource prepNotes(
  String title,
  String description, {
  String? id,
  String? url,
}) {
  return PrepResource(
    id: id ?? _resourceId(title),
    title: title,
    type: PrepResourceType.notes,
    source: 'Study notes',
    description: description,
    timeLabel: '15 min read',
    url: url,
  );
}

PrepResource prepFormula(
  String title,
  String description, {
  String? id,
  String? url,
}) {
  return PrepResource(
    id: id ?? _resourceId(title),
    title: title,
    type: PrepResourceType.formula,
    source: 'Formula cards',
    description: description,
    timeLabel: 'Quick revise',
    url: url,
  );
}

PrepResource prepLecture(
  String title,
  String description, {
  String? id,
  String? url,
}) {
  return PrepResource(
    id: id ?? _resourceId(title),
    title: title,
    type: PrepResourceType.lecture,
    source: 'Playlist import',
    description: description,
    timeLabel: 'Curated videos',
    url:
        url ??
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(title)}',
  );
}

PrepResource prepMock(String title, String description, {String? id}) {
  return PrepResource(
    id: id ?? _resourceId(title),
    title: title,
    type: PrepResourceType.mock,
    source: 'Timed practice',
    description: description,
    timeLabel: 'Exam mode',
    isPremium: true,
  );
}

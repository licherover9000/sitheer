import 'package:sitheer/model/prep_question.dart';

/// Sample PYQ-style questions keyed by chapter id (expand over time).
final prepQuestionsByChapter = <String, List<PrepQuestion>>{
  'algo-sorting': [
    const PrepQuestion(
      id: 'q-algo-sort-1',
      chapterId: 'algo-sorting',
      prompt: 'What is the worst-case time complexity of QuickSort?',
      options: ['O(n)', 'O(n log n)', 'O(n^2)', 'O(log n)'],
      correctIndex: 2,
      explanation: 'Poor pivot choice can degrade QuickSort to O(n^2).',
    ),
    const PrepQuestion(
      id: 'q-algo-sort-2',
      chapterId: 'algo-sorting',
      prompt: 'MergeSort is stable because:',
      options: [
        'It uses extra memory',
        'Equal elements keep relative order during merge',
        'It is in-place',
        'It uses a heap',
      ],
      correctIndex: 1,
    ),
  ],
  'ds-trees': [
    const PrepQuestion(
      id: 'q-ds-tree-1',
      chapterId: 'ds-trees',
      prompt: 'In-order traversal of a BST yields:',
      options: [
        'Random order',
        'Descending keys',
        'Sorted ascending keys',
        'Level order',
      ],
      correctIndex: 2,
    ),
  ],
  'os-memory': [
    const PrepQuestion(
      id: 'q-os-mem-1',
      chapterId: 'os-memory',
      prompt: 'Paging avoids:',
      options: [
        'External fragmentation',
        'Internal fragmentation only',
        'TLB misses',
        'Page faults',
      ],
      correctIndex: 0,
    ),
  ],
  'stats-core': [
    const PrepQuestion(
      id: 'q-stats-1',
      chapterId: 'stats-core',
      prompt: 'For a normal distribution, about 95% of values lie within:',
      options: ['1 sigma', '2 sigma', '3 sigma', '0.5 sigma'],
      correctIndex: 1,
    ),
  ],
  'prog-da-python': [
    const PrepQuestion(
      id: 'q-prog-1',
      chapterId: 'prog-da-python',
      prompt: 'Time complexity of `x in set` for a Python set is:',
      options: ['O(1) average', 'O(n)', 'O(log n)', 'O(n^2)'],
      correctIndex: 0,
    ),
  ],
  'dbms-sql': [
    const PrepQuestion(
      id: 'q-dbms-sql-1',
      chapterId: 'dbms-sql',
      prompt: 'Which clause filters rows before grouping?',
      options: ['WHERE', 'HAVING', 'ORDER BY', 'GROUP BY'],
      correctIndex: 0,
    ),
    const PrepQuestion(
      id: 'q-dbms-sql-2',
      chapterId: 'dbms-sql',
      prompt: 'Division in relational algebra is used for:',
      options: [
        'All tuples in A related to every tuple in B',
        'Cartesian product',
        'Union of relations',
        'Deleting duplicates',
      ],
      correctIndex: 0,
    ),
  ],
  'cn-routing': [
    const PrepQuestion(
      id: 'q-cn-route-1',
      chapterId: 'cn-routing',
      prompt: 'Distance-vector routing suffers from:',
      options: [
        'Count-to-infinity',
        'No loops',
        'Global link-state knowledge',
        'Fixed path MTU',
      ],
      correctIndex: 0,
    ),
  ],
  'math-la': [
    const PrepQuestion(
      id: 'q-math-la-1',
      chapterId: 'math-la',
      prompt: 'Eigenvalues of a matrix exist when:',
      options: [
        'Av = lambda v has non-zero v',
        'Matrix is always singular',
        'Determinant is zero only',
        'Matrix is symmetric only',
      ],
      correctIndex: 0,
    ),
  ],
  'toc-dfa': [
    const PrepQuestion(
      id: 'q-toc-dfa-1',
      chapterId: 'toc-dfa',
      prompt: 'Minimization of DFA merges states that are:',
      options: [
        'Indistinguishable on all inputs',
        'Unreachable only',
        'Final and non-final',
        'Equivalent on empty string only',
      ],
      correctIndex: 0,
    ),
  ],
};

List<PrepQuestion> questionsForChapter(String chapterId) {
  return prepQuestionsByChapter[chapterId] ??
      [
        PrepQuestion(
          id: 'generic-$chapterId',
          chapterId: chapterId,
          prompt: 'Placeholder: add more questions for $chapterId',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          explanation: 'Import a full question bank into Firestore later.',
        ),
      ];
}

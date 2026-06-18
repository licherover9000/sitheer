import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitheer/model/prep_question.dart';

void main() {
  test('parses an MCQ from JSON and evaluates correctness', () {
    final q = PrepQuestion.fromJson(
      jsonDecode('''
      {
        "id": "x1", "chapterId": "os-process", "type": "mcq",
        "prompt": "P?", "options": ["a","b","c"], "correctIndex": 2,
        "year": 2012, "marks": 1
      }''')
          as Map<String, dynamic>,
    );
    expect(q.type, QuestionType.mcq);
    expect(q.year, 2012);
    expect(q.isIndexCorrect(2), isTrue);
    expect(q.isIndexCorrect(1), isFalse);
    // 1-mark MCQ default penalty.
    expect(q.penalty, closeTo(1 / 3, 1e-9));
  });

  test('parses a NAT and applies tolerance; NAT has no penalty', () {
    final q = PrepQuestion.fromJson(
      jsonDecode('''
      {
        "id": "x2", "chapterId": "cn-routing", "type": "nat",
        "prompt": "hosts?", "numericAnswer": 62, "numericTolerance": 0.5,
        "marks": 1
      }''')
          as Map<String, dynamic>,
    );
    expect(q.type, QuestionType.nat);
    expect(q.isNumericCorrect(62.4), isTrue);
    expect(q.isNumericCorrect(61), isFalse);
    expect(q.penalty, 0);
    expect(q.correctAnswerText, contains('62'));
  });

  test('parses an MSQ requiring the exact set', () {
    final q = PrepQuestion.fromJson(
      jsonDecode('''
      {
        "id": "x3", "chapterId": "os-sync", "type": "msq",
        "prompt": "select", "options": ["a","b","c","d"],
        "correctIndexes": [0,1,3], "marks": 2
      }''')
          as Map<String, dynamic>,
    );
    expect(q.type, QuestionType.msq);
    expect(q.areIndexesCorrect([3, 1, 0]), isTrue);
    expect(q.areIndexesCorrect([0, 1]), isFalse);
    expect(q.penalty, 0);
  });

  test('round-trips through toJson/fromJson', () {
    const original = PrepQuestion(
      id: 'r1',
      chapterId: 'algo-dp',
      prompt: 'LCS complexity?',
      options: ['O(mn)', 'O(m+n)'],
      correctIndex: 0,
      type: QuestionType.mcq,
      year: 2012,
      marks: 1,
      tags: ['dp'],
      source: 'GATE CSE 2012',
    );
    final restored = PrepQuestion.fromJson(original.toJson());
    expect(restored.id, 'r1');
    expect(restored.options, original.options);
    expect(restored.correctIndex, 0);
    expect(restored.year, 2012);
    expect(restored.tags, ['dp']);
    expect(restored.source, 'GATE CSE 2012');
  });
}

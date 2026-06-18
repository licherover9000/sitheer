import 'package:flutter_test/flutter_test.dart';
import 'package:sitheer/model/question_attempt.dart';

void main() {
  QuestionAttempt attempt({int? selected, bool marked = false}) =>
      QuestionAttempt(
        questionId: 'q1',
        chapterId: 'algo-sorting',
        prompt: 'Best case of merge sort?',
        options: const ['n', 'n log n', 'n^2', '1'],
        correctIndex: 1,
        selectedIndex: selected,
        explanation: 'Merge sort is always n log n.',
        markedForReview: marked,
        attemptedAt: DateTime.utc(2026, 6, 18, 9),
      );

  test('classifies correct / wrong / skipped', () {
    expect(attempt(selected: 1).isCorrect, isTrue);
    expect(attempt(selected: 2).isWrong, isTrue);
    expect(attempt(selected: null).isSkipped, isTrue);
    expect(attempt(selected: null).isCorrect, isFalse);
  });

  test('QuestionAttempt round-trips through map', () {
    final original = attempt(selected: 2, marked: true);
    final restored = QuestionAttempt.fromMap(original.toMap());

    expect(restored.questionId, original.questionId);
    expect(restored.chapterId, original.chapterId);
    expect(restored.options, original.options);
    expect(restored.correctIndex, original.correctIndex);
    expect(restored.selectedIndex, 2);
    expect(restored.markedForReview, isTrue);
    expect(restored.isWrong, isTrue);
    expect(restored.attemptedAt, original.attemptedAt);
  });

  test('PracticeSession derives counts, accuracy, and marks', () {
    final session = PracticeSession(
      id: 's1',
      source: 'pyq',
      refId: 'algo-sorting',
      title: 'PYQ drill - Sorting',
      attempts: [
        attempt(selected: 1), // correct
        attempt(selected: 1), // correct
        attempt(selected: 2), // wrong
        attempt(selected: null), // skipped
      ],
      completedAt: DateTime.utc(2026, 6, 18, 9),
    );

    expect(session.total, 4);
    expect(session.correctCount, 2);
    expect(session.incorrectCount, 1);
    expect(session.skippedCount, 1);
    expect(session.accuracy, closeTo(0.5, 1e-9));
    // +1 +1 for correct, -1/3 for wrong, 0 for skipped.
    expect(session.marks, closeTo(2 - 1 / 3, 1e-9));
    expect(session.wrongAttempts.length, 1);
  });

  test('PracticeSession round-trips through map', () {
    final session = PracticeSession(
      id: 's2',
      source: 'mock',
      refId: 'mock-1',
      title: 'Full mock 1',
      attempts: [attempt(selected: 1), attempt(selected: 0, marked: true)],
      completedAt: DateTime.utc(2026, 6, 18, 10),
    );
    final restored = PracticeSession.fromMap(session.toMap());

    expect(restored.id, 's2');
    expect(restored.source, 'mock');
    expect(restored.refId, 'mock-1');
    expect(restored.attempts.length, 2);
    expect(restored.attempts[1].markedForReview, isTrue);
    expect(restored.completedAt, session.completedAt);
  });
}

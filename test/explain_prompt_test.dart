import 'package:flutter_test/flutter_test.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/services/mentor/mentor_context.dart';

void main() {
  final attempt = QuestionAttempt(
    questionId: 'q1',
    chapterId: 'dbms-normal',
    prompt: 'Which normal form removes transitive dependency?',
    options: const ['1NF', '2NF', '3NF', 'BCNF'],
    correctIndex: 2,
    selectedIndex: 1,
    explanation: '3NF removes transitive dependencies.',
    attemptedAt: DateTime.utc(2026, 6, 18),
  );

  test('buildExplainPrompt includes question, options, and both answers', () {
    final prompt = buildExplainPrompt(attempt);

    expect(
      prompt,
      contains('Which normal form removes transitive dependency?'),
    );
    expect(prompt, contains('A. 1NF'));
    expect(prompt, contains('Correct answer: 3NF'));
    expect(prompt, contains('My answer: 2NF'));
    expect(prompt, contains('Reference note:'));
  });

  test('buildExplainPrompt marks skipped questions', () {
    final skipped = QuestionAttempt(
      questionId: 'q2',
      chapterId: 'dbms-normal',
      prompt: 'Q?',
      options: const ['a', 'b'],
      correctIndex: 0,
      selectedIndex: null,
      attemptedAt: DateTime.utc(2026, 6, 18),
    );
    expect(buildExplainPrompt(skipped), contains('skipped'));
  });

  test('simpler variant asks for a different explanation', () {
    final prompt = buildExplainPrompt(attempt, simpler: true);
    expect(prompt.toLowerCase(), contains('simpler'));
  });
}

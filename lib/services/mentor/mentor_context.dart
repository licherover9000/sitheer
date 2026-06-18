import 'package:sitheer/model/mentor_reply.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/providers/prep_provider.dart';

String buildMentorSystemPrompt(PrepProvider prep) {
  final subjects = [
    ...prep.subjects,
  ]..sort((a, b) => prep.subjectProgress(a).compareTo(prep.subjectProgress(b)));
  final weakest = subjects
      .take(3)
      .map((s) {
        return '${s.title} (${(prep.subjectProgress(s) * 100).round()}%)';
      })
      .join(', ');
  final week = prep.currentRoadmapWeek;
  final mockLines = prep.mocks
      .take(3)
      .map((m) {
        final attempt = prep.mockAttempt(m.id);
        final score = attempt?.score ?? m.score;
        return '${m.title}: $score/${m.questions}';
      })
      .join('; ');

  return '''
You are Tayari, a GATE exam mentor for ${prep.selectedExam}.
Be concise, actionable, and exam-focused. Use bullet points when helpful.
Never invent college cutoffs; suggest verifying official sources.

Student context:
- Exam: ${prep.selectedExam}
- Overall progress: ${(prep.overallProgress * 100).round()}%
- Active roadmap week: ${prep.currentWeek}${week != null ? ' (${week.title})' : ''}
- Weak subjects: $weakest
- Recent mocks: ${mockLines.isEmpty ? 'none yet' : mockLines}
- Checkpoints completed: ${prep.completedCheckpoints.length}
''';
}

String buildMentorUserPrompt(String question, MentorIntent intent) {
  final focus = switch (intent) {
    MentorIntent.plan =>
      'Focus on a weekly study plan with daily tasks and measurable checkpoints.',
    MentorIntent.concept =>
      'Focus on concept clarity, common traps, and a 3-step fix.',
    MentorIntent.mock =>
      'Focus on mock strategy, time splits, and score improvement loops.',
    MentorIntent.pyq =>
      'Focus on PYQ selection, attempt order, and revision spacing.',
    MentorIntent.general => 'Answer directly with next actions.',
  };
  return '$focus\n\nStudent question: $question';
}

/// Builds a prompt asking the mentor to explain a specific flagged/wrong
/// question. When [simpler] is true it asks for a fresh, easier re-explanation
/// (the "Explain differently" follow-up).
String buildExplainPrompt(QuestionAttempt q, {bool simpler = false}) {
  const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  String label(int i) => i >= 0 && i < q.options.length && i < letters.length
      ? '${letters[i]}. ${q.options[i]}'
      : 'option ${i + 1}';

  final options = [
    for (var i = 0; i < q.options.length; i++) label(i),
  ].join('\n');
  final picked = q.selectedIndex == null
      ? 'skipped (no answer)'
      : label(q.selectedIndex!);

  final buffer = StringBuffer();
  if (simpler) {
    buffer.writeln(
      'Re-explain this GATE question in a simpler, different way than before. '
      'Use a short analogy or a tiny worked example.',
    );
  } else {
    buffer.writeln(
      'Explain this GATE question step by step so I understand it deeply.',
    );
  }
  buffer
    ..writeln()
    ..writeln('Question: ${q.prompt}')
    ..writeln('Options:')
    ..writeln(options)
    ..writeln('Correct answer: ${label(q.correctIndex)}')
    ..writeln('My answer: $picked');
  if (q.explanation != null && q.explanation!.trim().isNotEmpty) {
    buffer.writeln('Reference note: ${q.explanation!.trim()}');
  }
  buffer
    ..writeln()
    ..writeln(
      'Cover: (1) the core concept being tested, (2) why the correct option '
      'is right, (3) the likely mistake behind my answer, and (4) one tip to '
      'remember it. Be concise and exam-focused.',
    );
  return buffer.toString();
}

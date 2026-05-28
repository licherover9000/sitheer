import 'package:sitheer/model/mentor_reply.dart';
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

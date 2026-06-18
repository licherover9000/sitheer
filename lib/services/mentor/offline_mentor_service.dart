import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/model/prep_progress.dart';
import 'package:sitheer/model/mentor_reply.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/services/mentor/mentor_intent_classifier.dart';

/// Rule-based fallback when API keys are missing or requests fail.
class OfflineMentorService {
  const OfflineMentorService();

  MentorReply reply({required String question, required PrepProvider prep}) {
    final q = question.toLowerCase().trim();
    if (q.isEmpty) {
      return const MentorReply(
        answer:
            'Ask about a subject, PYQ set, mock review, or your weekly plan.',
        sources: ['offline'],
      );
    }

    final subjects = [...prep.subjects]
      ..sort(
        (a, b) => prep.subjectProgress(a).compareTo(prep.subjectProgress(b)),
      );
    final intent = classifyMentorIntent(question);
    if (subjects.isEmpty) {
      return MentorReply(
        answer:
            'Pick an exam stream to load your roadmap and subjects, '
            'then ask me again.',
        sources: const ['offline'],
        intent: intent,
      );
    }
    final weakest = subjects.first;
    final strongest = subjects.last;
    final week = prep.currentRoadmapWeek;

    String answer;
    if (q.contains('rank') || q.contains('score')) {
      final latest = prep.mocks
          .map((m) => prep.mockAttempt(m.id))
          .whereType<MockAttemptRecord>()
          .toList();
      if (latest.isEmpty) {
        answer =
            'Attempt a full mock first. Then share your score - '
            'I will map leaks to ${weakest.title} and ${prep.selectedExam} cutoffs.';
      } else {
        final last = latest.last;
        answer =
            'Latest mock score: ${last.score}. '
            'Push ${weakest.title} this week; you are at '
            '${(prep.subjectProgress(weakest) * 100).round()}% on that track.';
      }
    } else if (q.contains('plan') ||
        q.contains('week') ||
        q.contains('7 day')) {
      final w = week;
      answer = w == null
          ? 'Pick an exam stream to load your roadmap.'
          : 'Week ${w.week}: ${w.title}. Focus: ${w.focus}. '
                'Start with checkpoints: ${w.checkpoints.take(2).join('; ')}.';
    } else if (q.contains('pyq') || q.contains('previous')) {
      final targetPyqs = weakest.chapters.isEmpty
          ? 15
          : weakest.chapters.first.pyqCount;
      answer =
          'Open Vault > ${weakest.title} > start the PYQ drill. '
          'Target $targetPyqs questions, '
          'then retake wrong ones after 48 hours.';
    } else if (q.contains('mock')) {
      if (prep.mocks.isEmpty) {
        answer =
            'No mock papers are loaded yet for ${prep.selectedExam}. '
            'Check the Mocks tab once content syncs.';
      } else {
        final paper = prep.mocks.first;
        answer =
            'Run "${paper.title}" (${paper.duration}). '
            'After submit, review ${paper.focusAreas.join(', ')}.';
      }
    } else if (q.contains('operating') ||
        q.contains(' os') ||
        q.startsWith('os')) {
      answer = _subjectTip('os', prep);
    } else if (q.contains('dbms') || q.contains('sql')) {
      answer = _subjectTip('dbms', prep);
    } else if (q.contains('network')) {
      answer = _subjectTip('cn', prep);
    } else if (q.contains('algorithm') || q.contains('graph')) {
      answer = _subjectTip('algo', prep);
    } else {
      answer =
          'For ${prep.selectedExam}: repair ${weakest.title} first '
          '(~${(prep.subjectProgress(weakest) * 100).round()}%), '
          'then maintain ${strongest.title}. '
          'Active roadmap week ${prep.currentWeek}: ${week?.title ?? '-'}.';
    }

    return MentorReply(
      answer: answer,
      sources: const ['offline'],
      intent: intent,
    );
  }

  String _subjectTip(String code, PrepProvider prep) {
    PrepSubject? subject;
    for (final s in prep.subjects) {
      if (s.code == code) {
        subject = s;
        break;
      }
    }
    if (subject == null || subject.chapters.isEmpty) {
      return 'That subject is not in your ${prep.selectedExam} track.';
    }
    final chapter = subject.chapters.first;
    return '${subject.title}: drill "${chapter.title}" '
        '(${chapter.pyqCount} PYQs). '
        'Accuracy saved: '
        '${(prep.chapterAccuracy(chapter.id, fallback: chapter.accuracy) * 100).round()}%.';
  }
}

import 'package:sitheer/model/mentor_reply.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/services/mentor/combined_mentor_service.dart';
import 'package:sitheer/services/mentor/mentor_context.dart';
import 'package:sitheer/services/mentor/offline_mentor_service.dart';

export 'package:sitheer/model/mentor_reply.dart';

/// Facade for Ask Tayari - Gemini + OpenAI combined, with offline fallback.
class MentorService {
  MentorService({
    CombinedMentorService? combined,
    OfflineMentorService? offline,
  }) : _combined = combined ?? CombinedMentorService(),
       _offline = offline ?? const OfflineMentorService();

  final CombinedMentorService _combined;
  final OfflineMentorService _offline;

  Future<MentorReply> replyAsync({
    required String question,
    required PrepProvider prep,
    String? geminiKey,
    String? openaiKey,
    bool useCloud = true,
  }) {
    return _combined.reply(
      question: question,
      prep: prep,
      geminiKey: geminiKey,
      openaiKey: openaiKey,
      useCloud: useCloud,
    );
  }

  /// Asks the mentor to explain a specific flagged/wrong question. Reuses the
  /// combined Gemini/OpenAI/cloud plumbing with a question-focused prompt.
  Future<MentorReply> explainQuestion({
    required QuestionAttempt question,
    required PrepProvider prep,
    bool simpler = false,
    String? geminiKey,
    String? openaiKey,
    bool useCloud = true,
  }) {
    return _combined.reply(
      question: buildExplainPrompt(question, simpler: simpler),
      prep: prep,
      geminiKey: geminiKey,
      openaiKey: openaiKey,
      useCloud: useCloud,
    );
  }

  /// Synchronous offline-only reply (tests / no network).
  MentorReply reply({required String question, required PrepProvider prep}) {
    return _offline.reply(question: question, prep: prep);
  }
}

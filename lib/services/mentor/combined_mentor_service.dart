import 'package:flutter/foundation.dart';
import 'package:sitheer/model/mentor_reply.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/services/mentor/gemini_client.dart';
import 'package:sitheer/services/mentor/mentor_cloud_client.dart';
import 'package:sitheer/services/mentor/mentor_context.dart';
import 'package:sitheer/services/mentor/mentor_intent_classifier.dart';
import 'package:sitheer/services/mentor/offline_mentor_service.dart';
import 'package:sitheer/services/mentor/openai_client.dart';

class CombinedMentorService {
  CombinedMentorService({
    GeminiClient? gemini,
    OpenAIClient? openai,
    OfflineMentorService? offline,
    MentorCloudClient? cloud,
  }) : _gemini = gemini ?? const GeminiClient(),
       _openai = openai ?? const OpenAIClient(),
       _offline = offline ?? const OfflineMentorService(),
       _cloud = cloud ?? const MentorCloudClient();

  final GeminiClient _gemini;
  final OpenAIClient _openai;
  final OfflineMentorService _offline;
  final MentorCloudClient _cloud;

  Future<MentorReply> reply({
    required String question,
    required PrepProvider prep,
    String? geminiKey,
    String? openaiKey,
    bool useCloud = true,
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return _offline.reply(question: trimmed, prep: prep);
    }

    final gemini = geminiKey?.trim() ?? '';
    final openai = openaiKey?.trim() ?? '';
    final hasGemini = gemini.isNotEmpty;
    final hasOpenai = openai.isNotEmpty;
    if (!hasGemini && !hasOpenai) {
      return _offline.reply(question: trimmed, prep: prep);
    }

    final intent = classifyMentorIntent(trimmed);
    final system = buildMentorSystemPrompt(prep);
    final user = buildMentorUserPrompt(trimmed, intent);

    if (useCloud) {
      final cloudReply = await _cloud.tryReply(
        question: trimmed,
        systemPrompt: system,
        userPrompt: user,
        intent: intent,
      );
      if (cloudReply != null) return cloudReply;
    }

    final useBoth = hasGemini && hasOpenai && shouldUseBothModels(intent);

    if (useBoth) {
      return _dualReply(
        system: system,
        user: user,
        intent: intent,
        geminiKey: gemini,
        openaiKey: openai,
        prep: prep,
        question: trimmed,
      );
    }

    if (hasGemini && _prefersGemini(intent)) {
      try {
        final text = await _gemini.complete(
          apiKey: gemini,
          systemPrompt: system,
          userPrompt: user,
        );
        return MentorReply(
          answer: text,
          sources: const ['gemini'],
          intent: intent,
        );
      } catch (_) {
        if (hasOpenai) {
          return _singleOpenai(
            system: system,
            user: user,
            intent: intent,
            openaiKey: openai,
            prep: prep,
            question: trimmed,
          );
        }
      }
    }

    if (hasOpenai) {
      return _singleOpenai(
        system: system,
        user: user,
        intent: intent,
        openaiKey: openai,
        prep: prep,
        question: trimmed,
      );
    }

    try {
      final text = await _gemini.complete(
        apiKey: gemini,
        systemPrompt: system,
        userPrompt: user,
      );
      return MentorReply(
        answer: text,
        sources: const ['gemini'],
        intent: intent,
      );
    } catch (_) {
      return _offline.reply(question: trimmed, prep: prep);
    }
  }

  bool _prefersGemini(MentorIntent intent) =>
      intent == MentorIntent.plan || intent == MentorIntent.pyq;

  Future<MentorReply> _singleOpenai({
    required String system,
    required String user,
    required MentorIntent intent,
    required String openaiKey,
    required PrepProvider prep,
    required String question,
  }) async {
    try {
      final text = await _openai.complete(
        apiKey: openaiKey,
        systemPrompt: system,
        userPrompt: user,
      );
      return MentorReply(
        answer: text,
        sources: const ['openai'],
        intent: intent,
      );
    } catch (_) {
      return _offline.reply(question: question, prep: prep);
    }
  }

  Future<MentorReply> _dualReply({
    required String system,
    required String user,
    required MentorIntent intent,
    required String geminiKey,
    required String openaiKey,
    required PrepProvider prep,
    required String question,
  }) async {
    String? geminiText;
    String? openaiText;
    final errors = <String>[];

    await Future.wait([
      () async {
        try {
          geminiText = await _gemini.complete(
            apiKey: geminiKey,
            systemPrompt: system,
            userPrompt: user,
          );
        } catch (e) {
          errors.add('Gemini: $e');
        }
      }(),
      () async {
        try {
          openaiText = await _openai.complete(
            apiKey: openaiKey,
            systemPrompt: system,
            userPrompt: user,
          );
        } catch (e) {
          errors.add('OpenAI: $e');
        }
      }(),
    ]);

    final sources = <String>[];
    final sections = <String>[];

    if (geminiText != null && geminiText!.trim().isNotEmpty) {
      sources.add('gemini');
      sections.add('**Study plan (Gemini)**\n${geminiText!.trim()}');
    }
    if (openaiText != null && openaiText!.trim().isNotEmpty) {
      sources.add('openai');
      sections.add('**Concept coaching (OpenAI)**\n${openaiText!.trim()}');
    }

    if (sections.isEmpty) {
      // Surface the offline answer to the user; keep raw API error text out of
      // the UI (it can contain keys/quota details). Log it for debugging only.
      if (errors.isNotEmpty) {
        debugPrint('Mentor API errors: ${errors.join(' | ')}');
      }
      final fallback = _offline.reply(question: question, prep: prep);
      return MentorReply(
        answer:
            '${fallback.answer}\n\n(AI services are unavailable right now - '
            'showing offline guidance.)',
        sources: const ['offline'],
        intent: intent,
      );
    }

    if (sections.length == 1) {
      return MentorReply(
        answer: sections.first.split('\n').skip(1).join('\n'),
        sources: sources,
        intent: intent,
      );
    }

    return MentorReply(
      answer: sections.join('\n\n'),
      sources: sources,
      intent: intent,
    );
  }
}

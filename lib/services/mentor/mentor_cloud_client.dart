import 'package:cloud_functions/cloud_functions.dart';
import 'package:sitheer/model/mentor_reply.dart';
import 'package:sitheer/services/mentor/mentor_intent_classifier.dart';

/// Calls Firebase Callable `mentorChat` so API keys stay on the server.
class MentorCloudClient {
  const MentorCloudClient();

  Future<MentorReply?> tryReply({
    required String question,
    required String systemPrompt,
    required String userPrompt,
    required MentorIntent intent,
  }) async {
    try {
      final provider = switch (intent) {
        MentorIntent.plan || MentorIntent.pyq => 'gemini',
        MentorIntent.concept || MentorIntent.mock => 'openai',
        MentorIntent.general => shouldUseBothModels(intent) ? 'both' : 'gemini',
      };

      final callable = FirebaseFunctions.instance.httpsCallable('mentorChat');
      final result = await callable.call<Map<String, dynamic>>({
        'question': question,
        'systemPrompt': systemPrompt,
        'userPrompt': userPrompt,
        'provider': provider,
      });

      final data = result.data;
      final answer = data['answer'] as String?;
      if (answer == null || answer.trim().isEmpty) return null;

      final sources = List<String>.from(
        (data['sources'] as List?)?.map((e) => e.toString()) ?? ['cloud'],
      );

      return MentorReply(
        answer: answer.trim(),
        sources: sources,
        intent: intent,
      );
    } catch (_) {
      return null;
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIClient {
  const OpenAIClient({this.model = 'gpt-4o-mini'});

  final String model;

  Future<String> complete({
    required String apiKey,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = jsonEncode({
      'model': model,
      'temperature': 0.65,
      'max_tokens': 1200,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    });

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('OpenAI returned no choices');
    }
    final message = choices.first['message'] as Map<String, dynamic>?;
    final text = message?['content'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw Exception('OpenAI returned empty content');
    }
    return text.trim();
  }
}

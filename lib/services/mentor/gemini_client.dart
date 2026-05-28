import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiClient {
  const GeminiClient({this.model = 'gemini-1.5-flash'});

  final String model;

  Future<String> complete({
    required String apiKey,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userPrompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.65, 'maxOutputTokens': 1200},
    });

    final response = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned no candidates');
    }
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini returned empty content');
    }
    final text = parts.first['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned empty text');
    }
    return text.trim();
  }
}

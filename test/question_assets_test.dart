import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitheer/model/prep_question.dart';

/// Validates the curated PYQ JSON assets: every entry parses, ids are unique,
/// and each answer key is consistent with its type.
void main() {
  for (final path in const [
    'assets/questions/gate-cs.json',
    'assets/questions/gate-da.json',
  ]) {
    test('$path is well-formed', () {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path should exist');

      final decoded = jsonDecode(file.readAsStringSync()) as List;
      final ids = <String>{};

      for (final item in decoded) {
        final q = PrepQuestion.fromJson(Map<String, dynamic>.from(item as Map));
        expect(q.id.isNotEmpty, isTrue);
        expect(ids.add(q.id), isTrue, reason: 'duplicate id ${q.id}');
        expect(q.prompt.isNotEmpty, isTrue, reason: '${q.id} needs a prompt');

        switch (q.type) {
          case QuestionType.mcq:
            expect(
              q.options.length >= 2,
              isTrue,
              reason: '${q.id} MCQ needs >=2 options',
            );
            expect(
              q.correctIndex >= 0 && q.correctIndex < q.options.length,
              isTrue,
              reason: '${q.id} correctIndex out of range',
            );
          case QuestionType.msq:
            expect(
              q.correctIndexes.isNotEmpty,
              isTrue,
              reason: '${q.id} MSQ needs correctIndexes',
            );
            for (final i in q.correctIndexes) {
              expect(
                i >= 0 && i < q.options.length,
                isTrue,
                reason: '${q.id} MSQ index $i out of range',
              );
            }
          case QuestionType.nat:
            expect(
              q.numericAnswer != null,
              isTrue,
              reason: '${q.id} NAT needs numericAnswer',
            );
        }
      }
    });
  }
}

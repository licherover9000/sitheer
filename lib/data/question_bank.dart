import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sitheer/data/prep_catalog.dart' show supportedExams;
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/prep_exam_config.dart';
import 'package:sitheer/data/prep_questions.dart';
import 'package:sitheer/model/prep_question.dart';

/// Central question registry. Merges the in-code seed
/// ([prepQuestionsByChapter]) with curated real-PYQ JSON assets and indexes
/// questions by chapter, by exam, and by year.
///
/// Load order matters: call [load] after the content catalog/registry is ready
/// so exam grouping (chapter -> subject -> exam) can be resolved.
class QuestionBank {
  QuestionBank._();
  static final QuestionBank instance = QuestionBank._();

  static const _assetByExam = {
    'GATE CS': 'assets/questions/gate-cs.json',
    'GATE DA': 'assets/questions/gate-da.json',
  };

  final Map<String, List<PrepQuestion>> _byChapter = {};
  final Map<String, List<PrepQuestion>> _byExam = {};
  final List<PrepQuestion> _all = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<PrepQuestion> get allQuestions => List.unmodifiable(_all);

  Future<void> load() async {
    if (_loaded) return;

    // Seed (in-code) first; JSON assets override by id.
    final byId = <String, PrepQuestion>{};
    for (final list in prepQuestionsByChapter.values) {
      for (final q in list) {
        byId[q.id] = q;
      }
    }
    for (final asset in _assetByExam.values) {
      try {
        final raw = await rootBundle.loadString(asset);
        final decoded = jsonDecode(raw) as List;
        for (final item in decoded) {
          final q = PrepQuestion.fromJson(Map<String, dynamic>.from(item));
          byId[q.id] = q;
        }
      } catch (e) {
        debugPrint('QuestionBank: could not load $asset: $e');
      }
    }

    _index(byId.values.toList());
    _loaded = true;
  }

  void _index(List<PrepQuestion> questions) {
    _byChapter.clear();
    _byExam.clear();
    _all
      ..clear()
      ..addAll(questions);
    for (final q in questions) {
      _byChapter.putIfAbsent(q.chapterId, () => []).add(q);
      final ctx = findChapterContext(q.chapterId);
      if (ctx == null) continue;
      for (final exam in supportedExams) {
        if (subjectMatchesExam(ctx.$1, exam)) {
          _byExam.putIfAbsent(exam, () => []).add(q);
        }
      }
    }
  }

  List<PrepQuestion> forChapter(String chapterId) =>
      _byChapter[chapterId] ?? const [];

  List<PrepQuestion> forExam(String exam) => _byExam[exam] ?? const [];

  /// Years that have at least one question for [exam], newest first.
  List<int> availableYears(String exam) {
    final years = forExam(
      exam,
    ).map((q) => q.year).whereType<int>().toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<PrepQuestion> forYear(String exam, int year) =>
      forExam(exam).where((q) => q.year == year).toList();

  int countForYear(String exam, int year) =>
      forExam(exam).where((q) => q.year == year).length;
}

/// Backwards-compatible accessor used across the prep screens. Falls back to
/// the in-code seed when the bank has not been loaded yet (e.g. in tests).
List<PrepQuestion> questionsForChapter(String chapterId) {
  final fromBank = QuestionBank.instance.forChapter(chapterId);
  if (fromBank.isNotEmpty) return fromBank;
  final seed = prepQuestionsByChapter[chapterId];
  if (seed != null && seed.isNotEmpty) return seed;
  // Keep drills from crashing on chapters with no questions yet.
  return [
    PrepQuestion(
      id: 'generic-$chapterId',
      chapterId: chapterId,
      prompt: 'No questions added for this topic yet.',
      options: const ['OK'],
      correctIndex: 0,
      explanation: 'Add questions to the JSON bank to practise this topic.',
    ),
  ];
}

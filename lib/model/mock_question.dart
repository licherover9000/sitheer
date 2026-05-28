/// Shared data-transfer objects for the mock test flow.
/// Used by both [MockAttemptScreen] and [MockAnalysisScreen].
library;

class MockQuestion {
  const MockQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.chapterId,
    this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String chapterId;
  final String? explanation;
}

class MockQuestionResult {
  const MockQuestionResult({
    required this.question,
    required this.selectedIndex,
  });

  final MockQuestion question;
  final int? selectedIndex;
}

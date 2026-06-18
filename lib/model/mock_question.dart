/// Data-transfer object for a single mock-test question, used while building
/// and rendering a [MockAttemptScreen]. Per-question results are captured as
/// [QuestionAttempt]s when the mock is submitted.
library;

class MockQuestion {
  const MockQuestion({
    required this.questionId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.chapterId,
    this.explanation,
  });

  final String questionId;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String chapterId;
  final String? explanation;
}

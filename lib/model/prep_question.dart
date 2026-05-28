class PrepQuestion {
  const PrepQuestion({
    required this.id,
    required this.chapterId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  final String id;
  final String chapterId;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
}

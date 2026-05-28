import 'package:sitheer/model/prep_content.dart';

class PrepExamBundle {
  const PrepExamBundle({
    required this.examId,
    required this.examLabel,
    required this.version,
    required this.subjects,
    required this.roadmapWeeks,
    required this.mockPapers,
  });

  final String examId;
  final String examLabel;
  final int version;
  final List<PrepSubject> subjects;
  final List<RoadmapWeek> roadmapWeeks;
  final List<MockPaper> mockPapers;
}

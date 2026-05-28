import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/prep_content_codec.dart';
import 'package:sitheer/model/prep_exam_bundle.dart';

const prepContentVersion = 1;

PrepExamBundle localBundleForExam(String examLabel) {
  final examId = examIdFromLabel(examLabel);
  return PrepExamBundle(
    examId: examId,
    examLabel: examLabel,
    version: prepContentVersion,
    subjects: subjectsForExam(examLabel),
    roadmapWeeks: weeksForExam(examLabel),
    mockPapers: mocksForExam(examLabel),
  );
}

List<PrepExamBundle> allLocalBundles() => [
  localBundleForExam('GATE CS'),
  localBundleForExam('GATE DA'),
];

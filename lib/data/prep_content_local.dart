import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/prep_content_codec.dart';
import 'package:sitheer/model/prep_exam_bundle.dart';
import 'package:sitheer/model/pyq_volume.dart';

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

List<PyqVolume> allLocalPyqVolumes() => [
  const PyqVolume(
    id: 'gate-cs-2024',
    examId: 'gate-cs',
    label: 'GATE CSE 2024 Question Paper',
    year: 2024,
    storagePath: 'pyqs/gate_cs_2024.pdf',
    downloadUrl:
        'https://engineering.careers360.com/download/sample-papers/gate-2024-computer-science-information-technology-question-paper-and-answer-key',
  ),
  const PyqVolume(
    id: 'gate-da-2024',
    examId: 'gate-da',
    label: 'GATE DA 2024 Question Paper',
    year: 2024,
    storagePath: 'pyqs/gate_da_2024.pdf',
    downloadUrl:
        'https://engineering.careers360.com/download/sample-papers/gate-2024-data-science-and-artificial-intelligence-question-paper-and-answer-key',
  ),
];

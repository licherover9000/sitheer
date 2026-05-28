import 'package:sitheer/data/gate_da_catalog.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/data/prep_exam_config.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/model/prep_exam_bundle.dart';

/// In-memory catalog used by accessors; populated from Firestore or local seed.
class PrepContentRegistry {
  PrepContentRegistry._();
  static final PrepContentRegistry instance = PrepContentRegistry._();

  final Map<String, PrepExamBundle> _bundles = {};
  bool _ready = false;

  bool get isReady => _ready;

  void setBundle(PrepExamBundle bundle) {
    _bundles[bundle.examId] = bundle;
    _ready = true;
  }

  void setBundles(Iterable<PrepExamBundle> bundles) {
    for (final bundle in bundles) {
      _bundles[bundle.examId] = bundle;
    }
    _ready = _bundles.isNotEmpty;
  }

  PrepExamBundle? bundleForExam(String examLabel) {
    final id = examLabel == 'GATE DA' ? 'gate-da' : 'gate-cs';
    return _bundles[id];
  }

  List<PrepSubject> allSubjects() {
    if (_bundles.isNotEmpty) {
      return _bundles.values.expand((b) => b.subjects).toList();
    }
    return [...prepSubjects, ...gateDaSubjects];
  }

  List<PrepSubject> subjectsForExam(String exam) {
    final remote = bundleForExam(exam)?.subjects;
    if (remote != null && remote.isNotEmpty) return remote;
    return _localAllSubjects()
        .where((s) => subjectMatchesExam(s.code, exam))
        .toList();
  }

  List<RoadmapWeek> weeksForExam(String exam) {
    final remote = bundleForExam(exam)?.roadmapWeeks;
    if (remote != null && remote.isNotEmpty) return remote;
    final weeks = exam == 'GATE DA' ? gateDaRoadmapWeeks : roadmapWeeks;
    return weeks.where((w) => weekMatchesExam(w.subjectCodes, exam)).toList();
  }

  List<MockPaper> mocksForExam(String exam) {
    final remote = bundleForExam(exam)?.mockPapers;
    if (remote != null && remote.isNotEmpty) return remote;
    return mockPapers.where((m) => mockMatchesExam(m.stream, exam)).toList();
  }

  List<PrepSubject> _localAllSubjects() => [...prepSubjects, ...gateDaSubjects];
}

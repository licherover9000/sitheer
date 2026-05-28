import 'package:sitheer/data/prep_content_registry.dart';
import 'package:sitheer/model/prep_content.dart';

final _registry = PrepContentRegistry.instance;

List<PrepSubject> allCatalogSubjects() => _registry.allSubjects();

List<PrepSubject> subjectsForExam(String exam) =>
    _registry.subjectsForExam(exam);

List<RoadmapWeek> weeksForExam(String exam) => _registry.weeksForExam(exam);

List<MockPaper> mocksForExam(String exam) => _registry.mocksForExam(exam);

int totalPyqsForExam(String exam) {
  return subjectsForExam(exam).fold(
    0,
    (sum, subject) => sum + subject.chapters.fold(0, (s, c) => s + c.pyqCount),
  );
}

int totalChaptersForExam(String exam) {
  return subjectsForExam(exam).fold(0, (sum, s) => sum + s.chapters.length);
}

PrepSubject? findSubject(String code) {
  for (final subject in allCatalogSubjects()) {
    if (subject.code == code) return subject;
  }
  return null;
}

PrepChapter? findChapter(String chapterId) {
  for (final subject in allCatalogSubjects()) {
    for (final chapter in subject.chapters) {
      if (chapter.id == chapterId) return chapter;
    }
  }
  return null;
}

PrepResource? findResource(String resourceId) {
  for (final subject in allCatalogSubjects()) {
    for (final chapter in subject.chapters) {
      for (final resource in chapter.resources) {
        if (resource.id == resourceId) return resource;
      }
    }
  }
  return null;
}

(String subjectCode, PrepChapter chapter)? findChapterContext(
  String chapterId,
) {
  for (final subject in allCatalogSubjects()) {
    for (final chapter in subject.chapters) {
      if (chapter.id == chapterId) {
        return (subject.code, chapter);
      }
    }
  }
  return null;
}

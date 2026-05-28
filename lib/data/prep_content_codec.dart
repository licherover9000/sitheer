import 'package:flutter/material.dart';
import 'package:sitheer/data/prep_icon_map.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/model/prep_exam_bundle.dart';

String examIdFromLabel(String label) {
  return switch (label) {
    'GATE DA' => 'gate-da',
    _ => 'gate-cs',
  };
}

String examLabelFromId(String id) {
  return switch (id) {
    'gate-da' => 'GATE DA',
    _ => 'GATE CS',
  };
}

Map<String, dynamic> bundleToMap(PrepExamBundle bundle) => {
  'examId': bundle.examId,
  'examLabel': bundle.examLabel,
  'version': bundle.version,
  'subjects': bundle.subjects.map(subjectToMap).toList(),
  'roadmapWeeks': bundle.roadmapWeeks.map(weekToMap).toList(),
  'mockPapers': bundle.mockPapers.map(mockToMap).toList(),
};

PrepExamBundle bundleFromMap(Map<String, dynamic> map) {
  return PrepExamBundle(
    examId: map['examId'] as String,
    examLabel: map['examLabel'] as String,
    version: map['version'] as int? ?? 1,
    subjects: (map['subjects'] as List)
        .map((e) => subjectFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    roadmapWeeks: (map['roadmapWeeks'] as List)
        .map((e) => weekFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    mockPapers: (map['mockPapers'] as List)
        .map((e) => mockFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

Map<String, dynamic> subjectToMap(PrepSubject s) => {
  'code': s.code,
  'title': s.title,
  'subtitle': s.subtitle,
  'icon': prepIconKey(s.icon),
  'accent': s.accent.toARGB32(),
  'progress': s.progress,
  'chapters': s.chapters.map(chapterToMap).toList(),
};

PrepSubject subjectFromMap(Map<String, dynamic> map) {
  return PrepSubject(
    code: map['code'] as String,
    title: map['title'] as String,
    subtitle: map['subtitle'] as String,
    icon: prepIconFromKey(map['icon'] as String?),
    accent: Color(map['accent'] as int),
    progress: (map['progress'] as num).toDouble(),
    chapters: (map['chapters'] as List)
        .map((e) => chapterFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

Map<String, dynamic> chapterToMap(PrepChapter c) => {
  'id': c.id,
  'title': c.title,
  'weightage': c.weightage,
  'difficulty': c.difficulty,
  'pyqCount': c.pyqCount,
  'accuracy': c.accuracy,
  'resources': c.resources.map(resourceToMap).toList(),
};

PrepChapter chapterFromMap(Map<String, dynamic> map) {
  return PrepChapter(
    id: map['id'] as String,
    title: map['title'] as String,
    weightage: map['weightage'] as String,
    difficulty: map['difficulty'] as String,
    pyqCount: map['pyqCount'] as int,
    accuracy: (map['accuracy'] as num).toDouble(),
    resources: (map['resources'] as List)
        .map((e) => resourceFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

Map<String, dynamic> resourceToMap(PrepResource r) => {
  'id': r.id,
  'title': r.title,
  'type': r.type.name,
  'source': r.source,
  'description': r.description,
  'timeLabel': r.timeLabel,
  'url': r.url,
  'storagePath': r.storagePath,
  'isPremium': r.isPremium,
};

PrepResource resourceFromMap(Map<String, dynamic> map) {
  return PrepResource(
    id: map['id'] as String,
    title: map['title'] as String,
    type: PrepResourceType.values.byName(map['type'] as String),
    source: map['source'] as String,
    description: map['description'] as String,
    timeLabel: map['timeLabel'] as String,
    url: map['url'] as String?,
    storagePath: map['storagePath'] as String?,
    isPremium: map['isPremium'] as bool? ?? false,
  );
}

Map<String, dynamic> weekToMap(RoadmapWeek w) => {
  'week': w.week,
  'title': w.title,
  'phase': w.phase,
  'hours': w.hours,
  'focus': w.focus,
  'outcomes': w.outcomes,
  'checkpoints': w.checkpoints,
  'subjectCodes': w.subjectCodes,
};

RoadmapWeek weekFromMap(Map<String, dynamic> map) {
  return RoadmapWeek(
    week: map['week'] as int,
    title: map['title'] as String,
    phase: map['phase'] as String,
    hours: map['hours'] as int,
    focus: map['focus'] as String,
    outcomes: List<String>.from(map['outcomes'] as List),
    checkpoints: List<String>.from(map['checkpoints'] as List),
    subjectCodes: List<String>.from(map['subjectCodes'] as List),
  );
}

Map<String, dynamic> mockToMap(MockPaper m) => {
  'id': m.id,
  'title': m.title,
  'stream': m.stream,
  'year': m.year,
  'duration': m.duration,
  'questions': m.questions,
  'score': m.score,
  'accuracy': m.accuracy,
  'status': m.status,
  'focusAreas': m.focusAreas,
};

MockPaper mockFromMap(Map<String, dynamic> map) {
  return MockPaper(
    id: map['id'] as String,
    title: map['title'] as String,
    stream: map['stream'] as String,
    year: map['year'] as int,
    duration: map['duration'] as String,
    questions: map['questions'] as int,
    score: map['score'] as int,
    accuracy: (map['accuracy'] as num).toDouble(),
    status: map['status'] as String,
    focusAreas: List<String>.from(map['focusAreas'] as List),
  );
}

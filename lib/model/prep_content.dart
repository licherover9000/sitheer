import 'package:flutter/material.dart';

enum PrepResourceType { pyq, notes, formula, lecture, mock, article }

class PrepResource {
  const PrepResource({
    required this.id,
    required this.title,
    required this.type,
    required this.source,
    required this.description,
    required this.timeLabel,
    this.url,
    this.storagePath,
    this.isPremium = false,
  });

  final String id;
  final String title;
  final PrepResourceType type;
  final String source;
  final String description;
  final String timeLabel;
  final String? url;
  final String? storagePath;
  final bool isPremium;
}

class PrepChapter {
  const PrepChapter({
    required this.id,
    required this.title,
    required this.weightage,
    required this.difficulty,
    required this.pyqCount,
    required this.accuracy,
    required this.resources,
  });

  final String id;
  final String title;
  final String weightage;
  final String difficulty;
  final int pyqCount;
  final double accuracy;
  final List<PrepResource> resources;
}

class PrepSubject {
  const PrepSubject({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.progress,
    required this.chapters,
  });

  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final double progress;
  final List<PrepChapter> chapters;
}

class RoadmapWeek {
  const RoadmapWeek({
    required this.week,
    required this.title,
    required this.phase,
    required this.hours,
    required this.focus,
    required this.outcomes,
    required this.checkpoints,
    required this.subjectCodes,
  });

  final int week;
  final String title;
  final String phase;
  final int hours;
  final String focus;
  final List<String> outcomes;
  final List<String> checkpoints;
  final List<String> subjectCodes;
}

class MockPaper {
  const MockPaper({
    required this.id,
    required this.title,
    required this.stream,
    required this.year,
    required this.duration,
    required this.questions,
    required this.score,
    required this.accuracy,
    required this.status,
    required this.focusAreas,
  });

  final String id;
  final String title;
  final String stream;
  final int year;
  final String duration;
  final int questions;
  final int score;
  final double accuracy;
  final String status;
  final List<String> focusAreas;
}

class PredictorCollege {
  const PredictorCollege({
    required this.name,
    required this.program,
    required this.route,
    required this.rankBand,
    required this.fit,
  });

  final String name;
  final String program;
  final String route;
  final String rankBand;
  final String fit;
}

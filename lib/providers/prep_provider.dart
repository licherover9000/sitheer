import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/prep_content_registry.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/model/prep_progress.dart';
import 'package:sitheer/repositories/prep_repository.dart';
import 'package:sitheer/services/auth_service.dart';

class PrepProvider extends ChangeNotifier {
  PrepProvider() {
    _init();
  }

  final PrepRepository _repo = PrepRepository.instance;
  StreamSubscription<Map<String, dynamic>?>? _remoteSub;

  String _selectedExam = supportedExams.first;
  int _currentWeek = 1;
  final Set<String> _completedCheckpoints = {};
  final Map<String, ChapterProgress> _chapterProgress = {};
  final Map<String, MockAttemptRecord> _mockAttempts = {};
  bool _loaded = false;
  bool _contentReady = false;
  String? _contentError;

  String get selectedExam => _selectedExam;
  int get currentWeek => _currentWeek;
  bool get isLoaded => _loaded;
  bool get contentReady => _contentReady;
  String? get contentError => _contentError;
  Set<String> get completedCheckpoints => _completedCheckpoints;

  List<PrepSubject> get subjects => subjectsForExam(_selectedExam);
  List<RoadmapWeek> get weeks => weeksForExam(_selectedExam);
  List<MockPaper> get mocks => mocksForExam(_selectedExam);

  RoadmapWeek? get currentRoadmapWeek {
    for (final week in weeks) {
      if (week.week == _currentWeek) return week;
    }
    return weeks.isNotEmpty ? weeks.first : null;
  }

  int get totalPyqs => totalPyqsForExam(_selectedExam);
  int get totalChapters => totalChaptersForExam(_selectedExam);

  double get overallProgress {
    final chapters = subjects.expand((s) => s.chapters).toList();
    if (chapters.isEmpty) return 0;
    var sum = 0.0;
    for (final chapter in chapters) {
      sum += chapterAccuracy(chapter.id, fallback: chapter.accuracy);
    }
    return sum / chapters.length;
  }

  Future<void> _init() async {
    final local = await _repo.loadLocalState();
    _applyState(local);

    try {
      if (!PrepContentRegistry.instance.isReady) {
        final bundles = await _repo.bootstrapContent();
        PrepContentRegistry.instance.setBundles(bundles);
      }
      _contentReady = PrepContentRegistry.instance.isReady;
      _contentError = null;
    } catch (e) {
      _contentError = e.toString();
    }

    _loaded = true;
    notifyListeners();

    final uid = AuthService.instance.userId;
    if (uid != null) {
      try {
        await _syncRemote(uid);
        _remoteSub?.cancel();
        _remoteSub = _repo.watchRemoteProfile(uid).listen((remote) {
          if (remote != null) _applyState(remote);
          notifyListeners();
        });
      } catch (_) {
        // Offline/tests: local state still works.
      }
    }
  }

  void _applyState(Map<String, dynamic> state) {
    _selectedExam = state['selectedExam'] as String? ?? supportedExams.first;
    _currentWeek = state['currentWeek'] as int? ?? 1;
    _completedCheckpoints
      ..clear()
      ..addAll(List<String>.from(state['completedCheckpoints'] as List? ?? []));

    _chapterProgress
      ..clear()
      ..addAll(
        _repo.parseChapterProgress(
          state['chapterProgress'] as Map<String, dynamic>?,
        ),
      );

    _mockAttempts.clear();
    final mocks = state['mockAttempts'] as Map<String, dynamic>?;
    if (mocks != null) {
      for (final entry in mocks.entries) {
        _mockAttempts[entry.key] = MockAttemptRecord.fromMap(
          Map<String, dynamic>.from(entry.value),
        );
      }
    }
  }

  Map<String, dynamic> _toState() => {
    'selectedExam': _selectedExam,
    'currentWeek': _currentWeek,
    'completedCheckpoints': _completedCheckpoints.toList(),
    'chapterProgress': _repo.chapterProgressToMap(_chapterProgress),
    'mockAttempts': _mockAttempts.map((k, v) => MapEntry(k, v.toMap())),
  };

  Future<void> _persist() async {
    final state = _toState();
    await _repo.saveLocalState(state);
    final uid = AuthService.instance.userId;
    if (uid != null) {
      try {
        await _repo.saveRemoteProfile(uid, state);
      } catch (_) {
        // Ignore when Firebase is unavailable.
      }
    }
    notifyListeners();
  }

  Future<void> _syncRemote(String userId) async {
    final remote = await _repo.loadRemoteProfile(userId);
    if (remote != null && remote.isNotEmpty) {
      _applyState(remote);
      notifyListeners();
    } else {
      await _repo.saveRemoteProfile(userId, _toState());
    }
  }

  Future<void> setExam(String exam) async {
    if (_selectedExam == exam) return;
    _selectedExam = exam;
    if (_currentWeek > weeks.length) _currentWeek = 1;
    await _persist();
  }

  Future<void> refreshContent({bool forceUpload = false}) async {
    try {
      final bundles = forceUpload
          ? await _repo.forceRefreshContent()
          : await _repo.bootstrapContent();
      PrepContentRegistry.instance.setBundles(bundles);
      _contentReady = PrepContentRegistry.instance.isReady;
      _contentError = null;
    } catch (e) {
      _contentError = e.toString();
    }
    notifyListeners();
  }

  Future<void> setCurrentWeek(int week) async {
    _currentWeek = week;
    await _persist();
  }

  Future<void> toggleCheckpoint(String checkpoint) async {
    if (_completedCheckpoints.contains(checkpoint)) {
      _completedCheckpoints.remove(checkpoint);
    } else {
      _completedCheckpoints.add(checkpoint);
    }
    await _persist();
  }

  bool isCheckpointDone(String checkpoint) =>
      _completedCheckpoints.contains(checkpoint);

  double chapterAccuracy(String chapterId, {double fallback = 0}) {
    return _chapterProgress[chapterId]?.accuracy ?? fallback;
  }

  double subjectProgress(PrepSubject subject) {
    if (subject.chapters.isEmpty) return subject.progress;
    var sum = 0.0;
    for (final chapter in subject.chapters) {
      sum += chapterAccuracy(chapter.id, fallback: chapter.accuracy);
    }
    return sum / subject.chapters.length;
  }

  bool isResourceDone(String resourceId) {
    for (final progress in _chapterProgress.values) {
      if (progress.completedResourceIds.contains(resourceId)) return true;
    }
    return false;
  }

  Future<void> markResourceComplete(
    String chapterId,
    String resourceId, {
    bool? done,
  }) async {
    final existing = _chapterProgress[chapterId] ?? const ChapterProgress();
    final ids = List<String>.from(existing.completedResourceIds);
    final shouldComplete = done ?? !ids.contains(resourceId);
    if (shouldComplete) {
      if (!ids.contains(resourceId)) ids.add(resourceId);
    } else {
      ids.remove(resourceId);
    }
    _chapterProgress[chapterId] = existing.copyWith(completedResourceIds: ids);
    await _persist();
  }

  Future<void> recordQuizResult(
    String chapterId,
    double accuracy,
    int attempted,
  ) async {
    final existing = _chapterProgress[chapterId] ?? const ChapterProgress();
    _chapterProgress[chapterId] = existing.copyWith(
      accuracy: accuracy,
      attemptedPyqs: existing.attemptedPyqs + attempted,
    );
    await _persist();
  }

  Future<void> recordMockAttempt(MockPaper paper, int score) async {
    final accuracy = paper.questions == 0 ? 0.0 : score / paper.questions;
    _mockAttempts[paper.id] = MockAttemptRecord(
      paperId: paper.id,
      score: score,
      accuracy: accuracy,
      completedAt: DateTime.now(),
    );
    await _persist();
  }

  MockAttemptRecord? mockAttempt(String paperId) => _mockAttempts[paperId];

  Future<void> createRoadmapTask(String title, {String? tag}) async {
    // Tasks are created from UI via TaskProviders + FirebaseAuth.
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    super.dispose();
  }
}

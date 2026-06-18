import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/prep_content_registry.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/model/prep_progress.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/model/pyq_volume.dart';
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

  /// Recent mock/PYQ sessions, newest first. Capped to keep the synced
  /// Firestore document small.
  final List<PracticeSession> _sessions = [];
  static const int _maxStoredSessions = 10;

  /// Questions the user flagged to revisit and learn with the AI mentor,
  /// newest first.
  final List<QuestionAttempt> _flaggedQuestions = [];

  List<PyqVolume> _pyqVolumes = [];
  bool _loaded = false;
  bool _contentReady = false;
  String? _contentError;

  String get selectedExam => _selectedExam;
  int get currentWeek => _currentWeek;
  bool get isLoaded => _loaded;
  bool get contentReady => _contentReady;
  String? get contentError => _contentError;
  Set<String> get completedCheckpoints => _completedCheckpoints;
  List<PyqVolume> get pyqVolumes => List.unmodifiable(_pyqVolumes);
  List<PracticeSession> get recentSessions => List.unmodifiable(_sessions);
  List<QuestionAttempt> get flaggedQuestions =>
      List.unmodifiable(_flaggedQuestions);

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

    // Fetch PYQ volumes (silent failure)
    await refreshPyqVolumes();

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

    _sessions
      ..clear()
      ..addAll(
        (state['sessions'] as List? ?? const []).map(
          (e) => PracticeSession.fromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    _sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    _flaggedQuestions
      ..clear()
      ..addAll(
        (state['flaggedQuestions'] as List? ?? const []).map(
          (e) => QuestionAttempt.fromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
  }

  Map<String, dynamic> _toState() => {
    'selectedExam': _selectedExam,
    'currentWeek': _currentWeek,
    'completedCheckpoints': _completedCheckpoints.toList(),
    'chapterProgress': _repo.chapterProgressToMap(_chapterProgress),
    'mockAttempts': _mockAttempts.map((k, v) => MapEntry(k, v.toMap())),
    'sessions': _sessions.map((s) => s.toMap()).toList(),
    'flaggedQuestions': _flaggedQuestions.map((q) => q.toMap()).toList(),
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
    await refreshPyqVolumes();
  }

  Future<void> refreshContent() async {
    try {
      final bundles = await _repo.bootstrapContent();
      PrepContentRegistry.instance.setBundles(bundles);
      _contentReady = PrepContentRegistry.instance.isReady;
      _contentError = null;
      await refreshPyqVolumes();
    } catch (e) {
      _contentError = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshPyqVolumes() async {
    try {
      _pyqVolumes = await _repo.fetchPyqVolumes(_selectedExam);
    } catch (_) {
      _pyqVolumes = [];
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
    int attempted, {
    int incorrectCount = 0,
  }) async {
    final existing = _chapterProgress[chapterId] ?? const ChapterProgress();
    _chapterProgress[chapterId] = existing.copyWith(
      accuracy: accuracy,
      attemptedPyqs: existing.attemptedPyqs + attempted,
      incorrectCount: existing.incorrectCount + incorrectCount,
    );
    await _persist();
  }

  Future<void> recordMockAttempt(
    MockPaper paper,
    int correctCount,
    int incorrectCount,
    int skippedCount,
  ) async {
    final total = paper.questions;
    final accuracy = total == 0 ? 0.0 : correctCount / total;
    // GATE scoring: +1 MCQ correct, -1/3 MCQ wrong, 0 skipped
    final marksObtained = correctCount - (incorrectCount / 3);

    _mockAttempts[paper.id] = MockAttemptRecord(
      paperId: paper.id,
      score: correctCount,
      accuracy: accuracy,
      completedAt: DateTime.now(),
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      skippedCount: skippedCount,
      marksObtained: marksObtained,
    );
    await _persist();
  }

  MockAttemptRecord? mockAttempt(String paperId) => _mockAttempts[paperId];

  /// Persists a completed mock/PYQ session (newest first, capped). Powers the
  /// wrong-answer review flow.
  Future<void> recordPracticeSession(PracticeSession session) async {
    _sessions
      ..removeWhere((s) => s.id == session.id)
      ..insert(0, session);
    if (_sessions.length > _maxStoredSessions) {
      _sessions.removeRange(_maxStoredSessions, _sessions.length);
    }
    await _persist();
  }

  /// Most recent stored session for a given source/ref, if any.
  PracticeSession? latestSessionFor(String source, String refId) {
    for (final s in _sessions) {
      if (s.source == source && s.refId == refId) return s;
    }
    return null;
  }

  /// All wrong attempts across stored sessions, newest first.
  List<QuestionAttempt> get allWrongAttempts =>
      _sessions.expand((s) => s.wrongAttempts).toList(growable: false);

  bool isFlagged(String questionId) =>
      _flaggedQuestions.any((q) => q.questionId == questionId);

  /// Adds [attempt] to the flagged list, or removes it if already flagged.
  Future<void> toggleFlag(QuestionAttempt attempt) async {
    final index = _flaggedQuestions.indexWhere(
      (q) => q.questionId == attempt.questionId,
    );
    if (index >= 0) {
      _flaggedQuestions.removeAt(index);
    } else {
      _flaggedQuestions.insert(0, attempt.copyWith(markedForReview: true));
    }
    await _persist();
  }

  Future<void> unflag(String questionId) async {
    _flaggedQuestions.removeWhere((q) => q.questionId == questionId);
    await _persist();
  }

  /// Returns total incorrect count across all chapters (for mistake tracker).
  int get totalIncorrect =>
      _chapterProgress.values.fold(0, (sum, p) => sum + p.incorrectCount);

  /// Returns chapters sorted by incorrectCount descending (weakest first).
  List<MapEntry<String, ChapterProgress>> get weakestChaptersByMistakes {
    final entries = _chapterProgress.entries.toList();
    entries.sort(
      (a, b) => b.value.incorrectCount.compareTo(a.value.incorrectCount),
    );
    return entries;
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    super.dispose();
  }
}

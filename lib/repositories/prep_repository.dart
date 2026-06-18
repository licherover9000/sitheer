import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitheer/data/prep_content_codec.dart';
import 'package:sitheer/data/prep_content_local.dart';
import 'package:sitheer/model/prep_exam_bundle.dart';
import 'package:sitheer/model/prep_progress.dart';
import 'package:sitheer/model/pyq_volume.dart';

class PrepRepository {
  PrepRepository._();
  static final PrepRepository instance = PrepRepository._();

  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  static const _localKey = 'prep_state_v1';
  static const _contentCachePrefix = 'prep_content_cache_';

  /// Loads exam bundles from Firestore, then falls back to the bundled catalog.
  ///
  /// Firestore catalog writes are intentionally not performed by the client.
  /// Use the Admin SDK seed script under `functions/scripts` for production
  /// content imports.
  Future<List<PrepExamBundle>> bootstrapContent() async {
    final bundles = <PrepExamBundle>[];
    for (final local in allLocalBundles()) {
      final loaded = await fetchExamBundle(local.examId) ?? local;
      bundles.add(loaded);
      await _cacheContentBundle(loaded);
    }
    return bundles;
  }

  @Deprecated('Use the Admin SDK seed script instead of client writes.')
  Future<void> seedExamContentIfMissing(PrepExamBundle bundle) async {
    return;
  }

  /// Reads cloud-hosted questions for an exam from
  /// `content/exams/items/{examId}/questions`. Returns an empty list when
  /// Firebase is unavailable or the collection is empty (the app then relies on
  /// the bundled JSON assets). Writes are Admin-SDK only.
  Future<List<Map<String, dynamic>>> fetchExamQuestions(String examId) async {
    final db = _db;
    if (db == null) return const [];
    try {
      final snap = await db
          .collection('content')
          .doc('exams')
          .collection('items')
          .doc(examId)
          .collection('questions')
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<PrepExamBundle?> fetchExamBundle(String examId) async {
    final db = _db;
    if (db == null) return _loadCachedBundle(examId);
    try {
      final snap = await db
          .collection('content')
          .doc('exams')
          .collection('items')
          .doc(examId)
          .get();
      if (!snap.exists || snap.data() == null) {
        return _loadCachedBundle(examId);
      }
      final bundle = bundleFromMap(snap.data()!);
      await _cacheContentBundle(bundle);
      return bundle;
    } catch (_) {
      return _loadCachedBundle(examId);
    }
  }

  Future<void> _cacheContentBundle(PrepExamBundle bundle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_contentCachePrefix${bundle.examId}',
      jsonEncode(bundleToMap(bundle)),
    );
  }

  Future<PrepExamBundle?> _loadCachedBundle(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_contentCachePrefix$examId');
    if (raw == null) return null;
    try {
      return bundleFromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveLocalState(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(state));
  }

  Future<Map<String, dynamic>?> loadRemoteProfile(String userId) async {
    final db = _db;
    if (db == null) return null;
    final doc = await db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data()?['prepProfile'] as Map<String, dynamic>?;
  }

  Stream<Map<String, dynamic>?> watchRemoteProfile(String userId) {
    final db = _db;
    if (db == null) return const Stream.empty();
    return db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.data()?['prepProfile'] as Map<String, dynamic>?);
  }

  Future<void> saveRemoteProfile(
    String userId,
    Map<String, dynamic> prepProfile,
  ) async {
    final db = _db;
    if (db == null) return;
    await db.collection('users').doc(userId).set({
      'prepProfile': prepProfile,
    }, SetOptions(merge: true));
  }

  Map<String, ChapterProgress> parseChapterProgress(Map<String, dynamic>? raw) {
    if (raw == null) return {};
    return raw.map(
      (key, value) => MapEntry(
        key,
        ChapterProgress.fromMap(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  Map<String, dynamic> chapterProgressToMap(
    Map<String, ChapterProgress> progress,
  ) {
    return progress.map((k, v) => MapEntry(k, v.toMap()));
  }

  Future<List<PyqVolume>> fetchPyqVolumes(String examId) async {
    final fallback = _localPyqVolumesFor(examId);
    final db = _db;
    if (db == null) return fallback;
    try {
      final snap = await db
          .collection('content')
          .doc('pyqVolumes')
          .collection('items')
          .where('examId', isEqualTo: examId)
          .get();
      final volumes = snap.docs
          .map((doc) => PyqVolume.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      volumes.sort(_comparePyqVolumes);
      return volumes.isEmpty ? fallback : volumes;
    } catch (_) {
      return fallback;
    }
  }

  List<PyqVolume> _localPyqVolumesFor(String examId) {
    final volumes = allLocalPyqVolumes()
        .where((volume) => volume.examId == examId)
        .toList();
    volumes.sort(_comparePyqVolumes);
    return volumes;
  }

  int _comparePyqVolumes(PyqVolume a, PyqVolume b) {
    final aOrder = a.volumeNumber ?? (a.year == 0 ? 9999 : a.year);
    final bOrder = b.volumeNumber ?? (b.year == 0 ? 9999 : b.year);
    final order = aOrder.compareTo(bOrder);
    if (order != 0) return order;
    return a.label.compareTo(b.label);
  }
}

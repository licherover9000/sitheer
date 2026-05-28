import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MentorKeysProvider extends ChangeNotifier {
  MentorKeysProvider() {
    _load();
  }

  static const _storage = FlutterSecureStorage();
  static const _geminiKey = 'mentor_gemini_api_key';
  static const _openaiKey = 'mentor_openai_api_key';
  static const _useCloudKey = 'mentor_use_cloud';
  static const _legacyGemini = 'mentor_gemini_api_key';
  static const _legacyOpenai = 'mentor_openai_api_key';

  String _gemini = '';
  String _openai = '';
  bool _useCloudMentor = true;
  bool _loaded = false;

  String get geminiApiKey => _effectiveGemini;
  String get openaiApiKey => _effectiveOpenai;
  bool get useCloudMentor => _useCloudMentor;
  bool get isLoaded => _loaded;
  bool get hasGemini => _effectiveGemini.isNotEmpty;
  bool get hasOpenai => _effectiveOpenai.isNotEmpty;
  bool get hasAnyKey => hasGemini || hasOpenai;

  String get _effectiveGemini {
    if (_gemini.isNotEmpty) return _gemini;
    return const String.fromEnvironment('GEMINI_API_KEY');
  }

  String get _effectiveOpenai {
    if (_openai.isNotEmpty) return _openai;
    return const String.fromEnvironment('OPENAI_API_KEY');
  }

  Future<void> _load() async {
    _gemini = (await _storage.read(key: _geminiKey)) ?? '';
    _openai = (await _storage.read(key: _openaiKey)) ?? '';

    // Migrate keys from older SharedPreferences storage.
    if (_gemini.isEmpty || _openai.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final legacyGemini = prefs.getString(_legacyGemini);
      final legacyOpenai = prefs.getString(_legacyOpenai);
      if (legacyGemini != null && legacyGemini.isNotEmpty) {
        _gemini = legacyGemini;
        await _storage.write(key: _geminiKey, value: _gemini);
        await prefs.remove(_legacyGemini);
      }
      if (legacyOpenai != null && legacyOpenai.isNotEmpty) {
        _openai = legacyOpenai;
        await _storage.write(key: _openaiKey, value: _openai);
        await prefs.remove(_legacyOpenai);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    _useCloudMentor = prefs.getBool(_useCloudKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setGeminiKey(String value) async {
    _gemini = value.trim();
    await _storage.write(key: _geminiKey, value: _gemini);
    notifyListeners();
  }

  Future<void> setOpenaiKey(String value) async {
    _openai = value.trim();
    await _storage.write(key: _openaiKey, value: _openai);
    notifyListeners();
  }

  Future<void> setUseCloudMentor(bool value) async {
    _useCloudMentor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useCloudKey, value);
    notifyListeners();
  }

  Future<void> clearKeys() async {
    _gemini = '';
    _openai = '';
    await _storage.delete(key: _geminiKey);
    await _storage.delete(key: _openaiKey);
    notifyListeners();
  }
}

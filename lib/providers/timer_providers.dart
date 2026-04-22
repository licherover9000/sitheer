import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimerMode { focus, shortBreak, longBreak }

enum TimerState { idle, running, paused, finished }

class TimerProviders extends ChangeNotifier {
  TimerMode _mode = TimerMode.focus;
  TimerState _state = TimerState.idle;
  Timer? _timer;
  int _secondsLeft = 25 * 60;
  int _completedSessions = 0;
  int _focusedMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  TimerProviders() {
    _loadSettings();
  }
  //Getters
  TimerMode get mode => _mode;
  TimerState get state => _state;
  int get seconds => _secondsLeft;
  int get sessions => _completedSessions;

  int get focusedMinutes => _focusedMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;

  // human readable mm:ss string
  String get timeString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress => _secondsLeft / _totalSeconds;

  int get _totalSeconds {
    switch (_mode) {
      case TimerMode.focus:
        return _focusedMinutes * 60;
      case TimerMode.shortBreak:
        return _shortBreakMinutes * 60;
      case TimerMode.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _focusedMinutes = prefs.getInt('focusedMinutes') ?? 25;
    _shortBreakMinutes = prefs.getInt('shortBreakMinutes') ?? 5;
    _longBreakMinutes = prefs.getInt('longBreakMinutes') ?? 15;
    reset();
  }

  Future<void> updateDurations({
    int? focus,
    int? shortBreak,
    int? longBreak,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (focus != null) {
      await prefs.setInt('focusedMinutes', focus);
    }
    if (shortBreak != null) {
      await prefs.setInt('shortBreakMinutes', shortBreak);
    }
    if (longBreak != null) {
      await prefs.setInt('longBreakMinutes', longBreak);
    }
    if (_state == TimerState.idle) {
      reset();
    }
  }

  void start() {
    _state = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        notifyListeners();
      } else {
        _onFinished();
      }
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _secondsLeft = _totalSeconds;
    _state = TimerState.idle;
    notifyListeners();
  }

  void setMode(TimerMode mode) {
    _timer?.cancel();
    _mode = mode;
    _secondsLeft = _totalSeconds;
    _state = TimerState.idle;
    notifyListeners();
  }

  void _onFinished() {
    _timer?.cancel();
    _state = TimerState.finished;
    if (_mode == TimerMode.focus) _completedSessions++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

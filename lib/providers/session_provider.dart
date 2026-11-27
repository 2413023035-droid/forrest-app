import 'dart:async';
import 'package:flutter/material.dart';
import '../data/repositories/session_repository.dart';
import '../core/utils/coin_calculator.dart';
import '../core/utils/grid_calculator.dart';

enum SessionState { idle, running, completed, failed }

class SessionProvider extends ChangeNotifier {
  final _repo = SessionRepository();

  SessionState _state = SessionState.idle;
  Timer? _timer;

  String _mode = 'timer';
  int _targetSeconds = 25 * 60; // default 25 menit
  int _elapsedSeconds = 0;
  String _selectedTagId = 'lainnya';
  String _selectedTreeId = 'tree_oak';
  String? _currentSessionId;
  int _lastCoinsEarned = 0;
  bool _lastIsCompleted = false;

  // Getters
  SessionState get state => _state;
  String get mode => _mode;
  int get elapsedSeconds => _elapsedSeconds;
  int get targetSeconds => _targetSeconds;
  int get lastCoinsEarned => _lastCoinsEarned;
  bool get lastIsCompleted => _lastIsCompleted;
  String get selectedTagId => _selectedTagId;
  String get selectedTreeId => _selectedTreeId;

  int get remainingSeconds =>
      (_targetSeconds - _elapsedSeconds).clamp(0, _targetSeconds);

  double get progress {
    if (_mode == 'timer' && _targetSeconds > 0) {
      return (_elapsedSeconds / _targetSeconds).clamp(0.0, 1.0);
    }
    // Stopwatch: animasi cap 60 menit
    return (_elapsedSeconds / (60 * 60)).clamp(0.0, 1.0);
  }

  void configure({
    required String mode,
    required int targetSeconds,
    required String tagId,
    required String treeId,
  }) {
    _mode = mode;
    _targetSeconds = targetSeconds;
    _selectedTagId = tagId;
    _selectedTreeId = treeId;
  }

  Future<void> startSession(int streakDays) async {
    _elapsedSeconds = 0;
    _lastCoinsEarned = 0;
    _lastIsCompleted = false;
    _state = SessionState.running;
    notifyListeners();

    // Ambil posisi grid berikutnya
    final occupied = await _repo.fetchOccupiedGridPositions();
    final (gx, gy) = GridCalculator.nextPosition(occupied);

    _currentSessionId = await _repo.createSession(
      mode: _mode,
      tagId: _selectedTagId,
      treeTypeId: _selectedTreeId,
      targetSeconds: _mode == 'timer' ? _targetSeconds : null,
      gridX: gx,
      gridY: gy,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(streakDays));
  }

  void _tick(int streakDays) {
    _elapsedSeconds++;
    if (_mode == 'timer' && _elapsedSeconds >= _targetSeconds) {
      _finishSession(isCompleted: true, streakDays: streakDays);
      return;
    }
    notifyListeners();
  }

  Future<void> _finishSession({
    required bool isCompleted,
    required int streakDays,
  }) async {
    _timer?.cancel();
    _lastIsCompleted = isCompleted;
    _lastCoinsEarned = CoinCalculator.calculate(
      mode: _mode,
      actualSeconds: _elapsedSeconds,
      targetSeconds: _targetSeconds,
      isCompleted: isCompleted,
      streakDays: streakDays,
    );
    _state = isCompleted ? SessionState.completed : SessionState.failed;

    if (_currentSessionId != null) {
      await _repo.endSession(
        sessionId: _currentSessionId!,
        actualSeconds: _elapsedSeconds,
        isCompleted: isCompleted,
        coinsEarned: _lastCoinsEarned,
      );
    }
    notifyListeners();
  }

  /// Dipanggil saat app ke background (penalti)
  Future<void> handleAppBackground(int streakDays) async {
    if (_state != SessionState.running) return;
    await _finishSession(isCompleted: false, streakDays: streakDays);
  }

  /// Stop manual (stopwatch mode)
  Future<void> stopManually(int streakDays) async {
    if (_state != SessionState.running) return;
    await _finishSession(isCompleted: true, streakDays: streakDays);
  }

  void reset() {
    _timer?.cancel();
    _state = SessionState.idle;
    _elapsedSeconds = 0;
    _currentSessionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

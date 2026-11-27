import 'package:flutter/material.dart';
import '../data/models/focus_session_model.dart';
import '../data/repositories/session_repository.dart';

class ForestProvider extends ChangeNotifier {
  final _repo = SessionRepository();

  List<FocusSessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<FocusSessionModel> get sessions => _sessions;
  List<FocusSessionModel> get completedSessions =>
      _sessions.where((s) => s.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadForest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await _repo.fetchForestSessions();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Tambahkan sesi baru ke cache lokal setelah sesi selesai
  void addSession(FocusSessionModel session) {
    _sessions.insert(0, session);
    notifyListeners();
  }

  /// Statistik per tag
  Map<String, int> get secondsPerTag {
    final map = <String, int>{};
    for (final s in _sessions.where((s) => s.isCompleted)) {
      map[s.tagId] = (map[s.tagId] ?? 0) + s.durationActualSeconds;
    }
    return map;
  }

  /// Data grafik harian (7 hari terakhir)
  List<MapEntry<DateTime, int>> get dailyFocusLast7Days {
    final now = DateTime.now();
    final result = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      result[day] = 0;
    }
    for (final s in _sessions.where((s) => s.isCompleted)) {
      final day = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      if (result.containsKey(day)) {
        result[day] = (result[day] ?? 0) + s.durationActualSeconds;
      }
    }
    return result.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }
}

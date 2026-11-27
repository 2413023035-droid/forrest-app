import 'package:flutter/material.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final _repo = ProfileRepository();

  ProfileModel? _profile;
  bool _isLoading = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  int get coins => _profile?.coins ?? 0;
  int get streakDays => _profile?.streakDays ?? 0;
  String get equippedTreeId => _profile?.equippedTreeId ?? 'tree_oak';
  String get equippedThemeId => _profile?.equippedThemeId ?? 'theme_default';
  String get language => _profile?.language ?? 'id';

  Future<void> load(String userId) async {
    _isLoading = true;
    notifyListeners();
    _profile = await _repo.fetchProfile(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> applySessionReward({
    required String userId,
    required int coinsEarned,
    required bool isCompleted,
    required int actualSeconds,
  }) async {
    _profile = await _repo.applySessionReward(
      userId: userId,
      coinsEarned: coinsEarned,
      isCompleted: isCompleted,
    );
    // Update total_focus_seconds lokal
    if (_profile != null) {
      _profile = _profile!.copyWith(
        totalFocusSeconds: _profile!.totalFocusSeconds + actualSeconds,
      );
    }
    notifyListeners();
  }

  Future<bool> spendCoins(String userId, int amount) async {
    final success = await _repo.spendCoins(userId, amount);
    if (success && _profile != null) {
      _profile = _profile!.copyWith(coins: _profile!.coins - amount);
      notifyListeners();
    }
    return success;
  }

  Future<void> equipItem(String userId, String itemId, String type) async {
    final field = type == 'tree' ? 'equipped_tree_id' : 'equipped_theme_id';
    await _repo.updateProfile(userId, {field: itemId});
    if (type == 'tree') {
      _profile = _profile?.copyWith(equippedTreeId: itemId);
    } else {
      _profile = _profile?.copyWith(equippedThemeId: itemId);
    }
    notifyListeners();
  }

  Future<void> updateDisplayName(String userId, String name) async {
    await _repo.updateProfile(userId, {'display_name': name});
    _profile = _profile?.copyWith(displayName: name);
    notifyListeners();
  }

  Future<void> setLanguage(String userId, String lang) async {
    await _repo.updateProfile(userId, {'language': lang});
    _profile = _profile?.copyWith(language: lang);
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../supabase/supabase_client.dart';

class ProfileRepository {
  Future<ProfileModel?> fetchProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> fields) async {
    await supabase
        .from('profiles')
        .update({...fields, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }

  /// Tambah koin & update streak setelah sesi selesai
  Future<ProfileModel?> applySessionReward({
    required String userId,
    required int coinsEarned,
    required bool isCompleted,
  }) async {
    // Ambil profil terkini
    final profile = await fetchProfile(userId);
    if (profile == null) return null;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate = profile.lastFocusDate;

    int newStreak = profile.streakDays;
    if (isCompleted) {
      if (lastDate == null) {
        newStreak = 1;
      } else {
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final diff = todayDate.difference(lastDay).inDays;
        if (diff == 1) {
          newStreak = profile.streakDays + 1; // hari berturut-turut
        } else if (diff == 0) {
          newStreak = profile.streakDays; // sudah fokus hari ini
        } else {
          newStreak = 1; // streak putus
        }
      }
    }

    await updateProfile(userId, {
      'coins': profile.coins + coinsEarned,
      'streak_days': newStreak,
      'last_focus_date': isCompleted ? todayDate.toIso8601String().split('T').first : profile.lastFocusDate?.toIso8601String().split('T').first,
      'total_focus_seconds': profile.totalFocusSeconds,
      'total_sessions': profile.totalSessions + 1,
    });

    return await fetchProfile(userId);
  }

  /// Kurangi koin untuk pembelian di toko
  Future<bool> spendCoins(String userId, int amount) async {
    final profile = await fetchProfile(userId);
    if (profile == null || profile.coins < amount) return false;
    await updateProfile(userId, {'coins': profile.coins - amount});
    return true;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final data = await supabase
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    return data == null;
  }
}

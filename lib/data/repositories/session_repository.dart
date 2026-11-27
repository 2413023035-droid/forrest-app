import '../models/focus_session_model.dart';
import '../supabase/supabase_client.dart';

class SessionRepository {
  /// Buat record sesi baru saat user mulai fokus
  Future<String> createSession({
    required String mode,
    required String tagId,
    required String treeTypeId,
    int? targetSeconds,
    required int gridX,
    required int gridY,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('focus_sessions')
        .insert({
          'user_id': userId,
          'mode': mode,
          'tag_id': tagId,
          'tree_type_id': treeTypeId,
          'duration_target_seconds': targetSeconds,
          'grid_x': gridX,
          'grid_y': gridY,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();
    return response['id'] as String;
  }

  /// Update sesi saat selesai atau gagal
  Future<void> endSession({
    required String sessionId,
    required int actualSeconds,
    required bool isCompleted,
    required int coinsEarned,
  }) async {
    await supabase.from('focus_sessions').update({
      'duration_actual_seconds': actualSeconds,
      'is_completed': isCompleted,
      'coins_earned': coinsEarned,
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', sessionId);
  }

  /// Ambil semua sesi untuk hutan (hanya yang selesai)
  Future<List<FocusSessionModel>> fetchForestSessions() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('focus_sessions')
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false);
    return (data as List)
        .map((e) => FocusSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil sesi untuk statistik (N hari terakhir)
  Future<List<FocusSessionModel>> fetchRecentSessions({int days = 30}) async {
    final userId = supabase.auth.currentUser!.id;
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final data = await supabase
        .from('focus_sessions')
        .select()
        .eq('user_id', userId)
        .gte('started_at', since)
        .order('started_at');
    return (data as List)
        .map((e) => FocusSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Daftar posisi grid yang sudah terpakai
  Future<List<(int, int)>> fetchOccupiedGridPositions() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('focus_sessions')
        .select('grid_x, grid_y')
        .eq('user_id', userId)
        .not('grid_x', 'is', null);
    return (data as List)
        .where((e) => e['grid_x'] != null && e['grid_y'] != null)
        .map((e) => (e['grid_x'] as int, e['grid_y'] as int))
        .toList();
  }
}

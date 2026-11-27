class FocusSessionModel {
  final String id;
  final String userId;
  final String mode; // 'timer' | 'stopwatch'
  final String tagId;
  final String treeTypeId;
  final int? durationTargetSeconds;
  final int durationActualSeconds;
  final bool isCompleted;
  final int coinsEarned;
  final int? gridX;
  final int? gridY;
  final String? note;
  final DateTime startedAt;
  final DateTime? endedAt;

  const FocusSessionModel({
    required this.id,
    required this.userId,
    required this.mode,
    required this.tagId,
    required this.treeTypeId,
    this.durationTargetSeconds,
    required this.durationActualSeconds,
    required this.isCompleted,
    required this.coinsEarned,
    this.gridX,
    this.gridY,
    this.note,
    required this.startedAt,
    this.endedAt,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) =>
      FocusSessionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        mode: json['mode'] as String,
        tagId: (json['tag_id'] as String?) ?? 'lainnya',
        treeTypeId: (json['tree_type_id'] as String?) ?? 'tree_oak',
        durationTargetSeconds: json['duration_target_seconds'] as int?,
        durationActualSeconds: (json['duration_actual_seconds'] as int?) ?? 0,
        isCompleted: (json['is_completed'] as bool?) ?? false,
        coinsEarned: (json['coins_earned'] as int?) ?? 0,
        gridX: json['grid_x'] as int?,
        gridY: json['grid_y'] as int?,
        note: json['note'] as String?,
        startedAt: DateTime.parse(json['started_at'] as String),
        endedAt: json['ended_at'] != null
            ? DateTime.parse(json['ended_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'mode': mode,
    'tag_id': tagId,
    'tree_type_id': treeTypeId,
    'duration_target_seconds': durationTargetSeconds,
    'duration_actual_seconds': durationActualSeconds,
    'is_completed': isCompleted,
    'coins_earned': coinsEarned,
    'grid_x': gridX,
    'grid_y': gridY,
    'note': note,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
  };
}

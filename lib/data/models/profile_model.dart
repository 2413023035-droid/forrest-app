class ProfileModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarColor;
  final int coins;
  final int streakDays;
  final DateTime? lastFocusDate;
  final String equippedTreeId;
  final String equippedThemeId;
  final String language;
  final bool notifyReminder;
  final int totalFocusSeconds;
  final int totalSessions;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarColor = '#2E7D32',
    this.coins = 0,
    this.streakDays = 0,
    this.lastFocusDate,
    this.equippedTreeId = 'tree_oak',
    this.equippedThemeId = 'theme_default',
    this.language = 'id',
    this.notifyReminder = true,
    this.totalFocusSeconds = 0,
    this.totalSessions = 0,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    username: (json['username'] as String?) ?? '',
    displayName: (json['display_name'] as String?) ?? '',
    avatarColor: (json['avatar_color'] as String?) ?? '#2E7D32',
    coins: (json['coins'] as int?) ?? 0,
    streakDays: (json['streak_days'] as int?) ?? 0,
    lastFocusDate: json['last_focus_date'] != null
        ? DateTime.parse(json['last_focus_date'] as String)
        : null,
    equippedTreeId: (json['equipped_tree_id'] as String?) ?? 'tree_oak',
    equippedThemeId: (json['equipped_theme_id'] as String?) ?? 'theme_default',
    language: (json['language'] as String?) ?? 'id',
    notifyReminder: (json['notify_reminder'] as bool?) ?? true,
    totalFocusSeconds: (json['total_focus_seconds'] as int?) ?? 0,
    totalSessions: (json['total_sessions'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'avatar_color': avatarColor,
    'coins': coins,
    'streak_days': streakDays,
    'last_focus_date': lastFocusDate?.toIso8601String().split('T').first,
    'equipped_tree_id': equippedTreeId,
    'equipped_theme_id': equippedThemeId,
    'language': language,
    'notify_reminder': notifyReminder,
    'total_focus_seconds': totalFocusSeconds,
    'total_sessions': totalSessions,
  };

  ProfileModel copyWith({
    int? coins,
    int? streakDays,
    DateTime? lastFocusDate,
    String? equippedTreeId,
    String? equippedThemeId,
    String? displayName,
    String? language,
    bool? notifyReminder,
    int? totalFocusSeconds,
    int? totalSessions,
  }) =>
      ProfileModel(
        id: id,
        username: username,
        displayName: displayName ?? this.displayName,
        avatarColor: avatarColor,
        coins: coins ?? this.coins,
        streakDays: streakDays ?? this.streakDays,
        lastFocusDate: lastFocusDate ?? this.lastFocusDate,
        equippedTreeId: equippedTreeId ?? this.equippedTreeId,
        equippedThemeId: equippedThemeId ?? this.equippedThemeId,
        language: language ?? this.language,
        notifyReminder: notifyReminder ?? this.notifyReminder,
        totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
        totalSessions: totalSessions ?? this.totalSessions,
      );
}

class TagModel {
  final String id;
  final String nameId;
  final String nameEn;
  final String icon;
  final String colorHex;
  final bool isCustom;
  final String? userId;

  const TagModel({
    required this.id,
    required this.nameId,
    required this.nameEn,
    required this.icon,
    required this.colorHex,
    this.isCustom = false,
    this.userId,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) => TagModel(
    id: json['id'] as String,
    nameId: json['name_id'] as String,
    nameEn: json['name_en'] as String,
    icon: (json['icon'] as String?) ?? '🏷️',
    colorHex: (json['color_hex'] as String?) ?? '#757575',
    isCustom: (json['is_custom'] as bool?) ?? false,
    userId: json['user_id'] as String?,
  );

  /// Nama sesuai bahasa aktif
  String localName(String lang) => lang == 'en' ? nameEn : nameId;
}

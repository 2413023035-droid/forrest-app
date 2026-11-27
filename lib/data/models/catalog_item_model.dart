class CatalogItemModel {
  final String id;
  final String type; // 'tree' | 'theme'
  final String nameId;
  final String nameEn;
  final String? descriptionId;
  final String? descriptionEn;
  final String assetKey;
  final int priceCoins;
  final bool isDefault;
  final int sortOrder;

  const CatalogItemModel({
    required this.id,
    required this.type,
    required this.nameId,
    required this.nameEn,
    this.descriptionId,
    this.descriptionEn,
    required this.assetKey,
    required this.priceCoins,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) =>
      CatalogItemModel(
        id: json['id'] as String,
        type: json['type'] as String,
        nameId: json['name_id'] as String,
        nameEn: json['name_en'] as String,
        descriptionId: json['description_id'] as String?,
        descriptionEn: json['description_en'] as String?,
        assetKey: json['asset_key'] as String,
        priceCoins: (json['price_coins'] as int?) ?? 0,
        isDefault: (json['is_default'] as bool?) ?? false,
        sortOrder: (json['sort_order'] as int?) ?? 0,
      );

  String localName(String lang) => lang == 'en' ? nameEn : nameId;
  bool get isFree => priceCoins == 0;
}

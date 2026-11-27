import 'package:flutter/material.dart';
import '../data/models/catalog_item_model.dart';
import '../data/models/tag_model.dart';
import '../data/repositories/shop_repository.dart';

class ShopProvider extends ChangeNotifier {
  final _repo = ShopRepository();

  List<CatalogItemModel> _catalog = [];
  List<String> _ownedIds = [];
  List<TagModel> _tags = [];
  bool _isLoading = false;

  List<CatalogItemModel> get trees =>
      _catalog.where((i) => i.type == 'tree').toList();
  List<CatalogItemModel> get themes =>
      _catalog.where((i) => i.type == 'theme').toList();
  List<TagModel> get tags => _tags;
  List<String> get ownedIds => _ownedIds;
  bool get isLoading => _isLoading;

  bool isOwned(String itemId) => _ownedIds.contains(itemId);

  Future<void> load(String userId) async {
    _isLoading = true;
    notifyListeners();
    final results = await Future.wait([
      _repo.fetchAllItems(),
      _repo.fetchOwnedItemIds(userId),
      _repo.fetchTags(),
    ]);
    _catalog  = results[0] as List<CatalogItemModel>;
    _ownedIds = results[1] as List<String>;
    _tags     = results[2] as List<TagModel>;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> purchaseItem({
    required String userId,
    required CatalogItemModel item,
    required int userCoins,
  }) async {
    if (isOwned(item.id)) return false;
    if (userCoins < item.priceCoins) return false;

    await _repo.purchaseItem(userId, item.id);
    _ownedIds = [..._ownedIds, item.id];
    notifyListeners();
    return true;
  }
}

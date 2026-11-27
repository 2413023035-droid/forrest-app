import '../models/tag_model.dart';
import '../models/catalog_item_model.dart';
import '../supabase/supabase_client.dart';

class ShopRepository {
  Future<List<CatalogItemModel>> fetchAllItems() async {
    final data = await supabase
        .from('catalog_items')
        .select()
        .order('type')
        .order('sort_order');
    return (data as List)
        .map((e) => CatalogItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchOwnedItemIds(String userId) async {
    final data = await supabase
        .from('user_inventory')
        .select('item_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['item_id'] as String).toList();
  }

  Future<void> purchaseItem(String userId, String itemId) async {
    await supabase.from('user_inventory').insert({
      'user_id': userId,
      'item_id': itemId,
    });
  }

  Future<List<TagModel>> fetchTags() async {
    final userId = supabase.auth.currentUser?.id;
    final data = await supabase
        .from('tags')
        .select()
        .or('is_custom.eq.false,user_id.eq.$userId')
        .order('sort_order');
    return (data as List)
        .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../data/models/catalog_item_model.dart';
import '../../widgets/tree_widget.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileId = context.read<ProfileProvider>().profile?.id;
      if (profileId != null) context.read<ShopProvider>().load(profileId);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _buy(CatalogItemModel item) async {
    final shop    = context.read<ShopProvider>();
    final profile = context.read<ProfileProvider>();
    if (profile.profile == null) return;

    final coins = profile.profile!.coins;
    if (coins < item.priceCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koin tidak cukup 🪙')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Beli ${item.nameId}?'),
        content: Text('Harga: ${item.priceCoins} 🪙\nKoin kamu: $coins 🪙'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Beli')),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await shop.purchaseItem(
      userId: profile.profile!.id,
      item: item,
      userCoins: coins,
    );
    if (ok) {
      await profile.spendCoins(profile.profile!.id, item.priceCoins);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.nameId} berhasil dibeli! 🎉')),
        );
      }
    }
  }

  Future<void> _equip(CatalogItemModel item) async {
    final profile = context.read<ProfileProvider>();
    if (profile.profile == null) return;
    await profile.equipItem(profile.profile!.id, item.id, item.type);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.nameId} dipasang! ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop    = context.watch<ShopProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Bibit 🏪'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🪙'),
                const SizedBox(width: 4),
                Text(
                  '${profile?.coins ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: '🌲 Pohon'),
            Tab(text: '🏞️ Tema'),
          ],
        ),
      ),
      body: shop.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _ItemGrid(
                  items: shop.trees,
                  shop: shop,
                  equippedId: profile?.equippedTreeId,
                  onBuy: _buy,
                  onEquip: _equip,
                  buildPreview: (item) => TreeWidget(
                    treeTypeId: item.assetKey,
                    size: 72,
                  ),
                ),
                _ItemGrid(
                  items: shop.themes,
                  shop: shop,
                  equippedId: profile?.equippedThemeId,
                  onBuy: _buy,
                  onEquip: _equip,
                  buildPreview: (item) => _ThemePreview(assetKey: item.assetKey),
                ),
              ],
            ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  final List<CatalogItemModel> items;
  final ShopProvider shop;
  final String? equippedId;
  final Future<void> Function(CatalogItemModel) onBuy;
  final Future<void> Function(CatalogItemModel) onEquip;
  final Widget Function(CatalogItemModel) buildPreview;

  const _ItemGrid({
    required this.items,
    required this.shop,
    required this.equippedId,
    required this.onBuy,
    required this.onEquip,
    required this.buildPreview,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item    = items[i];
        final owned   = shop.isOwned(item.id);
        final equipped = item.id == equippedId;
        final cs = Theme.of(context).colorScheme;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: equipped
                ? BorderSide(color: cs.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: owned && !equipped ? () => onEquip(item) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(child: buildPreview(item)),
                  const SizedBox(height: 8),
                  Text(item.nameId,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  if (equipped)
                    Chip(
                      label: const Text('✅ Dipakai', style: TextStyle(fontSize: 11)),
                      backgroundColor: cs.primaryContainer,
                      padding: EdgeInsets.zero,
                    )
                  else if (owned)
                    OutlinedButton(
                      onPressed: () => onEquip(item),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(100, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Pakai', style: TextStyle(fontSize: 12)),
                    )
                  else
                    FilledButton.tonal(
                      onPressed: () => onBuy(item),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(100, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text('${item.priceCoins} 🪙',
                          style: const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final String assetKey;
  const _ThemePreview({required this.assetKey});

  @override
  Widget build(BuildContext context) {
    final colors = switch (assetKey) {
      'desert'   => [const Color(0xFFFFF8E1), const Color(0xFFFFCC80)],
      'snow'     => [const Color(0xFFE3F2FD), const Color(0xFFB3E5FC)],
      'tropical' => [const Color(0xFFE0F7FA), const Color(0xFF80DEEA)],
      _          => [const Color(0xFFE8F5E9), const Color(0xFFA5D6A7)],
    };
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('🌳', style: TextStyle(fontSize: 36)),
      ),
    );
  }
}

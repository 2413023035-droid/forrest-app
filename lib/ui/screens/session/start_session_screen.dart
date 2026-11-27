import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/tree_widget.dart';
import '../../widgets/tag_chip.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  String _mode = 'timer';
  int _durationMinutes = 25;
  String _selectedTagId = 'lainnya';
  String _selectedTreeId = 'tree_oak';

  final _durations = [15, 20, 25, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final auth = context.read<ProfileProvider>();
    if (auth.profile != null) {
      context.read<ShopProvider>().load(auth.profile!.id);
    }
  }

  void _startSession() {
    final session = context.read<SessionProvider>();
    session.configure(
      mode: _mode,
      targetSeconds: _durationMinutes * 60,
      tagId: _selectedTagId,
      treeId: _selectedTreeId,
    );
    Navigator.pushNamed(context, AppRoutes.focusActive);
  }

  @override
  Widget build(BuildContext context) {
    final shop    = context.watch<ShopProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final ownedTreeIds = shop.ownedIds;

    return Scaffold(
      appBar: AppBar(title: const Text('Mulai Sesi Fokus')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selector
            Text('Mode', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'timer',     label: Text('Timer'),     icon: Icon(Icons.timer_outlined)),
                ButtonSegment(value: 'stopwatch', label: Text('Stopwatch'), icon: Icon(Icons.stopwatch_outlined)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 20),

            // Durasi (hanya untuk timer)
            if (_mode == 'timer') ...[
              Text('Durasi', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _durations.map((d) {
                  final selected = d == _durationMinutes;
                  return ChoiceChip(
                    label: Text('${d}m'),
                    selected: selected,
                    onSelected: (_) => setState(() => _durationMinutes = d),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Tag kategori
            Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: shop.tags.map((tag) => TagChip(
                tag: tag,
                isSelected: tag.id == _selectedTagId,
                onTap: () => setState(() => _selectedTagId = tag.id),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Pilih bibit pohon
            Text('Bibit Pohon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: shop.trees.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final tree = shop.trees[i];
                  final owned = ownedTreeIds.contains(tree.id);
                  final selected = tree.assetKey == _selectedTreeId ||
                      tree.id == _selectedTreeId;
                  return GestureDetector(
                    onTap: owned
                        ? () => setState(() => _selectedTreeId = tree.assetKey)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TreeWidget(
                            treeTypeId: tree.assetKey,
                            size: 56,
                            growthProgress: owned ? 1.0 : 0.3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tree.nameId,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                          if (!owned)
                            Text(
                              '🔒',
                              style: const TextStyle(fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.eco_outlined),
              label: Text(
                _mode == 'timer'
                    ? 'Tanam Sekarang ($_durationMinutes menit)'
                    : 'Mulai Stopwatch',
                style: const TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

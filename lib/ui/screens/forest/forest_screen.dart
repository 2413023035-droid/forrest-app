import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forest_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/utils/grid_calculator.dart';
import '../../core/utils/date_helper.dart';
import '../widgets/tree_widget.dart';

class ForestScreen extends StatefulWidget {
  const ForestScreen({super.key});

  @override
  State<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends State<ForestScreen> {
  static const double _tileW = 60.0;
  static const double _tileH = 40.0;

  @override
  Widget build(BuildContext context) {
    final forest  = context.watch<ForestProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final theme   = profile?.equippedThemeId ?? 'theme_default';
    final cs      = Theme.of(context).colorScheme;

    final bgGradient = _themeGradient(theme);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Hutan Saya 🌳',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${forest.completedSessions.length} pohon',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Hutan isometrik
              Expanded(
                child: forest.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : forest.completedSessions.isEmpty
                        ? _EmptyForest()
                        : _IsometricForest(
                            sessions: forest.completedSessions
                                .where((s) => s.gridX != null)
                                .toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _themeGradient(String themeId) {
    return switch (themeId) {
      'theme_desert'   => const [Color(0xFFFFF8E1), Color(0xFFFFCC80)],
      'theme_snow'     => const [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
      'theme_tropical' => const [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
      _                => const [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
    };
  }
}

class _IsometricForest extends StatelessWidget {
  final List sessions;

  const _IsometricForest({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 2.0,
      child: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Stack(
            alignment: Alignment.center,
            children: sessions.map((s) {
              final offset = GridCalculator.toIsometric(
                s.gridX!, s.gridY!, 60.0, 40.0,
              );
              return Positioned(
                left: 300 + offset.dx - 30,
                top: 300 + offset.dy - 60,
                child: GestureDetector(
                  onTap: () => _showTreeInfo(context, s),
                  child: TreeWidget(
                    treeTypeId: s.treeTypeId,
                    growthProgress: 1.0,
                    isDead: !s.isCompleted,
                    size: 60,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showTreeInfo(BuildContext context, dynamic s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: TreeWidget(
                treeTypeId: s.treeTypeId,
                isDead: !s.isCompleted,
                size: 80,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Tanggal', value: DateHelper.formatDate(s.startedAt)),
            _InfoRow(label: 'Durasi',  value: DateHelper.formatDuration(s.durationActualSeconds)),
            _InfoRow(label: 'Koin',    value: '${s.coinsEarned} 🪙'),
            _InfoRow(label: 'Mode',    value: s.mode == 'timer' ? 'Timer' : 'Stopwatch'),
            _InfoRow(
              label: 'Status',
              value: s.isCompleted ? '✅ Selesai' : '🥀 Layu',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyForest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Hutanmu masih kosong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Selesaikan sesi fokus untuk menanam pohon pertamamu!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

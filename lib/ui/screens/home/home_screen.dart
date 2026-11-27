import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/forest_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/coin_calculator.dart';
import '../../core/utils/date_helper.dart';
import '../widgets/tree_widget.dart';
import '../screens/forest/forest_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final _pages = const [
    _HomeTab(),
    ForestScreen(),
    StatsScreen(),
    ShopScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForestProvider>().loadForest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),  selectedIcon: Icon(Icons.home),         label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.park_outlined),  selectedIcon: Icon(Icons.park),         label: 'Hutan'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store),        label: 'Toko'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person),       label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final forest  = context.watch<ForestProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forrest 🌳'),
        actions: [
          // Koin badge di AppBar
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  CoinCalculator.format(profile?.coins ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting
            Text(
              'Hai, ${profile?.displayName ?? 'Pelajar'} 👋',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Siap fokus hari ini?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Streak & statistik hari ini
            Row(children: [
              Expanded(
                child: _StatCard(
                  icon: '🔥',
                  label: 'Streak',
                  value: '${profile?.streakDays ?? 0} hari',
                  color: cs.errorContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: '🌳',
                  label: 'Pohon',
                  value: '${forest.completedSessions.length}',
                  color: cs.primaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: '⏱️',
                  label: 'Total Fokus',
                  value: DateHelper.formatDuration(
                    profile?.totalFocusSeconds ?? 0,
                  ),
                  color: cs.secondaryContainer,
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Preview pohon terkini
            if (forest.completedSessions.isNotEmpty) ...[
              Text('Pohon Terbaru', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forest.completedSessions.take(10).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final s = forest.completedSessions[i];
                    return Column(
                      children: [
                        TreeWidget(
                          treeTypeId: s.treeTypeId,
                          growthProgress: 1.0,
                          size: 60,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateHelper.formatDate(s.startedAt),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Tombol mulai sesi
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.startSession),
              icon: const Icon(Icons.eco_outlined),
              label: const Text('Mulai Sesi Fokus', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

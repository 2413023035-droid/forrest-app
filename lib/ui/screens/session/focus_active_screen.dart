import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/tree_widget.dart';

class FocusActiveScreen extends StatefulWidget {
  const FocusActiveScreen({super.key});

  @override
  State<FocusActiveScreen> createState() => _FocusActiveScreenState();
}

class _FocusActiveScreenState extends State<FocusActiveScreen>
    with WidgetsBindingObserver {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  Future<void> _startSession() async {
    final session  = context.read<SessionProvider>();
    final profile  = context.read<ProfileProvider>();
    await session.startSession(profile.streakDays);
    setState(() => _started = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final session = context.read<SessionProvider>();
      final profile = context.read<ProfileProvider>();
      if (session.state == SessionState.running) {
        session.handleAppBackground(profile.streakDays).then((_) {
          if (mounted) _showFailedDialog();
        });
      }
    }
  }

  Future<void> _showFailedDialog() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final session = context.read<SessionProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🥀 Pohonmu Layu'),
        content: Text(
          'Kamu meninggalkan aplikasi.\nKamu mendapat ${session.lastCoinsEarned} koin.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyRewardAndGoHome();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyRewardAndGoHome() async {
    final session = context.read<SessionProvider>();
    final profile = context.read<ProfileProvider>();
    final auth = context.read<ProfileProvider>();
    if (auth.profile != null) {
      await profile.applySessionReward(
        userId: auth.profile!.id,
        coinsEarned: session.lastCoinsEarned,
        isCompleted: session.lastIsCompleted,
        actualSeconds: session.elapsedSeconds,
      );
    }
    session.reset();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  Future<void> _onStop() async {
    final session = context.read<SessionProvider>();
    if (session.mode == 'stopwatch') {
      final profile = context.read<ProfileProvider>().streakDays;
      await session.stopManually(profile);
      _showCompletedSheet();
    } else {
      // Timer mode: konfirmasi berhenti
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Berhenti?'),
          content: const Text(
            'Pohonmu akan layu dan kamu mendapat koin proporsional.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Lanjut Fokus')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Berhenti')),
          ],
        ),
      );
      if (confirm == true && mounted) {
        final profile = context.read<ProfileProvider>().streakDays;
        await session.handleAppBackground(profile);
        _applyRewardAndGoHome();
      }
    }
  }

  void _showCompletedSheet() {
    final session = context.read<SessionProvider>();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              session.lastIsCompleted ? '🎉 Pohon Tumbuh!' : '🥀 Pohon Layu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TreeWidget(
              treeTypeId: session.selectedTreeId,
              growthProgress: 1.0,
              isDead: !session.lastIsCompleted,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              '+${session.lastCoinsEarned} 🪙',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFFFC107),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _applyRewardAndGoHome,
              child: const Text('Kembali ke Beranda'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final cs = Theme.of(context).colorScheme;

    // Auto-show result sheet when timer completes
    if (session.state == SessionState.completed && _started) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showCompletedSheet());
    }

    final displaySeconds = session.mode == 'timer'
        ? session.remainingSeconds
        : session.elapsedSeconds;

    return PopScope(
      canPop: false, // Lock back button saat sesi aktif
      child: Scaffold(
        backgroundColor: cs.primaryContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.mode == 'timer' ? '⏱️ Timer' : '⏱️ Stopwatch',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      session.mode == 'timer'
                          ? 'Target: ${session.targetSeconds ~/ 60}m'
                          : 'Berjalan...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Spacer(),

                // Pohon animasi tumbuh
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: session.progress),
                  duration: const Duration(seconds: 1),
                  builder: (_, v, __) => TreeWidget(
                    treeTypeId: session.selectedTreeId,
                    growthProgress: v,
                    size: 200,
                  ),
                ),
                const SizedBox(height: 32),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: session.progress,
                    minHeight: 8,
                    backgroundColor: cs.onPrimaryContainer.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                const SizedBox(height: 24),

                // Timer display
                Text(
                  _formatTime(displaySeconds),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),

                const Spacer(),

                // Stop button
                OutlinedButton.icon(
                  onPressed: _onStop,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    session.mode == 'stopwatch' ? 'Selesai' : 'Berhenti',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(200, 52),
                    side: BorderSide(color: cs.primary),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

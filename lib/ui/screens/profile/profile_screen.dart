import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth    = context.read<AuthProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final cs      = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar & nama
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    (profile?.displayName.isNotEmpty == true
                        ? profile!.displayName[0].toUpperCase()
                        : '?'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.displayName ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${profile?.username ?? ''}',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Koin', value: '${profile?.coins ?? 0} 🪙'),
                  _StatItem(label: 'Streak', value: '${profile?.streakDays ?? 0} 🔥'),
                  _StatItem(
                    label: 'Fokus',
                    value: DateHelper.formatDuration(profile?.totalFocusSeconds ?? 0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pengaturan
          Text('Pengaturan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Bahasa'),
                  subtitle: Text(profile?.language == 'en' ? 'English' : 'Indonesia'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context),
                ),
                const Divider(height: 0, indent: 16),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifikasi Reminder'),
                  trailing: Switch(
                    value: profile?.notifyReminder ?? true,
                    onChanged: (val) {
                      final profileId = context.read<ProfileProvider>().profile?.id;
                      if (profileId != null) {
                        context.read<ProfileProvider>().updateDisplayName(
                          profileId, profile?.displayName ?? '',
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Keluar', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Indonesia 🇮🇩'),
            onTap: () {
              final id = context.read<ProfileProvider>().profile?.id;
              if (id != null) context.read<ProfileProvider>().setLanguage(id, 'id');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('English 🇬🇧'),
            onTap: () {
              final id = context.read<ProfileProvider>().profile?.id;
              if (id != null) context.read<ProfileProvider>().setLanguage(id, 'en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<ProfileProvider>().clear();
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (_) => false);
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/forest_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../core/utils/date_helper.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forest = context.watch<ForestProvider>();
    final shop   = context.watch<ShopProvider>();
    final cs     = Theme.of(context).colorScheme;

    final dailyData = forest.dailyFocusLast7Days;
    final tagData   = forest.secondsPerTag;

    final maxY = dailyData.isEmpty
        ? 60.0
        : dailyData.map((e) => e.value / 60).reduce((a, b) => a > b ? a : b).toDouble() + 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Fokus 📊')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7 Hari Terakhir (menit)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            // Bar chart 7 hari
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: dailyData.asMap().entries.map((entry) {
                    final minutes = entry.value.value / 60;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: minutes,
                          color: cs.primary,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) =>
                            Text('${v.toInt()}m', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          if (v.toInt() >= dailyData.length) return const Text('');
                          final d = dailyData[v.toInt()].key;
                          return Text('${d.day}/${d.month}',
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Fokus per Kategori',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            if (tagData.isEmpty)
              Text(
                'Belum ada data. Mulai sesi fokus!',
                style: TextStyle(color: cs.onSurfaceVariant),
              )
            else
              ...tagData.entries.map((entry) {
                final matchingTags = shop.tags.where((t) => t.id == entry.key);
                final tag = matchingTags.isEmpty ? null : matchingTags.first;
                final totalSeconds = tagData.values.fold(0, (a, b) => a + b);
                final ratio = totalSeconds == 0 ? 0.0 : entry.value / totalSeconds;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(tag?.icon ?? '🏷️', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(tag?.nameId ?? entry.key),
                                Text(DateHelper.formatDuration(entry.value)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Ringkasan total
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    _SummaryRow(
                      label: 'Total sesi',
                      value: '${forest.completedSessions.length}',
                    ),
                    _SummaryRow(
                      label: 'Total fokus',
                      value: DateHelper.formatDuration(
                        forest.completedSessions.fold(
                          0, (s, e) => s + e.durationActualSeconds,
                        ),
                      ),
                    ),
                    _SummaryRow(
                      label: 'Pohon berhasil',
                      value: '${forest.completedSessions.length} 🌳',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

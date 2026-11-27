class CoinCalculator {
  CoinCalculator._();

  /// Hitung koin dari satu sesi
  /// Streak bonus: +10% per hari berturut-turut, max +50%
  static int calculate({
    required String mode,
    required int actualSeconds,
    required int targetSeconds,
    required bool isCompleted,
    required int streakDays,
  }) {
    if (actualSeconds < 60) return 0; // minimal 1 menit untuk dapat koin

    final actualMinutes = actualSeconds ~/ 60;
    int baseCoins;

    if (mode == 'stopwatch') {
      baseCoins = actualMinutes;
    } else if (isCompleted) {
      baseCoins = actualMinutes;
    } else {
      // Timer gagal: proporsional
      if (targetSeconds == 0) return 0;
      final ratio = actualSeconds / targetSeconds;
      baseCoins = (ratio * (targetSeconds ~/ 60)).round();
    }

    // Streak bonus (cap 50%)
    final streakBonus = (streakDays * 0.1).clamp(0.0, 0.5);
    return (baseCoins * (1 + streakBonus)).floor();
  }

  /// Format tampilan koin: 1500 → "1.5K"
  static String format(int coins) {
    if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}

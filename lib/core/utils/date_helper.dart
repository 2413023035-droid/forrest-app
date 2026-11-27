import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  static String formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy', 'id').format(dt);

  static String formatTime(DateTime dt) =>
      DateFormat('HH:mm', 'id').format(dt);

  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}j ${m}m';
    if (m > 0) return '${m}m ${s}d';
    return '${s}d';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Hitung streak: apakah last_focus_date adalah kemarin?
  static bool isConsecutiveDay(DateTime? lastDate) {
    if (lastDate == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(lastDate, yesterday);
  }
}

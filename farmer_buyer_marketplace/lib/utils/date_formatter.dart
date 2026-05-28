import 'package:intl/intl.dart'; // Add intl: ^0.18.0 to pubspec.yaml

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 7) return format(date);
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    return 'Just now';
  }
}
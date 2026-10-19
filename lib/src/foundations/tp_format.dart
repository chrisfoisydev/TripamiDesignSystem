/// How Tripami writes times, durations, days and groups of people.
///
/// Times are 12-hour, lowercase, with minutes only when they aren't zero
/// ("3pm", "9:30am"). Durations use "h" and "min" with a space
/// ("1 h 50 min", "45 min"). Days are short on chips ("Wed 18") and long in
/// titles ("Wednesday, November 18"); dates elsewhere read "Wed, Nov 18". Names join with commas and "and".
abstract final class TPFormat {
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// "9:30am", "3pm", "12pm" (noon), "12am" (midnight).
  static String time(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final suffix = t.hour < 12 ? 'am' : 'pm';
    return t.minute == 0 ? '$hour$suffix' : '$hour:${_two(t.minute)}$suffix';
  }

  /// "1 h 50 min", "2 h", "45 min", "1 min". Rounds up to the next whole
  /// minute, so a countdown never shows "0 min" while time is left.
  static String duration(Duration d) {
    final total = (d.inSeconds / 60).ceil().clamp(0, 1 << 31);
    final h = total ~/ 60, m = total % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  /// "Wed 18": day chips and compact labels.
  static String dayShort(DateTime d) => '${_days[d.weekday - 1].substring(0, 3)} ${d.day}';

  /// "Wednesday, November 18": titles.
  static String dayLong(DateTime d) => '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

  /// "Sandra", "Sandra and LeAnn", "Shannon, Christy and Sarah",
  /// and past [max] names, "Shannon, Christy and 3 others".
  static String names(List<String> names, {int max = 3}) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length <= max) {
      return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
    }
    final shown = names.take(max - 1).join(', ');
    final rest = names.length - (max - 1);
    return '$shown and $rest others';
  }

  /// First names only, as travelers refer to each other: "Sarah Johnson" → "Sarah".
  static String firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

  static String _two(int n) => n.toString().padLeft(2, '0');
}

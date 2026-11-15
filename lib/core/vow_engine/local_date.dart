/// A calendar date with no time and no time zone.
///
/// Journeys are counted in the devotee's own calendar days, so day numbers
/// must not shift when the phone changes time zone or daylight saving.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `YYYY-MM-DD`.
  factory LocalDate.parse(String iso) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (match == null) {
      throw FormatException('Expected YYYY-MM-DD', iso);
    }
    final date = LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    if (date.toIso() != iso) {
      throw FormatException('Not a real calendar date', iso);
    }
    return date;
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  LocalDate addDays(int days) {
    final shifted = DateTime.utc(year, month, day + days);
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }

  /// Whole days from [other] to this date. Negative if this date is earlier.
  int daysSince(LocalDate other) => _utc.difference(other._utc).inDays;

  /// Midnight at the start of this date in the phone's local time zone.
  DateTime toLocalDateTime() => DateTime(year, month, day);

  String toIso() {
    // Normalised through DateTime so that LocalDate(2027, 2, 30) is caught
    // by parse().
    final d = _utc;
    String pad(int value, int width) => value.toString().padLeft(width, '0');
    return '${pad(d.year, 4)}-${pad(d.month, 2)}-${pad(d.day, 2)}';
  }

  @override
  int compareTo(LocalDate other) => _utc.compareTo(other._utc);

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

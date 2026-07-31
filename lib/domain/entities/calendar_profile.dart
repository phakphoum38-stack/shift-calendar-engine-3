/// Calendar integration settings assigned to an employee.
class CalendarProfile {
  const CalendarProfile({
    this.googleCalendarId = '',
    this.colorId = '',
    this.syncEnabled = false,
  });

  final String googleCalendarId;
  final String colorId;
  final bool syncEnabled;

  bool get isConfigured => googleCalendarId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarProfile &&
          googleCalendarId == other.googleCalendarId &&
          colorId == other.colorId &&
          syncEnabled == other.syncEnabled;

  @override
  int get hashCode => Object.hash(googleCalendarId, colorId, syncEnabled);
}

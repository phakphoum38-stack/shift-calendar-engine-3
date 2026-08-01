import 'package:intl/intl.dart';

/// Formats a date with Buddhist Era years for Thai display only.
///
/// Date calculations and persisted values remain Gregorian. Replacing the
/// rendered year avoids constructing a different [DateTime], which would also
/// change the weekday.
String formatLocalizedDate(
  DateFormat formatter,
  DateTime value, {
  required String locale,
}) {
  final formatted = formatter.format(value);
  if (!locale.toLowerCase().startsWith('th')) return formatted;
  return formatted.replaceAll(
    value.year.toString(),
    (value.year + 543).toString(),
  );
}

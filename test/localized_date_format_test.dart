import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shift_calendar_engine/l10n/localized_date_format.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  test('uses Buddhist Era year for Thai display', () {
    final value = DateTime(2026, 7, 28, 14, 30);

    final formatted = formatLocalizedDate(
      DateFormat.yMMMM('th'),
      value,
      locale: 'th',
    );

    expect(formatted, contains('2569'));
    expect(formatted, isNot(contains('2026')));
  });

  test('keeps Gregorian year for English display', () {
    final value = DateTime(2026, 7, 28);

    final formatted = formatLocalizedDate(
      DateFormat.yMMMM('en'),
      value,
      locale: 'en',
    );

    expect(formatted, contains('2026'));
  });
}

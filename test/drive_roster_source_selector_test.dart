import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/roster/domain/drive_roster_source.dart';

void main() {
  const selector = DriveRosterSourceSelector();

  test('keeps the oldest modified file when a month has several files', () {
    final selected = selector.selectMonthlySources([
      _source('newer', 'Roster July copy', DateTime(2026, 7, 20), 7),
      _source('oldest', 'Roster July', DateTime(2026, 7, 3), 7),
      _source('middle', 'Roster July revised', DateTime(2026, 7, 10), 7),
    ]);

    expect(selected, hasLength(1));
    expect(selected.single.id, 'oldest');
  });

  test('orders monthly sources by recently modified', () {
    final selected = selector.selectMonthlySources([
      _source('june', 'Roster June', DateTime(2026, 6, 1), 6),
      _source('july', 'Roster July', DateTime(2026, 7, 1), 7),
    ]);

    expect(selected.map((source) => source.id), ['july', 'june']);
  });
}

DriveRosterSource _source(
  String id,
  String name,
  DateTime modifiedTime,
  int month,
) => DriveRosterSource(
  id: id,
  name: name,
  modifiedTime: modifiedTime,
  rosterMonth: DateTime(2026, month),
);

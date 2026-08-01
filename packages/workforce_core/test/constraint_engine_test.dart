import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  ShiftAssignment assignment({
    required String id,
    required String employeeId,
    required DateTime startsAt,
    required DateTime endsAt,
    String shiftCode = 'M',
  }) {
    return ShiftAssignment(
      id: id,
      employeeId: employeeId,
      shiftCode: shiftCode,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  test('shift assignment normalizes times to UTC and reports duration', () {
    final value = assignment(
      id: 'a1',
      employeeId: 'e1',
      startsAt: DateTime.parse('2026-08-01T08:00:00+07:00'),
      endsAt: DateTime.parse('2026-08-01T16:00:00+07:00'),
    );

    expect(value.startsAt.isUtc, isTrue);
    expect(value.endsAt.isUtc, isTrue);
    expect(value.duration, const Duration(hours: 8));
  });

  test('detects overlapping assignments for the same employee', () {
    final result = const RosterConstraintEngine().validate([
      assignment(
        id: 'a1',
        employeeId: 'e1',
        startsAt: DateTime.utc(2026, 8, 1, 8),
        endsAt: DateTime.utc(2026, 8, 1, 16),
      ),
      assignment(
        id: 'a2',
        employeeId: 'e1',
        startsAt: DateTime.utc(2026, 8, 1, 15),
        endsAt: DateTime.utc(2026, 8, 1, 23),
      ),
    ]);

    expect(result.isValid, isFalse);
    expect(
      result.errors.any(
        (violation) =>
            violation.code == RosterViolationCode.overlappingAssignment,
      ),
      isTrue,
    );
  });

  test('detects insufficient rest between assignments', () {
    final result =
        const RosterConstraintEngine(
          policy: RosterConstraintPolicy(minimumRest: Duration(hours: 10)),
        ).validate([
          assignment(
            id: 'a1',
            employeeId: 'e1',
            startsAt: DateTime.utc(2026, 8, 1, 8),
            endsAt: DateTime.utc(2026, 8, 1, 16),
          ),
          assignment(
            id: 'a2',
            employeeId: 'e1',
            startsAt: DateTime.utc(2026, 8, 2, 0),
            endsAt: DateTime.utc(2026, 8, 2, 8),
          ),
        ]);

    expect(result.errors.single.code, RosterViolationCode.insufficientRest);
  });

  test('warns when maximum consecutive days is exceeded', () {
    final values = <ShiftAssignment>[
      for (var day = 1; day <= 4; day++)
        assignment(
          id: 'a$day',
          employeeId: 'e1',
          startsAt: DateTime.utc(2026, 8, day, 8),
          endsAt: DateTime.utc(2026, 8, day, 16),
        ),
    ];

    final result = const RosterConstraintEngine(
      policy: RosterConstraintPolicy(maximumConsecutiveDays: 3),
    ).validate(values);

    expect(result.isValid, isTrue);
    expect(
      result.warnings.single.code,
      RosterViolationCode.maximumConsecutiveDays,
    );
  });

  test('does not compare assignments across different employees', () {
    final result = const RosterConstraintEngine().validate([
      assignment(
        id: 'a1',
        employeeId: 'e1',
        startsAt: DateTime.utc(2026, 8, 1, 8),
        endsAt: DateTime.utc(2026, 8, 1, 16),
      ),
      assignment(
        id: 'a2',
        employeeId: 'e2',
        startsAt: DateTime.utc(2026, 8, 1, 8),
        endsAt: DateTime.utc(2026, 8, 1, 16),
      ),
    ]);

    expect(result.isValid, isTrue);
    expect(result.violations, isEmpty);
  });
}

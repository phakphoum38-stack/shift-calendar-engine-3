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

  test('returns a perfect score for a valid balanced roster', () {
    final report = const RosterEvaluationEngine().evaluate(
      [
        assignment(
          id: 'a1',
          employeeId: 'e1',
          startsAt: DateTime.utc(2026, 8, 1, 8),
          endsAt: DateTime.utc(2026, 8, 1, 16),
        ),
        assignment(
          id: 'a2',
          employeeId: 'e2',
          startsAt: DateTime.utc(2026, 8, 2, 8),
          endsAt: DateTime.utc(2026, 8, 2, 16),
        ),
      ],
      employeeIds: const ['e1', 'e2'],
    );

    expect(report.isValid, isTrue);
    expect(report.overallScore, 100);
    expect(report.recommendations, isEmpty);
    expect(report.isExcellent, isTrue);
  });

  test('hard violations reduce score and add a publication recommendation', () {
    final report = const RosterEvaluationEngine().evaluate([
      assignment(
        id: 'a1',
        employeeId: 'e1',
        startsAt: DateTime.utc(2026, 8, 1, 8),
        endsAt: DateTime.utc(2026, 8, 1, 16),
      ),
      assignment(
        id: 'a2',
        employeeId: 'e1',
        startsAt: DateTime.utc(2026, 8, 1, 12),
        endsAt: DateTime.utc(2026, 8, 1, 20),
      ),
    ]);

    expect(report.isValid, isFalse);
    expect(report.overallScore, lessThan(100));
    expect(
      report.recommendations,
      contains('Resolve hard constraint violations before publishing.'),
    );
  });

  test('unbalanced assignments add a workload recommendation', () {
    final report = const RosterEvaluationEngine().evaluate(
      [
        for (var day = 1; day <= 3; day++)
          assignment(
            id: 'a$day',
            employeeId: 'e1',
            startsAt: DateTime.utc(2026, 8, day, 8),
            endsAt: DateTime.utc(2026, 8, day, 16),
          ),
      ],
      employeeIds: const ['e1', 'e2'],
    );

    expect(report.fairness.assignmentSpread, 3);
    expect(
      report.recommendations,
      contains('Redistribute assignments to improve total workload balance.'),
    );
  });
}

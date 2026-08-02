import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  ShiftAssignment assignment({
    required String id,
    required String employeeId,
    required String shiftCode,
    required DateTime startsAt,
  }) {
    return ShiftAssignment(
      id: id,
      employeeId: employeeId,
      shiftCode: shiftCode,
      startsAt: startsAt,
      endsAt: startsAt.add(const Duration(hours: 8)),
    );
  }

  test('returns a perfect score for an even assignment distribution', () {
    final report = const RosterFairnessEngine().evaluate([
      assignment(
        id: 'a1',
        employeeId: 'e1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 3, 8),
      ),
      assignment(
        id: 'a2',
        employeeId: 'e2',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 4, 8),
      ),
    ]);

    expect(report.score, 100);
    expect(report.assignmentSpread, 0);
    expect(report.isPerfectlyBalanced, isTrue);
  });

  test('includes employees with no assignments when ids are supplied', () {
    final report = const RosterFairnessEngine().evaluate(
      [
        assignment(
          id: 'a1',
          employeeId: 'e1',
          shiftCode: 'N',
          startsAt: DateTime.utc(2026, 8, 3, 20),
        ),
      ],
      employeeIds: const ['e1', 'e2'],
    );

    expect(report.employeeSummaries, hasLength(2));
    expect(report.assignmentSpread, 1);
    expect(
      report.employeeSummaries
          .singleWhere((value) => value.employeeId == 'e2')
          .totalAssignments,
      0,
    );
  });

  test('classifies morning afternoon night and other shift codes', () {
    final report = const RosterFairnessEngine().evaluate([
      assignment(
        id: 'a1',
        employeeId: 'e1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 3, 8),
      ),
      assignment(
        id: 'a2',
        employeeId: 'e1',
        shiftCode: 'A',
        startsAt: DateTime.utc(2026, 8, 4, 16),
      ),
      assignment(
        id: 'a3',
        employeeId: 'e1',
        shiftCode: 'N',
        startsAt: DateTime.utc(2026, 8, 5, 20),
      ),
      assignment(
        id: 'a4',
        employeeId: 'e1',
        shiftCode: 'CT',
        startsAt: DateTime.utc(2026, 8, 6, 8),
      ),
    ]);

    final summary = report.employeeSummaries.single;
    expect(summary.morningAssignments, 1);
    expect(summary.afternoonAssignments, 1);
    expect(summary.nightAssignments, 1);
    expect(summary.otherAssignments, 1);
  });

  test('counts weekend assignments from assignment start dates', () {
    final report = const RosterFairnessEngine().evaluate([
      assignment(
        id: 'a1',
        employeeId: 'e1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 1, 8),
      ),
      assignment(
        id: 'a2',
        employeeId: 'e1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 3, 8),
      ),
    ]);

    expect(report.employeeSummaries.single.weekendAssignments, 1);
  });

  test('reduces score when total night and weekend spreads increase', () {
    final report = const RosterFairnessEngine().evaluate(
      [
        assignment(
          id: 'a1',
          employeeId: 'e1',
          shiftCode: 'N',
          startsAt: DateTime.utc(2026, 8, 1, 20),
        ),
        assignment(
          id: 'a2',
          employeeId: 'e1',
          shiftCode: 'N',
          startsAt: DateTime.utc(2026, 8, 2, 20),
        ),
      ],
      employeeIds: const ['e1', 'e2'],
    );

    expect(report.assignmentSpread, 2);
    expect(report.nightSpread, 2);
    expect(report.weekendSpread, 2);
    expect(report.score, lessThan(100));
  });
}

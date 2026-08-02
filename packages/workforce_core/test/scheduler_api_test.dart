import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

final class _WarningRule implements RosterConstraintRule {
  const _WarningRule(this.id);

  @override
  final String id;

  @override
  Iterable<RosterViolation> evaluate(RosterConstraintContext context) {
    return const [
      RosterViolation(
        code: RosterViolationCode.maximumConsecutiveDays,
        severity: RosterViolationSeverity.warning,
        message: 'Custom policy warning.',
      ),
    ];
  }
}

void main() {
  ShiftAssignment assignment(String id, String employeeId, int startHour) {
    return ShiftAssignment(
      id: id,
      employeeId: employeeId,
      shiftCode: 'M',
      startsAt: DateTime.utc(2026, 8, 1, startHour),
      endsAt: DateTime.utc(2026, 8, 1, startHour + 8),
    );
  }

  test('constraint pipeline aggregates canonical and extension rules', () {
    const pipeline = RosterConstraintPipeline(
      rules: [_WarningRule('custom-warning')],
    );
    const context = RosterConstraintContext(assignments: []);

    final validation = pipeline.validate(context);

    expect(validation.isValid, isTrue);
    expect(validation.warnings, hasLength(1));
  });

  test('constraint pipeline rejects duplicate rule ids', () {
    const pipeline = RosterConstraintPipeline(
      rules: [_WarningRule('duplicate'), _WarningRule('duplicate')],
    );
    const context = RosterConstraintContext(assignments: []);

    expect(() => pipeline.validate(context), throwsStateError);
  });

  test('scheduler API rejects invalid existing assignments', () {
    final request = SchedulerRequest(
      employeeIds: const ['e1'],
      slots: const [],
      existingAssignments: [
        assignment('a1', 'e1', 8),
        assignment('a2', 'e1', 12),
      ],
    );
    final generate = () => const SchedulerApi().generate(request);

    expect(generate, throwsA(isA<SchedulerInputException>()));
  });

  test('scheduler API returns publishable deterministic execution', () {
    final execution = const SchedulerApi().generate(
      SchedulerRequest(
        employeeIds: const ['e1', 'e2'],
        slots: [
          SchedulerShiftSlot(
            id: 'slot-1',
            shiftCode: 'M',
            startsAt: DateTime.utc(2026, 8, 1, 8),
            endsAt: DateTime.utc(2026, 8, 1, 16),
          ),
        ],
      ),
    );

    expect(execution.result.assignments, hasLength(1));
    expect(execution.validation.isValid, isTrue);
    expect(execution.canPublish, isTrue);
  });
}

import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  test('canonical plugin reuses roster constraint validation', () {
    final assignment = ShiftAssignment(
      id: 'a1',
      employeeId: 'e1',
      shiftCode: 'M',
      startsAt: DateTime.utc(2026, 8, 5, 8),
      endsAt: DateTime.utc(2026, 8, 5, 16),
    );
    final engine = AiConstraintPluginEngine(
      plugins: const [CanonicalConstraintPlugin()],
    );

    final result = engine.evaluate(
      AiConstraintContext(assignments: [assignment, assignment]),
    );

    expect(result.isValid, isFalse);
    expect(
      result.violations.any(
        (violation) =>
            violation.code == RosterViolationCode.duplicateAssignment,
      ),
      isTrue,
    );
  });

  test('plugin ids must be unique', () {
    expect(
      () => AiConstraintPluginEngine(
        plugins: const [
          CanonicalConstraintPlugin(),
          CanonicalConstraintPlugin(),
        ],
      ),
      throwsArgumentError,
    );
  });
}

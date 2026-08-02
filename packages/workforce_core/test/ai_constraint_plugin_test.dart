import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  test('plugin engine aggregates extension violations', () {
    final engine = AiConstraintPluginEngine(
      plugins: const [_TestPlugin(id: 'hospital.skill')],
    );

    final result = engine.evaluate(
      AiConstraintContext(assignments: const []),
    );

    expect(result.isValid, isFalse);
    expect(result.violations, hasLength(1));
    expect(
      result.violations.single.code,
      RosterViolationCode.outsideAvailability,
    );
  });

  test('plugin ids must be unique', () {
    expect(
      () => AiConstraintPluginEngine(
        plugins: const [
          _TestPlugin(id: 'hospital.skill'),
          _TestPlugin(id: 'hospital.skill'),
        ],
      ),
      throwsArgumentError,
    );
  });
}

final class _TestPlugin implements AiConstraintPlugin {
  const _TestPlugin({required this.id});

  @override
  final String id;

  @override
  Iterable<RosterViolation> evaluate(AiConstraintContext context) {
    return const [
      RosterViolation(
        code: RosterViolationCode.outsideAvailability,
        severity: RosterViolationSeverity.error,
        message: 'Extension rule rejected the proposal.',
      ),
    ];
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_shift_template_catalog.dart';

void main() {
  test('returns only active templates in deterministic order', () {
    const evening = ShiftTemplate(
      id: 'evening',
      code: 'E',
      name: 'Evening',
      startTime: Duration(hours: 16),
      endTime: Duration.zero,
      colorValue: 0,
      workingHours: 8,
    );
    const morningB = ShiftTemplate(
      id: 'morning-b',
      code: 'M',
      name: 'Morning B',
      startTime: Duration(hours: 8),
      endTime: Duration(hours: 16),
      colorValue: 0,
      workingHours: 8,
    );
    const morningA = ShiftTemplate(
      id: 'morning-a',
      code: 'M',
      name: 'Morning A',
      startTime: Duration(hours: 8),
      endTime: Duration(hours: 16),
      colorValue: 0,
      workingHours: 8,
    );
    const inactiveNight = ShiftTemplate(
      id: 'night',
      code: 'N',
      name: 'Night',
      startTime: Duration.zero,
      endTime: Duration(hours: 8),
      colorValue: 0,
      workingHours: 8,
      active: false,
    );

    final result = AiSchedulerShiftTemplateCatalog.active(const [
      evening,
      morningB,
      inactiveNight,
      morningA,
    ]);

    expect(
      result.map((template) => template.id),
      orderedEquals(const ['morning-a', 'morning-b', 'evening']),
    );
    expect(result, isA<List<ShiftTemplate>>());
    expect(() => result.add(inactiveNight), throwsUnsupportedError);
  });

  test('returns an empty immutable list when no template is active', () {
    const inactive = ShiftTemplate(
      id: 'inactive',
      code: 'X',
      name: 'Inactive',
      startTime: Duration.zero,
      endTime: Duration.zero,
      colorValue: 0,
      workingHours: 0,
      active: false,
    );

    final result = AiSchedulerShiftTemplateCatalog.active(const [inactive]);

    expect(result, isEmpty);
    expect(() => result.add(inactive), throwsUnsupportedError);
  });
}

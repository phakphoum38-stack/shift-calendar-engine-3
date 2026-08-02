import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_shift_input_controller.dart';

void main() {
  const morning = ShiftTemplate(
    id: 'morning',
    code: 'M',
    name: 'Morning',
    startTime: Duration(hours: 8),
    endTime: Duration(hours: 16),
    colorValue: 0,
    workingHours: 8,
  );
  const night = ShiftTemplate(
    id: 'night',
    code: 'N',
    name: 'Night',
    startTime: Duration(hours: 20),
    endTime: Duration(hours: 8),
    colorValue: 0,
    workingHours: 12,
  );

  test('adds explicit inputs with stable deterministic identifiers', () {
    final controller = AiSchedulerShiftInputController();

    final first = controller.add(date: DateTime(2026, 8, 4, 12), shift: morning);
    final second = controller.add(date: DateTime(2026, 8, 4), shift: morning);

    expect(first.id, '20260804-morning');
    expect(second.id, '20260804-morning-2');
    expect(first.date, DateTime(2026, 8, 4));
    expect(controller.inputs, [first, second]);
  });

  test('sorts requested slots by date, start time, then identifier', () {
    final controller = AiSchedulerShiftInputController();

    final late = controller.add(date: DateTime(2026, 8, 5), shift: night);
    final nextDay = controller.add(date: DateTime(2026, 8, 6), shift: morning);
    final early = controller.add(date: DateTime(2026, 8, 5), shift: morning);

    expect(controller.inputs, [early, late, nextDay]);
  });

  test('trims boundary metadata and supports remove and clear', () {
    final controller = AiSchedulerShiftInputController();
    var notifications = 0;
    controller.addListener(() => notifications += 1);

    final input = controller.add(
      date: DateTime(2026, 8, 4),
      shift: morning,
      departmentId: ' RAD ',
      location: ' Room 1 ',
    );

    expect(input.departmentId, 'RAD');
    expect(input.location, 'Room 1');
    expect(controller.remove('missing'), isFalse);
    expect(controller.remove(input.id), isTrue);
    expect(controller.isEmpty, isTrue);

    controller.add(date: DateTime(2026, 8, 4), shift: morning);
    controller.clear();

    expect(controller.inputs, isEmpty);
    expect(notifications, 4);
  });
}

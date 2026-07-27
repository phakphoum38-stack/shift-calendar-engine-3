import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/core/result/result.dart';
import 'package:shift_calendar_engine/core/storage/atomic_string_store.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/features/employees/infrastructure/shared_preferences_employee_repository.dart';
import 'package:shift_calendar_engine/features/foundation/infrastructure/canonical_json_codec.dart';
import 'package:shift_calendar_engine/features/foundation/infrastructure/shared_preferences_schedule_repository.dart';
import 'package:shift_calendar_engine/features/shift_templates/infrastructure/shared_preferences_shift_template_repository.dart';

import 'support/fixtures.dart';

void main() {
  test('canonical schedule survives versioned round-trip', () {
    const codec = CanonicalJsonCodec();
    final schedule = canonicalScheduleFixture();

    final decoded = codec.decodeSchedule(codec.encodeSchedule(schedule));

    expect(scheduleValues(decoded), scheduleValues(schedule));
  });

  test('unsupported and malformed canonical data fail explicitly', () {
    const codec = CanonicalJsonCodec();

    expect(
      () => codec.decodeSchedule('{"formatVersion":2,"schedule":{}}'),
      throwsA(isA<CanonicalCodecException>()),
    );
    expect(
      () => codec.decodeSchedule('{broken'),
      throwsA(isA<CanonicalCodecException>()),
    );
  });

  test('atomic repository saves and restores canonical schedule', () async {
    final memory = _MemoryStringStore();
    final repository = SharedPreferencesScheduleRepository(
      store: AtomicStringStore(keyPrefix: 'test.schedule', store: memory),
    );
    final schedule = canonicalScheduleFixture();

    expect(await repository.save(schedule), isA<Success>());
    final loaded = await repository.loadActive();

    expect(loaded, isA<Success<Schedule?>>());
    final restored = (loaded as Success<Schedule?>).value;
    expect(restored, isNotNull);
    expect(scheduleValues(restored!), scheduleValues(schedule));
  });

  test('failed staged write preserves the last valid schedule', () async {
    final memory = _FailingStringStore();
    final repository = SharedPreferencesScheduleRepository(
      store: AtomicStringStore(keyPrefix: 'test.schedule', store: memory),
    );
    final original = canonicalScheduleFixture();

    expect(await repository.save(original), isA<Success>());
    memory.failNextSlotWrite = true;
    final replacement = Schedule(
      id: original.id,
      name: 'Replacement',
      months: original.months,
    );

    expect(await repository.save(replacement), isA<Failure>());
    final loaded = await repository.loadActive();
    final restored = (loaded as Success<Schedule?>).value;
    expect(restored, isNotNull);
    expect(restored!.name, original.name);
    expect(scheduleValues(restored), scheduleValues(original));
  });

  test('employee and shift repositories enforce unique codes', () async {
    final employeeRepository = SharedPreferencesEmployeeRepository(
      store: AtomicStringStore(
        keyPrefix: 'test.employees',
        store: _MemoryStringStore(),
      ),
    );
    final shiftRepository = SharedPreferencesShiftTemplateRepository(
      store: AtomicStringStore(
        keyPrefix: 'test.shifts',
        store: _MemoryStringStore(),
      ),
    );
    final fixture = canonicalScheduleFixture();
    final assignment = fixture.assignments.first;

    expect(await employeeRepository.save(assignment.employee), isA<Success>());
    expect(
      await employeeRepository.save(assignment.employee.copyWith(id: 'other')),
      isA<ValidationFailure>(),
    );
    expect(await shiftRepository.save(assignment.shift), isA<Success>());
    expect(
      await shiftRepository.save(assignment.shift.copyWith(id: 'other')),
      isA<ValidationFailure>(),
    );
  });
}

class _MemoryStringStore implements StringStore {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

class _FailingStringStore extends _MemoryStringStore {
  bool failNextSlotWrite = false;

  @override
  Future<void> setString(String key, String value) async {
    if (failNextSlotWrite && key.contains('.slot.')) {
      failNextSlotWrite = false;
      throw StateError('Simulated storage failure');
    }
    await super.setString(key, value);
  }
}

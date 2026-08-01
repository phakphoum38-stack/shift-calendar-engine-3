import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/core/result/result.dart';
import 'package:shift_calendar_engine/core/storage/atomic_string_store.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/repositories/employee_repository.dart';
import 'package:shift_calendar_engine/features/employees/infrastructure/shared_preferences_employee_repository.dart';

import 'support/fixtures.dart';

void main() {
  late SharedPreferencesEmployeeRepository repository;
  late Employee employee;

  setUp(() {
    repository = SharedPreferencesEmployeeRepository(
      store: AtomicStringStore(
        namespace: 'test.employee.directory',
        store: _MemoryStringStore(),
      ),
    );
    employee = canonicalScheduleFixture().assignments.first.employee;
  });

  test('findById returns the canonical employee or null', () async {
    expect(await repository.save(employee), isA<Success<Employee>>());

    final found = await repository.findById(employee.id);
    final missing = await repository.findById('missing');

    expect((found as Success<Employee?>).value, employee);
    expect((missing as Success<Employee?>).value, isNull);
  });

  test('search matches identity and organizational fields', () async {
    final second = employee.copyWith(
      id: 'employee-2',
      employeeCode: 'RAD-002',
      firstName: 'Somchai',
      lastName: 'Worker',
      nickname: 'Chai',
      position: 'Radiologic technologist',
    );
    expect(await repository.save(employee), isA<Success<Employee>>());
    expect(await repository.save(second), isA<Success<Employee>>());

    final byCode = await repository.search(
      const EmployeeQuery(text: 'rad-002'),
    );
    final byNickname = await repository.search(
      const EmployeeQuery(text: 'chai'),
    );
    final byDepartment = await repository.search(
      EmployeeQuery(departmentId: employee.department.id),
    );

    expect((byCode as Success<List<Employee>>).value, [second]);
    expect((byNickname as Success<List<Employee>>).value, [second]);
    expect(
      (byDepartment as Success<List<Employee>>).value,
      containsAll([employee, second]),
    );
  });

  test('activeOnly hides inactive employees by default', () async {
    final inactive = employee.copyWith(
      id: 'inactive',
      employeeCode: 'INACTIVE-001',
      active: false,
    );
    expect(await repository.save(inactive), isA<Success<Employee>>());

    final activeOnly = await repository.findAll();
    final all = await repository.findAll(activeOnly: false);

    expect((activeOnly as Success<List<Employee>>).value, isEmpty);
    expect((all as Success<List<Employee>>).value, [inactive]);
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

import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  final createdAt = DateTime.utc(2026, 7, 31);

  test('normalizes required employee text', () {
    final employee = Employee(
      id: 'employee-1',
      organizationId: 'organization-1',
      employeeCode: '  XR-001  ',
      displayName: '  Somchai  ',
      status: EmployeeStatus.active,
      version: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    expect(employee.employeeCode, 'XR-001');
    expect(employee.displayName, 'Somchai');
    expect(employee.isActive, isTrue);
  });

  test('rejects an empty employee code', () {
    expect(
      () => Employee(
        id: 'employee-1',
        organizationId: 'organization-1',
        employeeCode: '   ',
        displayName: 'Somchai',
        status: EmployeeStatus.active,
        version: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      throwsArgumentError,
    );
  });

  test('requires deletedAt for archived employees', () {
    expect(
      () => Employee(
        id: 'employee-1',
        organizationId: 'organization-1',
        employeeCode: 'XR-001',
        displayName: 'Somchai',
        status: EmployeeStatus.archived,
        version: 2,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      throwsArgumentError,
    );
  });

  test('identity equality uses the employee id', () {
    final first = Employee(
      id: 'employee-1',
      organizationId: 'organization-1',
      employeeCode: 'XR-001',
      displayName: 'Somchai',
      status: EmployeeStatus.active,
      version: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final second = first.copyWith(displayName: 'สมชาย');

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });
}

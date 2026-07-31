import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine_3/core/result/result.dart';
import 'package:shift_calendar_engine_3/domain/entities/branch.dart';
import 'package:shift_calendar_engine_3/domain/entities/department.dart';
import 'package:shift_calendar_engine_3/domain/entities/employee.dart';
import 'package:shift_calendar_engine_3/domain/entities/organization.dart';
import 'package:shift_calendar_engine_3/domain/entities/team.dart';
import 'package:shift_calendar_engine_3/features/organization/application/organization_hierarchy_service.dart';

void main() {
  const service = OrganizationHierarchyService();
  const organization = Organization(id: 'org-1', code: 'ORG', name: 'Hospital');
  const branch = Branch(
    id: 'branch-1',
    organizationId: 'org-1',
    code: 'MAIN',
    name: 'Main',
  );
  const department = Department(
    id: 'department-1',
    code: 'RAD',
    name: 'Radiology',
    organizationId: 'org-1',
    branchId: 'branch-1',
  );
  const team = Team(
    id: 'team-1',
    departmentId: 'department-1',
    code: 'CT',
    name: 'CT',
  );

  test('accepts a consistent organization hierarchy', () {
    const employee = Employee(
      id: 'employee-1',
      employeeCode: 'E001',
      firstName: 'Test',
      lastName: 'User',
      organizationId: 'org-1',
      branchId: 'branch-1',
      department: department,
      teamId: 'team-1',
      position: 'Technologist',
    );

    final result = service.validate(
      organizations: const [organization],
      branches: const [branch],
      departments: const [department],
      teams: const [team],
      employees: const [employee],
    );

    expect(result, isA<Success<void>>());
  });

  test('rejects an employee team from another department', () {
    const otherDepartment = Department(
      id: 'department-2',
      code: 'ER',
      name: 'Emergency',
      organizationId: 'org-1',
      branchId: 'branch-1',
    );
    const employee = Employee(
      id: 'employee-1',
      employeeCode: 'E001',
      firstName: 'Test',
      lastName: 'User',
      organizationId: 'org-1',
      branchId: 'branch-1',
      department: otherDepartment,
      teamId: 'team-1',
      position: 'Technologist',
    );

    final result = service.validate(
      organizations: const [organization],
      branches: const [branch],
      departments: const [department, otherDepartment],
      teams: const [team],
      employees: const [employee],
    );

    expect(result, isA<ValidationFailure<void>>());
  });
}

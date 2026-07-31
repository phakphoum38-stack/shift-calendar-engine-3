import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 1);
  final updatedAt = DateTime.utc(2026, 8, 1, 1);

  test('organization normalizes required values and exposes active state', () {
    final organization = Organization(
      id: 'org-1',
      code: ' HOSP ',
      name: ' Main Hospital ',
      status: OrganizationStatus.active,
      version: 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(organization.code, 'HOSP');
    expect(organization.name, 'Main Hospital');
    expect(organization.isActive, isTrue);
  });

  test('archived organization requires a deletion timestamp', () {
    expect(
      () => Organization(
        id: 'org-1',
        code: 'HOSP',
        name: 'Main Hospital',
        status: OrganizationStatus.archived,
        version: 1,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
      throwsArgumentError,
    );
  });

  test('branch, department, and team preserve hierarchy', () {
    final branch = Branch(
      id: 'branch-1',
      organizationId: 'org-1',
      code: 'BKK',
      name: 'Bangkok',
      version: 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final department = Department(
      id: 'department-1',
      organizationId: 'org-1',
      branchId: branch.id,
      code: 'RAD',
      name: 'Radiology',
      version: 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final team = Team(
      id: 'team-1',
      organizationId: 'org-1',
      branchId: branch.id,
      departmentId: department.id,
      code: 'CT',
      name: 'CT Team',
      version: 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(branch.organizationId, 'org-1');
    expect(department.branchId, branch.id);
    expect(team.departmentId, department.id);
    expect(team.isActive, isTrue);
  });

  test('entities use id-based equality', () {
    final first = Branch(
      id: 'branch-1',
      organizationId: 'org-1',
      code: 'BKK',
      name: 'Bangkok',
      version: 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final second = Branch(
      id: 'branch-1',
      organizationId: 'org-1',
      code: 'CNX',
      name: 'Chiang Mai',
      version: 2,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });
}

import '../../../core/result/result.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/organization.dart';
import '../../../domain/entities/team.dart';

/// Validates references across the organization hierarchy before persistence.
class OrganizationHierarchyService {
  const OrganizationHierarchyService();

  Result<void> validate({
    required List<Organization> organizations,
    required List<Branch> branches,
    required List<Department> departments,
    required List<Team> teams,
    required List<Employee> employees,
  }) {
    final organizationIds = organizations.map((item) => item.id).toSet();
    final branchById = {for (final item in branches) item.id: item};
    final departmentById = {for (final item in departments) item.id: item};
    final teamById = {for (final item in teams) item.id: item};
    final errors = <String, String>{};

    for (final branch in branches) {
      if (!organizationIds.contains(branch.organizationId)) {
        errors['branch.${branch.id}.organizationId'] =
            'Organization ${branch.organizationId} does not exist.';
      }
    }

    for (final department in departments) {
      if (department.organizationId.isNotEmpty &&
          !organizationIds.contains(department.organizationId)) {
        errors['department.${department.id}.organizationId'] =
            'Organization ${department.organizationId} does not exist.';
      }
      if (department.branchId.isNotEmpty) {
        final branch = branchById[department.branchId];
        if (branch == null) {
          errors['department.${department.id}.branchId'] =
              'Branch ${department.branchId} does not exist.';
        } else if (department.organizationId.isNotEmpty &&
            branch.organizationId != department.organizationId) {
          errors['department.${department.id}.branchId'] =
              'Branch belongs to another organization.';
        }
      }
      if (department.parentDepartmentId.isNotEmpty &&
          !departmentById.containsKey(department.parentDepartmentId)) {
        errors['department.${department.id}.parentDepartmentId'] =
            'Parent department does not exist.';
      }
    }

    for (final team in teams) {
      final department = departmentById[team.departmentId];
      if (department == null) {
        errors['team.${team.id}.departmentId'] =
            'Department ${team.departmentId} does not exist.';
      }
      if (team.organizationId.isNotEmpty &&
          !organizationIds.contains(team.organizationId)) {
        errors['team.${team.id}.organizationId'] =
            'Organization ${team.organizationId} does not exist.';
      }
      if (team.branchId.isNotEmpty && !branchById.containsKey(team.branchId)) {
        errors['team.${team.id}.branchId'] =
            'Branch ${team.branchId} does not exist.';
      }
    }

    for (final employee in employees) {
      if (employee.organizationId.isNotEmpty &&
          !organizationIds.contains(employee.organizationId)) {
        errors['employee.${employee.id}.organizationId'] =
            'Organization ${employee.organizationId} does not exist.';
      }
      if (employee.branchId.isNotEmpty &&
          !branchById.containsKey(employee.branchId)) {
        errors['employee.${employee.id}.branchId'] =
            'Branch ${employee.branchId} does not exist.';
      }
      if (!departmentById.containsKey(employee.department.id)) {
        errors['employee.${employee.id}.department'] =
            'Department ${employee.department.id} does not exist.';
      }
      if (employee.teamId.isNotEmpty && !teamById.containsKey(employee.teamId)) {
        errors['employee.${employee.id}.teamId'] =
            'Team ${employee.teamId} does not exist.';
      }
    }

    if (errors.isNotEmpty) {
      return ValidationFailure<void>(
        'Organization hierarchy contains invalid references.',
        fieldErrors: errors,
      );
    }
    return const Success<void>(null);
  }
}

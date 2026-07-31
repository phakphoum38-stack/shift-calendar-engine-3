import '../../../core/result/result.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/organization.dart';
import '../../../domain/entities/team.dart';
import '../../../domain/repositories/branch_repository.dart';
import '../../../domain/repositories/department_repository.dart';
import '../../../domain/repositories/organization_repository.dart';
import '../../../domain/repositories/team_repository.dart';

/// Applies identity, uniqueness, and parent-reference checks before writes.
final class OrganizationWriteValidator {
  const OrganizationWriteValidator({
    required this.organizations,
    required this.branches,
    required this.departments,
    required this.teams,
  });

  final OrganizationRepository organizations;
  final BranchRepository branches;
  final DepartmentRepository departments;
  final TeamRepository teams;

  Future<Result<void>> validateOrganization(Organization value) async {
    final fields = <String, String>{};
    if (value.id.trim().isEmpty) fields['id'] = 'Required';
    if (value.code.trim().isEmpty) fields['code'] = 'Required';
    if (value.name.trim().isEmpty) fields['name'] = 'Required';
    if (fields.isNotEmpty) {
      return ValidationFailure('Invalid organization', fieldErrors: fields);
    }

    final existing = await organizations.findAll(activeOnly: false);
    if (existing case Success(value: final items)) {
      final duplicate = items.any(
        (item) =>
            item.id != value.id &&
            item.code.trim().toLowerCase() == value.code.trim().toLowerCase(),
      );
      if (duplicate) {
        return const ValidationFailure(
          'Organization code already exists',
          fieldErrors: {'code': 'Duplicate'},
        );
      }
    }
    return const Success(null);
  }

  Future<Result<void>> validateBranch(Branch value) async {
    final parent = await organizations.findById(value.organizationId);
    if (parent case Success(value: null)) {
      return const ValidationFailure(
        'Organization does not exist',
        fieldErrors: {'organizationId': 'Unknown organization'},
      );
    }

    final existing = await branches.findAll(
      organizationId: value.organizationId,
      activeOnly: false,
    );
    if (existing case Success(value: final items)) {
      final duplicate = items.any(
        (item) =>
            item.id != value.id &&
            item.code.trim().toLowerCase() == value.code.trim().toLowerCase(),
      );
      if (duplicate) {
        return const ValidationFailure(
          'Branch code already exists',
          fieldErrors: {'code': 'Duplicate'},
        );
      }
    }
    return const Success(null);
  }

  Future<Result<void>> validateDepartment(Department value) async {
    if (value.branchId.isNotEmpty) {
      final parent = await branches.findById(value.branchId);
      if (parent case Success(value: null)) {
        return const ValidationFailure(
          'Branch does not exist',
          fieldErrors: {'branchId': 'Unknown branch'},
        );
      }
    }

    if (value.parentDepartmentId.isNotEmpty) {
      if (value.parentDepartmentId == value.id) {
        return const ValidationFailure(
          'Department cannot be its own parent',
          fieldErrors: {'parentDepartmentId': 'Self reference'},
        );
      }
      final parent = await departments.findById(value.parentDepartmentId);
      if (parent case Success(value: null)) {
        return const ValidationFailure(
          'Parent department does not exist',
          fieldErrors: {'parentDepartmentId': 'Unknown department'},
        );
      }
    }
    return const Success(null);
  }

  Future<Result<void>> validateTeam(Team value) async {
    final parent = await departments.findById(value.departmentId);
    if (parent case Success(value: null)) {
      return const ValidationFailure(
        'Department does not exist',
        fieldErrors: {'departmentId': 'Unknown department'},
      );
    }

    final existing = await teams.findAll(
      departmentId: value.departmentId,
      activeOnly: false,
    );
    if (existing case Success(value: final items)) {
      final duplicate = items.any(
        (item) =>
            item.id != value.id &&
            item.code.trim().toLowerCase() == value.code.trim().toLowerCase(),
      );
      if (duplicate) {
        return const ValidationFailure(
          'Team code already exists',
          fieldErrors: {'code': 'Duplicate'},
        );
      }
    }
    return const Success(null);
  }
}

import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';

/// Validates employee identity and enterprise hierarchy assignments before save.
final class EmployeeWriteValidator {
  const EmployeeWriteValidator();

  Future<Result<void>> validate(
    Employee employee, {
    required EmployeeRepository repository,
  }) async {
    final fieldErrors = <String, String>{};

    if (employee.id.trim().isEmpty) {
      fieldErrors['id'] = 'Employee id is required.';
    }
    if (employee.employeeCode.trim().isEmpty) {
      fieldErrors['employeeCode'] = 'Employee code is required.';
    }
    if (employee.firstName.trim().isEmpty) {
      fieldErrors['firstName'] = 'First name is required.';
    }
    if (employee.position.trim().isEmpty) {
      fieldErrors['position'] = 'Position is required.';
    }
    if (employee.organizationId.trim().isEmpty) {
      fieldErrors['organizationId'] = 'Organization is required.';
    }
    if (employee.branchId.trim().isEmpty) {
      fieldErrors['branchId'] = 'Branch is required.';
    }
    if (employee.department.id.trim().isEmpty) {
      fieldErrors['department'] = 'Department is required.';
    }
    if (employee.department.organizationId.isNotEmpty &&
        employee.department.organizationId != employee.organizationId) {
      fieldErrors['department'] =
          'Department does not belong to the selected organization.';
    }
    if (employee.department.branchId.isNotEmpty &&
        employee.department.branchId != employee.branchId) {
      fieldErrors['department'] =
          'Department does not belong to the selected branch.';
    }

    final email = employee.email.trim();
    if (email.isNotEmpty && !_looksLikeEmail(email)) {
      fieldErrors['email'] = 'Email address is invalid.';
    }

    if (fieldErrors.isNotEmpty) {
      return ValidationFailure<void>(
        'Employee validation failed.',
        fieldErrors: fieldErrors,
      );
    }

    final existingResult = await repository.findAll(activeOnly: false);
    if (existingResult is Failure<List<Employee>>) {
      return PersistenceFailure<void>(
        existingResult.message,
        cause: existingResult.cause,
        stackTrace: existingResult.stackTrace,
      );
    }

    final employees = (existingResult as Success<List<Employee>>).value;
    final normalizedCode = employee.employeeCode.trim().toLowerCase();
    final duplicateCode = employees.any(
      (candidate) =>
          candidate.id != employee.id &&
          candidate.employeeCode.trim().toLowerCase() == normalizedCode,
    );
    if (duplicateCode) {
      return const ValidationFailure<void>(
        'Employee code already exists.',
        fieldErrors: {'employeeCode': 'Employee code must be unique.'},
      );
    }

    return const Success<void>(null);
  }

  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }
}

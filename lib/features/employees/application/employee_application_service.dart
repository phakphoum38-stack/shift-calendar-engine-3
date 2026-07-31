import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';
import 'employee_query.dart';
import 'employee_write_validator.dart';

/// Coordinates employee CRUD, search, hierarchy filtering, and pagination.
final class EmployeeApplicationService {
  const EmployeeApplicationService({
    required this.repository,
    this.validator = const EmployeeWriteValidator(),
  });

  final EmployeeRepository repository;
  final EmployeeWriteValidator validator;

  Future<Result<EmployeePage<Employee>>> search(
    EmployeeQuery query,
  ) async {
    final result = await repository.findAll(activeOnly: query.activeOnly);
    if (result is Failure<List<Employee>>) {
      return PersistenceFailure<EmployeePage<Employee>>(
        result.message,
        cause: result.cause,
        stackTrace: result.stackTrace,
      );
    }

    final normalizedSearch = query.searchText.trim().toLowerCase();
    final filtered = (result as Success<List<Employee>>)
        .value
        .where((employee) => _matchesHierarchy(employee, query))
        .where((employee) => _matchesSearch(employee, normalizedSearch))
        .toList(growable: false)
      ..sort(_compareEmployees);

    final start = (query.page - 1) * query.pageSize;
    final items = start >= filtered.length
        ? const <Employee>[]
        : filtered
            .skip(start)
            .take(query.pageSize)
            .toList(growable: false);

    return Success<EmployeePage<Employee>>(
      EmployeePage<Employee>(
        items: items,
        page: query.page,
        pageSize: query.pageSize,
        totalItems: filtered.length,
      ),
    );
  }

  Future<Result<Employee>> save(Employee employee) async {
    final validation = await validator.validate(
      employee,
      repository: repository,
    );
    if (validation is Failure<void>) {
      return ValidationFailure<Employee>(
        validation.message,
        fieldErrors: validation is ValidationFailure<void>
            ? validation.fieldErrors
            : const {},
        cause: validation.cause,
        stackTrace: validation.stackTrace,
      );
    }
    return repository.save(employee);
  }

  Future<Result<Employee>> move({
    required Employee employee,
    required String organizationId,
    required String branchId,
    required String teamId,
    required dynamic department,
  }) {
    return save(
      employee.copyWith(
        organizationId: organizationId,
        branchId: branchId,
        department: department,
        teamId: teamId,
      ),
    );
  }

  Future<Result<void>> delete(String employeeId) {
    if (employeeId.trim().isEmpty) {
      return Future.value(
        const ValidationFailure<void>(
          'Employee id is required.',
          fieldErrors: {'id': 'Employee id is required.'},
        ),
      );
    }
    return repository.delete(employeeId);
  }

  bool _matchesHierarchy(Employee employee, EmployeeQuery query) {
    if (query.organizationId != null &&
        employee.organizationId != query.organizationId) {
      return false;
    }
    if (query.branchId != null && employee.branchId != query.branchId) {
      return false;
    }
    if (query.departmentId != null &&
        employee.department.id != query.departmentId) {
      return false;
    }
    if (query.teamId != null && employee.teamId != query.teamId) {
      return false;
    }
    return true;
  }

  bool _matchesSearch(Employee employee, String normalizedSearch) {
    if (normalizedSearch.isEmpty) {
      return true;
    }
    final values = <String>[
      employee.employeeCode,
      employee.firstName,
      employee.lastName,
      employee.nickname,
      employee.fullName,
      employee.position,
      employee.email,
      employee.phone,
      employee.department.code,
      employee.department.name,
    ];
    return values.any(
      (value) => value.toLowerCase().contains(normalizedSearch),
    );
  }

  int _compareEmployees(Employee left, Employee right) {
    final byName = left.fullName.toLowerCase().compareTo(
      right.fullName.toLowerCase(),
    );
    if (byName != 0) {
      return byName;
    }
    return left.employeeCode.toLowerCase().compareTo(
      right.employeeCode.toLowerCase(),
    );
  }
}

import '../../../core/result/result.dart';
import '../../../core/storage/atomic_string_store.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';
import '../../foundation/infrastructure/canonical_json_codec.dart';

/// Atomic production repository for employee identities.
class SharedPreferencesEmployeeRepository implements EmployeeRepository {
  SharedPreferencesEmployeeRepository({
    AtomicStringStore? store,
    this.codec = const CanonicalJsonCodec(),
  }) : store =
           store ?? AtomicStringStore(namespace: 'sce3.canonical_employees.v1');

  final AtomicStringStore store;
  final CanonicalJsonCodec codec;

  @override
  Future<Result<void>> delete(String id) async {
    final loaded = await _load();

    if (loaded case Failure<List<Employee>>()) {
      return PersistenceFailure(loaded.message, cause: loaded);
    }

    final values = (loaded as Success<List<Employee>>).value
        .where((employee) => employee.id != id)
        .toList();

    final saved = await _saveAll(values);

    return switch (saved) {
      Success<List<Employee>>() => const Success(null),
      Failure<List<Employee>>() => PersistenceFailure(
        saved.message,
        cause: saved,
      ),
    };
  }

  @override
  Future<Result<List<Employee>>> findAll({bool activeOnly = true}) =>
      search(EmployeeQuery(activeOnly: activeOnly));

  @override
  Future<Result<Employee?>> findById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return const ValidationFailure(
        'Employee id is required.',
        fieldErrors: {'id': 'required'},
      );
    }

    final loaded = await _load();

    return switch (loaded) {
      Success<List<Employee>>(value: final values) => Success(
        values.cast<Employee?>().firstWhere(
          (employee) => employee!.id == normalizedId,
          orElse: () => null,
        ),
      ),
      Failure<List<Employee>>() => PersistenceFailure(
        loaded.message,
        cause: loaded,
      ),
    };
  }

  @override
  Future<Result<List<Employee>>> search(EmployeeQuery query) async {
    final loaded = await _load();

    return switch (loaded) {
      Success<List<Employee>>(value: final values) => Success(
        List.unmodifiable(_filterAndSort(values, query)),
      ),
      Failure<List<Employee>>() => PersistenceFailure(
        loaded.message,
        cause: loaded,
      ),
    };
  }

  @override
  Future<Result<Employee>> save(Employee employee) async {
    if (employee.id.trim().isEmpty ||
        employee.employeeCode.trim().isEmpty ||
        employee.firstName.trim().isEmpty) {
      return const ValidationFailure('Employee data is incomplete.');
    }

    final loaded = await _load();

    if (loaded case Failure<List<Employee>>()) {
      return PersistenceFailure(loaded.message, cause: loaded);
    }

    final values = List<Employee>.of((loaded as Success<List<Employee>>).value);

    final duplicateEmployeeCode = values.any(
      (value) =>
          value.id != employee.id &&
          value.employeeCode.trim().toLowerCase() ==
              employee.employeeCode.trim().toLowerCase(),
    );

    if (duplicateEmployeeCode) {
      return const ValidationFailure(
        'Employee code is already in use.',
        fieldErrors: {'employeeCode': 'duplicate'},
      );
    }

    final index = values.indexWhere((value) => value.id == employee.id);

    if (index == -1) {
      values.add(employee);
    } else {
      values[index] = employee;
    }

    final saved = await _saveAll(values);

    return switch (saved) {
      Success<List<Employee>>() => Success(employee),
      Failure<List<Employee>>() => PersistenceFailure(
        saved.message,
        cause: saved,
      ),
    };
  }

  List<Employee> _filterAndSort(List<Employee> values, EmployeeQuery query) {
    final text = query.text.trim().toLowerCase();
    final organizationId = query.organizationId.trim();
    final branchId = query.branchId.trim();
    final departmentId = query.departmentId.trim();
    final teamId = query.teamId.trim();

    final result =
        values.where((employee) {
          if (query.activeOnly && !employee.active) {
            return false;
          }

          if (organizationId.isNotEmpty &&
              employee.organizationId != organizationId) {
            return false;
          }

          if (branchId.isNotEmpty && employee.branchId != branchId) {
            return false;
          }

          if (departmentId.isNotEmpty &&
              employee.department.id != departmentId) {
            return false;
          }

          if (teamId.isNotEmpty && employee.teamId != teamId) {
            return false;
          }

          if (text.isEmpty) {
            return true;
          }

          return employee.id.toLowerCase().contains(text) ||
              employee.employeeCode.toLowerCase().contains(text) ||
              employee.firstName.toLowerCase().contains(text) ||
              employee.lastName.toLowerCase().contains(text) ||
              employee.nickname.toLowerCase().contains(text) ||
              employee.displayName.toLowerCase().contains(text) ||
              employee.position.toLowerCase().contains(text) ||
              employee.email.toLowerCase().contains(text) ||
              employee.phone.toLowerCase().contains(text) ||
              employee.department.code.toLowerCase().contains(text) ||
              employee.department.name.toLowerCase().contains(text);
        }).toList()..sort((a, b) {
          final departmentComparison = a.department.name.compareTo(
            b.department.name,
          );

          if (departmentComparison != 0) {
            return departmentComparison;
          }

          final nameComparison = a.displayName.compareTo(b.displayName);

          if (nameComparison != 0) {
            return nameComparison;
          }

          return a.id.compareTo(b.id);
        });

    return result;
  }

  Future<Result<List<Employee>>> _load() async {
    try {
      final payload = await store.read();

      final employees = payload == null
          ? <Employee>[]
          : codec.decodeEmployees(payload);

      return Success(List.unmodifiable(employees));
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not load employees.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result<List<Employee>>> _saveAll(List<Employee> values) async {
    try {
      final immutableValues = List<Employee>.unmodifiable(values);

      await store.write(codec.encodeEmployees(immutableValues));

      return Success(immutableValues);
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not save employees.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

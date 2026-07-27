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
  Future<Result<List<Employee>>> findAll({bool activeOnly = true}) async {
    final loaded = await _load();
    return switch (loaded) {
      Success<List<Employee>>(value: final values) => Success(
        List.unmodifiable(
          values.where((employee) => !activeOnly || employee.active),
        ),
      ),
      Failure<List<Employee>>() => loaded,
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
    if (values.any(
      (value) =>
          value.id != employee.id &&
          value.employeeCode.toLowerCase() ==
              employee.employeeCode.toLowerCase(),
    )) {
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

  Future<Result<List<Employee>>> _load() async {
    try {
      final payload = await store.read();
      return Success(
        payload == null ? const [] : codec.decodeEmployees(payload),
      );
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
      await store.write(codec.encodeEmployees(values));
      return Success(List.unmodifiable(values));
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not save employees.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/repositories/employee_repository.dart';
import 'employee_directory_service.dart';
import 'employee_directory_state.dart';

/// Owns employee directory loading, mutations, filters, and sorting.
class EmployeeDirectoryController extends ChangeNotifier {
  EmployeeDirectoryController({
    required this.repository,
    required this.schedule,
    this.service = const EmployeeDirectoryService(),
  });

  final EmployeeRepository repository;
  final EmployeeDirectoryService service;
  Schedule schedule;

  List<Employee> _persisted = const [];
  EmployeeDirectoryState _state = const EmployeeDirectoryState();

  EmployeeDirectoryState get state => _state;
  bool get loading => _state.loading;
  String? get error => _state.error;
  List<Employee> get employees => _state.employees;

  Future<void> load() async {
    if (_state.loading) return;
    _emit(_state.copyWith(loading: true, clearError: true));

    final result = await repository.findAll(activeOnly: false);
    switch (result) {
      case Success<List<Employee>>(value: final employees):
        _persisted = List.unmodifiable(employees);
        _refreshEmployees(loading: false);
      case Failure<List<Employee>>():
        _emit(_state.copyWith(loading: false, error: result.message));
    }
  }

  Future<void> refresh() => load();

  Future<bool> save(Employee employee) async {
    _emit(_state.copyWith(loading: true, clearError: true));
    final result = await repository.save(employee);

    switch (result) {
      case Success<Employee>(value: final saved):
        final values = List<Employee>.of(_persisted);
        final index = values.indexWhere((value) => value.id == saved.id);
        if (index == -1) {
          values.add(saved);
        } else {
          values[index] = saved;
        }
        _persisted = List.unmodifiable(values);
        _refreshEmployees(loading: false);
      case Failure<Employee>():
        _emit(_state.copyWith(loading: false, error: result.message));
    }

    return result.isSuccess;
  }

  Future<bool> deactivate(Employee employee) =>
      save(employee.copyWith(active: false));

  void updateSchedule(Schedule schedule) {
    if (identical(schedule, this.schedule)) return;
    this.schedule = schedule;
    _refreshEmployees();
  }

  void search(String query) => _emit(_state.copyWith(query: query));

  void setStatusFilter(EmployeeStatusFilter value) =>
      _emit(_state.copyWith(statusFilter: value));

  void setSort(EmployeeSort value) =>
      _emit(_state.copyWith(employeeSort: value));

  void setDepartment(String? value) => _emit(
        _state.copyWith(
          departmentId: value,
          clearDepartment: value == null,
        ),
      );

  void _refreshEmployees({bool? loading}) {
    final byId = <String, Employee>{
      for (final employee in service.fromSchedule(schedule))
        employee.id: employee,
      for (final employee in _persisted) employee.id: employee,
    };
    final employees = List<Employee>.unmodifiable(byId.values);
    final departmentStillExists = _state.departmentId == null ||
        employees.any(
          (employee) => employee.department.id == _state.departmentId,
        );

    _emit(
      _state.copyWith(
        employees: employees,
        loading: loading,
        clearDepartment: !departmentStillExists,
        clearError: true,
      ),
    );
  }

  void _emit(EmployeeDirectoryState value) {
    _state = value;
    notifyListeners();
  }
}

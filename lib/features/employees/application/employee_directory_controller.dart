import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/repositories/employee_repository.dart';
import 'employee_directory_service.dart';

/// Owns persistent employee directory state and filtering.
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
  String _query = '';
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;

  List<Employee> get employees {
    final byId = <String, Employee>{
      for (final employee in service.fromSchedule(schedule))
        employee.id: employee,
      for (final employee in _persisted) employee.id: employee,
    };
    final normalized = _query.trim().toLowerCase();
    final result =
        byId.values
            .where(
              (employee) =>
                  employee.active &&
                  (normalized.isEmpty ||
                      employee.employeeCode.toLowerCase().contains(
                        normalized,
                      ) ||
                      employee.displayName.toLowerCase().contains(normalized) ||
                      employee.position.toLowerCase().contains(normalized)),
            )
            .toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return List.unmodifiable(result);
  }

  Future<void> load() async {
    if (_loading) return;
    _setLoading();
    final result = await repository.findAll(activeOnly: false);
    switch (result) {
      case Success<List<Employee>>(value: final employees):
        _persisted = employees;
      case Failure<List<Employee>>():
        _error = result.message;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> save(Employee employee) async {
    _setLoading();
    final result = await repository.save(employee);
    if (result case Success<Employee>()) {
      final values = List<Employee>.of(_persisted);
      final index = values.indexWhere((value) => value.id == employee.id);
      if (index == -1) {
        values.add(employee);
      } else {
        values[index] = employee;
      }
      _persisted = List.unmodifiable(values);
    } else if (result case Failure<Employee>()) {
      _error = result.message;
    }
    _loading = false;
    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> deactivate(Employee employee) {
    return save(employee.copyWith(active: false));
  }

  void updateSchedule(Schedule schedule) {
    if (identical(schedule, this.schedule)) return;
    this.schedule = schedule;
    notifyListeners();
  }

  void search(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }

  void _setLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }
}

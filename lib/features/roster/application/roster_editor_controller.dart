import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/schedule_day.dart';
import '../../../domain/entities/schedule_month.dart';
import '../../../domain/entities/shift_assignment.dart';
import '../../../domain/entities/shift_template.dart';
import '../../../domain/repositories/employee_repository.dart';
import '../../../domain/repositories/schedule_repository.dart';
import '../../../domain/repositories/shift_template_repository.dart';

/// Owns explicit canonical roster mutations and persistence.
class RosterEditorController extends ChangeNotifier {
  RosterEditorController({
    required this.scheduleRepository,
    required this.employeeRepository,
    required this.shiftTemplateRepository,
    required this.schedule,
  });

  final ScheduleRepository scheduleRepository;
  final EmployeeRepository employeeRepository;
  final ShiftTemplateRepository shiftTemplateRepository;

  Schedule schedule;
  List<Employee> _employees = const [];
  List<ShiftTemplate> _shifts = const [];
  bool _loading = false;
  String? _error;

  List<Employee> get employees => _employees;
  List<ShiftTemplate> get shifts => _shifts;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadCatalogs() async {
    if (_loading) return;
    _setLoading();
    final employeeResult = await employeeRepository.findAll();
    final shiftResult = await shiftTemplateRepository.findAll();
    if (employeeResult case Success<List<Employee>>(value: final values)) {
      _employees = values;
    } else if (employeeResult case Failure<List<Employee>>()) {
      _error = employeeResult.message;
    }
    if (shiftResult case Success<List<ShiftTemplate>>(value: final values)) {
      _shifts = values;
    } else if (shiftResult case Failure<List<ShiftTemplate>>()) {
      _error ??= shiftResult.message;
    }
    _loading = false;
    notifyListeners();
  }

  void addAssignment(DateTime date, ShiftAssignment assignment) {
    final normalized = DateTime(date.year, date.month, date.day);
    final existingMonth =
        schedule.month(normalized) ?? ScheduleMonth(month: normalized);
    final existingDay =
        existingMonth.day(normalized) ?? ScheduleDay(date: normalized);
    final assignments = List<ShiftAssignment>.of(existingDay.assignments);
    final index = assignments.indexWhere((value) => value.id == assignment.id);
    if (index == -1) {
      assignments.add(assignment);
    } else {
      assignments[index] = assignment;
    }
    schedule = schedule.replaceMonth(
      existingMonth.replaceDay(existingDay.copyWith(assignments: assignments)),
    );
    notifyListeners();
  }

  void deleteAssignment(DateTime date, String assignmentId) {
    final month = schedule.month(date);
    final day = month?.day(date);
    if (month == null || day == null) return;
    schedule = schedule.replaceMonth(
      month.replaceDay(
        day.copyWith(
          assignments: day.assignments
              .where((value) => value.id != assignmentId)
              .toList(),
        ),
      ),
    );
    notifyListeners();
  }

  Future<bool> save() async {
    _setLoading();
    final result = await scheduleRepository.save(schedule);
    if (result case Success<Schedule>(value: final value)) {
      schedule = value;
    } else if (result case Failure<Schedule>()) {
      _error = result.message;
    }
    _loading = false;
    notifyListeners();
    return result.isSuccess;
  }

  void _setLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }
}

import 'dart:convert';

import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/schedule_day.dart';
import '../../../domain/entities/schedule_month.dart';
import '../../../domain/entities/shift_assignment.dart';
import '../../../domain/entities/shift_template.dart';

/// Controlled canonical JSON decoding failure with field context.
class CanonicalCodecException implements Exception {
  const CanonicalCodecException(this.message);

  final String message;

  @override
  String toString() => 'CanonicalCodecException: $message';
}

/// Shared explicit codecs for canonical roster relationships.
class CanonicalJsonCodec {
  const CanonicalJsonCodec();

  static const formatVersion = 1;

  String encodeEmployees(List<Employee> employees) {
    final ordered = List<Employee>.of(employees)
      ..sort((a, b) => a.id.compareTo(b.id));
    return jsonEncode({
      'formatVersion': formatVersion,
      'employees': [for (final employee in ordered) encodeEmployee(employee)],
    });
  }

  List<Employee> decodeEmployees(String source) {
    final root = _root(source);
    final result = <Employee>[];
    final ids = <String>{};
    for (final (index, item) in _list(root['employees'], 'employees').indexed) {
      final employee = decodeEmployee(
        _map(item, 'employees[$index]'),
        'employees[$index]',
      );
      if (!ids.add(employee.id)) {
        throw CanonicalCodecException(
          'Duplicate employee ID "${employee.id}".',
        );
      }
      result.add(employee);
    }
    return List.unmodifiable(result);
  }

  String encodeShifts(List<ShiftTemplate> shifts) {
    final ordered = List<ShiftTemplate>.of(shifts)
      ..sort((a, b) => a.id.compareTo(b.id));
    return jsonEncode({
      'formatVersion': formatVersion,
      'shifts': [for (final shift in ordered) encodeShift(shift)],
    });
  }

  List<ShiftTemplate> decodeShifts(String source) {
    final root = _root(source);
    final result = <ShiftTemplate>[];
    final ids = <String>{};
    for (final (index, item) in _list(root['shifts'], 'shifts').indexed) {
      final shift = decodeShift(_map(item, 'shifts[$index]'), 'shifts[$index]');
      if (!ids.add(shift.id)) {
        throw CanonicalCodecException('Duplicate shift ID "${shift.id}".');
      }
      result.add(shift);
    }
    return List.unmodifiable(result);
  }

  String encodeSchedule(Schedule schedule) => jsonEncode({
    'formatVersion': formatVersion,
    'schedule': {
      'id': schedule.id,
      'name': schedule.name,
      'months': [
        for (final month in schedule.months)
          {
            'month': _date(month.month),
            'days': [
              for (final day in month.days)
                {
                  'date': _date(day.date),
                  'holidayName': day.holidayName,
                  'assignments': [
                    for (final assignment in day.assignments)
                      encodeAssignment(assignment),
                  ],
                },
            ],
          },
      ],
    },
  });

  Schedule decodeSchedule(String source) {
    final root = _root(source);
    final value = _map(root['schedule'], 'schedule');
    final months = <ScheduleMonth>[];
    for (final (index, item) in _list(
      value['months'],
      'schedule.months',
    ).indexed) {
      final monthValue = _map(item, 'schedule.months[$index]');
      final days = <ScheduleDay>[];
      for (final (dayIndex, dayItem) in _list(
        monthValue['days'],
        'schedule.months[$index].days',
      ).indexed) {
        final dayValue = _map(
          dayItem,
          'schedule.months[$index].days[$dayIndex]',
        );
        final assignments = <ShiftAssignment>[];
        for (final (assignmentIndex, assignmentItem) in _list(
          dayValue['assignments'],
          'schedule.months[$index].days[$dayIndex].assignments',
        ).indexed) {
          assignments.add(
            decodeAssignment(
              _map(
                assignmentItem,
                'schedule.months[$index].days[$dayIndex]'
                '.assignments[$assignmentIndex]',
              ),
              'schedule.months[$index].days[$dayIndex]'
              '.assignments[$assignmentIndex]',
            ),
          );
        }
        days.add(
          ScheduleDay(
            date: _dateTime(
              dayValue['date'],
              'schedule.months[$index].days[$dayIndex].date',
            ),
            holidayName: _optionalString(
              dayValue['holidayName'],
              'holidayName',
            ),
            assignments: assignments,
          ),
        );
      }
      months.add(
        ScheduleMonth(
          month: _dateTime(
            monthValue['month'],
            'schedule.months[$index].month',
          ),
          days: days,
        ),
      );
    }
    return Schedule(
      id: _requiredString(value['id'], 'schedule.id'),
      name: _requiredString(value['name'], 'schedule.name'),
      months: months,
    );
  }

  Map<String, Object?> encodeEmployee(Employee employee) => {
    'id': employee.id,
    'employeeCode': employee.employeeCode,
    'firstName': employee.firstName,
    'lastName': employee.lastName,
    'nickname': employee.nickname,
    'department': {
      'id': employee.department.id,
      'code': employee.department.code,
      'name': employee.department.name,
      'active': employee.department.active,
    },
    'position': employee.position,
    'active': employee.active,
  };

  Employee decodeEmployee(Map<String, Object?> value, String path) {
    final department = _map(value['department'], '$path.department');
    return Employee(
      id: _requiredString(value['id'], '$path.id'),
      employeeCode: _requiredString(
        value['employeeCode'],
        '$path.employeeCode',
      ),
      firstName: _requiredString(value['firstName'], '$path.firstName'),
      lastName: _string(value['lastName'], '$path.lastName'),
      nickname: _string(value['nickname'], '$path.nickname'),
      department: Department(
        id: _requiredString(department['id'], '$path.department.id'),
        code: _requiredString(department['code'], '$path.department.code'),
        name: _requiredString(department['name'], '$path.department.name'),
        active: _boolean(department['active'], '$path.department.active'),
      ),
      position: _string(value['position'], '$path.position'),
      active: _boolean(value['active'], '$path.active'),
    );
  }

  Map<String, Object?> encodeShift(ShiftTemplate shift) => {
    'id': shift.id,
    'code': shift.code,
    'name': shift.name,
    'startMinutes': shift.startTime.inMinutes,
    'endMinutes': shift.endTime.inMinutes,
    'colorValue': shift.colorValue,
    'workingHours': shift.workingHours,
    'rate': shift.rate,
    'active': shift.active,
  };

  ShiftTemplate decodeShift(Map<String, Object?> value, String path) {
    return ShiftTemplate(
      id: _requiredString(value['id'], '$path.id'),
      code: _requiredString(value['code'], '$path.code'),
      name: _requiredString(value['name'], '$path.name'),
      startTime: Duration(
        minutes: _integer(value['startMinutes'], '$path.startMinutes'),
      ),
      endTime: Duration(
        minutes: _integer(value['endMinutes'], '$path.endMinutes'),
      ),
      colorValue: _integer(value['colorValue'], '$path.colorValue'),
      workingHours: _number(value['workingHours'], '$path.workingHours'),
      rate: _number(value['rate'], '$path.rate'),
      active: _boolean(value['active'], '$path.active'),
    );
  }

  Map<String, Object?> encodeAssignment(ShiftAssignment assignment) => {
    'id': assignment.id,
    'employee': encodeEmployee(assignment.employee),
    'shift': encodeShift(assignment.shift),
    'location': assignment.location,
    'remark': assignment.remark,
    'approved': assignment.approved,
  };

  ShiftAssignment decodeAssignment(Map<String, Object?> value, String path) {
    return ShiftAssignment(
      id: _requiredString(value['id'], '$path.id'),
      employee: decodeEmployee(
        _map(value['employee'], '$path.employee'),
        '$path.employee',
      ),
      shift: decodeShift(_map(value['shift'], '$path.shift'), '$path.shift'),
      location: _optionalString(value['location'], '$path.location'),
      remark: _optionalString(value['remark'], '$path.remark'),
      approved: _boolean(value['approved'], '$path.approved'),
    );
  }

  Map<String, Object?> _root(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw CanonicalCodecException('Malformed JSON: $error');
    }
    final root = _map(decoded, 'root');
    final version = _integer(root['formatVersion'], 'formatVersion');
    if (version != formatVersion) {
      throw CanonicalCodecException('Unsupported format version $version.');
    }
    return root;
  }

  static String _date(DateTime value) =>
      DateTime(value.year, value.month, value.day).toIso8601String();

  DateTime _dateTime(Object? value, String path) {
    final source = _requiredString(value, path);
    final parsed = DateTime.tryParse(source);
    if (parsed == null) {
      throw CanonicalCodecException('$path must be an ISO-8601 date.');
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  Map<String, Object?> _map(Object? value, String path) {
    if (value is! Map<String, Object?>) {
      throw CanonicalCodecException('$path must be an object.');
    }
    return value;
  }

  List<Object?> _list(Object? value, String path) {
    if (value is! List<Object?>) {
      throw CanonicalCodecException('$path must be a list.');
    }
    return value;
  }

  String _requiredString(Object? value, String path) {
    final result = _string(value, path).trim();
    if (result.isEmpty) {
      throw CanonicalCodecException('$path must not be empty.');
    }
    return result;
  }

  String _string(Object? value, String path) {
    if (value is! String) {
      throw CanonicalCodecException('$path must be a string.');
    }
    return value;
  }

  String? _optionalString(Object? value, String path) {
    if (value == null) return null;
    return _string(value, path);
  }

  bool _boolean(Object? value, String path) {
    if (value is! bool) {
      throw CanonicalCodecException('$path must be a boolean.');
    }
    return value;
  }

  int _integer(Object? value, String path) {
    if (value is! int) {
      throw CanonicalCodecException('$path must be an integer.');
    }
    return value;
  }

  double _number(Object? value, String path) {
    if (value is! num) {
      throw CanonicalCodecException('$path must be a number.');
    }
    return value.toDouble();
  }
}

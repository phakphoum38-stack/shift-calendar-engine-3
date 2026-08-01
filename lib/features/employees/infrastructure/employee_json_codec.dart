import 'dart:convert';

import '../../../domain/entities/calendar_profile.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/employment.dart';
import '../../../domain/entities/source_profile.dart';

/// Versioned JSON codec for the enterprise employee directory.
final class EmployeeJsonCodec {
  const EmployeeJsonCodec();

  static const formatVersion = 2;

  String encode(List<Employee> employees) {
    final ordered = List<Employee>.of(employees)
      ..sort((left, right) => left.id.compareTo(right.id));
    return jsonEncode({
      'formatVersion': formatVersion,
      'employees': [for (final employee in ordered) _encodeEmployee(employee)],
    });
  }

  List<Employee> decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Employee payload must be a JSON object.');
    }

    final values = decoded['employees'];
    if (values is! List) {
      throw const FormatException('Employee payload must contain employees.');
    }

    final ids = <String>{};
    final employees = <Employee>[];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value is! Map) {
        throw FormatException('employees[$index] must be an object.');
      }
      final employee = _decodeEmployee(
        Map<String, dynamic>.from(value),
        'employees[$index]',
      );
      if (!ids.add(employee.id)) {
        throw FormatException('Duplicate employee id: ${employee.id}.');
      }
      employees.add(employee);
    }
    return List.unmodifiable(employees);
  }

  Map<String, Object?> _encodeEmployee(Employee employee) => {
    'id': employee.id,
    'employeeCode': employee.employeeCode,
    'firstName': employee.firstName,
    'lastName': employee.lastName,
    'nickname': employee.nickname,
    'organizationId': employee.organizationId,
    'branchId': employee.branchId,
    'department': {
      'id': employee.department.id,
      'code': employee.department.code,
      'name': employee.department.name,
      'organizationId': employee.department.organizationId,
      'branchId': employee.department.branchId,
      'parentDepartmentId': employee.department.parentDepartmentId,
      'active': employee.department.active,
    },
    'teamId': employee.teamId,
    'position': employee.position,
    'email': employee.email,
    'phone': employee.phone,
    'employment': {
      'type': employee.employment.type.name,
      'startDate': employee.employment.startDate?.toIso8601String(),
      'endDate': employee.employment.endDate?.toIso8601String(),
      'supervisorEmployeeId': employee.employment.supervisorEmployeeId,
      'shiftGroupId': employee.employment.shiftGroupId,
      'defaultShiftTemplateId': employee.employment.defaultShiftTemplateId,
    },
    'calendarProfile': {
      'googleCalendarId': employee.calendarProfile.googleCalendarId,
      'colorId': employee.calendarProfile.colorId,
      'syncEnabled': employee.calendarProfile.syncEnabled,
    },
    'sourceProfile': {
      'sourceId': employee.sourceProfile.sourceId,
      'sheetName': employee.sourceProfile.sheetName,
      'rowKey': employee.sourceProfile.rowKey,
      'externalEmployeeId': employee.sourceProfile.externalEmployeeId,
      'googleAccountEmail': employee.sourceProfile.googleAccountEmail,
    },
    'active': employee.active,
  };

  Employee _decodeEmployee(Map<String, dynamic> value, String path) {
    final departmentValue = _map(value['department'], '$path.department');
    final employmentValue = _optionalMap(value['employment']);
    final calendarValue = _optionalMap(value['calendarProfile']);
    final sourceValue = _optionalMap(value['sourceProfile']);

    return Employee(
      id: _requiredString(value['id'], '$path.id'),
      employeeCode: _requiredString(
        value['employeeCode'],
        '$path.employeeCode',
      ),
      firstName: _requiredString(value['firstName'], '$path.firstName'),
      lastName: _string(value['lastName']),
      nickname: _string(value['nickname']),
      organizationId: _string(value['organizationId']),
      branchId: _string(value['branchId']),
      department: Department(
        id: _requiredString(departmentValue['id'], '$path.department.id'),
        code: _requiredString(departmentValue['code'], '$path.department.code'),
        name: _requiredString(departmentValue['name'], '$path.department.name'),
        organizationId: _string(departmentValue['organizationId']),
        branchId: _string(departmentValue['branchId']),
        parentDepartmentId: _string(departmentValue['parentDepartmentId']),
        active: _boolean(departmentValue['active'], fallback: true),
      ),
      teamId: _string(value['teamId']),
      position: _string(value['position']),
      email: _string(value['email']),
      phone: _string(value['phone']),
      employment: Employment(
        type: _employmentType(employmentValue['type']),
        startDate: _date(employmentValue['startDate']),
        endDate: _date(employmentValue['endDate']),
        supervisorEmployeeId: _string(employmentValue['supervisorEmployeeId']),
        shiftGroupId: _string(employmentValue['shiftGroupId']),
        defaultShiftTemplateId: _string(
          employmentValue['defaultShiftTemplateId'],
        ),
      ),
      calendarProfile: CalendarProfile(
        googleCalendarId: _string(calendarValue['googleCalendarId']),
        colorId: _string(calendarValue['colorId']),
        syncEnabled: _boolean(calendarValue['syncEnabled']),
      ),
      sourceProfile: SourceProfile(
        sourceId: _string(sourceValue['sourceId']),
        sheetName: _string(sourceValue['sheetName']),
        rowKey: _string(sourceValue['rowKey']),
        externalEmployeeId: _string(sourceValue['externalEmployeeId']),
        googleAccountEmail: _string(sourceValue['googleAccountEmail']),
      ),
      active: _boolean(value['active'], fallback: true),
    );
  }

  Map<String, dynamic> _map(Object? value, String path) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('$path must be an object.');
  }

  Map<String, dynamic> _optionalMap(Object? value) {
    if (value == null) {
      return const <String, dynamic>{};
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw const FormatException('Optional employee profile must be an object.');
  }

  String _requiredString(Object? value, String path) {
    final result = _string(value).trim();
    if (result.isEmpty) {
      throw FormatException('$path is required.');
    }
    return result;
  }

  String _string(Object? value) => value is String ? value : '';

  bool _boolean(Object? value, {bool fallback = false}) =>
      value is bool ? value : fallback;

  DateTime? _date(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  EmploymentType _employmentType(Object? value) {
    if (value is String) {
      for (final type in EmploymentType.values) {
        if (type.name == value) {
          return type;
        }
      }
    }
    return EmploymentType.fullTime;
  }
}

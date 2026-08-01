import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';

class ApiEmployeeRepository implements EmployeeRepository {
  const ApiEmployeeRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Result<List<Employee>>> findAll({bool activeOnly = true}) async {
    try {
      final employees = <Employee>[];
      var page = 1;
      var lastPage = 1;

      do {
        final json = await apiClient.get(
          '/api/v1/employees',
          queryParameters: {'page': page},
        );

        final rawItems = json['data'];

        if (rawItems is List) {
          employees.addAll(
            rawItems.whereType<Map>().map(
              (item) => _employeeFromJson(Map<String, dynamic>.from(item)),
            ),
          );
        }

        final meta = json['meta'];

        if (meta is Map) {
          final value = meta['last_page'];
          lastPage = value is int
              ? value
              : int.tryParse(value?.toString() ?? '') ?? 1;
        }

        page++;
      } while (page <= lastPage);

      final filtered = activeOnly
          ? employees.where((employee) => employee.active).toList()
          : employees;

      return Success(List<Employee>.unmodifiable(filtered));
    } on ApiException catch (error, stackTrace) {
      return NetworkFailure<List<Employee>>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      return NetworkFailure<List<Employee>>(
        'Unable to load employees.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<List<Employee>>> search(EmployeeQuery query) async {
    final loaded = await findAll(activeOnly: query.activeOnly);

    if (loaded case Failure<List<Employee>>()) {
      return loaded;
    }

    final text = query.text.trim().toLowerCase();

    final employees =
        (loaded as Success<List<Employee>>).value
            .where((employee) {
              if (query.organizationId.isNotEmpty &&
                  employee.organizationId != query.organizationId) {
                return false;
              }

              if (query.branchId.isNotEmpty &&
                  employee.branchId != query.branchId) {
                return false;
              }

              if (query.departmentId.isNotEmpty &&
                  employee.department.id != query.departmentId) {
                return false;
              }

              if (query.teamId.isNotEmpty && employee.teamId != query.teamId) {
                return false;
              }

              if (text.isEmpty) {
                return true;
              }

              final searchableValues = <String>[
                employee.id,
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

              return searchableValues.any(
                (value) => value.toLowerCase().contains(text),
              );
            })
            .toList(growable: false)
          ..sort(_compareEmployees);

    return Success(List<Employee>.unmodifiable(employees));
  }

  @override
  Future<Result<Employee?>> findById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return const ValidationFailure<Employee?>(
        'Employee id is required.',
        fieldErrors: {'id': 'Employee id is required.'},
      );
    }

    try {
      final json = await apiClient.get('/api/v1/employees/$normalizedId');

      final data = json['data'];

      if (data is! Map) {
        return const NetworkFailure<Employee?>(
          'The employee API returned an unexpected response.',
        );
      }

      return Success(_employeeFromJson(Map<String, dynamic>.from(data)));
    } on ApiException catch (error, stackTrace) {
      if (error.statusCode == 404) {
        return const Success<Employee?>(null);
      }

      return NetworkFailure<Employee?>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      return NetworkFailure<Employee?>(
        'Unable to load the employee.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<Employee>> save(Employee employee) async {
    try {
      final existing = await findById(employee.id);

      if (existing case Failure<Employee?>()) {
        return NetworkFailure<Employee>(
          existing.message,
          cause: existing,
          stackTrace: existing.stackTrace,
        );
      }

      final existingEmployee = (existing as Success<Employee?>).value;

      final json = existingEmployee == null
          ? await apiClient.post(
              '/api/v1/employees',
              body: _employeeToJson(employee),
            )
          : await apiClient.put(
              '/api/v1/employees/${employee.id}',
              body: _employeeToJson(employee),
            );

      final data = json['data'];

      if (data is! Map) {
        return const NetworkFailure<Employee>(
          'The employee API returned an unexpected response.',
        );
      }

      return Success(_employeeFromJson(Map<String, dynamic>.from(data)));
    } on ApiException catch (error, stackTrace) {
      if (error.statusCode == 422) {
        return ValidationFailure<Employee>(
          error.message,
          fieldErrors: _fieldErrors(error.body),
          cause: error,
          stackTrace: stackTrace,
        );
      }

      return NetworkFailure<Employee>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      return NetworkFailure<Employee>(
        'Unable to save the employee.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return const ValidationFailure<void>(
        'Employee id is required.',
        fieldErrors: {'id': 'Employee id is required.'},
      );
    }

    try {
      await apiClient.delete('/api/v1/employees/$normalizedId');

      return const Success<void>(null);
    } on ApiException catch (error, stackTrace) {
      if (error.statusCode == 404) {
        return const Success<void>(null);
      }

      return NetworkFailure<void>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      return NetworkFailure<void>(
        'Unable to delete the employee.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Employee _employeeFromJson(Map<String, dynamic> json) {
    final organizationId = json['organizationId']?.toString() ?? '';
    final branchId = json['branchId']?.toString() ?? '';
    final departmentId = json['departmentId']?.toString() ?? '';

    return Employee(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      organizationId: organizationId,
      branchId: branchId,
      department: Department(
        id: departmentId,
        code: '',
        name: '',
        organizationId: organizationId,
        branchId: branchId,
      ),
      teamId: json['teamId']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      active: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _employeeToJson(Employee employee) {
    return {
      'organization_id': _nullable(employee.organizationId),
      'branch_id': _nullable(employee.branchId),
      'department_id': _nullable(employee.department.id),
      'team_id': _nullable(employee.teamId),
      'employee_code': employee.employeeCode.trim(),
      'first_name': employee.firstName.trim(),
      'last_name': employee.lastName.trim(),
      'nickname': _nullable(employee.nickname),
      'position': _nullable(employee.position),
      'email': _nullable(employee.email),
      'phone': _nullable(employee.phone),
      'is_active': employee.active,
    };
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  Map<String, String> _fieldErrors(Object? body) {
    if (body is! Map) {
      return const <String, String>{};
    }

    final errors = body['errors'];

    if (errors is! Map) {
      return const <String, String>{};
    }

    final result = <String, String>{};

    for (final entry in errors.entries) {
      final value = entry.value;

      if (value is List && value.isNotEmpty) {
        result[entry.key.toString()] = value.first.toString();
      } else if (value != null) {
        result[entry.key.toString()] = value.toString();
      }
    }

    return result;
  }

  int _compareEmployees(Employee left, Employee right) {
    final nameComparison = left.fullName.toLowerCase().compareTo(
      right.fullName.toLowerCase(),
    );

    if (nameComparison != 0) {
      return nameComparison;
    }

    return left.employeeCode.toLowerCase().compareTo(
      right.employeeCode.toLowerCase(),
    );
  }
}

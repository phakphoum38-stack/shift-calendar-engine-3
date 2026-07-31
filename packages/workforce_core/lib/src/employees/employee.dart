enum EmployeeStatus { active, inactive, archived }

final class Employee {
  Employee({
    required this.id,
    required this.organizationId,
    required String employeeCode,
    required String displayName,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.departmentId,
    this.email,
    this.phoneNumber,
    this.deletedAt,
  }) : employeeCode = _required(employeeCode, 'employeeCode'),
       displayName = _required(displayName, 'displayName') {
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'must be at least 1');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt');
    }
    if (status == EmployeeStatus.archived && deletedAt == null) {
      throw ArgumentError('archived employees require deletedAt');
    }
  }

  final String id;
  final String organizationId;
  final String? departmentId;
  final String employeeCode;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final EmployeeStatus status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isActive => status == EmployeeStatus.active && deletedAt == null;

  Employee copyWith({
    String? organizationId,
    String? departmentId,
    String? employeeCode,
    String? displayName,
    String? email,
    String? phoneNumber,
    EmployeeStatus? status,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDepartment = false,
    bool clearEmail = false,
    bool clearPhoneNumber = false,
    bool clearDeletedAt = false,
  }) {
    return Employee(
      id: id,
      organizationId: organizationId ?? this.organizationId,
      departmentId: clearDepartment ? null : departmentId ?? this.departmentId,
      employeeCode: employeeCode ?? this.employeeCode,
      displayName: displayName ?? this.displayName,
      email: clearEmail ? null : email ?? this.email,
      phoneNumber: clearPhoneNumber ? null : phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  static String _required(String value, String field) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) => other is Employee && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

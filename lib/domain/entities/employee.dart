import 'department.dart';

/// Person who may receive canonical shift assignments.
class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.position,
    this.nickname = '',
    this.active = true,
  });

  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String nickname;
  final Department department;
  final String position;
  final bool active;

  String get fullName => '$firstName $lastName'.trim();

  String get displayName =>
      nickname.trim().isEmpty ? fullName : '$fullName ($nickname)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          id == other.id &&
          employeeCode == other.employeeCode &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          nickname == other.nickname &&
          department == other.department &&
          position == other.position &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
    id,
    employeeCode,
    firstName,
    lastName,
    nickname,
    department,
    position,
    active,
  );
}

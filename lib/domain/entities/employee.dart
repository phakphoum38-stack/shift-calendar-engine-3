import 'calendar_profile.dart';
import 'department.dart';
import 'employment.dart';
import 'source_profile.dart';

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
    this.organizationId = '',
    this.branchId = '',
    this.teamId = '',
    this.email = '',
    this.phone = '',
    this.employment = const Employment(),
    this.calendarProfile = const CalendarProfile(),
    this.sourceProfile = const SourceProfile(),
    this.active = true,
  });

  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String nickname;
  final String organizationId;
  final String branchId;
  final Department department;
  final String teamId;
  final String position;
  final String email;
  final String phone;
  final Employment employment;
  final CalendarProfile calendarProfile;
  final SourceProfile sourceProfile;
  final bool active;

  String get fullName => '$firstName $lastName'.trim();

  String get displayName =>
      nickname.trim().isEmpty ? fullName : '$fullName ($nickname)';

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? firstName,
    String? lastName,
    String? nickname,
    String? organizationId,
    String? branchId,
    Department? department,
    String? teamId,
    String? position,
    String? email,
    String? phone,
    Employment? employment,
    CalendarProfile? calendarProfile,
    SourceProfile? sourceProfile,
    bool? active,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      department: department ?? this.department,
      teamId: teamId ?? this.teamId,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employment: employment ?? this.employment,
      calendarProfile: calendarProfile ?? this.calendarProfile,
      sourceProfile: sourceProfile ?? this.sourceProfile,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          id == other.id &&
          employeeCode == other.employeeCode &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          nickname == other.nickname &&
          organizationId == other.organizationId &&
          branchId == other.branchId &&
          department == other.department &&
          teamId == other.teamId &&
          position == other.position &&
          email == other.email &&
          phone == other.phone &&
          employment == other.employment &&
          calendarProfile == other.calendarProfile &&
          sourceProfile == other.sourceProfile &&
          active == other.active;

  @override
  int get hashCode => Object.hashAll([
        id,
        employeeCode,
        firstName,
        lastName,
        nickname,
        organizationId,
        branchId,
        department,
        teamId,
        position,
        email,
        phone,
        employment,
        calendarProfile,
        sourceProfile,
        active,
      ]);
}

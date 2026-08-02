import '../../../domain/entities/branch.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/organization.dart';
import '../../../domain/entities/team.dart';

abstract final class OrganizationJsonCodec {
  static Map<String, Object?> encodeOrganization(Organization value) => {
    'id': value.id,
    'code': value.code,
    'name': value.name,
    'displayName': value.displayName,
    'timeZone': value.timeZone,
    'locale': value.locale,
    'countryCode': value.countryCode,
    'active': value.active,
  };

  static Organization decodeOrganization(Map<String, Object?> json) =>
      Organization(
        id: _string(json, 'id'),
        code: _string(json, 'code'),
        name: _string(json, 'name'),
        displayName: _string(json, 'displayName'),
        timeZone: _string(json, 'timeZone', fallback: 'Asia/Bangkok'),
        locale: _string(json, 'locale', fallback: 'th'),
        countryCode: _string(json, 'countryCode', fallback: 'TH'),
        active: _boolean(json, 'active'),
      );

  static Map<String, Object?> encodeBranch(Branch value) => {
    'id': value.id,
    'organizationId': value.organizationId,
    'code': value.code,
    'name': value.name,
    'address': value.address,
    'timeZone': value.timeZone,
    'active': value.active,
  };

  static Branch decodeBranch(Map<String, Object?> json) => Branch(
    id: _string(json, 'id'),
    organizationId: _string(json, 'organizationId'),
    code: _string(json, 'code'),
    name: _string(json, 'name'),
    address: _string(json, 'address'),
    timeZone: _string(json, 'timeZone'),
    active: _boolean(json, 'active'),
  );

  static Map<String, Object?> encodeDepartment(Department value) => {
    'id': value.id,
    'organizationId': value.organizationId,
    'branchId': value.branchId,
    'parentDepartmentId': value.parentDepartmentId,
    'code': value.code,
    'name': value.name,
    'active': value.active,
  };

  static Department decodeDepartment(Map<String, Object?> json) => Department(
    id: _string(json, 'id'),
    organizationId: _string(json, 'organizationId'),
    branchId: _string(json, 'branchId'),
    parentDepartmentId: _string(json, 'parentDepartmentId'),
    code: _string(json, 'code'),
    name: _string(json, 'name'),
    active: _boolean(json, 'active'),
  );

  static Map<String, Object?> encodeTeam(Team value) => {
    'id': value.id,
    'departmentId': value.departmentId,
    'code': value.code,
    'name': value.name,
    'active': value.active,
  };

  static Team decodeTeam(Map<String, Object?> json) => Team(
    id: _string(json, 'id'),
    departmentId: _string(json, 'departmentId'),
    code: _string(json, 'code'),
    name: _string(json, 'name'),
    active: _boolean(json, 'active'),
  );

  static String _string(
    Map<String, Object?> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    return value is String ? value : fallback;
  }

  static bool _boolean(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is bool ? value : true;
  }
}

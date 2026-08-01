import '../../../core/result/result.dart';
import '../../../domain/entities/branch.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/organization.dart';
import '../../../domain/entities/team.dart';
import '../../../domain/repositories/branch_repository.dart';
import '../../../domain/repositories/department_repository.dart';
import '../../../domain/repositories/organization_repository.dart';
import '../../../domain/repositories/team_repository.dart';
import 'organization_json_codec.dart';
import 'shared_preferences_json_collection.dart';

final class SharedPreferencesOrganizationRepository
    implements OrganizationRepository {
  SharedPreferencesOrganizationRepository(this._store);

  final SharedPreferencesJsonCollection _store;

  @override
  Future<Result<void>> delete(String id) => _guard(() async {
    final records = _store.read()..removeWhere((item) => item['id'] == id);
    await _store.write(records);
  });

  @override
  Future<Result<List<Organization>>> findAll({bool activeOnly = true}) =>
      _guard(() async {
        final values = _store.read().map(
          OrganizationJsonCodec.decodeOrganization,
        );
        return values
            .where((item) => !activeOnly || item.active)
            .toList(growable: false);
      });

  @override
  Future<Result<Organization?>> findById(String id) => _guard(() async {
    for (final record in _store.read()) {
      if (record['id'] == id) {
        return OrganizationJsonCodec.decodeOrganization(record);
      }
    }
    return null;
  });

  @override
  Future<Result<Organization>> save(Organization organization) =>
      _guard(() async {
        final records = _store.read();
        _upsert(
          records,
          organization.id,
          OrganizationJsonCodec.encodeOrganization(organization),
        );
        await _store.write(records);
        return organization;
      });
}

final class SharedPreferencesBranchRepository implements BranchRepository {
  SharedPreferencesBranchRepository(this._store);

  final SharedPreferencesJsonCollection _store;

  @override
  Future<Result<void>> delete(String id) => _guard(() async {
    final records = _store.read()..removeWhere((item) => item['id'] == id);
    await _store.write(records);
  });

  @override
  Future<Result<List<Branch>>> findAll({
    String? organizationId,
    bool activeOnly = true,
  }) => _guard(() async {
    final values = _store.read().map(OrganizationJsonCodec.decodeBranch);
    return values
        .where(
          (item) =>
              (organizationId == null ||
                  item.organizationId == organizationId) &&
              (!activeOnly || item.active),
        )
        .toList(growable: false);
  });

  @override
  Future<Result<Branch?>> findById(String id) => _guard(() async {
    for (final record in _store.read()) {
      if (record['id'] == id) return OrganizationJsonCodec.decodeBranch(record);
    }
    return null;
  });

  @override
  Future<Result<Branch>> save(Branch branch) => _guard(() async {
    final records = _store.read();
    _upsert(records, branch.id, OrganizationJsonCodec.encodeBranch(branch));
    await _store.write(records);
    return branch;
  });
}

final class SharedPreferencesDepartmentRepository
    implements DepartmentRepository {
  SharedPreferencesDepartmentRepository(this._store);

  final SharedPreferencesJsonCollection _store;

  @override
  Future<Result<void>> delete(String id) => _guard(() async {
    final records = _store.read()..removeWhere((item) => item['id'] == id);
    await _store.write(records);
  });

  @override
  Future<Result<List<Department>>> findAll({
    String? organizationId,
    String? branchId,
    bool activeOnly = true,
  }) => _guard(() async {
    final values = _store.read().map(OrganizationJsonCodec.decodeDepartment);
    return values
        .where(
          (item) =>
              (organizationId == null ||
                  item.organizationId == organizationId) &&
              (branchId == null || item.branchId == branchId) &&
              (!activeOnly || item.active),
        )
        .toList(growable: false);
  });

  @override
  Future<Result<Department?>> findById(String id) => _guard(() async {
    for (final record in _store.read()) {
      if (record['id'] == id) {
        return OrganizationJsonCodec.decodeDepartment(record);
      }
    }
    return null;
  });

  @override
  Future<Result<Department>> save(Department department) => _guard(() async {
    final records = _store.read();
    _upsert(
      records,
      department.id,
      OrganizationJsonCodec.encodeDepartment(department),
    );
    await _store.write(records);
    return department;
  });
}

final class SharedPreferencesTeamRepository implements TeamRepository {
  SharedPreferencesTeamRepository({
    required this._teamStore,
    required this._departmentStore,
  });

  final SharedPreferencesJsonCollection _teamStore;
  final SharedPreferencesJsonCollection _departmentStore;

  @override
  Future<Result<void>> delete(String id) => _guard(() async {
    final records = _teamStore.read()..removeWhere((item) => item['id'] == id);
    await _teamStore.write(records);
  });

  @override
  Future<Result<List<Team>>> findAll({
    String? organizationId,
    String? branchId,
    String? departmentId,
    bool activeOnly = true,
  }) => _guard(() async {
    final allowedDepartments = _departmentStore
        .read()
        .map(OrganizationJsonCodec.decodeDepartment)
        .where(
          (item) =>
              (organizationId == null ||
                  item.organizationId == organizationId) &&
              (branchId == null || item.branchId == branchId),
        )
        .map((item) => item.id)
        .toSet();
    final values = _teamStore.read().map(OrganizationJsonCodec.decodeTeam);
    return values
        .where(
          (item) =>
              (departmentId == null || item.departmentId == departmentId) &&
              ((organizationId == null && branchId == null) ||
                  allowedDepartments.contains(item.departmentId)) &&
              (!activeOnly || item.active),
        )
        .toList(growable: false);
  });

  @override
  Future<Result<Team?>> findById(String id) => _guard(() async {
    for (final record in _teamStore.read()) {
      if (record['id'] == id) return OrganizationJsonCodec.decodeTeam(record);
    }
    return null;
  });

  @override
  Future<Result<Team>> save(Team team) => _guard(() async {
    final records = _teamStore.read();
    _upsert(records, team.id, OrganizationJsonCodec.encodeTeam(team));
    await _teamStore.write(records);
    return team;
  });
}

void _upsert(
  List<Map<String, Object?>> records,
  String id,
  Map<String, Object?> replacement,
) {
  final index = records.indexWhere((item) => item['id'] == id);
  if (index < 0) {
    records.add(replacement);
  } else {
    records[index] = replacement;
  }
}

Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
  try {
    return Success(await operation());
  } catch (error, stackTrace) {
    return PersistenceFailure(
      'Organization persistence operation failed.',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}

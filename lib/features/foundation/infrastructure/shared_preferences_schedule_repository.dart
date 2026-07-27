import '../../../core/result/result.dart';
import '../../../core/storage/atomic_string_store.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/repositories/schedule_repository.dart';
import 'canonical_json_codec.dart';

/// Atomic production repository for the canonical schedule.
class SharedPreferencesScheduleRepository implements ScheduleRepository {
  SharedPreferencesScheduleRepository({
    AtomicStringStore? store,
    this.codec = const CanonicalJsonCodec(),
  }) : store =
           store ?? AtomicStringStore(keyPrefix: 'sce3.canonical_schedule.v1');

  final AtomicStringStore store;
  final CanonicalJsonCodec codec;

  @override
  Future<Result<Schedule?>> loadActive() async {
    try {
      final payload = await store.read();
      return Success(payload == null ? null : codec.decodeSchedule(payload));
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not load the canonical schedule.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<Schedule>> save(Schedule schedule) async {
    try {
      if (schedule.id.trim().isEmpty || schedule.name.trim().isEmpty) {
        return const ValidationFailure(
          'Schedule identity and name are required.',
        );
      }
      await store.write(codec.encodeSchedule(schedule));
      return Success(schedule);
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not save the canonical schedule.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

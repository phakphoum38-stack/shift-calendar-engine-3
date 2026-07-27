import '../../core/result/result.dart';
import '../entities/schedule.dart';

/// Persistence boundary for the canonical schedule aggregate.
abstract interface class ScheduleRepository {
  Future<Result<Schedule?>> loadActive();

  Future<Result<Schedule>> save(Schedule schedule);
}

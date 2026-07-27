import '../../../core/result/result.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/repositories/schedule_repository.dart';

/// Process-local schedule store used until durable Phase 2 storage is wired.
class MemoryScheduleRepository implements ScheduleRepository {
  MemoryScheduleRepository({Schedule? initialSchedule})
    : _schedule = initialSchedule;

  Schedule? _schedule;

  @override
  Future<Result<Schedule?>> loadActive() async => Success(_schedule);

  @override
  Future<Result<Schedule>> save(Schedule schedule) async {
    _schedule = schedule;
    return Success(schedule);
  }
}

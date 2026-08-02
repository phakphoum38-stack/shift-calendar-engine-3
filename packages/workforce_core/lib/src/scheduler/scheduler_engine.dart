import 'scheduler_request.dart';
import 'scheduler_result.dart';

abstract interface class SchedulerEngine {
  SchedulerResult generate(SchedulerRequest request);
}

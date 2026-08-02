import 'package:workforce_core/workforce_core.dart';

import '../features/ai_scheduler/application/ai_scheduler_controller.dart';
import '../features/ai_scheduler/application/ai_scheduler_request_factory.dart';
import 'app_dependencies.dart';

/// Composition helpers for the AI scheduler feature.
extension AiSchedulerDependencies on AppDependencies {
  AiSchedulerController createAiSchedulerController(
    AiSchedulerAssistant assistant,
  ) {
    return AiSchedulerController(assistant: assistant);
  }

  /// Creates the production-safe deterministic scheduler composition.
  ///
  /// The assistant only generates a proposal. Persistence and publishing stay
  /// outside this composition boundary and require an explicit user action.
  AiSchedulerController createDefaultAiSchedulerController() {
    return createAiSchedulerController(const DeterministicAiScheduler());
  }

  AiSchedulerRequestFactory createAiSchedulerRequestFactory() {
    return const AiSchedulerRequestFactory();
  }
}

import 'package:flutter/material.dart';
import 'package:workforce_core/workforce_core.dart';

import '../application/ai_scheduler_controller.dart';
import 'ai_scheduler_page.dart';

/// Binds the AI scheduler application controller to the presentation page.
///
/// Scheduling decisions remain in workforce_core. This widget only translates
/// controller state into loading, failure, proposal, and rejection UI states.
class AiSchedulerWorkspace extends StatelessWidget {
  const AiSchedulerWorkspace({
    required this.controller,
    required this.requestFactory,
    this.onPreview,
    this.onCompare,
    this.onApprove,
    super.key,
  });

  final AiSchedulerController controller;
  final SchedulerRequest Function() requestFactory;
  final VoidCallback? onPreview;
  final VoidCallback? onCompare;
  final VoidCallback? onApprove;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AiSchedulerPage(
          proposal: controller.proposal,
          loading: controller.loading,
          errorMessage: controller.error?.toString(),
          onGenerate: controller.loading
              ? null
              : () => controller.generate(requestFactory()),
          onPreview: onPreview,
          onCompare: onCompare,
          onApprove: onApprove,
          onReject: controller.proposal == null ? null : controller.reject,
        );
      },
    );
  }
}

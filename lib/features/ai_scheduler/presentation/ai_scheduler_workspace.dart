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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final error = controller.error;

        return Stack(
          children: [
            AiSchedulerPage(
              proposal: controller.proposal,
              onGenerate: controller.loading
                  ? null
                  : () => controller.generate(requestFactory()),
              onPreview: onPreview,
              onCompare: onCompare,
              onApprove: onApprove,
              onReject: controller.proposal == null ? null : controller.reject,
            ),
            if (error != null)
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Unable to generate proposal: $error',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (controller.loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}

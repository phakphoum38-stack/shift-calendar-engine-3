import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/schedule.dart';
import '../../shift_templates/application/shift_template_controller.dart';
import '../application/ai_scheduler_controller.dart';
import '../application/ai_scheduler_request_provider.dart';
import 'ai_scheduler_shift_input_controller.dart';
import 'ai_scheduler_shift_template_catalog.dart';
import 'ai_scheduler_workspace.dart';

/// Owns the presentation-only lifecycle required by the AI Scheduler screen.
///
/// Canonical shift-template persistence remains in [ShiftTemplateController].
/// This runtime loads that catalog once, exposes only active deterministic
/// templates, and owns explicit requested-shift input until the screen closes.
class AiSchedulerRuntime extends StatefulWidget {
  const AiSchedulerRuntime({
    required this.controller,
    required this.requestProvider,
    required this.schedule,
    required this.shiftTemplateControllerFactory,
    this.onPreview,
    this.onCompare,
    this.onApprove,
    super.key,
  });

  final AiSchedulerController controller;
  final AiSchedulerRequestProvider requestProvider;
  final Schedule schedule;
  final ShiftTemplateController Function() shiftTemplateControllerFactory;
  final VoidCallback? onPreview;
  final VoidCallback? onCompare;
  final VoidCallback? onApprove;

  @override
  State<AiSchedulerRuntime> createState() => _AiSchedulerRuntimeState();
}

class _AiSchedulerRuntimeState extends State<AiSchedulerRuntime> {
  late final ShiftTemplateController shiftTemplateController;
  late final AiSchedulerShiftInputController shiftInputController;

  @override
  void initState() {
    super.initState();
    shiftTemplateController = widget.shiftTemplateControllerFactory();
    shiftInputController = AiSchedulerShiftInputController();
    unawaited(shiftTemplateController.load());
  }

  @override
  void dispose() {
    shiftInputController.dispose();
    shiftTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: shiftTemplateController,
      builder: (context, _) {
        return AiSchedulerWorkspace(
          controller: widget.controller,
          requestProvider: widget.requestProvider,
          schedule: widget.schedule,
          shiftInputController: shiftInputController,
          shiftTemplates: AiSchedulerShiftTemplateCatalog.active(
            shiftTemplateController.templates,
          ),
          onPreview: widget.onPreview,
          onCompare: widget.onCompare,
          onApprove: widget.onApprove,
        );
      },
    );
  }
}

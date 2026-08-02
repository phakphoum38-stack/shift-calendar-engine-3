import 'package:flutter/material.dart';

import '../../../domain/entities/schedule.dart';
import '../application/ai_scheduler_controller.dart';
import '../application/ai_scheduler_request_factory.dart';
import '../application/ai_scheduler_request_provider.dart';
import 'ai_scheduler_page.dart';

/// Binds canonical request loading and scheduler state to the presentation page.
///
/// Requested shifts are supplied explicitly by the caller. This widget never
/// derives new work from existing assignments or presentation state.
class AiSchedulerWorkspace extends StatefulWidget {
  const AiSchedulerWorkspace({
    required this.controller,
    required this.requestProvider,
    required this.schedule,
    this.requestedShifts = const [],
    this.onPreview,
    this.onCompare,
    this.onApprove,
    super.key,
  });

  final AiSchedulerController controller;
  final AiSchedulerRequestProvider requestProvider;
  final Schedule schedule;
  final List<AiSchedulerShiftInput> requestedShifts;
  final VoidCallback? onPreview;
  final VoidCallback? onCompare;
  final VoidCallback? onApprove;

  @override
  State<AiSchedulerWorkspace> createState() => _AiSchedulerWorkspaceState();
}

class _AiSchedulerWorkspaceState extends State<AiSchedulerWorkspace> {
  Object? requestError;
  bool buildingRequest = false;

  bool get loading => buildingRequest || widget.controller.loading;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return AiSchedulerPage(
          proposal: widget.controller.proposal,
          loading: loading,
          errorMessage: _errorMessage,
          onGenerate: loading ? null : _generate,
          onPreview: widget.onPreview,
          onCompare: widget.onCompare,
          onApprove: widget.onApprove,
          onReject: widget.controller.proposal == null
              ? null
              : widget.controller.reject,
        );
      },
    );
  }

  String? get _errorMessage {
    final error = requestError ?? widget.controller.error;
    return error?.toString();
  }

  Future<void> _generate() async {
    if (loading) {
      return;
    }

    setState(() {
      buildingRequest = true;
      requestError = null;
    });

    try {
      final request = await widget.requestProvider.build(
        requestedShifts: widget.requestedShifts,
        schedule: widget.schedule,
      );

      if (mounted) {
        widget.controller.generate(request);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          requestError = error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          buildingRequest = false;
        });
      }
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:workforce_core/workforce_core.dart';

import 'ai_schedule_proposal_mapper.dart';
import 'ai_scheduler_view_data.dart';

enum AiSchedulerStatus { idle, generating, ready, failure }

final class AiSchedulerController extends ChangeNotifier {
  AiSchedulerController({
    required AiSchedulerAssistant assistant,
    this.mapper = const AiScheduleProposalMapper(),
  }) : _assistant = assistant;

  final AiSchedulerAssistant _assistant;
  final AiScheduleProposalMapper mapper;

  AiSchedulerStatus _status = AiSchedulerStatus.idle;
  AiSchedulerViewData? _proposal;
  Object? _error;

  AiSchedulerStatus get status => _status;
  AiSchedulerViewData? get proposal => _proposal;
  Object? get error => _error;
  bool get loading => _status == AiSchedulerStatus.generating;

  void generate(SchedulerRequest request) {
    _status = AiSchedulerStatus.generating;
    _error = null;
    notifyListeners();

    try {
      final canonicalProposal = _assistant.propose(request);
      _proposal = mapper.map(canonicalProposal);
      _status = AiSchedulerStatus.ready;
    } on Object catch (error) {
      _proposal = null;
      _error = error;
      _status = AiSchedulerStatus.failure;
    }

    notifyListeners();
  }

  void reject() {
    _proposal = null;
    _error = null;
    _status = AiSchedulerStatus.idle;
    notifyListeners();
  }
}

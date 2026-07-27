import 'package:flutter/material.dart';

import '../../../core/widgets/feature_empty_state.dart';
import '../../../l10n/l10n.dart';

/// Report workspace entry point with an honest empty state.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) => FeatureEmptyState(
    icon: Icons.assessment_outlined,
    title: context.l10n.noReports,
    message: context.l10n.reportDescription,
  );
}

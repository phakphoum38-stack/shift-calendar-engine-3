import 'package:flutter/material.dart';

import '../../../core/widgets/feature_empty_state.dart';
import '../../../l10n/l10n.dart';

/// Exchange workspace entry point with an honest empty state.
class ExchangePage extends StatelessWidget {
  const ExchangePage({super.key});

  @override
  Widget build(BuildContext context) => FeatureEmptyState(
    icon: Icons.swap_horiz_outlined,
    title: context.l10n.noRequests,
    message: context.l10n.exchangeDescription,
  );
}

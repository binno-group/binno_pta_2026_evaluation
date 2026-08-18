import 'package:binno_app/design_system/components/binno_reference_components.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BinnoHeroHeader(
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#A-4821',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.72),
                          ),
                    ),
                    const SizedBox(height: 72),
                    Text(
                      l10n.activeOrderTitle,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: colors.onPrimary),
                    ),
                    const SizedBox(height: BinnoSpacing.x3),
                    Text(
                      l10n.activeOrderSubtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.72),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(BinnoSpacing.x5),
            sliver: SliverList.list(
              children: [
                _TimelineStep(label: l10n.orderConfirmedStatus, complete: true),
                _TimelineStep(
                  label: l10n.paymentAcceptedStatus,
                  complete: true,
                ),
                _TimelineStep(label: l10n.activeOrderTitle, active: true),
                _TimelineStep(label: l10n.deliveredStatus),
                const SizedBox(height: BinnoSpacing.x8),
                const Divider(),
                const SizedBox(height: BinnoSpacing.x5),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      child: const Text('MS'),
                    ),
                    const SizedBox(width: BinnoSpacing.x3),
                    Expanded(
                      child: Text(
                        "Metall Savdo · 47-do'kon",
                        // l10n:ignore reference fixture
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.chatAction,
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: BinnoSpacing.x10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(l10n.chatAction),
                      ),
                    ),
                    const SizedBox(width: BinnoSpacing.x3),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(l10n.reportProblemAction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    this.complete = false,
    this.active = false,
  });

  final String label;
  final bool complete;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = complete
        ? colors.tertiary
        : active
            ? colors.primary
            : colors.outline;
    return SizedBox(
      height: BinnoSpacing.x16,
      child: Row(
        children: [
          Container(
            width: active ? 20 : 14,
            height: active ? 20 : 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: complete ? color : colors.surface,
              border: Border.all(color: color, width: active ? 3 : 2),
            ),
          ),
          const SizedBox(width: BinnoSpacing.x4),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        active || complete ? null : colors.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

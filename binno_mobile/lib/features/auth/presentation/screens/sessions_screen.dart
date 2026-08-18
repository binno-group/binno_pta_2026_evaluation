import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/components/binno_empty_state.dart';
import 'package:binno_app/design_system/components/binno_error_state.dart';
import 'package:binno_app/design_system/patterns/binno_skeleton.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sessionsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activeSessionsTitle)),
      body: state.when(
        loading: () => const _SessionsLoading(),
        error: (error, stackTrace) => BinnoErrorState(
          title: l10n.genericErrorTitle,
          explanation: l10n.genericErrorExplanation,
          actionLabel: l10n.retryAction,
          onRetry: () => ref.read(sessionsControllerProvider.notifier).load(),
        ),
        data: (sessions) => sessions.isEmpty
            ? BinnoEmptyState(
                title: l10n.sessionsEmptyTitle,
                explanation: l10n.emptyExplanation,
              )
            : _SessionsList(sessions: sessions),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(BinnoSpacing.x4),
        child: BinnoButton(
          label: l10n.logoutAllAction,
          onPressed: () =>
              ref.read(sessionsControllerProvider.notifier).logoutAll(),
        ),
      ),
    );
  }
}

class _SessionsLoading extends StatelessWidget {
  const _SessionsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(BinnoSpacing.x4),
      child: Column(
        children: [
          BinnoSkeleton(width: double.infinity, height: BinnoSpacing.x16),
          SizedBox(height: BinnoSpacing.x3),
          BinnoSkeleton(width: double.infinity, height: BinnoSpacing.x16),
        ],
      ),
    );
  }
}

class _SessionsList extends ConsumerWidget {
  const _SessionsList({required this.sessions});

  final List<ActiveSession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMd('uz');
    return ListView.separated(
      padding: const EdgeInsets.all(BinnoSpacing.x4),
      itemCount: sessions.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: BinnoSpacing.x2),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return ListTile(
          minTileHeight: BinnoSpacing.x16,
          leading: const Icon(Icons.devices_outlined),
          title: Text(session.deviceLabel),
          subtitle: Text(
            session.isCurrent
                ? l10n.currentSession
                : date.format(session.lastUsedAt),
          ),
          trailing: session.isCurrent
              ? null
              : IconButton(
                  tooltip: l10n.revokeSessionAction,
                  onPressed: () => ref
                      .read(sessionsControllerProvider.notifier)
                      .revoke(session.id),
                  icon: const Icon(Icons.logout),
                ),
        );
      },
    );
  }
}

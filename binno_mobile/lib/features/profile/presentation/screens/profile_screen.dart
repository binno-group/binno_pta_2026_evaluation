import 'package:binno_app/app/router/app_router.dart';
import 'package:binno_app/design_system/components/binno_reference_components.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BinnoHeroHeader(
            height: 260,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.72),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.profileName,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: colors.onPrimary),
                  ),
                  Text(
                    l10n.profilePhone,
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
          Padding(
            padding: const EdgeInsets.all(BinnoSpacing.x5),
            child: Column(
              children: [
                BinnoSurfaceCard(
                  onTap: () {},
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.surface,
                        child: const Icon(Icons.swap_horiz),
                      ),
                      const SizedBox(width: BinnoSpacing.x4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.roleSwitcherTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              l10n.availableRoles,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const SizedBox(height: BinnoSpacing.x3),
                BinnoSurfaceCard(
                  onTap: () => context.push(AppRoutes.sessions),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.surface,
                        child: const Icon(Icons.security_outlined),
                      ),
                      const SizedBox(width: BinnoSpacing.x4),
                      Expanded(
                        child: Text(
                          l10n.activeSessionsTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

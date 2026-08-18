import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../app/presentation/bloc/theme_cubit.dart';
import '../../../app/presentation/widgets/widgets.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// Profil tabi.
class BuyerProfilePage extends StatelessWidget {
  const BuyerProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    // Yangicha dizayndagi app bottom sheet (§17).
    final ok = await showAppConfirmSheet(
      context,
      icon: Icons.logout_rounded,
      title: 'Chiqasizmi?',
      message: 'Faol buyurtmalaringiz saqlanadi. Qayta kirganingizda '
          'ular joyida turadi.',
      confirmLabel: 'Chiqish',
      destructive: true,
    );
    if (ok && context.mounted) {
      binnoSnack(context, 'Hisobdan chiqildi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = MockData.addresses.first;

    return BinnoScreen(
      background: AppColors.surface,
      child: Column(
        children: [
          BinnoTabHeader(
            title: 'Profil',
            // Notification o'rniga edit ikonkasi (§16) — ma'lumot tahrirlash.
            trailing: _EditButton(
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.navy100,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 104,
                        height: 104,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.navy950,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'AK',
                          style: AppText.display(36, color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MockData.buyerName,
                      style: AppText.display(28),
                    ),
                    const SizedBox(height: 4),
                    Text(MockData.buyerPhone, style: AppText.meta(size: 14)),
                  ],
                ),
                const SizedBox(height: 28),
                _ProfileRow(
                  icon: Icons.place_outlined,
                  title: 'Yetkazish manzili',
                  subtitle: address.line,
                  onTap: () => context.push(AppRoutes.addresses),
                ),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: Icons.business_outlined,
                  title: 'Yuridik ma\'lumotlar',
                  subtitle: 'STIR ${MockData.buyerTin}',
                  onTap: () => context.push(AppRoutes.legalInfo),
                ),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: Icons.language_rounded,
                  title: 'Til',
                  trailingText: 'O\'zbekcha',
                  onTap: () => context.push(AppRoutes.language),
                ),
                const SizedBox(height: 12),
                // Mavzu almashtirgichi (§10) — default light.
                const _ThemeRow(),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: Icons.add_box_outlined,
                  title: 'Mahsulot so\'rash',
                  subtitle: 'Katalogda yo\'q mahsulotni so\'rang',
                  onTap: () => context.push(AppRoutes.productRequest),
                ),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: Icons.help_outline_rounded,
                  title: 'Yordam va shartlar',
                  onTap: () => context.push(AppRoutes.help),
                ),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: Icons.logout_rounded,
                  title: 'Chiqish',
                  destructive: true,
                  onTap: () => _confirmLogout(context),
                ),
                const SizedBox(height: 20),
                Text(
                  'To\'lov to\'g\'ridan-to\'g\'ri sotuvchi hisobiga o\'tadi. '
                  'BINNO pul ushlamaydi.',
                  textAlign: TextAlign.center,
                  style: AppText.note(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.ink;

    return BinnoCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        children: [
          BinnoIconChip(
            icon: icon,
            background: destructive ? AppColors.dangerBg : AppColors.navy100,
            color: destructive ? AppColors.danger : AppColors.navy950,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.s(15, FontWeight.w600, color: color),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta(),
                  ),
                ],
              ],
            ),
          ),
          if (trailingText != null) ...[
            const SizedBox(width: 10),
            Text(trailingText!, style: AppText.meta(size: 13)),
          ],
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: destructive ? AppColors.danger : AppColors.ink3,
          ),
        ],
      ),
    );
  }
}

/// The edit button in the profile header.
class _EditButton extends StatelessWidget {
  const _EditButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppDimens.shadowCard,
      ),
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.edit_outlined,
              size: 21,
              color: AppColors.navy950,
            ),
          ),
        ),
      ),
    );
  }
}

/// The theme (light/dark) toggle row.
class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDark;

    return BinnoCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      onTap: () => context.read<ThemeCubit>().toggle(),
      child: Row(
        children: [
          BinnoIconChip(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            background: AppColors.navy100,
            color: AppColors.navy950,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qorong\'i mavzu',
                  style: AppText.s(15, FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  isDark ? 'Yoqilgan' : 'O\'chirilgan',
                  style: AppText.meta(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppSwitch(
            value: isDark,
            onChanged: (v) => context.read<ThemeCubit>().setDark(v),
          ),
        ],
      ),
    );
  }
}

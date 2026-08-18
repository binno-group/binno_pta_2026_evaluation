import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/phone_caller_service.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_shell.dart';
import '../../../shared/widgets/binno_states.dart';

/// Help and terms.
///
/// The answers restate the product rules: no escrow, no ETA, stock is a
/// claim, refunds are the seller's obligation. The tone is calm and
/// blame-free.
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int? _open = 0;

  static const _supportPhone = '+998712000000';

  Future<void> _call() async {
    final ok = await sl<PhoneCallerService>().callDirect(_supportPhone);
    if (!mounted || ok) return;
    binnoSnack(context, 'Qo\'ng\'iroqni boshlab bo\'lmadi: $_supportPhone');
  }

  Future<void> _openUrl(String url) async {
    final ok = await sl<UrlLauncherService>().launchInBrowser(url);
    if (!mounted || ok) return;
    binnoSnack(context, 'Havolani ochib bo\'lmadi: $url');
  }

  @override
  Widget build(BuildContext context) {
    final topics = MockData.helpTopics;

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoPageHeader(
            title: 'Yordam',
            subtitle: 'Ko\'p beriladigan savollar va shartlar',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                const BinnoSoftCard(
                  child: Text(
                    'To\'lov to\'g\'ridan-to\'g\'ri sotuvchi hisobiga '
                    'o\'tadi. BINNO pul ushlamaydi.',
                    style: TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                for (var i = 0; i < topics.length; i++) ...[
                  if (i != 0) const BinnoHairline(),
                  _FaqRow(
                    topic: topics[i],
                    open: _open == i,
                    onTap: () => setState(() => _open = _open == i ? null : i),
                  ),
                ],
                const SizedBox(height: 24),
                const BinnoHairline(),
                const SizedBox(height: 8),
                BinnoSettingsRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Operatorga yozish',
                  subtitle: 'Ish vaqti: 09:00–18:00, dushanba–shanba',
                  onTap: () => context.push(AppRoutes.chat),
                ),
                BinnoSettingsRow(
                  icon: Icons.call_outlined,
                  title: 'Qo\'ng\'iroq qilish',
                  subtitle: '+998 71 200 00 00',
                  onTap: _call,
                ),
                BinnoSettingsRow(
                  icon: Icons.description_outlined,
                  title: 'Ommaviy oferta',
                  subtitle: 'Foydalanish shartlari',
                  onTap: () => _openUrl('https://binno.uz/oferta'),
                ),
                BinnoSettingsRow(
                  icon: Icons.shield_outlined,
                  title: 'Maxfiylik siyosati',
                  onTap: () => _openUrl('https://binno.uz/privacy'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Solution Labs MChJ · STIR 313 086 534\nBINNO v0.1.0',
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

class _FaqRow extends StatelessWidget {
  const _FaqRow({required this.topic, required this.open, this.onTap});

  final MockHelpTopic topic;
  final bool open;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    topic.question,
                    style: AppText.s(15, FontWeight.w600, height: 1.35),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: AppColors.ink3,
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: AppDimens.motionBase,
              crossFadeState: open
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 10, right: 34),
                child: Text(topic.answer, style: AppText.body(size: 13)),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

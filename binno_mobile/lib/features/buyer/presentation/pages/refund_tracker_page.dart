import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 12 · The refund tracker, in the overdue state.
///
/// Rule (§6.3, ADR-001): BINNO holds no money, so it **technically cannot**
/// perform the refund. That is admitted honestly: "the seller's refund
/// obligation: 3 working days". Once overdue, a block lands at the owner
/// level.
class RefundTrackerPage extends StatefulWidget {
  const RefundTrackerPage({super.key});

  @override
  State<RefundTrackerPage> createState() => _RefundTrackerPageState();
}

class _RefundTrackerPageState extends State<RefundTrackerPage> {
  /// The buyer confirmed the money arrived; the dispute closes.
  bool _confirmed = false;

  /// Sent back to operator review.
  bool _escalated = false;

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          const BinnoBackBar(label: '${MockData.orderId} · qaytarish'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              children: [
                const BinnoAmountBlock(
                  eyebrow: 'Qaytariladi',
                  amount: MockData.refundAmount,
                ),
                const SizedBox(height: 14),
                if (_confirmed)
                  const BinnoBanner(
                    tone: BinnoBannerTone.success,
                    text: 'Nizo yopildi — pul kelib tushgani tasdiqlandi',
                  )
                else if (_escalated)
                  const BinnoBanner(
                    tone: BinnoBannerTone.warning,
                    text: 'Operator tekshiruvida — natija SMS orqali keladi',
                  )
                else
                  const BinnoBanner(
                    tone: BinnoBannerTone.danger,
                    text: 'Muddat o\'tdi — sotuvchining qaytarish '
                        'majburiyati: 3 ish kuni',
                  ),
                const SizedBox(height: 24),
                const BinnoHairline(),
                const SizedBox(height: 18),
                BinnoTimeline(
                  doneColor: AppColors.success,
                  stepGap: 20,
                  steps: [
                    const BinnoTimelineStep(
                      title: 'So\'raldi',
                      state: BinnoStepState.done,
                      trailing: '28-iyul, 14:20',
                    ),
                    const BinnoTimelineStep(
                      title: 'Sotuvchi kvitansiya yukladi',
                      subtitle: 'Payme · qismiy summa',
                      state: BinnoStepState.done,
                      trailing: '29-iyul',
                    ),
                    BinnoTimelineStep(
                      title: 'Operator tekshirmoqda',
                      subtitle: '4 ish soatigacha · natija SMS orqali keladi',
                      state: _confirmed
                          ? BinnoStepState.done
                          : BinnoStepState.current,
                    ),
                    BinnoTimelineStep(
                      title: 'Siz tasdiqladingiz',
                      state: _confirmed
                          ? BinnoStepState.done
                          : BinnoStepState.future,
                      trailing: _confirmed ? 'hozir' : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_confirmed)
            BinnoFooter(
              note: 'Nizo yopildi. Savol qolsa yordam bo\'limiga yozing.',
              children: [
                BinnoSecondaryButton(
                  label: 'Yopish',
                  strong: true,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            )
          else
            BinnoFooter(
              note: 'Pul kelib tushganini tasdiqlaganingizdan keyin nizo '
                  'yopiladi',
              children: [
                BinnoPrimaryButton(
                  label: 'Pulni oldim',
                  onPressed: () {
                    setState(() {
                      _confirmed = true;
                      _escalated = false;
                    });
                    binnoSnack(context, 'Tasdiqlandi — nizo yopildi');
                  },
                ),
                BinnoSecondaryButton(
                  label: _escalated ? 'Operator tekshirmoqda' : 'Pul kelmadi',
                  destructive: !_escalated,
                  onPressed: _escalated
                      ? null
                      : () {
                          setState(() => _escalated = true);
                          binnoSnack(
                            context,
                            'Operator tekshiruviga yuborildi — natija SMS '
                            'orqali keladi',
                          );
                        },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 11 · Rating, **per store**, not per owner.
///
/// Rule (§2): the rating stays with the store, because service quality is
/// tied to the place. A reason category is mandatory for 1–2 stars.
class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _stars = 3;

  /// `null` while no reason is picked. Mandatory for 1–2 stars.
  int? _tag;

  final _comment = TextEditingController();

  static const _tags = ['Kechikdi', 'Miqdor to\'liq emas', 'Sifat', 'Muloqot'];

  static const _captions = {
    1: 'Juda yomon — nima bo\'ldi?',
    2: 'Yomon — sabab kerak',
    3: '3 dan 5 — yaxshi, lekin kamchilik bor',
    4: 'Yaxshi',
    5: 'A\'lo',
  };

  bool get _reasonRequired => _stars <= 2;

  bool get _canSubmit => !_reasonRequired || _tag != null;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _tag == null ? null : _tags[_tag!];
    binnoSnack(
      context,
      reason == null
          ? '$_stars yulduz — baho yuborildi'
          : '$_stars yulduz · $reason — baho yuborildi',
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final store = MockData.metallSavdo;

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoBackBar(label: '${MockData.orderId} · yetkazildi'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 12),
              children: [
                Column(
                  children: [
                    Text(
                      store.name,
                      textAlign: TextAlign.center,
                      style: AppText.display(26, height: 1.1),
                    ),
                    Text(
                      store.unitNumber,
                      textAlign: TextAlign.center,
                      style: AppText.display(26, height: 1.1),
                    ),
                    const SizedBox(height: 6),
                    Text(store.complexBlock, style: AppText.meta(size: 13)),
                    const SizedBox(height: 22),
                    BinnoStars(
                      value: _stars,
                      onChanged: (v) => setState(() => _stars = v),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      _captions[_stars]!,
                      textAlign: TextAlign.center,
                      style: AppText.s(14, FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const BinnoHairline(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'NIMA BO\'LDI',
                      style: AppText.eyebrow(weight: FontWeight.w700),
                    ),
                    if (_reasonRequired) ...[
                      const SizedBox(width: 8),
                      Text(
                        '· majburiy',
                        style: AppText.s(
                          11,
                          FontWeight.w600,
                          color: AppColors.warningText,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                BinnoChoiceChips(
                  options: _tags,
                  // -1 means none selected.
                  selectedIndex: _tag ?? -1,
                  // Tapping the selected chip again clears the choice.
                  onChanged: (v) =>
                      setState(() => _tag = _tag == v ? null : v),
                ),
                const SizedBox(height: 12),
                BinnoTextArea(
                  controller: _comment,
                  hint: 'Izoh (ixtiyoriy)',
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          BinnoFooter(
            note: 'Baho do\'konga tegishli — ega boshqa do\'konlariga '
                'o\'tmaydi',
            children: [
              BinnoPrimaryButton(
                label: 'Bahoni yuborish',
                enabled: _canSubmit,
                onPressed: _canSubmit ? _submit : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

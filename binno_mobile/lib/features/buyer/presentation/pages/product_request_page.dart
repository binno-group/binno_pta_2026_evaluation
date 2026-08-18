import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../shared/widgets/binno_buttons.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_inputs.dart';
import '../../../shared/widgets/binno_states.dart';

/// Requesting a product.
///
/// Rule (§3.3): neither a store nor a buyer can **add** a product to the
/// catalogue; they can only ask. The request lands in the operator queue
/// and within **one working day** is added or rejected with a reason.
class ProductRequestPage extends StatefulWidget {
  const ProductRequestPage({super.key});

  @override
  State<ProductRequestPage> createState() => _ProductRequestPageState();
}

class _ProductRequestPageState extends State<ProductRequestPage> {
  final _name = TextEditingController(text: 'Keramik plita 60×60');
  final _note = TextEditingController();
  int _unit = 0;

  /// The number of attached photos; the mock stage only adds slots.
  int _photos = 0;

  static const _units = ['dona', 'qop', 'm²', 'tonna'];
  static const _maxPhotos = 3;

  bool get _canSubmit => _name.text.trim().isNotEmpty;

  void _submit() {
    final name = _name.text.trim();
    binnoSnack(
      context,
      '"$name" (${_units[_unit]}) so\'rovi yuborildi — '
      '1 ish kunida javob beramiz',
    );
    Navigator.of(context).maybePop();
  }

  @override
  void initState() {
    super.initState();
    // So the button disables while the name is empty.
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          const BinnoPageHeader(
            title: 'Mahsulot so\'rash',
            subtitle: 'Katalogda yo\'q mahsulotni qo\'shishni so\'rang',
            titleSize: 28,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                Text('MAHSULOT NOMI', style: AppText.eyebrow()),
                const SizedBox(height: 10),
                BinnoTextArea(
                  controller: _name,
                  hint: 'Masalan: keramik plita 60×60',
                ),
                const SizedBox(height: 22),
                Text('O\'LCHOV BIRLIGI', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                BinnoChoiceChips(
                  options: _units,
                  selectedIndex: _unit,
                  onChanged: (v) => setState(() => _unit = v),
                ),
                const SizedBox(height: 22),
                Text('TAVSIF', style: AppText.eyebrow()),
                const SizedBox(height: 10),
                BinnoTextArea(
                  controller: _note,
                  hint: 'O\'lcham, ishlab chiqaruvchi, marka — bilganingizcha',
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 22),
                Text('SURAT (IXTIYORIY)', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < _photos; i++)
                      const BinnoImageSlot(
                        width: 96,
                        height: 96,
                        dark: false,
                        placeholder: 'Surat',
                      ),
                    if (_photos < _maxPhotos)
                      BinnoAddTile(
                        size: 96,
                        onTap: () => setState(() => _photos++),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Surat bo\'lsa operator mahsulotni tezroq va aniqroq '
                  'qo\'shadi.',
                  style: AppText.meta(),
                ),
                const SizedBox(height: 24),
                const BinnoBanner(
                  tone: BinnoBannerTone.info,
                  icon: Icons.schedule_rounded,
                  text: 'So\'rov operator navbatiga tushadi. 1 ish kunida '
                      'mahsulot katalogga qo\'shiladi yoki sabab bilan '
                      'rad javobi keladi — natijani bildirishnoma orqali '
                      'bilasiz.',
                ),
              ],
            ),
          ),
          BinnoFooter(
            topBorder: true,
            children: [
              BinnoPrimaryButton(
                label: 'So\'rovni yuborish',
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

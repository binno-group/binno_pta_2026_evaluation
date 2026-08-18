import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_buttons.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_inputs.dart';
import '../../../shared/widgets/binno_rows.dart';
import '../../../shared/widgets/binno_states.dart';

/// Legal-entity details.
///
/// Rule (§6.1): for a legal-entity buyer the **STIR is mandatory** (9
/// digits) and goes into the invoice details. The tax document comes from
/// the seller, not the platform, and this screen says so honestly.
class LegalInfoPage extends StatefulWidget {
  const LegalInfoPage({super.key});

  @override
  State<LegalInfoPage> createState() => _LegalInfoPageState();
}

class _LegalInfoPageState extends State<LegalInfoPage> {
  int _buyerType = 1; // 0 = jismoniy, 1 = yuridik

  final _tin = TextEditingController(text: MockData.buyerTin);
  final _orgName = TextEditingController(text: '«Qurilish Servis» MChJ');
  final _legalAddress = TextEditingController(
    text: 'Toshkent, Yunusobod t., Amir Temur 108',
  );
  final _bankAccount = TextEditingController(text: '2020 8000 1234 5678 9012');
  final _mfo = TextEditingController(text: '00873');
  final _fullName = TextEditingController(text: MockData.buyerName);
  final _phone = TextEditingController(text: MockData.buyerPhone);

  /// The STIR: exactly 9 digits (§6.1).
  bool get _tinValid =>
      RegExp(r'^\d{9}$').hasMatch(_tin.text.replaceAll(' ', ''));

  bool get _canSave => _buyerType == 0
      ? _fullName.text.trim().isNotEmpty
      : _tinValid && _orgName.text.trim().isNotEmpty;

  @override
  void dispose() {
    _tin.dispose();
    _orgName.dispose();
    _legalAddress.dispose();
    _bankAccount.dispose();
    _mfo.dispose();
    _fullName.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    binnoSnack(
      context,
      _buyerType == 0
          ? 'Ma\'lumotlar saqlandi'
          : 'STIR ${_tin.text} · ${_orgName.text} saqlandi',
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          const BinnoPageHeader(
            title: 'Yuridik\nma\'lumotlar',
            subtitle: 'To\'lov varaqasi shu ma\'lumotlar bilan tuziladi',
            titleSize: 28,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                Text('XARIDOR TURI', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                BinnoSegmented(
                  options: const ['Jismoniy', 'Yuridik'],
                  selectedIndex: _buyerType,
                  onChanged: (v) => setState(() => _buyerType = v),
                ),
                const SizedBox(height: 24),
                if (_buyerType == 1) ...[
                  BinnoField(
                    label: 'STIR',
                    value: '123456789',
                    controller: _tin,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    hint: _tinValid
                        ? '9 raqam · soliq organidagi raqamingiz'
                        : 'STIR aynan 9 raqamdan iborat bo\'lishi kerak',
                  ),
                  const SizedBox(height: 16),
                  BinnoField(
                    label: 'Tashkilot nomi',
                    value: 'MChJ nomi',
                    controller: _orgName,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  BinnoField(
                    label: 'Yuridik manzil',
                    value: 'Shahar, tuman, ko\'cha',
                    controller: _legalAddress,
                  ),
                  const SizedBox(height: 16),
                  BinnoField(
                    label: 'Bank hisob raqami',
                    value: '20 raqam',
                    controller: _bankAccount,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  BinnoField(
                    label: 'MFO',
                    value: '5 raqam',
                    controller: _mfo,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const BinnoBanner(
                    tone: BinnoBannerTone.info,
                    text: 'Yuridik xaridorga elektron faktura sotuvchining '
                        'soliq tizimi orqali beriladi. BINNO soliq hujjatini '
                        'rasmiylashtirmaydi — platforma hujjati "to\'lov '
                        'varaqasi (invoys)" deb ataladi.',
                  ),
                ] else ...[
                  BinnoField(
                    label: 'F.I.Sh.',
                    value: 'Familiya Ism Sharif',
                    controller: _fullName,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  BinnoField(
                    label: 'Telefon',
                    value: '+998 90 000 00 00',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  const BinnoBanner(
                    tone: BinnoBannerTone.info,
                    text: 'Jismoniy xaridorga fiskal chek sotuvchi tomonidan '
                        'beriladi. STIR talab qilinmaydi.',
                  ),
                ],
                const SizedBox(height: 24),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Text('OXIRGI TO\'LOV VARAQASI', style: AppText.eyebrow()),
                const SizedBox(height: 14),
                const BinnoInfoRow(
                  label: 'Raqam',
                  value: MockData.invoiceNumber,
                ),
                const SizedBox(height: 10),
                const BinnoInfoRow(label: 'Sana', value: '25-iyul 2026'),
                const SizedBox(height: 10),
                const BinnoInfoRow(
                  label: 'Summa',
                  value: '2 040 000 so\'m',
                ),
              ],
            ),
          ),
          BinnoFooter(
            topBorder: true,
            children: [
              BinnoPrimaryButton(
                label: 'Saqlash',
                enabled: _canSave,
                onPressed: _canSave ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_inputs.dart';

/// Language selection.
///
/// The font fully covers Uzbek Latin (o', g', ʼ) and Cyrillic, so all
/// three variants render alike.
class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final languages = MockData.languages;

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoPageHeader(
            title: 'Til',
            subtitle: 'Ilova tili va bildirishnomalar tili',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                for (var i = 0; i < languages.length; i++) ...[
                  if (i != 0) const BinnoHairline(),
                  InkWell(
                    onTap: () {
                      setState(() => _selected = i);
                      binnoSnack(
                        context,
                        '${languages[i].name} tanlandi',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  languages[i].name,
                                  style: AppText.s(15, FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  languages[i].native,
                                  style: AppText.meta(),
                                ),
                              ],
                            ),
                          ),
                          BinnoRadioDot(selected: i == _selected),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'SMS xabarlar ham shu tilda keladi.',
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

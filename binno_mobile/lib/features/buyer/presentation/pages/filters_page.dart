import 'package:flutter/material.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/mock/search_filters.dart';
import '../../../shared/widgets/binno_buttons.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_inputs.dart';

/// Filters.
///
/// The sort criteria match the ranking factors (§4.3): price, distance,
/// freshness, response time. The "by rating" criterion is also per
/// **store**, never merged at the owner level.
class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, this.initial});

  /// The current state on the results screen; shown when this opens.
  final SearchFilters? initial;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late int _sort;
  late int _fulfillment;
  late bool _freshOnly;
  late bool _verifiedOnly;
  late RangeValues _price;
  late double _radiusKm;
  late Set<String> _complexes;
  late String _query;

  static const _sortOptions = [
    'Narx — arzonidan',
    'Masofa — yaqinidan',
    'Yangilanish — yangisidan',
    'Reyting — yuqorisidan',
  ];

  @override
  void initState() {
    super.initState();
    _applyState(widget.initial ?? const SearchFilters());
    _query = widget.initial?.query ?? const SearchFilters().query;
  }

  void _applyState(SearchFilters f) {
    _sort = f.sort;
    _fulfillment = f.fulfillment;
    _freshOnly = f.freshOnly;
    _verifiedOnly = f.verifiedOnly;
    _price = RangeValues(f.priceMin, f.priceMax);
    _radiusKm = f.radiusKm;
    _complexes = {...f.complexes};
  }

  SearchFilters get _current => SearchFilters(
    query: _query,
    sort: _sort,
    fulfillment: _fulfillment,
    freshOnly: _freshOnly,
    verifiedOnly: _verifiedOnly,
    priceMin: _price.start,
    priceMax: _price.end,
    radiusKm: _radiusKm,
    complexes: _complexes,
  );

  /// The result count, shown live on the button.
  int get _matchCount => _current.apply(MockData.searchResults).length;

  void _reset() => setState(() => _applyState(const SearchFilters()));

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          BinnoPageHeader(
            title: 'Filtrlar',
            subtitle: '$_query · $_matchCount taklif',
            trailing: InkWell(
              onTap: _reset,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                child: Text('Tozalash', style: AppText.link()),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                Text('SARALASH', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                for (var i = 0; i < _sortOptions.length; i++)
                  _RadioRow(
                    label: _sortOptions[i],
                    selected: _sort == i,
                    onTap: () => setState(() => _sort = i),
                  ),
                const SizedBox(height: 18),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Text('OLISH USULI', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                BinnoSegmented(
                  options: const ['Barchasi', 'Yetkazish', 'Olib ketish'],
                  selectedIndex: _fulfillment,
                  onChanged: (v) => setState(() => _fulfillment = v),
                ),
                const SizedBox(height: 22),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text('NARX ORALIG\'I', style: AppText.eyebrow()),
                    ),
                    Text(
                      '${Money.format(_price.start)} – '
                      '${Money.som(_price.end)}',
                      style: AppText.s(13, FontWeight.w600),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _price,
                  min: 30000,
                  max: 80000,
                  divisions: 25,
                  activeColor: AppColors.navy950,
                  inactiveColor: AppColors.surface2,
                  onChanged: (v) => setState(() => _price = v),
                ),
                const SizedBox(height: 6),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text('RADIUS', style: AppText.eyebrow()),
                    ),
                    Text(
                      '${_radiusKm.round()} km',
                      style: AppText.s(13, FontWeight.w600),
                    ),
                  ],
                ),
                Slider(
                  value: _radiusKm,
                  min: 5,
                  max: 30,
                  divisions: 5,
                  activeColor: AppColors.navy950,
                  inactiveColor: AppColors.surface2,
                  onChanged: (v) => setState(() => _radiusKm = v),
                ),
                const SizedBox(height: 6),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Text('SAVDO MAJMUASI', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                for (final complex in MockData.complexes)
                  _CheckRow(
                    label: complex.name,
                    subtitle: complex.summary,
                    value: _complexes.contains(complex.name),
                    onChanged: (v) => setState(() {
                      if (v) {
                        _complexes.add(complex.name);
                      } else {
                        _complexes.remove(complex.name);
                      }
                    }),
                  ),
                const SizedBox(height: 12),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Text('QO\'SHIMCHA', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                _SwitchRow(
                  label: 'Faqat bugun yangilangan',
                  subtitle: 'Eskirgan narxli e\'lonlar chiqmaydi',
                  value: _freshOnly,
                  onChanged: (v) => setState(() => _freshOnly = v),
                ),
                _SwitchRow(
                  label: 'Faqat tasdiqlangan do\'konlar',
                  subtitle: 'STIR bo\'yicha verifikatsiyadan o\'tgan',
                  value: _verifiedOnly,
                  onChanged: (v) => setState(() => _verifiedOnly = v),
                ),
              ],
            ),
          ),
          BinnoFooter(
            topBorder: true,
            children: [
              // Applied even with zero results: the results screen shows
              // the empty state and "clear filters", so nothing is lost.
              BinnoPrimaryButton(
                label: _matchCount == 0
                    ? 'Mos taklif topilmadi'
                    : 'Natijalarni ko\'rsatish · $_matchCount',
                onPressed: () => Navigator.of(context).pop(_current),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.s(
                  15,
                  selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            BinnoRadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value ? AppColors.navy950 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.navy950 : AppColors.border16,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.s(15, FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.meta()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.s(15, FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppText.meta()),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          BinnoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

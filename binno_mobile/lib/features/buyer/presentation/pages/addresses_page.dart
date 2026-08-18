import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_buttons.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_inputs.dart';
import '../../../shared/widgets/binno_labels.dart';
import '../../../shared/widgets/binno_states.dart';
import 'map_picker_page.dart';

/// Delivery addresses.
///
/// The address is the entry point of discovery (§4.1): it sets the search
/// centre and the zone tariff. The screen therefore returns the selected
/// address to its caller.
class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  /// A local copy; adding, editing, and deleting happen on this list.
  late final List<MockAddress> _addresses = [...MockData.addresses];

  int _selected = 0;

  /// Opens the map and turns the result into an address.
  ///
  /// With `editIndex`, the existing address is **replaced**; no new card is
  /// added.
  Future<void> _openMap({int? editIndex}) async {
    final existing = editIndex == null ? null : _addresses[editIndex];

    final query = existing == null
        ? ''
        : '?lat=${existing.latitude}&lng=${existing.longitude}';

    final picked = await context.push<Object?>(
      '${AppRoutes.mapPicker}$query',
    );
    if (!mounted) return;
    if (picked is! PickedAddress) return;

    final label = await _askLabel(existing?.label);
    if (!mounted || label == null) return;

    final address = MockAddress(
      label: label,
      line: picked.address ?? picked.coordinates,
      district: existing?.district ?? _districtOf(picked),
      receiver: existing?.receiver ??
          '${MockData.buyerName.split(' ').first} · ${MockData.buyerPhone}',
      latitude: picked.latitude,
      longitude: picked.longitude,
      isDefault: existing?.isDefault ?? false,
    );

    setState(() {
      if (editIndex == null) {
        _addresses.add(address);
        _selected = _addresses.length - 1;
      } else {
        _addresses[editIndex] = address;
        _selected = editIndex;
      }
    });

    if (!mounted) return;
    binnoSnack(
      context,
      editIndex == null
          ? 'Manzil qo\'shildi: ${address.line}'
          : '${address.label} yangilandi',
    );
  }

  /// Extracts the district from the reverse-geocoding result.
  String _districtOf(PickedAddress picked) {
    final address = picked.address;
    if (address == null) return 'Toshkent';

    final part = address
        .split(',')
        .map((p) => p.trim())
        .firstWhere(
          (p) => p.contains('tuman') || p.endsWith(' t.'),
          orElse: () => '',
        );
    return part.isEmpty ? 'Toshkent' : part;
  }

  /// Names the address, e.g. "Uy", "Obyekt", "Ombor".
  Future<String?> _askLabel(String? initial) async {
    final controller = TextEditingController(text: initial ?? 'Obyekt');

    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.rCard),
          ),
          title: Text('Manzil nomi', style: AppText.display(22)),
          content: BinnoTextArea(
            controller: controller,
            hint: 'Uy, Obyekt, Ombor…',
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Bekor qilish',
                style: AppText.s(14, FontWeight.w600, color: AppColors.ink2),
              ),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.of(
                  dialogContext,
                ).pop(value.isEmpty ? 'Manzil' : value);
              },
              child: Text(
                'Saqlash',
                style: AppText.s(14, FontWeight.w600, color: AppColors.navy950),
              ),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _delete(int index) {
    final removed = _addresses[index];
    setState(() {
      _addresses.removeAt(index);
      // Deleting an address above the selected one shifts the index;
      // otherwise the caller would get a different address back.
      if (index < _selected) _selected--;
      if (_selected >= _addresses.length) _selected = _addresses.length - 1;
      if (_selected < 0) _selected = 0;
    });
    binnoSnack(context, '${removed.label} o\'chirildi');
  }

  @override
  Widget build(BuildContext context) {
    final hasAddresses = _addresses.isNotEmpty;

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoPageHeader(
            title: 'Manzillar',
            subtitle: 'Qidiruv va yetkazish tanlangan manzil bo\'yicha',
          ),
          Expanded(
            child: hasAddresses
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                    children: [
                      for (var i = 0; i < _addresses.length; i++) ...[
                        if (i != 0) const SizedBox(height: 12),
                        _AddressCard(
                          address: _addresses[i],
                          selected: i == _selected,
                          onTap: () => setState(() => _selected = i),
                          onEdit: () => _openMap(editIndex: i),
                          // The last address cannot be deleted: without
                          // one there is no search centre (§4.1).
                          onDelete: _addresses.length > 1
                              ? () => _delete(i)
                              : null,
                        ),
                      ],
                      const SizedBox(height: 22),
                      const BinnoBanner(
                        tone: BinnoBannerTone.info,
                        icon: Icons.lock_outline_rounded,
                        text: 'Sotuvchi qidiruv bosqichida faqat tumaningizni '
                            'ko\'radi. Aniq manzil qabuldan keyin, uy raqami '
                            'esa to\'lov tasdiqlangach ochiladi.',
                      ),
                    ],
                  )
                : const BinnoEmptyState(
                    icon: Icons.place_outlined,
                    title: 'Manzil yo\'q',
                    body: 'Qidiruv manzildan boshlanadi. Xaritadan yetkazish '
                        'nuqtangizni belgilang.',
                  ),
          ),
          BinnoFooter(
            topBorder: true,
            children: [
              if (hasAddresses) ...[
                BinnoPrimaryButton(
                  label: 'Shu manzilni tanlash',
                  onPressed: () =>
                      Navigator.of(context).pop(_addresses[_selected]),
                ),
                const SizedBox(height: 10),
                BinnoSecondaryButton(
                  label: 'Yangi manzil qo\'shish',
                  icon: Icons.add_rounded,
                  onPressed: _openMap,
                ),
              ] else
                BinnoPrimaryButton(
                  label: 'Xaritadan tanlash',
                  icon: Icons.add_rounded,
                  onPressed: _openMap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final MockAddress address;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            border: Border.all(
              color: selected ? AppColors.navy950 : AppColors.border15,
              width: AppDimens.bwControl,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.s(15, FontWeight.w600),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          const BinnoPill(
                            'ASOSIY',
                            tone: BinnoPillTone.brandNew,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(address.line, style: AppText.s(14, FontWeight.w400)),
                    const SizedBox(height: 2),
                    Text(address.district, style: AppText.meta()),
                    const SizedBox(height: 2),
                    Text(address.receiver, style: AppText.meta()),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  BinnoRadioDot(selected: selected),
                  const SizedBox(height: 6),
                  InkResponse(
                    onTap: onEdit,
                    radius: 22,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.ink2,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    InkResponse(
                      onTap: onDelete,
                      radius: 22,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.ink3,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

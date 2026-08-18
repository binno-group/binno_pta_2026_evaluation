import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/widgets/binno_chrome.dart';

/// The dev gallery, opening every screen from one place.
///
/// It is a **testing tool, not navigation**: the app starts at `/home` and
/// moves through the tabs. The gallery opens from Profile via "Dev: barcha
/// ekranlar" and is removed from the production build.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  static const _tabs = <_Item>[
    _Item('T1', 'Bosh sahifa', 'manzil va hero taklif', AppRoutes.home,
        isTab: true),
    _Item('T2', 'Katalog', 'kategoriya va majmualar', AppRoutes.catalog,
        isTab: true),
    _Item('T3', 'Buyurtmalar', 'holat bo\'yicha ro\'yxat', AppRoutes.orders,
        isTab: true),
    _Item('T4', 'Profil', 'sozlamalar va yordam', AppRoutes.profile,
        isTab: true),
  ];

  static const _discovery = <_Item>[
    _Item('01', 'Qidiruv', 'tarix va ommabop so\'rovlar', AppRoutes.search),
    _Item('02', 'Qidiruv natijalari', 'freshness bosqichlari',
        AppRoutes.searchResults),
    _Item('03', 'Filtrlar', 'saralash · narx · radius', AppRoutes.filters),
    _Item('04', 'Majmua sahifasi', 'signature · bloklar bo\'yicha',
        AppRoutes.complex),
    _Item('05', 'Do\'kon sahifasi', 'takliflar va sharhlar', AppRoutes.store),
    _Item('06', 'Eganing boshqa do\'konlari', 'yana N do\'koni',
        AppRoutes.ownerStores),
    _Item('07', 'Taklif sahifasi', 'surat yetakchi', AppRoutes.offer),
    _Item('08', 'Mahsulot so\'rash', 'katalogda yo\'q mahsulot',
        AppRoutes.productRequest),
    _Item('09', 'Bo\'sh natija', 'NIMA → NEGA → NIMA QILISH',
        AppRoutes.emptyResults),
    _Item('10', 'Oflayn / bloklangan', 'keshdagi narx eskirgan',
        AppRoutes.offline),
  ];

  static const _orderFlow = <_Item>[
    _Item('11', 'Buyurtmani shakllantirish', 'fokus: miqdor',
        AppRoutes.orderDraft),
    _Item('12', 'Tasdiqlash kutilmoqda', 'ETA yo\'q', AppRoutes.awaiting),
    _Item('13', 'Muqobillar', 'buyer_decision_pending',
        AppRoutes.alternatives),
    _Item('14', 'To\'lov', 'eskrou yo\'q', AppRoutes.payment),
    _Item('15', 'Faol buyurtma', 'jonli xarita yo\'q', AppRoutes.orderActive),
    _Item('16', 'Qaytarish so\'rovi', 'dalil suratlari', AppRoutes.refund),
    _Item('17', 'Qaytarish tracker', 'muddati o\'tgan',
        AppRoutes.refundTracker),
    _Item('18', 'Baholash', 'do\'kon darajasida', AppRoutes.rating),
  ];

  static const _account = <_Item>[
    _Item('19', 'Chat', 'do\'kon bilan yozishma', AppRoutes.chat),
    _Item('20', 'Bildirishnomalar', 'holat o\'zgarishlari',
        AppRoutes.notifications),
    _Item('21', 'Manzillar', 'qidiruv markazi', AppRoutes.addresses),
    _Item('22', 'Yuridik ma\'lumotlar', 'STIR va rekvizitlar',
        AppRoutes.legalInfo),
    _Item('23', 'Til', 'lotin · kirill · rus', AppRoutes.language),
    _Item('24', 'Yordam va shartlar', 'FAQ va oferta', AppRoutes.help),
  ];

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      onNavy: true,
      background: AppColors.canvas,
      child: Column(
        children: [
          BinnoNavyHeader(
            bottomPadding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BinnoBackBar(onNavy: true, safeArea: false),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barcha ekranlar',
                        style: AppText.display(
                          30,
                          color: AppColors.white,
                          height: 1.06,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '28 ekran · mock ma\'lumot bilan',
                        style: AppText.s(
                          13,
                          FontWeight.w400,
                          color: AppColors.onNavyMeta,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: const [
                _Section(title: 'TABLAR', items: _tabs),
                _Section(title: 'TOPISH', items: _discovery),
                _Section(title: 'BUYURTMA OQIMI', items: _orderFlow),
                _Section(title: 'HISOB VA ALOQA', items: _account),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  const _Item(
    this.index,
    this.title,
    this.subtitle,
    this.route, {
    this.isTab = false,
  });

  final String index;
  final String title;
  final String subtitle;
  final String route;

  /// A tab root opens with `go` (inside the shell); a detail screen
  /// opens with `push` (above the shell).
  final bool isTab;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.eyebrow(weight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final item in items) _Tile(item: item),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});

  final _Item item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.rField),
        child: InkWell(
          onTap: () {
            if (item.isTab) {
              context.go(item.route);
            } else {
              context.push(item.route);
            }
          },
          borderRadius: BorderRadius.circular(AppDimens.rField),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    item.index,
                    style: AppText.display(16, color: AppColors.ink3),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppText.rowTitle()),
                      const SizedBox(height: 2),
                      Text(item.subtitle, style: AppText.meta()),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.ink3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

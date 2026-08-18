import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/filters_nav.dart';
import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/mock/search_filters.dart';
import '../../../shared/widgets/widgets.dart';

/// Global search; every search from home and the catalogue opens here
/// (§6). Four tabs: All, Categories, Products, Stores.
///
/// The "All" tab shows each section truncated (4 categories, 6 stores),
/// and the "See all" affordance on the right jumps to the matching tab
/// (§7).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);
  final _controller = TextEditingController();
  final _focus = FocusNode();

  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _match(String value) =>
      _query.trim().isEmpty ||
      value.toLowerCase().contains(_query.trim().toLowerCase());

  List<MockCategory> get _categories =>
      MockData.categories.where((c) => _match(c.name)).toList();

  List<MockOffer> get _products =>
      MockData.allProducts.where((o) => _match(o.productTitle)).toList();

  List<MockStore> get _stores => MockData.allStores
      .where((s) => _match(s.name) || _match(s.title))
      .toList();

  void _submit([String? value]) {
    final q = (value ?? _query).trim();
    if (q.isEmpty) return;
    context.push(AppRoutes.searchResults, extra: SearchFilters(query: q));
  }

  void _openCategory(String name) {
    context.push(AppRoutes.searchResults, extra: SearchFilters(query: name));
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      background: AppColors.surface,
      child: Column(
        children: [
          _SearchBar(
            controller: _controller,
            focus: _focus,
            onChanged: (v) => setState(() => _query = v),
            onSubmit: _submit,
            onFilter: () => openFiltersThenResults(context),
            onClear: _query.isEmpty
                ? null
                : () {
                    _controller.clear();
                    setState(() => _query = '');
                  },
          ),
          _Tabs(controller: _tab),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _AllTab(
                  categories: _categories,
                  products: _products,
                  stores: _stores,
                  query: _query,
                  onSeeCategories: () => _tab.animateTo(1),
                  onSeeProducts: () => _tab.animateTo(2),
                  onSeeStores: () => _tab.animateTo(3),
                  onCategory: _openCategory,
                ),
                _CategoriesTab(
                  categories: _categories,
                  onCategory: _openCategory,
                ),
                _ProductsTab(products: _products),
                _StoresTab(stores: _stores),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focus,
    required this.onChanged,
    required this.onSubmit,
    this.onFilter,
    this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onFilter;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
        child: Row(
          children: [
            InkResponse(
              onTap: () => Navigator.of(context).maybePop(),
              radius: 24,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 26,
                  color: AppColors.navy950,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: AppDimens.hControl,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimens.rField),
                  boxShadow: AppDimens.shadowCard,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: AppColors.ink3,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focus,
                        textInputAction: TextInputAction.search,
                        onChanged: onChanged,
                        onSubmitted: onSubmit,
                        style: AppText.s(15, FontWeight.w500),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Sement, armatura, do\'kon…',
                          hintStyle: AppText.s(
                            15,
                            FontWeight.w400,
                            color: AppColors.ink3,
                          ),
                        ),
                      ),
                    ),
                    if (onClear != null)
                      InkResponse(
                        onTap: onClear,
                        radius: 18,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.ink3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onFilter != null) ...[
              const SizedBox(width: 10),
              _FilterIcon(onTap: onFilter),
            ],
          ],
        ),
      ),
    );
  }
}

/// The filter button in the search bar (§2).
class _FilterIcon extends StatelessWidget {
  const _FilterIcon({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.rField),
        boxShadow: AppDimens.shadowCard,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.rField),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.rField),
          child: const SizedBox(
            width: AppDimens.hControl,
            height: AppDimens.hControl,
            child: Icon(
              Icons.tune_rounded,
              size: 21,
              color: AppColors.navy950,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab bar ─────────────────────────────────────────────────────────────────
class _Tabs extends StatelessWidget {
  const _Tabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.only(right: 22),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: AppColors.navy950,
        indicatorWeight: 2.5,
        dividerColor: Colors.transparent,
        labelColor: AppColors.navy950,
        unselectedLabelColor: AppColors.ink3,
        labelStyle: AppText.s(15, FontWeight.w700),
        unselectedLabelStyle: AppText.s(15, FontWeight.w500),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: 'Barchasi'),
          Tab(text: 'Kategoriyalar'),
          Tab(text: 'Mahsulotlar'),
          Tab(text: 'Do\'konlar'),
        ],
      ),
    );
  }
}

// ── The "All" tab ────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  const _AllTab({
    required this.categories,
    required this.products,
    required this.stores,
    required this.query,
    required this.onSeeCategories,
    required this.onSeeProducts,
    required this.onSeeStores,
    required this.onCategory,
  });

  final List<MockCategory> categories;
  final List<MockOffer> products;
  final List<MockStore> stores;
  final String query;
  final VoidCallback onSeeCategories;
  final VoidCallback onSeeProducts;
  final VoidCallback onSeeStores;
  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty && products.isEmpty && stores.isEmpty) {
      return _EmptyQuery(query: query);
    }

    final topCategories = categories.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      children: [
        if (topCategories.isNotEmpty) ...[
          _SectionHeader(title: 'Kategoriyalar', onSeeAll: onSeeCategories),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < topCategories.length; i++) ...[
                if (i != 0) const SizedBox(width: 10),
                Expanded(
                  child: BinnoCategoryCard(
                    label: topCategories[i].name,
                    asset: topCategories[i].asset,
                    onTap: () => onCategory(topCategories[i].name),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
        if (products.isNotEmpty) ...[
          _SectionHeader(title: 'Mahsulotlar', onSeeAll: onSeeProducts),
          const SizedBox(height: 6),
          for (final offer in products.take(3)) _ProductRow(offer: offer),
          const SizedBox(height: 18),
        ],
        if (stores.isNotEmpty) ...[
          _SectionHeader(title: 'Do\'konlar', onSeeAll: onSeeStores),
          const SizedBox(height: 6),
          for (final store in stores.take(6)) _StoreRow(store: store),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.display(20))),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(AppDimens.rPill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  Text('Barchasi', style: AppText.link()),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.navy700,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── The "Categories" tab ─────────────────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.categories, required this.onCategory});

  final List<MockCategory> categories;
  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const _EmptyList(label: 'Kategoriya');

    return GridView.count(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        for (final c in categories)
          BinnoCategoryCard(
            label: c.name,
            asset: c.asset,
            offerCount: c.offerCount,
            compact: false,
            onTap: () => onCategory(c.name),
          ),
      ],
    );
  }
}

// ── The "Products" tab ───────────────────────────────────────────────────────
class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.products});

  final List<MockOffer> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _EmptyList(label: 'Mahsulot');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: BinnoHairline(),
      ),
      itemBuilder: (context, i) => _ProductRow(offer: products[i]),
    );
  }
}

// ── The "Stores" tab ─────────────────────────────────────────────────────────
class _StoresTab extends StatelessWidget {
  const _StoresTab({required this.stores});

  final List<MockStore> stores;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const _EmptyList(label: 'Do\'kon');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      itemCount: stores.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: BinnoHairline(),
      ),
      itemBuilder: (context, i) => _StoreRow(store: stores[i]),
    );
  }
}

// ── Rows ──────────────────────────────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.offer});

  final MockOffer offer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.offer),
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BinnoProductImage(
              thumbLabel: offer.thumbLabel,
              asset: MockData.productAsset(offer.thumbLabel),
              size: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.rowTitle(),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${Money.format(offer.price)} so\'m / ${offer.unit} · '
                    '${offer.store.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.store});

  final MockStore store;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.store),
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navy100,
                borderRadius: BorderRadius.circular(AppDimens.rThumb),
              ),
              child: Text(
                store.initials ??
                    (store.name.isEmpty ? '?' : store.name.substring(0, 1)),
                style: AppText.s(16, FontWeight.w700, color: AppColors.navy950),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          store.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.rowTitle(),
                        ),
                      ),
                      if (store.verified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: AppColors.navy700,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    store.isNew
                        ? '${store.complexBlock} · Yangi'
                        : '${store.rating.toStringAsFixed(1).replaceAll('.', ',')}'
                              ' ★ (${store.reviewCount}) · '
                              '${store.complexBlock}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────
class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text('$label topilmadi', style: AppText.meta(size: 14)),
      ),
    );
  }
}

class _EmptyQuery extends StatelessWidget {
  const _EmptyQuery({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.ink3,
            ),
            const SizedBox(height: 16),
            Text(
              '"$query" bo\'yicha\nhech narsa topilmadi',
              textAlign: TextAlign.center,
              style: AppText.display(20, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Boshqa so\'z bilan urinib ko\'ring.',
              textAlign: TextAlign.center,
              style: AppText.meta(size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

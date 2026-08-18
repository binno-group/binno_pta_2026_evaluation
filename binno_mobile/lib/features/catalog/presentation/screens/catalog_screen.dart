import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/components/binno_reference_components.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('catalog_grid'),
          padding: const EdgeInsets.all(BinnoSpacing.x5),
          children: [
            Text(
              l10n.catalogSummary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: BinnoSpacing.x6),
            Text(
              l10n.catalogHeadline,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              l10n.catalogSort,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: BinnoSpacing.x6),
            BinnoSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cheapestLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: BinnoSpacing.x3),
                  const _OfferName(name: 'Sardor Savdo', branch: "51-do'kon"),
                  const SizedBox(height: BinnoSpacing.x8),
                  Text(
                    '45 000',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(l10n.priceUnit),
                  const SizedBox(height: BinnoSpacing.x3),
                  BinnoStatusPill(
                    label: l10n.stalePriceStatus,
                    tone: BinnoStatusTone.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BinnoSpacing.x3),
            _OfferRow(
              name: 'Metall Savdo',
              stock: '120 qop · 4,8',
              price: '48 000',
              status: l10n.updatedTodayStatus,
            ),
            const Divider(),
            const _OfferRow(
              name: 'Baraka Qurilish',
              stock: "340 qop · A-blok, 9-do'kon",
              price: '49 500',
            ),
            const Divider(),
            const _OfferRow(
              name: 'Nurli Beton',
              stock: '210 qop · 4,6',
              price: '50 000',
            ),
            const SizedBox(height: BinnoSpacing.x8),
            BinnoButton(label: l10n.filterAction, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _OfferName extends StatelessWidget {
  const _OfferName({required this.name, required this.branch});
  final String name;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$name\n$branch',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({
    required this.name,
    required this.stock,
    required this.price,
    this.status,
  });
  final String name;
  final String stock;
  final String price;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BinnoSpacing.x3),
      child: Row(
        children: [
          const BinnoSurfaceCard(
            padding: EdgeInsets.all(BinnoSpacing.x4),
            child: Text('M400'),
          ),
          const SizedBox(width: BinnoSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(stock, style: Theme.of(context).textTheme.bodyMedium),
                if (status != null)
                  BinnoStatusPill(
                    label: status!,
                    tone: BinnoStatusTone.success,
                  ),
              ],
            ),
          ),
          Text(price, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

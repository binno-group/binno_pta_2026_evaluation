import 'package:flutter/material.dart';
import '../../../../core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// 13 · The empty result: **WHAT, WHY, WHAT TO DO**.
///
/// A store cannot add a product to the catalogue, but it can ask: request
/// a product, then the operator queue, then an answer within one working
/// day (§3.3).
class EmptyResultsPage extends StatelessWidget {
  const EmptyResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  InkResponse(
                    onTap: () => Navigator.of(context).maybePop(),
                    radius: 24,
                    child: const SizedBox(
                      width: AppDimens.hTapTarget,
                      height: AppDimens.hTapTarget,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 26,
                        color: AppColors.navy950,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: BinnoSearchField(
                      placeholder: 'keramik plita 60×60',
                      floating: false,
                      filled: true,
                      onTap: () => context.push(AppRoutes.search),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 70, 32, 0),
              child: BinnoEmptyState(
                title: 'Bu so\'rov bo\'yicha\nhozir taklif yo\'q',
                body: 'Yunusobod atrofidagi do\'konlarda bu o\'lcham e\'lon '
                    'qilinmagan. Radiusni kengaytirib ko\'ring yoki '
                    'mahsulotni so\'rang — 1 ish kunida javob beramiz.',
              ),
            ),
          ),
          BinnoFooter(
            children: [
              BinnoPrimaryButton(
                label: 'Radiusni 15 km ga kengaytirish',
                onPressed: () => context.push(AppRoutes.searchResults),
              ),
              BinnoSecondaryButton(
                label: 'Mahsulot so\'rash',
                onPressed: () => context.push(AppRoutes.productRequest),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

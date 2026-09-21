import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../services/purchase_service.dart';
import '../utils/app_colors.dart';
import 'neon_text.dart';

/// Shows the "Remove Ads" paywall popup offering the Monthly/Yearly plans.
Future<void> showRemoveAdsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const RemoveAdsDialog(),
  );
}

class RemoveAdsDialog extends StatefulWidget {
  const RemoveAdsDialog({super.key});

  @override
  State<RemoveAdsDialog> createState() => _RemoveAdsDialogState();
}

class _RemoveAdsDialogState extends State<RemoveAdsDialog> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final purchases = context.watch<PurchaseService>();

    if (purchases.isPremium) {
      // Purchase just went through while this dialog was open - close it
      // and let the underlying screen show its "Premium Active" state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    final products = [...purchases.products]
      ..sort((a, b) => a.id == PurchaseService.yearlyId ? -1 : 1);
    _selectedId ??= purchases.yearly?.id ?? purchases.monthly?.id;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: AppColors.cardGradient),
          border: Border.all(color: AppColors.primary.withValues(alpha: .25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .15),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.block_rounded, color: AppColors.primary, size: 26),
                const SizedBox(width: 10),
                const Expanded(
                  child: NeonText(text: 'Remove Ads', fontSize: 19),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.close_rounded, color: AppColors.textTertiary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Go premium for an ad-free experience, forever.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ..._buildBody(purchases, products),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(
    PurchaseService purchases,
    List<ProductDetails> products,
  ) {
    if (!purchases.isAvailable) {
      return [_message('In-app purchases are not available on this device.')];
    }
    if (purchases.isLoadingProducts) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ];
    }
    if (products.isEmpty) {
      return [_message('Plans are not available right now. Please try again later.')];
    }

    return [
      for (final product in products)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PlanTile(
            product: product,
            isSelected: _selectedId == product.id,
            isBestValue: product.id == PurchaseService.yearlyId,
            onTap: () => setState(() => _selectedId = product.id),
          ),
        ),
      if (purchases.errorMessage != null) ...[
        Text(
          purchases.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
        const SizedBox(height: 8),
      ],
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: purchases.isPurchasePending || _selectedId == null
              ? null
              : () {
                  final product = products.firstWhere(
                    (p) => p.id == _selectedId,
                  );
                  purchases.buy(product);
                },
          child: purchases.isPurchasePending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => purchases.restorePurchases(),
        child: Text(
          'Restore Purchases',
          style: TextStyle(color: AppColors.textTertiary),
        ),
      ),
    ];
  }

  Widget _message(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.textTertiary),
    ),
  );
}

class _PlanTile extends StatelessWidget {
  final ProductDetails product;
  final bool isSelected;
  final bool isBestValue;
  final VoidCallback onTap;

  const _PlanTile({
    required this.product,
    required this.isSelected,
    required this.isBestValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.primary.withValues(alpha: .12)
              : AppColors.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: .12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.title.isNotEmpty ? product.title : product.id,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              product.price,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

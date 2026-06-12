import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/lab_test.dart';
import '../../theme/app_theme.dart';
import '../../providers/patho_lab_provider.dart';

class PackageHeaderCard extends ConsumerWidget {
  final TestPackageModel package;
  final VoidCallback onBack;

  const PackageHeaderCard({super.key, required this.package, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labState = ref.watch(pathoLabProvider);
    final lab = labState.labs.where((l) => l.labId == package.labId).firstOrNull;
    final labName = lab?.labName ?? 'Diagnostic Center';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/logo/lab.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withAlpha(200),
                    AppColors.primary.withAlpha(180),
                    AppColors.primary,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(60)),
                      ),
                      child: const Icon(Iconsax.arrow_left_2, size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.packageName,
                              style: AppTextStyles.header.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Iconsax.hospital, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    labName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withAlpha(200),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildPriceBadge(),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${package.packageFinalPrice.toStringAsFixed(0)}',
            style: AppTextStyles.header.copyWith(
              fontSize: 28,
              color: AppColors.primaryAccent,
            ),
          ),
          if (package.discountPercentage > 0) ...[
            const SizedBox(height: 4),
            Text(
              '₹${package.packageMarketPrice.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(
                decoration: TextDecoration.lineThrough,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${package.discountPercentage.toStringAsFixed(0)}% OFF',
                style: AppTextStyles.tagline.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

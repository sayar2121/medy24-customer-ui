import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medicine_provider.dart';
import '../../cards/medicine/medicine_header_card.dart';
import '../../cards/medicine/medicine_description_card.dart';
import '../../cards/medicine/medicine_composition_card.dart';
import '../../cards/medicine/medicine_precautions_card.dart';
import '../../theme/app_theme.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MedicineDetailsScreen extends ConsumerWidget {
  const MedicineDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = ref.watch(medicineProvider).selectedMedicine;

    if (medicine == null) {
      return const Scaffold(body: Center(child: Text('No medicine selected')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            MedicineHeaderCard(medicine: medicine),
            const SizedBox(height: AppSpacing.sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  MedicineDescriptionCard(medicine: medicine),
                  const SizedBox(height: AppSpacing.elementGap),
                  MedicineCompositionCard(medicine: medicine),
                  const SizedBox(height: AppSpacing.elementGap),
                  MedicinePrecautionsCard(medicine: medicine),
                  const SizedBox(height: 120), // Bottom padding for button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.borderRadius),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Final Price', style: AppTextStyles.caption),
                  Text(
                    '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                    style: AppTextStyles.subHeader.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sectionGap),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add to cart logic
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Iconsax.shopping_cart, size: 20),
                      SizedBox(width: 10),
                      Text('Add to Cart'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';

class MedicineDescriptionCard extends StatelessWidget {
  final MedicineModel medicine;

  const MedicineDescriptionCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final details = medicine.medicineDetails;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Description',
                style: AppTextStyles.cardTitle,
              ),
              const Spacer(),
              Text(
                'Qty: ${details?.medicineQuantity ?? 'N/A'}',
                style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            details?.medicineDescription ?? 'No description available.',
            style: AppTextStyles.cardSubtitle.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

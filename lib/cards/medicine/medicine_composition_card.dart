import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';

class MedicineCompositionCard extends StatelessWidget {
  final MedicineModel medicine;

  const MedicineCompositionCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final details = medicine.medicineDetails;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Composition',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            details?.medicineComposition ?? 'No composition info available.',
            style: AppTextStyles.cardSubtitle.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

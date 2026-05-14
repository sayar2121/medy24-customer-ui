import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';

class MedicinePrecautionsCard extends StatelessWidget {
  final MedicineModel medicine;

  const MedicinePrecautionsCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final details = medicine.medicineDetails;
    final precautions = details?.precautions ?? [];

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
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Safety Precautions', style: AppTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 16),
          if (precautions.isEmpty)
            const Text(
              'No specific precautions listed.',
              style: AppTextStyles.cardSubtitle,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: precautions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        precautions[index].toString(),
                        style: AppTextStyles.cardSubtitle.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

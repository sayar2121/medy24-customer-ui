import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../cards/medicine/medicine_card.dart';

class MedicineListScreen extends ConsumerStatefulWidget {
  const MedicineListScreen({super.key});

  @override
  ConsumerState<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends ConsumerState<MedicineListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(medicineProvider.notifier).fetchAllMedicines(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicineState = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medicines',
              style: AppTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              'Order from your nearest pharmacy',
              style: AppTextStyles.tagline.copyWith(fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/medicine-search'),
            icon: const Icon(
              Iconsax.search_normal_1,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {}, // Filter logic
            icon: const Icon(Iconsax.filter_edit, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: medicineState.isLoading && medicineState.medicines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : medicineState.error != null
          ? Center(child: Text(medicineState.error!))
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(medicineProvider.notifier).fetchAllMedicines(),
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62, // Adjusted to prevent overflow
                  crossAxisSpacing: AppSpacing.elementGap,
                  mainAxisSpacing: AppSpacing.elementGap,
                ),
                itemCount: medicineState.medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicineState.medicines[index];
                  return MedicineCard(
                    medicine: medicine,
                    onTap: () {
                      ref
                          .read(medicineProvider.notifier)
                          .selectMedicine(medicine);
                      context.push('/medicine-details');
                    },
                  );
                },
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/medicine/medicine_card.dart';
import '../../providers/cart_provider.dart';

class SkinCareScreen extends ConsumerStatefulWidget {
  const SkinCareScreen({super.key});

  @override
  ConsumerState<SkinCareScreen> createState() => _SkinCareScreenState();
}

class _SkinCareScreenState extends ConsumerState<SkinCareScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(medicineProvider.notifier).searchMedicines(category: 'Skin Care'),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(medicineProvider.notifier).searchMedicines(
            category: 'Skin Care',
            loadMore: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicineState = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Skin Care',
        subtitle: 'Premium products for your skin',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/medicine-search'),
            icon: const Icon(Iconsax.search_normal_1),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Iconsax.shopping_cart),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final cartItemCount = ref.watch(cartProvider).items.length;
                  if (cartItemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(medicineProvider.notifier).searchMedicines(category: 'Skin Care'),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Promotional Banner for Skin Care
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.pink.withAlpha(50),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'SPECIAL OFFER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Glow Up Sale!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Up to 30% off on serums',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.face_retouching_natural, size: 64, color: Colors.pinkAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            if (medicineState.isLoading && !medicineState.isFetchingMoreSearch)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (medicineState.error != null)
              SliverFillRemaining(
                child: Center(child: Text(medicineState.error!)),
              )
            else if (medicineState.searchResults.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No Skin Care products found.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: AppSpacing.elementGap,
                    mainAxisSpacing: AppSpacing.elementGap,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final medicine = medicineState.searchResults[index];
                    return MedicineCard(
                      medicine: medicine,
                      onTap: () {
                        ref
                            .read(medicineProvider.notifier)
                            .selectMedicine(medicine);
                        context.push('/medicine-details');
                      },
                    );
                  }, childCount: medicineState.searchResults.length),
                ),
              ),
            if (medicineState.isFetchingMoreSearch)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

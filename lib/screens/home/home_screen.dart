import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/home_top_header.dart';
import '../../widgets/home_search_input.dart';
import '../../widgets/home_category_tabs.dart';
import '../../widgets/promo_banner_carousel.dart';
import '../../widgets/home_service_grid.dart';
import '../../widgets/home_order_via_section.dart';
import '../../widgets/health_concern_grid.dart';
import '../../widgets/footer_card.dart';
import '../../providers/medicine_provider.dart';
import '../../cards/medicine/medicine_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(medicineProvider.notifier).fetchAllMedicines(),
    );
  }

  String _getLocation(dynamic user) {
    try {
      final saved = user?.savedAddresses as List<dynamic>?;
      if (saved != null && saved.isNotEmpty) {
        final first = saved.first as Map<String, dynamic>?;
        final addr = first?['address1'] as String?;
        if (addr != null && addr.isNotEmpty) return addr;
      }
    } catch (_) {}
    return 'Kolkata 700086';
  }

  Future<void> _launchWhatsApp() async {
    // WhatsApp ordering — can integrate url_launcher if added to pubspec
    context.push('/order-with-prescription');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final location = _getLocation(user);
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sticky Top Header + Search + Tabs
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 0,
            collapsedHeight: 0,
            toolbarHeight: 0,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 2,
            shadowColor: Colors.black.withAlpha(20),
            flexibleSpace: null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(186),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location Header
                  HomeTopHeader(
                    location: location,
                    deliveryTime: '30 mins',
                    cartCount: cartCount,
                    onLocationTap: () => context.push('/map-picker'),
                    onCartTap: () => context.push('/cart'),
                    onProfileTap: () => context.push('/profile'),
                  ),

                  // Search Bar
                  HomeSearchInput(
                    onTap: () => context.push('/medicine-search'),
                  ),

                  // Category Tabs
                  HomeCategoryTabs(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (i) =>
                        setState(() => _selectedTabIndex = i),
                    tabs: const [
                      HomeCategoryTab(label: 'All'),
                      HomeCategoryTab(
                        label: '50% OFF',
                        badge: 'HOT',
                        badgeColor: Color(0xFFEF4444),
                      ),
                      HomeCategoryTab(
                        label: 'Lab Tests',
                        badge: 'FREE',
                        badgeColor: Color(0xFF10B981),
                      ),
                      HomeCategoryTab(label: 'Packages'),
                      HomeCategoryTab(
                        label: 'New Arrivals',
                        badge: 'NEW',
                        badgeColor: Color(0xFF3B82F6),
                      ),
                      HomeCategoryTab(label: 'Skin Care'),
                      HomeCategoryTab(label: 'Vitamins'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable Body
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // ── Promo Banner Carousel (auto-scrolls every 3s)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PromoBannerCarousel(
                  banners: const [
                    PromoBannerItem(
                      badge: '🎉 BEST OFFER',
                      title: 'GET 20% OFF',
                      subtitle: 'on medicines and essentials',
                      gradientColors: [Color(0xFF005A6B), Color(0xFF008396), Color(0xFF7C3AED)],
                      icon: Icons.local_pharmacy_outlined,
                    ),
                    PromoBannerItem(
                      badge: '🧪 LAB SPECIAL',
                      title: 'FLAT 15% OFF',
                      subtitle: 'on all lab tests & packages',
                      gradientColors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
                      icon: Icons.science_outlined,
                    ),
                    PromoBannerItem(
                      badge: '💊 LIMITED TIME',
                      title: 'UP TO 40% OFF',
                      subtitle: 'on health packages for family',
                      gradientColors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFEC4899)],
                      icon: Icons.family_restroom_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 2x2 Service Grid
              HomeServiceGrid(
                items: [
                  HomeServiceGridItem(
                    title: 'Order\nMedicines',
                    subtitle: 'Free Delivery',
                    offerText: '20% off with MEDY20',
                    offerColor: AppColors.primaryAccent,
                    imagePath: 'assets/logo/order_medicine.png',
                    onTap: () => context.push('/medicine-list'),
                  ),
                  HomeServiceGridItem(
                    title: 'Lab Tests\nAt Home',
                    subtitle: 'Free Home Pickup',
                    offerText: 'Flat 15% off',
                    offerColor: AppColors.success,
                    imagePath: 'assets/logo/book_lab_test.png',
                    onTap: () => context.push('/lab-test-list'),
                  ),
                  HomeServiceGridItem(
                    title: 'Test\nPackages',
                    subtitle: 'For you & family',
                    offerText: 'Up to 40% off',
                    offerColor: AppColors.purple,
                    imagePath: 'assets/logo/patho_lab.png',
                    onTap: () => context.push('/test-package-list'),
                  ),
                  HomeServiceGridItem(
                    title: 'Upload\nPrescription',
                    subtitle: 'We do the rest',
                    offerText: 'Quick & Easy',
                    offerColor: AppColors.warning,
                    imagePath: 'assets/logo/order_with_prescription.png',
                    onTap: () =>
                        context.push('/order-with-prescription'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Featured Medicines Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Medicines',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/medicine-list'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ── Featured Medicines List
              Consumer(
                builder: (context, ref, child) {
                  final medicineState = ref.watch(medicineProvider);
                  
                  if (medicineState.isLoading && medicineState.medicines.isEmpty) {
                    return const SizedBox(
                      height: 260,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (medicineState.medicines.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final displayMeds = medicineState.medicines.take(5).toList();

                  return SizedBox(
                    height: 260,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: displayMeds.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final medicine = displayMeds[index];
                        return SizedBox(
                          width: 160,
                          child: MedicineCard(
                            medicine: medicine,
                            onTap: () {
                              ref.read(medicineProvider.notifier).selectMedicine(medicine);
                              context.push('/medicine-details');
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Order Via Section
              HomeOrderViaSection(
                onWhatsAppTap: _launchWhatsApp,
                onPrescriptionTap: () =>
                    context.push('/order-with-prescription'),
                onCallTap: () {},
              ),

              const SizedBox(height: 28),

              // ── Health Concern Grid
              HealthConcernGrid(
                items: [
                  HealthConcernItem(
                    title: 'Full Body\nCheckups',
                    bgColor: const Color(0xFFDCFCE7),
                    imagePath: 'assets/logo/book_lab_test.png',
                    onTap: () => context.push('/lab-test-list'),
                  ),
                  HealthConcernItem(
                    title: 'Diabetes',
                    bgColor: const Color(0xFFDBEAFE),
                    imagePath: 'assets/logo/book_lab_test.png',
                    onTap: () => context.push('/lab-test-list'),
                  ),
                  HealthConcernItem(
                    title: 'Fever &\nInfection',
                    bgColor: const Color(0xFFFEF3C7),
                    imagePath: 'assets/logo/book_lab_test.png',
                    onTap: () => context.push('/lab-test-list'),
                  ),
                  HealthConcernItem(
                    title: 'Vitamins',
                    bgColor: const Color(0xFFFEF9C3),
                    imagePath: 'assets/logo/order_medicine.png',
                    onTap: () => context.push('/medicine-list'),
                  ),
                  HealthConcernItem(
                    title: 'Women\nCare',
                    bgColor: const Color(0xFFFCE7F3),
                    imagePath: 'assets/logo/order_medicine.png',
                    onTap: () => context.push('/medicine-list'),
                  ),
                  HealthConcernItem(
                    title: 'Thyroid',
                    bgColor: const Color(0xFFEDE9FE),
                    imagePath: 'assets/logo/book_lab_test.png',
                    onTap: () => context.push('/lab-test-list'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Recent Section Header (if needed later)
              _RecentHeader(),

              const SizedBox(height: 16),

              // ── Footer
              const FooterCard(),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _RecentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/my-medicine-orders'),
            child: const Text(
              'View All',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

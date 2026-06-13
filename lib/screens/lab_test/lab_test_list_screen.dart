import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/lab_test_provider.dart';
import '../../providers/patho_lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/lab_test/lab_test_grid_card.dart';
import '../../widgets/explore_package_card.dart';

class LabTestListScreen extends ConsumerStatefulWidget {
  const LabTestListScreen({super.key});

  @override
  ConsumerState<LabTestListScreen> createState() => _LabTestListScreenState();
}

class _LabTestListScreenState extends ConsumerState<LabTestListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(labTestProvider.notifier).fetchAllTests();
      ref.read(pathoLabProvider.notifier).fetchLabs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final labTestState = ref.watch(labTestProvider);
    
    // Extract unique categories for the filter
    final categories = ['All'];
    for (var test in labTestState.tests) {
      final cat = test.coreTestDetails?.testCategory;
      if (cat != null && cat.isNotEmpty && !categories.contains(cat)) {
        categories.add(cat);
      }
    }

    // Filter tests
    var displayTests = labTestState.tests;
    if (_selectedCategory != 'All') {
      displayTests = displayTests.where((test) {
        return test.coreTestDetails?.testCategory == _selectedCategory;
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isSearching ? null : 'Lab Tests',
        subtitle: _isSearching ? null : 'Book diagnostic tests from best labs',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Iconsax.close_circle : Iconsax.search_normal_1,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: 8,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search for tests...',
                  prefixIcon: const Icon(
                    Iconsax.search_normal,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  // Logic for local or API filtering can be added here
                },
              ),
            ),
          Expanded(
            child: labTestState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : labTestState.error != null
                ? Center(child: Text('Error: ${labTestState.error}'))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(labTestProvider.notifier).fetchAllTests(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Promo Banner
                        if (!_isSearching)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screenPadding,
                                16,
                                AppSpacing.screenPadding,
                                0,
                              ),
                              child: ExplorePackageCard(
                                onTap: () => context.push('/test-package-list'),
                              ),
                            ),
                          ),
                          
                        // Horizontal Category Filter
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: SizedBox(
                              height: 38,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenPadding,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected = _selectedCategory == category;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected 
                                              ? AppColors.primary 
                                              : AppColors.divider,
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: AppColors.primary.withAlpha(50),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ] : null,
                                      ),
                                      child: Text(
                                        category,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Grid of Tests
                        displayTests.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: Text(
                                      'No tests found',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.screenPadding,
                                  0,
                                  AppSpacing.screenPadding,
                                  32,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.68,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final test = displayTests[index];
                                      return LabTestGridCard(
                                        test: test,
                                        onTap: () {
                                          context.push('/lab-test-details/${test.testId}');
                                        },
                                      );
                                    },
                                    childCount: displayTests.length,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

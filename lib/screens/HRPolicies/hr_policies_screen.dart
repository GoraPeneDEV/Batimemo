import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/HRPolicies/policy_model.dart';
import 'Widgets/policy_item_widget.dart';
import 'hr_policies_store.dart';
import 'hr_policy_detail_screen.dart';

class HRPoliciesScreen extends StatefulWidget {
  const HRPoliciesScreen({super.key});

  @override
  State<HRPoliciesScreen> createState() => _HRPoliciesScreenState();
}

class _HRPoliciesScreenState extends State<HRPoliciesScreen>
    with SingleTickerProviderStateMixin {
  final HRPoliciesStore _store = HRPoliciesStore();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _store.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _store.refreshData();
  }

  void _showCategoryFilter(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  16.height,
                  Text(
                    language.lblFilterByCategory,
                    style: boldTextStyle(size: 18),
                  ),
                  24.height,

                  // All Categories option
                  Observer(
                    builder: (_) => InkWell(
                      onTap: () {
                        _store.filterByCategory(null);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _store.selectedCategoryId == null
                              ? const Color(0xFF696CFF).withOpacity(0.1)
                              : (isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _store.selectedCategoryId == null
                                ? const Color(0xFF696CFF)
                                : (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Iconsax.category,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    language.lblAllCategories,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    language.lblShowAllPolicies,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_store.selectedCategoryId == null)
                              const Icon(
                                Iconsax.tick_circle,
                                color: Color(0xFF696CFF),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Category list
                  Observer(
                    builder: (_) => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _store.categories.length,
                      itemBuilder: (context, index) {
                        final category = _store.categories[index];
                        final isSelected = _store.selectedCategoryId == category.id;

                        return InkWell(
                          onTap: () {
                            _store.filterByCategory(category.id);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF696CFF).withOpacity(0.1)
                                  : (isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF696CFF)
                                    : (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      int.parse(category.color.replaceAll('#', '0xFF')),
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.folder,
                                    color: Color(
                                      int.parse(category.color.replaceAll('#', '0xFF')),
                                    ),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                        ),
                                      ),
                                      if (category.description != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          category.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Iconsax.tick_circle,
                                    color: Color(0xFF696CFF),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPolicyStats(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                16.height,
                Text(
                  language.lblPolicyStatistics,
                  style: boldTextStyle(size: 18),
                ),
                24.height,

                Observer(
                  builder: (_) {
                    if (_store.stats == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      children: [
                        // Total
                        _buildStatCard(
                          icon: Iconsax.document_text,
                          label: language.lblTotalPolicies,
                          value: _store.stats!.total.toString(),
                          color: const Color(0xFF696CFF),
                          isDark: isDark,
                        ),
                        12.height,

                        // Pending
                        _buildStatCard(
                          icon: Iconsax.clock,
                          label: language.lblPending,
                          value: _store.stats!.pending.toString(),
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                        12.height,

                        // Overdue
                        _buildStatCard(
                          icon: Iconsax.warning_2,
                          label: language.lblOverdue,
                          value: _store.stats!.overdue.toString(),
                          color: Colors.red,
                          isDark: isDark,
                        ),
                        12.height,

                        // Acknowledged
                        _buildStatCard(
                          icon: Iconsax.tick_circle,
                          label: language.lblAcknowledged,
                          value: _store.stats!.acknowledged.toString(),
                          color: Colors.green,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
          highlightColor: isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header shimmer
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                // Chips shimmer
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF696CFF).withOpacity(0.2),
                    const Color(0xFF5457E6).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Iconsax.document,
                size: 60,
                color: const Color(0xFF696CFF).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language.lblNoPolicies,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.info_circle,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              language.lblErrorLoadingPolicies,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _store.errorMessage ?? language.lblSomethingWentWrong,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Iconsax.refresh, color: Colors.white),
              label: Text(language.lblRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF696CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyList(List<PolicyModel> policies, bool isDark) {
    if (policies.isEmpty) {
      String message = language.lblNoPoliciesFound;
      switch (_tabController.index) {
        case 1:
          message = language.lblNoPendingPolicies;
          break;
        case 2:
          message = language.lblNoOverduePolicies;
          break;
        case 3:
          message = language.lblNoAcknowledgedPolicies;
          break;
      }
      return _buildEmptyState(isDark, message);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: policies.length,
      itemBuilder: (context, index) {
        final policy = policies[index];
        return PolicyItemWidget(
          policy: policy,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HRPolicyDetailScreen(
                  policyId: policy.policyId,
                  store: _store,
                ),
              ),
            ).then((_) {
              // Refresh the list when returning from detail screen
              _store.refreshData();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Observer(
        builder: (_) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header Section (56px)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          language.lblHRPolicies,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.filter, color: Colors.white),
                          tooltip: language.lblFilterByCategory,
                          onPressed: () => _showCategoryFilter(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: language.lblAll),
                      Tab(text: language.lblPending),
                      Tab(text: language.lblOverdue),
                      Tab(text: language.lblAcknowledged),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                      child: Column(
                        children: [
                          // Active Filter Chip
                          Observer(
                            builder: (_) {
                              return _store.selectedCategoryId != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                        bottom: 8,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF696CFF),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${language.lblCategory}: ${_store.categories.firstWhere((c) => c.id == _store.selectedCategoryId).name}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () {
                                                  _store.filterByCategory(null);
                                                },
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),

                          // Tab View
                          Expanded(
                            child: Observer(
                              builder: (_) {
                                if (_store.isLoading) {
                                  return _buildShimmerLoader(isDark);
                                }

                                if (_store.errorMessage != null) {
                                  return _buildErrorState(isDark);
                                }

                                return RefreshIndicator(
                                  onRefresh: _refreshData,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildPolicyList(_store.allPolicies, isDark),
                                      _buildPolicyList(_store.pendingPolicies, isDark),
                                      _buildPolicyList(_store.overduePolicies, isDark),
                                      _buildPolicyList(_store.acknowledgedPolicies, isDark),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPolicyStats(context),
        backgroundColor: const Color(0xFF696CFF),
        child: const Icon(Iconsax.chart, color: Colors.white),
      ),
    );
  }
}

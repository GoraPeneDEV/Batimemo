import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String loadingText;

  const CustomLoadingWidget({
    super.key,
    this.loadingText = "Loading attendance status, please wait...",
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildShimmerCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attendance Type Section
              Row(
                children: [
                  _buildShimmerBox(width: 120, height: 16, radius: 6),
                  const Spacer(),
                  _buildShimmerBox(width: 80, height: 32, radius: 8),
                ],
              ),
              const SizedBox(height: 8),
              _buildShimmerBox(width: double.infinity, height: 20, radius: 6),
              const SizedBox(height: 12),
              _buildShimmerBox(width: double.infinity, height: 50, radius: 10),

              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: appStore.isDarkModeOn
                    ? Colors.grey[700]
                    : const Color(0xFFE5E7EB),
              ),

              const SizedBox(height: 16),

              // Check-in Section
              _buildShimmerBox(width: 200, height: 14, radius: 6),
              const SizedBox(height: 12),
              _buildShimmerBox(width: double.infinity, height: 46, radius: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: appStore.isDarkModeOn
            ? Colors.grey[800]!
            : const Color(0xFFE5E7EB),
        highlightColor: appStore.isDarkModeOn
            ? Colors.grey[700]!
            : const Color(0xFFF9FAFB),
        child: child,
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? Colors.grey[800]
            : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

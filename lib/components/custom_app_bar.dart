import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';

import '../main.dart';

/// Reusable Custom App Bar Component
///
/// A flexible app bar widget for all screens across the app with:
/// - Customizable gradient background
/// - Rounded bottom corners
/// - Optional back button
/// - Optional right actions (filters, icons, etc.)
/// - Optional content widget below title (stats, badges, etc.)
/// - Dark mode support
///
/// Usage Examples:
/// ```dart
/// // Simple app bar with back button
/// CustomAppBar(
///   title: 'My Payslips',
///   showBackButton: true,
/// )
///
/// // App bar with filter action
/// CustomAppBar(
///   title: 'Modifiers',
///   showBackButton: true,
///   rightActions: [
///     AppBarActionButton(
///       icon: Iconsax.filter,
///       onPressed: () => _showFilters(),
///     ),
///   ],
/// )
///
/// // App bar with stats content
/// CustomAppBar(
///   title: 'Dashboard',
///   showBackButton: false,
///   contentWidget: _buildStatsCards(),
/// )
///
/// // App bar with custom colors (Attendance theme)
/// CustomAppBar(
///   title: 'Attendance',
///   gradientColors: AppBarGradients.attendance,
/// )
/// ```
class CustomAppBar extends StatelessWidget {
  /// Title text to display
  final String title;

  /// Subtitle text (optional)
  final String? subtitle;

  /// Show back button (default: true for sub-screens, false for main screens)
  final bool showBackButton;

  /// Right side action widgets (e.g., filter button, more menu)
  final List<Widget>? rightActions;

  /// Optional content widget below the title (e.g., stats, badges)
  /// If provided, the app bar will expand to accommodate this content
  final Widget? contentWidget;

  /// Custom height (if not provided, calculated based on content)
  final double? height;

  /// Gradient colors (defaults to purple gradient)
  final List<Color>? gradientColors;

  /// Border radius for bottom corners (default: 30)
  final double borderRadius;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.rightActions,
    this.contentWidget,
    this.height,
    this.gradientColors,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ??
                (appStore.isDarkModeOn
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)]),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row (title + actions)
              _buildHeaderRow(context),

              // Optional content widget
              if (contentWidget != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: contentWidget!,
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back button (if enabled)
          if (showBackButton) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right actions
          if (rightActions != null && rightActions!.isNotEmpty)
            ...rightActions!
          else
            // Default year badge if no custom actions
            _buildDefaultYearBadge(),
        ],
      ),
    );
  }

  Widget _buildDefaultYearBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.calendar, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            DateTime.now().year.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// App Bar Action Button
///
/// A reusable action button for the app bar with glass effect
class AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// App Bar Badge Widget
///
/// A reusable badge widget for displaying counts, status, etc.
class AppBarBadge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const AppBarBadge({
    super.key,
    this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// App Bar Stats Card (for content widget)
///
/// A compact stats card to display in the app bar content area
class AppBarStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const AppBarStatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            if (icon != null) const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Predefined gradient colors for different modules
class AppBarGradients {
  // Payroll - Purple gradient
  static const List<Color> payroll = [
    Color(0xFF696CFF),
    Color(0xFF5457E6),
  ];

  // Attendance - Blue gradient
  static const List<Color> attendance = [
    Color(0xFF4285F4),
    Color(0xFF1967D2),
  ];

  // Leave - Green gradient
  static const List<Color> leave = [
    Color(0xFF34A853),
    Color(0xFF0F9D58),
  ];

  // Expense - Orange gradient
  static const List<Color> expense = [
    Color(0xFFFF6B35),
    Color(0xFFFF8C42),
  ];

  // Documents - Teal gradient
  static const List<Color> documents = [
    Color(0xFF00BFA5),
    Color(0xFF00897B),
  ];

  // Approvals - Indigo gradient
  static const List<Color> approvals = [
    Color(0xFF5C6BC0),
    Color(0xFF3949AB),
  ];

  // Account/Profile - Deep Purple gradient
  static const List<Color> profile = [
    Color(0xFF7E57C2),
    Color(0xFF5E35B1),
  ];

  // Dashboard/Home - Default Purple gradient
  static const List<Color> dashboard = payroll;

  // Dark mode gradient (for any module in dark mode)
  static const List<Color> darkMode = [
    Color(0xFF1F2937),
    Color(0xFF111827),
  ];
}

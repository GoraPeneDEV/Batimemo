import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/app_constants.dart';
import '../../Utils/app_widgets.dart';
import '../../models/Settings/module_settings_model.dart';
import '../Account/account_screen.dart';
import '../Notification/notification_screen.dart';
import '../Leave/leave_dashboard_screen.dart';
import '../Expense/ExpenseScreen.dart';
import '../Loan/loan_screen.dart';
import '../Document/DocumentManagement/document_management_home_screen.dart';
import '../AttendanceHistory/attendance_history_screen.dart';
import '../AttendanceRegularization/attendance_regularization_list_screen.dart';
import '../DigitalId/digital_id_card_screen.dart';
// TODO: Approval screen needs to be implemented
// import '../Approvals/approval_screen.dart';
import '../Payroll/payroll_dashboard_screen.dart';
import '../Holidays/holiday_screen.dart';
import '../Project/project_dashboard_screen.dart';
import '../Calendar/calendar_screen.dart';
import '../NoticeBoard/notice_board_screen.dart';
import '../HRPolicies/hr_policies_screen.dart';
import '../Assets/assets_list_screen.dart';
import '../Disciplinary/warnings_list_screen.dart';
import 'Component/attendance_component.dart';
import 'Component/demo_mode_banner.dart';

/// Modern Home Screen - Employee Dashboard
/// Features gradient header, animated greetings, and enhanced UI
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _scrollOffset = 0.0;
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _init();
    _scrollController.addListener(_onScroll);
    _buildModulesList();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _init() async {
    await appStore.refreshAttendanceStatus();
    await sharedHelper.setAppVersionToPref();
  }

  void _buildModulesList() {
    modules.clear();
    // Loan Module
    if (moduleService.isLoanModuleEnabled()) {
      modules.add({
        'title': language.lblLoanRequests,
        'icon': Iconsax.wallet_3,
        'gradient': const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        'onTap': () => const LoanScreen().launch(context),
      });
    }

    // Documents Module
    if (moduleService.isDocumentModuleEnabled()) {
      modules.add({
        'title': language.lblDocuments,
        'icon': Iconsax.folder_2,
        'gradient': const [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
        'onTap': () => const DocumentManagementHomeScreen().launch(context),
      });
    }

    // Attendance History
    modules.add({
      'title': language.lblAttendanceHistory,
      'icon': Iconsax.clock,
      'gradient': const [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
      'onTap': () => AttendanceHistoryScreen().launch(context),
    });

    // Attendance Regularization
    modules.add({
      'title': language.lblRegularization,
      'icon': Iconsax.edit_2,
      'gradient': const [Color(0xFFFEAC5E), Color(0xFFC779D0)],
      'onTap': () => const AttendanceRegularizationListScreen().launch(context),
    });

    // Digital ID Card
    if (moduleService.isDigitalIdCardModuleEnabled()) {
      modules.add({
        'title': language.lblDigitalIDCard,
        'icon': Iconsax.card,
        'gradient': const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        'onTap': () => const DigitalIDCardScreen().launch(context),
      });
    }

    // Approvals - TODO: Implement ApprovalScreen
    // if (moduleService.isApprovalModuleEnabled() && getBoolAsync(approverPref)) {
    //   modules.add({
    //     'title': language.lblApprovals,
    //     'icon': Iconsax.task_square,
    //     'gradient': const [Color(0xFF43E97B), Color(0xFF38F9D7)],
    //     'onTap': () => ApprovalScreen().launch(context, isNewTask: true),
    //   });
    // }

    // Payroll Module
    if (moduleService.isPayrollModuleEnabled()) {
      modules.add({
        'title': language.lblPayroll,
        'icon': Iconsax.wallet_2,
        'gradient': const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        'onTap': () => const PayrollDashboardScreen().launch(context),
      });
    }

    // Holidays
    modules.add({
      'title': language.lblHolidays,
      'icon': Iconsax.sun_1,
      'gradient': const [Color(0xFFFD7B7D), Color(0xFFFDAD4D)],
      'onTap': () => const HolidayScreen().launch(context),
    });

    // Projects Module
    if (moduleService.isProjectModuleEnabled()) {
      modules.add({
        'title': 'Projets',
        'icon': Iconsax.briefcase,
        'gradient': const [Color(0xFF10B981), Color(0xFF059669)],
        'onTap': () => const ProjectDashboardScreen().launch(context),
      });
    }

    // Calendar - Paid Addon
    if (moduleService.isCalendarModuleEnabled()) {
      modules.add({
        'title': language.lblCalendar,
        'icon': Iconsax.calendar_1,
        'gradient': const [Color(0xFF667EEA), Color(0xFF764BA2)],
        'onTap': () => const CalendarScreen().launch(context),
      });
    }

    // NoticeBoard - Paid Addon
    if (moduleService.isNoticeModuleEnabled()) {
      modules.add({
        'title': language.lblNoticeBoard,
        'icon': Iconsax.clipboard_text,
        'gradient': const [Color(0xFF43E97B), Color(0xFF38F9D7)],
        'onTap': () => const NoticeBoard().launch(context),
      });
    }

    // HR Policies Module
    if (moduleService.isHrPoliciesModuleEnabled()) {
      modules.add({
        'title': language.lblHRPolicies,
        'icon': Iconsax.document_text,
        'gradient': const [Color(0xFF6A11CB), Color(0xFF2575FC)],
        'onTap': () => const HRPoliciesScreen().launch(context),
      });
    }

    // Assets Module
    if (moduleService.isAssetsModuleEnabled()) {
      modules.add({
        'title': language.lblAssets,
        'icon': Iconsax.box,
        'gradient': const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        'onTap': () => const AssetsListScreen().launch(context),
      });
    }

    // Disciplinary Module
    if (moduleService.isDisciplinaryActionsModuleEnabled()) {
      modules.add({
        'title': language.lblDisciplinary,
        'icon': Iconsax.warning_2,
        'gradient': const [Color(0xFFEF4444), Color(0xFFDC2626)],
        'onTap': () => const WarningsListScreen().launch(context),
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return language.lblGoodMorning;
    if (hour < 17) return language.lblGoodAfternoon;
    if (hour < 21) return language.lblGoodEvening;
    return language.lblGoodNight;
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 21) return '🌆';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: appStore.isDarkModeOn
                  ? [
                      const Color(0xFF1F2937),
                      const Color(0xFF111827),
                    ]
                  : [
                      const Color(0xFF696CFF),
                      const Color(0xFF5457E6),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Clean Simple Header
                _buildSimpleHeader(),

                // Main Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: appStore.isDarkModeOn
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          const SizedBox(height: 24),

                          // Greeting Card
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildGreetingCard(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Attendance Component
                          const AttendanceComponent(),

                          // Demo Mode Banner
                          if (getBoolAsync('isDemoCreds')) ...[
                            const SizedBox(height: 16),
                            const DemoModeBanner(),
                          ],

                          const SizedBox(height: 24),

                          // Modules Section Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              language.lblQuickActions,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: appStore.isDarkModeOn
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Modern Modules Grid
                          _buildModernModulesGrid(),

                          const SizedBox(height: 100),

                          // Footer
                          FooterSignature(
                            textColor: appStore.textPrimaryColor!,
                          ),

                          const SizedBox(height: 55),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Clean Simple Header
  Widget _buildSimpleHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Profile Image
          Hero(
            tag: 'profile',
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: profileImageWidget(size:20),
                ),
              ),
            ),
          ),
          14.width,

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sharedHelper.getFullName(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Text(
                  getStringAsync(designationPref),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).onTap(() => AccountScreen().launch(context)),
          ),

          // Notification Icon
          IconButton(
            icon: const Icon(
              Iconsax.notification,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => NotificationScreen().launch(context),
          ),
        ],
      ),
    );
  }

  /// Greeting Card with Time-based Message
  Widget _buildGreetingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Emoji Container
              Text(
                _getGreetingEmoji(),
                style: const TextStyle(fontSize: 40),
              ),
              16.width,

              // Greeting Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    2.height,
                    Text(
                      language.lblHaveAProductiveDay,
                      style: TextStyle(
                        fontSize: 13,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Modern Modules Grid with Gradients
  Widget _buildModernModulesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AlignedGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return _buildModuleCard(
            title: module['title'],
            icon: module['icon'],
            gradient: module['gradient'],
            onTap: module['onTap'],
          );
        },
      ),
    );
  }

  /// Individual Module Card with Gradient
  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gradient Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              10.height,

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[300]
                      : const Color(0xFF374151),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/main.dart';
import 'package:open_core_hr/screens/Home/Component/attendance_component.dart';
import 'package:open_core_hr/screens/Home/Component/demo_mode_banner.dart';
import 'package:open_core_hr/screens/Leave/leave_dashboard_screen.dart';
import 'package:open_core_hr/screens/Project/project_dashboard_screen.dart';
import 'package:open_core_hr/stores/project_store.dart';
import 'package:provider/provider.dart';

import '../../../models/Settings/module_settings_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_widgets.dart';
import '../../Approvals/approval_screen.dart';
import '../../AttendanceHistory/attendance_history_screen.dart';
import '../../AttendanceRegularization/attendance_regularization_list_screen.dart';
import '../../DigitalId/digital_id_card_screen.dart';
import '../../Document/DocumentManagement/document_management_home_screen.dart';
import '../../Expense/ExpenseScreen.dart';
import '../../Holidays/holiday_screen.dart';
import '../../Loan/loan_screen.dart';
import '../../Payslip/payslip_screen.dart';

class WidgetsComponent extends StatefulWidget {
  const WidgetsComponent({
    super.key,
  });

  @override
  State<WidgetsComponent> createState() => _WidgetsComponentState();
}

class _WidgetsComponentState extends State<WidgetsComponent> {
  ModuleSettingsModel? moduleSettings;
  List<Map<String, dynamic>> modules = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    buildModulesList();
    setState(() {});
    await sharedHelper.setAppVersionToPref();
  }

  buildModulesList() {
    // Leave Module
    if (moduleService.isLeaveModuleEnabled()) {
      modules.add({
        'title': 'Leaves',
        'icon': Icons.calendar_today,
        'onTap': () => const LeaveDashboardScreen().launch(context),
      });
    }

    // Project Module
    if (moduleService.isProjectModuleEnabled()) {
      modules.add({
        'title': 'Projets',
        'icon': Iconsax.briefcase,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Provider.value(
              value: context.read<ProjectStore>(),
              child: const ProjectDashboardScreen(),
            ),
          ),
        ),
      });
    }

    //Expense Module
    if (moduleService.isExpenseModuleEnabled()) {
      modules.add({
        'title': language.lblExpenseRequests,
        'icon': Icons.attach_money,
        'onTap': () => const ExpenseScreen().launch(context),
      });
    }

    //Loan Module
    if (moduleService.isLoanModuleEnabled()) {
      modules.add({
        'title': language.lblLoanRequests,
        'icon': Iconsax.money,
        'onTap': () => const LoanScreen().launch(context),
      });
    }

    //Documents Module
    if (moduleService.isDocumentModuleEnabled()) {
      modules.add({
        'title': 'Documents',
        'icon': Iconsax.folder_2,
        'onTap': () => const DocumentManagementHomeScreen().launch(context),
      });
    }

    //Attendance History
    modules.add({
      'title': language.lblAttendanceHistory,
      'icon': Icons.calendar_month_outlined,
      'onTap': () => AttendanceHistoryScreen().launch(context),
    });

    //Attendance Regularization
    modules.add({
      'title': 'Attendance Regularization',
      'icon': Iconsax.edit_2,
      'onTap': () => const AttendanceRegularizationListScreen().launch(context),
    });

    //Digital Id card
    if (moduleService.isDigitalIdCardModuleEnabled()) {
      modules.add({
        'title': language.lblDigitalIDCard,
        'icon': Icons.credit_card,
        'onTap': () => const DigitalIDCardScreen().launch(context),
      });
    }

    //Approvals
    if (moduleService.isApprovalModuleEnabled() &&
        getBoolAsync(approverPref)) {
      modules.add({
        'title': language.lblApprovals,
        'icon': Icons.assignment_turned_in_outlined,
        'onTap': () => const ApprovalScreen().launch(context),
      });
    }

    //Payslip
    if (moduleService.isPayrollModuleEnabled()) {
      modules.add({
        'title': language.lblPayslip,
        'icon': Icons.money,
        'onTap': () => const PayslipScreen().launch(context),
      });
    }

    //Holidays
    modules.add({
      'title': language.lblHolidays,
      'icon': Icons.calendar_today,
      'onTap': () => const HolidayScreen().launch(context),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttendanceComponent(),
            if (getBoolAsync('isDemoCreds')) DemoModeBanner(),
            const SizedBox(height: 10),
            Observer(
              builder: (_) => AlignedGridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3, // 3 Columns
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final item = modules[index];
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: item['onTap'],
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF696CFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item['icon'],
                                size: 22,
                                color: const Color(0xFF696CFF),
                              ),
                            ),
                            8.height,
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                height: 1.2,
                              ),
                            ).paddingSymmetric(horizontal: 6),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            100.height,
            FooterSignature(
              textColor: appStore.textPrimaryColor!,
            ),
            55.height,
          ],
        ),
      ),
    );
  }

}

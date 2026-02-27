import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/Settings/module_settings_model.dart';

import '../../Utils/app_widgets.dart';
import '../../main.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  bool isLoading = false;
  ModuleSettingsModel? moduleSettings;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setState(() => isLoading = true);
    await moduleService.refreshModuleSettings();
    moduleSettings = moduleService.getModuleSettings();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        language.lblModules,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () async {
              toast(language.lblRefreshing);
              await init();
              toast(language.lblRefreshed);
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: loadingWidgetMaker(),
            )
          : moduleSettings == null
              ? Center(child: Text(language.lblNoData, style: boldTextStyle()))
              : _buildModulesGrid(),
    );
  }

  // Build Grid View for Modules
  Widget _buildModulesGrid() {
    // List of modules and their statuses
    final modules = [
      {
        'name': language.lblAttendance,
        'enabled': moduleSettings!.isGeofenceModuleEnabled
      },
      {'name': language.lblApprovals, 'enabled': moduleSettings!.isApprovalModuleEnabled},
      {
        'name': language.lblLeaveRequests,
        'enabled': moduleSettings!.isLeaveModuleEnabled
      },
      {
        'name': language.lblExpenseRequests,
        'enabled': moduleSettings!.isExpenseModuleEnabled
      },
      {
        'name': language.lblDocumentRequests,
        'enabled': moduleSettings!.isDocumentModuleEnabled
      },
      {'name': language.lblLoanRequests, 'enabled': moduleSettings!.isLoanModuleEnabled},
      {
        'name': language.lblClientVisit,
        'enabled': moduleSettings!.isClientVisitModuleEnabled
      },
      {
        'name': language.lblProductOrdering,
        'enabled': moduleSettings!.isProductModuleEnabled
      },
      {
        'name': language.lblNoticeBoard,
        'enabled': moduleSettings!.isNoticeModuleEnabled
      },
      {
        'name': language.lblPaymentCollection,
        'enabled': moduleSettings!.isPaymentCollectionModuleEnabled
      },
      {
        'name': language.lblDynamicForm,
        'enabled': moduleSettings!.isDynamicFormModuleEnabled
      },
      {'name': language.lblTeamChat, 'enabled': moduleSettings!.isChatModuleEnabled},
      {
        'name': language.lblGeoFencing,
        'enabled': moduleSettings!.isGeofenceModuleEnabled
      },
      {
        'name': language.lblIPBasedAttendance,
        'enabled': moduleSettings!.isIpBasedAttendanceModuleEnabled
      },
      {'name': language.lblUIDLogin, 'enabled': moduleSettings!.isUidLoginModuleEnabled},
      {
        'name': language.lblOfflineTracking,
        'enabled': moduleSettings!.isOfflineTrackingModuleEnabled
      },
      {
        'name': language.lblPayrollPayslip,
        'enabled': moduleSettings!.isPayrollModuleEnabled
      },
      {
        'name': language.lblSalesTarget,
        'enabled': moduleSettings!.isSalesTargetModuleEnabled
      },
      {
        'name': language.lblDigitalID,
        'enabled': moduleSettings!.isDigitalIdCardModuleEnabled
      },
      {
        'name': language.lblQRCodeAttendance,
        'enabled': moduleSettings!.isQrCodeAttendanceModuleEnabled
      },
      {
        'name': language.lblDynamicQRAttendance,
        'enabled': moduleSettings!.isDynamicQrCodeAttendanceEnabled
      },
      {
        'name': language.lblBreakSystem,
        'enabled': moduleSettings!.isBreakModuleEnabled
      },
      {
        'name': language.lblAIChatbot,
        'enabled': moduleSettings!.isAiChatModuleEnabled
      },
      {
        'name': language.lblBiometricVerification,
        'enabled': moduleSettings!.isBiometricVerificationModuleEnabled
      },
      {
        'name': language.lblCalendar,
        'enabled': moduleSettings!.isCalendarModuleEnabled
      },
      {
        'name': language.lblRecruitment,
        'enabled': moduleSettings!.isRecruitmentModuleEnabled
      },
      {
        'name': language.lblAccounting,
        'enabled': moduleSettings!.isAccountingModuleEnabled
      },
      {
        'name': language.lblManagerApp,
        'enabled': moduleSettings!.isManagerAppModuleEnabled
      },
      {
        'name': language.lblFaceAttendance,
        'enabled': moduleSettings!.isFaceAttendanceModuleEnabled
      },
      {
        'name': language.lblNotes,
        'enabled': moduleSettings!.isNotesModuleEnabled
      },
      {
        'name': language.lblAssetsManagement,
        'enabled': moduleSettings!.isAssetsModuleEnabled
      },
      {
        'name': language.lblDisciplinaryActions,
        'enabled': moduleSettings!.isDisciplinaryActionsModuleEnabled
      },
      {
        'name': language.lblHRPolicies,
        'enabled': moduleSettings!.isHrPoliciesModuleEnabled
      },
      {
        'name': language.lblGoogleRecaptcha,
        'enabled': moduleSettings!.isGoogleRecaptchaModuleEnabled
      },
      {
        'name': language.lblSystemBackup,
        'enabled': moduleSettings!.isSystemBackupModuleEnabled
      },
      {
        'name': language.lblLearningManagement,
        'enabled': moduleSettings!.isLmsModuleEnabled
      },
      {
        'name': language.lblFaceAttendanceDevice,
        'enabled': moduleSettings!.isFaceAttendanceDeviceModuleEnabled
      },
      {
        'name': language.lblFieldSales,
        'enabled': moduleSettings!.isFieldSalesModuleEnabled
      },
      {
        'name': language.lblAgoraVideoCall,
        'enabled': moduleSettings!.isAgoraCallModuleEnabled
      },
      {
        'name': language.lblLocationManagement,
        'enabled': moduleSettings!.isLocationManagementModuleEnabled
      },
      {
        'name': language.lblOcConnect,
        'enabled': moduleSettings!.isOcConnectModuleEnabled
      },
      {
        'name': language.lblSiteAttendance,
        'enabled': moduleSettings!.isSiteModuleEnabled
      },
      {
        'name': language.lblDataImportExport,
        'enabled': moduleSettings!.isDataImportExportModuleEnabled
      },
      {
        'name': language.lblSosEmergency,
        'enabled': moduleSettings!.isSosModuleEnabled
      }
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: modules.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two cards per row
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.0, // Adjust height-to-width ratio
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          return _buildModuleCard(
            module['name'].toString(),
            bool.parse(
              module['enabled']!.toString(),
            ),
          );
        },
      ),
    );
  }

  // Build Individual Module Card
  Widget _buildModuleCard(String title, bool? isEnabled) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Static Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.widgets, // Replace with any desired static icon
                        size: 28,
                        color: appStore.appPrimaryColor,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                isEnabled == true ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEnabled == true
                                ? language.lblEnabled
                                : language.lblDisabled,
                            style: primaryTextStyle(color: white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Module Title
                  Expanded(
                    child: Text(
                      title,
                      style: boldTextStyle(size: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

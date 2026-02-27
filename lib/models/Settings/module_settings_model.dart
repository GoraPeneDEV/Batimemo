class ModuleSettingsModel {
  bool? isProductModuleEnabled;
  bool? isTaskModuleEnabled;
  bool? isNoticeModuleEnabled;
  bool? isDynamicFormModuleEnabled;
  bool? isExpenseModuleEnabled;
  bool? isLeaveModuleEnabled;
  bool? isDocumentModuleEnabled;
  bool? isChatModuleEnabled;
  bool? isLoanModuleEnabled;
  bool? isAiChatModuleEnabled;
  bool? isPaymentCollectionModuleEnabled;
  bool? isGeofenceModuleEnabled;
  bool? isIpBasedAttendanceModuleEnabled;
  bool? isUidLoginModuleEnabled;
  bool? isClientVisitModuleEnabled;
  bool? isOfflineTrackingModuleEnabled;
  bool? isBiometricVerificationModuleEnabled;
  bool? isBreakModuleEnabled;
  bool? isDynamicQrCodeAttendanceEnabled;
  bool? isQrCodeAttendanceModuleEnabled;
  bool? isPayrollModuleEnabled;
  bool? isSalesTargetModuleEnabled;
  bool? isDigitalIdCardModuleEnabled;
  bool? isApprovalModuleEnabled;
  bool? isCalendarModuleEnabled;
  bool? isRecruitmentModuleEnabled;
  bool? isAccountingModuleEnabled;
  bool? isManagerAppModuleEnabled;
  bool? isFaceAttendanceModuleEnabled;
  bool? isNotesModuleEnabled;
  bool? isAssetsModuleEnabled;
  bool? isDisciplinaryActionsModuleEnabled;
  bool? isHrPoliciesModuleEnabled;
  bool? isGoogleRecaptchaModuleEnabled;
  bool? isSystemBackupModuleEnabled;
  bool? isLmsModuleEnabled;
  bool? isFaceAttendanceDeviceModuleEnabled;
  bool? isFieldSalesModuleEnabled;
  bool? isAgoraCallModuleEnabled;
  bool? isLocationManagementModuleEnabled;
  bool? isOcConnectModuleEnabled;
  bool? isSiteModuleEnabled;
  bool? isDataImportExportModuleEnabled;
  bool? isSosModuleEnabled;

  ModuleSettingsModel({
    this.isProductModuleEnabled,
    this.isTaskModuleEnabled,
    this.isNoticeModuleEnabled,
    this.isDynamicFormModuleEnabled,
    this.isExpenseModuleEnabled,
    this.isLeaveModuleEnabled,
    this.isDocumentModuleEnabled,
    this.isChatModuleEnabled,
    this.isLoanModuleEnabled,
    this.isAiChatModuleEnabled,
    this.isPaymentCollectionModuleEnabled,
    this.isGeofenceModuleEnabled,
    this.isIpBasedAttendanceModuleEnabled,
    this.isUidLoginModuleEnabled,
    this.isClientVisitModuleEnabled,
    this.isOfflineTrackingModuleEnabled,
    this.isBiometricVerificationModuleEnabled,
    this.isBreakModuleEnabled,
    this.isDynamicQrCodeAttendanceEnabled,
    this.isQrCodeAttendanceModuleEnabled,
    this.isPayrollModuleEnabled,
    this.isSalesTargetModuleEnabled,
    this.isDigitalIdCardModuleEnabled,
    this.isApprovalModuleEnabled,
    this.isCalendarModuleEnabled,
    this.isRecruitmentModuleEnabled,
    this.isAccountingModuleEnabled,
    this.isManagerAppModuleEnabled,
    this.isFaceAttendanceModuleEnabled,
    this.isNotesModuleEnabled,
    this.isAssetsModuleEnabled,
    this.isDisciplinaryActionsModuleEnabled,
    this.isHrPoliciesModuleEnabled,
    this.isGoogleRecaptchaModuleEnabled,
    this.isSystemBackupModuleEnabled,
    this.isLmsModuleEnabled,
    this.isFaceAttendanceDeviceModuleEnabled,
    this.isFieldSalesModuleEnabled,
    this.isAgoraCallModuleEnabled,
    this.isLocationManagementModuleEnabled,
    this.isOcConnectModuleEnabled,
    this.isSiteModuleEnabled,
    this.isDataImportExportModuleEnabled,
    this.isSosModuleEnabled,
  });

  ModuleSettingsModel.fromJson(Map<String, dynamic> json) {
    isProductModuleEnabled = json['isProductModuleEnabled'];
    isTaskModuleEnabled = json['isTaskModuleEnabled'];
    isNoticeModuleEnabled = json['isNoticeModuleEnabled'];
    isDynamicFormModuleEnabled = json['isDynamicFormModuleEnabled'];
    isExpenseModuleEnabled = json['isExpenseModuleEnabled'];
    isLeaveModuleEnabled = json['isLeaveModuleEnabled'];
    isDocumentModuleEnabled = json['isDocumentModuleEnabled'];
    isChatModuleEnabled = json['isChatModuleEnabled'];
    isLoanModuleEnabled = json['isLoanModuleEnabled'];
    isAiChatModuleEnabled = json['isAiChatModuleEnabled'];
    isPaymentCollectionModuleEnabled = json['isPaymentCollectionModuleEnabled'];
    isGeofenceModuleEnabled = json['isGeofenceModuleEnabled'];
    isIpBasedAttendanceModuleEnabled = json['isIpBasedAttendanceModuleEnabled'];
    isUidLoginModuleEnabled = json['isUidLoginModuleEnabled'];
    isClientVisitModuleEnabled = json['isClientVisitModuleEnabled'];
    isOfflineTrackingModuleEnabled = json['isOfflineTrackingModuleEnabled'];
    isBiometricVerificationModuleEnabled =
        json['isBiometricVerificationModuleEnabled'];
    isBreakModuleEnabled = json['isBreakModuleEnabled'];
    isDynamicQrCodeAttendanceEnabled = json['isDynamicQrCodeAttendanceEnabled'];
    isQrCodeAttendanceModuleEnabled = json['isQrCodeAttendanceModuleEnabled'];
    isPayrollModuleEnabled = json['isPayrollModuleEnabled'];
    isSalesTargetModuleEnabled = json['isSalesTargetModuleEnabled'];
    isDigitalIdCardModuleEnabled = json['isDigitalIdCardModuleEnabled'];
    isApprovalModuleEnabled = json['isApprovalModuleEnabled'];
    isCalendarModuleEnabled = json['isCalendarModuleEnabled'] ?? false;
    isRecruitmentModuleEnabled = json['isRecruitmentModuleEnabled'] ?? false;
    isAccountingModuleEnabled = json['isAccountingModuleEnabled'] ?? false;
    isManagerAppModuleEnabled = json['isManagerAppModuleEnabled'] ?? false;
    isFaceAttendanceModuleEnabled = json['isFaceAttendanceModuleEnabled'] ?? false;
    isNotesModuleEnabled = json['isNotesModuleEnabled'] ?? false;
    isAssetsModuleEnabled = json['isAssetsModuleEnabled'] ?? false;
    isDisciplinaryActionsModuleEnabled = json['isDisciplinaryActionsModuleEnabled'] ?? false;
    isHrPoliciesModuleEnabled = json['isHrPoliciesModuleEnabled'] ?? false;
    isGoogleRecaptchaModuleEnabled = json['isGoogleRecaptchaModuleEnabled'] ?? false;
    isSystemBackupModuleEnabled = json['isSystemBackupModuleEnabled'] ?? false;
    isLmsModuleEnabled = json['isLmsModuleEnabled'] ?? false;
    isFaceAttendanceDeviceModuleEnabled = json['isFaceAttendanceDeviceModuleEnabled'] ?? false;
    isFieldSalesModuleEnabled = json['isFieldSalesModuleEnabled'] ?? false;
    isAgoraCallModuleEnabled = json['isAgoraCallModuleEnabled'] ?? false;
    isLocationManagementModuleEnabled = json['isLocationManagementModuleEnabled'] ?? false;
    isOcConnectModuleEnabled = json['isOcConnectModuleEnabled'] ?? false;
    isSiteModuleEnabled = json['isSiteModuleEnabled'] ?? false;
    isDataImportExportModuleEnabled = json['isDataImportExportModuleEnabled'] ?? false;
    isSosModuleEnabled = json['isSosModuleEnabled'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isProductModuleEnabled'] = isProductModuleEnabled;
    data['isTaskModuleEnabled'] = isTaskModuleEnabled;
    data['isNoticeModuleEnabled'] = isNoticeModuleEnabled;
    data['isDynamicFormModuleEnabled'] = isDynamicFormModuleEnabled;
    data['isExpenseModuleEnabled'] = isExpenseModuleEnabled;
    data['isLeaveModuleEnabled'] = isLeaveModuleEnabled;
    data['isDocumentModuleEnabled'] = isDocumentModuleEnabled;
    data['isChatModuleEnabled'] = isChatModuleEnabled;
    data['isLoanModuleEnabled'] = isLoanModuleEnabled;
    data['isAiChatModuleEnabled'] = isAiChatModuleEnabled;
    data['isPaymentCollectionModuleEnabled'] = isPaymentCollectionModuleEnabled;
    data['isGeofenceModuleEnabled'] = isGeofenceModuleEnabled;
    data['isIpBasedAttendanceModuleEnabled'] = isIpBasedAttendanceModuleEnabled;
    data['isUidLoginModuleEnabled'] = isUidLoginModuleEnabled;
    data['isClientVisitModuleEnabled'] = isClientVisitModuleEnabled;
    data['isOfflineTrackingModuleEnabled'] = isOfflineTrackingModuleEnabled;
    data['isBiometricVerificationModuleEnabled'] =
        isBiometricVerificationModuleEnabled;
    data['isBreakModuleEnabled'] = isBreakModuleEnabled;
    data['isDynamicQrCodeAttendanceEnabled'] = isDynamicQrCodeAttendanceEnabled;
    data['isQrCodeAttendanceModuleEnabled'] = isQrCodeAttendanceModuleEnabled;
    data['isPayrollModuleEnabled'] = isPayrollModuleEnabled;
    data['isSalesTargetModuleEnabled'] = isSalesTargetModuleEnabled;
    data['isDigitalIdCardModuleEnabled'] = isDigitalIdCardModuleEnabled;
    data['isApprovalModuleEnabled'] = isApprovalModuleEnabled;
    data['isCalendarModuleEnabled'] = isCalendarModuleEnabled;
    data['isRecruitmentModuleEnabled'] = isRecruitmentModuleEnabled;
    data['isAccountingModuleEnabled'] = isAccountingModuleEnabled;
    data['isManagerAppModuleEnabled'] = isManagerAppModuleEnabled;
    data['isFaceAttendanceModuleEnabled'] = isFaceAttendanceModuleEnabled;
    data['isNotesModuleEnabled'] = isNotesModuleEnabled;
    data['isAssetsModuleEnabled'] = isAssetsModuleEnabled;
    data['isDisciplinaryActionsModuleEnabled'] = isDisciplinaryActionsModuleEnabled;
    data['isHrPoliciesModuleEnabled'] = isHrPoliciesModuleEnabled;
    data['isGoogleRecaptchaModuleEnabled'] = isGoogleRecaptchaModuleEnabled;
    data['isSystemBackupModuleEnabled'] = isSystemBackupModuleEnabled;
    data['isLmsModuleEnabled'] = isLmsModuleEnabled;
    data['isFaceAttendanceDeviceModuleEnabled'] = isFaceAttendanceDeviceModuleEnabled;
    data['isFieldSalesModuleEnabled'] = isFieldSalesModuleEnabled;
    data['isAgoraCallModuleEnabled'] = isAgoraCallModuleEnabled;
    data['isLocationManagementModuleEnabled'] = isLocationManagementModuleEnabled;
    data['isOcConnectModuleEnabled'] = isOcConnectModuleEnabled;
    data['isSiteModuleEnabled'] = isSiteModuleEnabled;
    data['isDataImportExportModuleEnabled'] = isDataImportExportModuleEnabled;
    data['isSosModuleEnabled'] = isSosModuleEnabled;
    return data;
  }
}

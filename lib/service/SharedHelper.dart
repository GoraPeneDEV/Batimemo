import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_device_unique_id/flutter_device_unique_id_platform_interface.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/api/network_utils.dart';
import 'package:open_core_hr/models/OnBoarding/my_onboarding_screen.dart';
import 'package:open_core_hr/models/Settings/app_settings_model.dart';
import 'package:open_core_hr/screens/Login/LoginScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibration/vibration.dart';

import '../main.dart';
import '../screens/Permission/permissions_screen.dart';
import '../screens/org_choose_screen.dart';
import '../utils/app_constants.dart';

class SharedHelper {
  void vibrate() async {
    var result = await Vibration.hasVibrator();
    if (result ?? false) {
      Vibration.vibrate();
    }
  }

  Future<String> setAppVersionToPref() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    var versionString = '$version build($buildNumber)';
    setValue(appVersionPref, versionString);
    return versionString;
  }

  String getFullName() {
    return '${getStringAsync(firstNamePref)} ${getStringAsync(lastNamePref)}';
  }

  String getPhoneNumber() {
    return getStringAsync(phoneNumberPref);
  }

  String getProfileImage() {
    return getStringAsync(avatarPref);
  }

  String getDesignation() {
    var designation = getStringAsync(designationPref);
    return designation == '' ? 'N/A' : designation;
  }

  bool hasProfileImage() {
    return getStringAsync(avatarPref) != '';
  }

  String getEmployeeCode() {
    var code = getStringAsync(employeeCodePref);
    return code == '' ? 'N/A' : code;
  }

  String getEmail() {
    return getStringAsync(emailPref);
  }

  String getCompanyAddress() {
    return getStringAsync(appCompanyAddressPref);
  }

  String getCompanyName() {
    return getStringAsync(appCompanyNamePref);
  }

  void logout(BuildContext context) async {
    // Preserve SaaS mode before clearing preferences
    final wasSaaSMode = getIsSaaSMode();

    clearSharedPref();
    toast('Logged out successfully');

    if (wasSaaSMode) {
      OrgChooseScreen().launch(context, isNewTask: true);
    } else {
      LoginScreen().launch(context, isNewTask: true);
    }
  }

  void logoutAlt() async {
    clearSharedPref();
    toast('Logged out successfully');
  }

  Future<String?> getDeviceId() async {
    String? uuid;
    try {
      uuid = await FlutterDevicePlatform.instance.getUniqueId();
    } catch (e) {
      uuid = null;
    }

    return uuid;
  }

  // Device validation removed - only needed for Field Sales app

  Future<void> setAppSettings(AppSettingsModel settings) async {
    // SaaS Mode - await to ensure it's set before any API calls
    await setValue(isSaaSModePref, settings.isSaaSMode ?? false);

    // Demo Mode - await to ensure it's set before any API calls
    await setValue(isDemoModePref, settings.isDemoMode ?? false);

    // Store server base URL for socket service and other uses
    // Derived from central API URL
    await setValue('serverBaseUrl', getServerBaseUrl());

    // App Settings
    setValue(privacyPolicyUrlPref, settings.privacyPolicyUrl);
    setValue(appCurrencyPref, settings.currency);
    setValue(appCurrencySymbolPref, settings.currencySymbol);
    setValue(appDistanceUnitPref, settings.distanceUnit);
    setValue(appCountryPhoneCodePref, settings.countryPhoneCode);

    // Support Settings
    setValue(appSupportEmailPref, settings.supportEmail);
    setValue(appSupportPhonePref, settings.supportPhone);
    setValue(appSupportWhatsAppPref, settings.supportWhatsapp);
    setValue(appWebsiteUrlPref, settings.website);

    // Company Settings
    setValue(appCompanyNamePref, settings.companyName);
    setValue(appCompanyLogoPref, settings.companyLogo);
    setValue(appCompanyAddressPref, settings.companyAddress);
    setValue(appCompanyPhonePref, settings.companyPhone);
    setValue(appCompanyEmailPref, settings.companyEmail);
    setValue(appCompanyWebsitePref, settings.companyWebsite);
    setValue(appCompanyCountryPref, settings.companyCountry);
    setValue(appCompanyStatePref, settings.companyState);
  }

  bool isSettingsRefreshed() {
    return getBoolAsync(isSettingsRefreshedPref);
  }

  String getUserInitials() {
    return getStringAsync(firstNamePref).substring(0, 1).toUpperCase() +
        getStringAsync(lastNamePref).substring(0, 1).toUpperCase();
  }

  Future refreshAppSettings() async {
    var appSettings = await apiService.getAppSettings();
    if (appSettings != null) {
      await setAppSettings(appSettings);
      setValue(isSettingsRefreshedPref, true);
    }
    if (getBoolAsync(isLoggedInPref)) {
      await refreshUserData();
    }
  }

  Future refreshUserData() async {
    var user = await apiService.me();
    if (user != null) {
      await setValue(firstNamePref, user.firstName);
      await setValue(lastNamePref, user.lastName);
      await setValue(genderPref, user.gender);
      if (!user.avatar.isEmptyOrNull) {
        await setValue(avatarPref, user.avatar ?? '');
      }
      await setValue(locationActivityTrackingEnabledPref,
          user.locationActivityTrackingEnabled);
      await setValue(employeeCodePref, user.employeeCode);
      await setValue(approverPref, user.isApprover);
      await setValue(addressPref, user.address);
      await setValue(phoneNumberPref, user.phoneNumber);
      await setValue(alternateNumberPref, user.alternateNumber);
      await setValue(statusPref, user.status);
      await setValue(emailPref, user.email);
      await setValue(designationPref, user.designation);
    }
  }

  void routeBasedOnStatus(BuildContext context, String status) {
    sharedHelper.refreshAppSettings();

    if (status == 'onboarding') {
      toast('Please complete the onboarding process');
      const MyOnboardingScreen().launch(context, isNewTask: true);
      return;
    } else if (status == 'active') {
      // Skip device verification for Employee App - go directly to permissions
      PermissionScreen().launch(context, isNewTask: true);
    } else {
      toast('Unknown status. Please contact your administrator.');
    }
  }

  bool isAccountActive() {
    var status = getStringAsync(statusPref);
    return status == 'active';
  }

  bool isAccountOnboarding() {
    var status = getStringAsync(statusPref);
    return status == 'onboarding';
  }

  void login() async {
    addFirebaseToken();
  }

  void addFirebaseToken() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging
        .getToken()
        .then((value) => apiService.addFirebaseToken(platformName(), value!));
    messaging.subscribeToTopic('announcement');
    messaging.subscribeToTopic('chat');
    messaging.subscribeToTopic('attendance');
    messaging.subscribeToTopic('general');

    setValue(notiAnnouncementPref, true);
    setValue(notiAttendancePref, true);
    setValue(notiGeneralPref, true);
  }
}

import 'package:nb_utils/nb_utils.dart';

// Shared Pref
// SaaS Mode - dynamically determined from backend
const isSaaSModeFallback = false; // Fallback if settings not loaded yet
const isSaaSModePref = 'isSaaSModePref'; // SharedPreferences key for SaaS mode

/// Get SaaS mode - checks SharedPreferences first, falls back to constant
bool getIsSaaSMode() {
  return getBoolAsync(isSaaSModePref, defaultValue: isSaaSModeFallback);
}

// Demo Mode - dynamically determined from backend
const isDemoModeFallback = false; // Fallback if settings not loaded yet
const isDemoModePref = 'isDemoModePref'; // SharedPreferences key for demo mode

/// Get Demo mode - checks SharedPreferences first, falls back to constant
bool getIsDemoMode() {
  return getBoolAsync(isDemoModePref, defaultValue: isDemoModeFallback);
}
const mapsKey = '';
const agoraAppId = '';
const appOpenCount = 'appOpenCount';
const isDarkModeOnPref = 'isDarkModeOnPref';
const appColorPrimaryPref = 'appColorPrimaryPref';
const isFirstLaunchedPref = 'isFirstLaunchedPref';
const isLoggedInPref = 'isLoggedInPref';
const isTrackingOnPref = 'isTrackingOnPref';
const isDeviceVerifiedPref = 'isDeviceVerifiedPref';
const loginErrorReasonPref = 'loginErrorReasonPref';
const tokenPref = 'tokenPref';
const errorReasonPref = 'ErrorReasonPref';
/* User */
const userIdPref = 'userIdPref';
const firstNamePref = 'firstNamePref';
const lastNamePref = 'lastNamePref';
const genderPref = 'genderPref';
const avatarPref = 'avatarPref';
const addressPref = 'addressPref';
const phoneNumberPref = 'phoneNumberPref';
const alternateNumberPref = 'alternateNumberPref';
const statusPref = 'statusPref';
const joinedAtPref = 'joinedAtPref';
const employeeCodePref = 'employeeCodePref';
const emailPref = 'emailPref';
const designationPref = 'designationPref';
const locationActivityTrackingEnabledPref =
    'locationActivityTrackingEnabledPref';
const approverPref = 'approverPref';

const tenantPref = 'tenantIdPref';

const lastSyncRunAtPref = 'lastSyncRunAtPref';
const appVersionPref = 'appVersionPref';

// App Settings Preferences
const privacyPolicyUrlPref = 'privacyPolicyUrlPref';
const appCurrencyPref = 'currencyPref';
const appCurrencySymbolPref = 'currencySymbolPref';
const appDistanceUnitPref = 'distanceUnitPref';
const appCountryPhoneCodePref = 'CountryPhoneCodePref';

// Support Settings Preferences
const appSupportEmailPref = 'appSupportEmailPref';
const appSupportPhonePref = 'appSupportPhonePref';
const appSupportWhatsAppPref = 'appSupportWhatsAppPref';
const appWebsiteUrlPref = 'appWebsiteUrlPref';

// Company Settings Preferences
const appCompanyNamePref = 'companyNamePref';
const appCompanyLogoPref = 'appCompanyLogoPref';
const appCompanyAddressPref = 'companyAddressPref';
const appCompanyPhonePref = 'companyPhonePref';
const appCompanyEmailPref = 'companyEmailPref';
const appCompanyWebsitePref = 'companyWebsitePref';
const appCompanyCountryPref = 'companyCountryPref';
const appCompanyStatePref = 'companyStatePref';

const isSettingsRefreshedPref = 'isSettingsRefreshed';
const appModuleSettingsPref = 'appModuleSettingsPref';

//products link
const adminPanelBuyNowLink =
    'https://codecanyon.net/item/field-manager-laravel-flutter-field-employee-tracking-complete-hrms-solution-android-ios/50190332';
const employeeAppBuyNowLink =
    'https://codecanyon.net/item/employee-app-for-field-manager-saas-non-saas-employee-gps-tracking-application-flutter/48199612';

const saasPanelBuyNowLink =
    'https://codecanyon.net/item/fieldmanager-saas-hrms-employees-gps-realtime-tracking-attendance-payroll-system-net-flutter/45820223';

//Tracking
const latitudePref = 'latitude';
const longitudePref = 'longitude';
const locationCountPref = 'loccount';
const activityCountPref = 'activityCount';

const playStoreUrl = 'https://play.google.com/store/apps/details?id=';
const privacyPolicyUrl = 'privacy-policy.html';
const mainAppName = 'BatiMemo';
const appDescription = "$mainAppName is a open source AI Powered HRMS.";

/* font sizes*/
const fontSizeButton = 13;
const fontSizeSmall = 12.0;
const fontSizeSMedium = 14.0;
const fontSizeMedium = 16.0;
const fontSizeLargeMedium = 18.0;
const fontSizeNormal = 20.0;
const fontSizeLarge = 24.0;
const fontSizeXLarge = 30.0;
const fontSizeXXLarge = 35.0;

/* font type */
const fontRegular = 'Regular';
const fontMedium = 'Medium';
const fontSemibold = 'Semibold';
const fontBold = 'Bold';

// Default App Language
const defaultLanguage = 'en';

//Notifications
const notiAnnouncementPref = 'notiAnnouncementPref';
const notiAttendancePref = 'notiAttendancePref';
const notiGeneralPref = 'notiGeneralPref';

//Interval in seconds
const deviceStatusUpdateInterval = 1;
const deviceLocationUpdateInterval = 1;

/* Font size

 */
const smallSize = 12;
const mediumSize = 16;
const normalSize = 18;
const largeSize = 24;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/OnBoarding/my_onboarding_screen.dart';
import 'package:open_core_hr/screens/Permission/permissions_screen.dart';
import 'package:open_core_hr/screens/OfflineMode/offline_mode_screen.dart';
import 'package:open_core_hr/screens/SettingUp/setting_up_screen.dart';
import 'package:open_core_hr/screens/navigation_screen.dart';
import 'package:open_core_hr/screens/server_unreachable_screen.dart';
import 'package:open_core_hr/utils/app_images.dart';
import 'package:open_core_hr/utils/app_widgets.dart';

import '../main.dart';
import '../utils/app_constants.dart';
import 'org_choose_screen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      bool isAnyConnection = connectivityResult.any((element) =>
          element == ConnectivityResult.mobile ||
          element == ConnectivityResult.wifi);

      if (isAnyConnection) {
        // Fetch app settings first to get SaaS mode status
        // This is needed for both logged-in and non-logged-in users
        try {
          await sharedHelper.refreshAppSettings();
        } catch (e) {
          log('Error fetching app settings: $e');
          // Continue with cached/default values
        }

        if (getBoolAsync(isLoggedInPref)) {
          // Validate tenant exists for SaaS mode
          if (getIsSaaSMode()) {
            String tenantId = getStringAsync(tenantPref);
            if (tenantId.isEmpty) {
              // No tenant selected, go to org selection
              if (mounted) const OrgChooseScreen().launch(context, isNewTask: true);
              return;
            }
          }

          await moduleService.refreshModuleSettings();

          FirebaseCrashlytics.instance.setUserIdentifier(
            getStringAsync(
              sharedHelper.getEmail(),
            ),
          );

          if (!mounted) return;

          // Check if user needs to complete onboarding
          if (sharedHelper.isAccountOnboarding()) {
            toast('Please complete the onboarding process');
            MyOnboardingScreen().launch(context, isNewTask: true);
            return;
          }

          // Go to main app - permission check handled in NavigationScreen
          const NavigationScreen().launch(context, isNewTask: true);
        } else {
          if (!mounted) return;
          if (getIsSaaSMode()) {
            const OrgChooseScreen().launch(context, isNewTask: true);
          } else {
            const SettingUpScreen().launch(context, isNewTask: true);
          }
        }
      } else {
        if (!mounted) return;
        const OfflineModeScreen().launch(context, isNewTask: true);
      }
    } catch (e) {
      log('Exception at splash screen: $e');
      if (!mounted) return;
      if (getBoolAsync(isLoggedInPref) && getBoolAsync(isTrackingOnPref)) {
        const OfflineModeScreen().launch(context, isNewTask: true);
      } else {
        //Logout user if token is expired
        if (e.toString().contains('Please login again')) {
          log('Token expired');
          if (getIsSaaSMode()) {
            sharedHelper.logoutAlt();
            if (!mounted) return;
            const OrgChooseScreen().launch(context, isNewTask: true);
          } else {
            sharedHelper.logoutAlt();
            if (!mounted) return;
            const SettingUpScreen().launch(context, isNewTask: true);
          }
        } else {
          const ServerUnreachableScreen().launch(context, isNewTask: true);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Scaffold(
      body: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo Section
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with gradient container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          appLogoWhiteImg,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name
                      const Text(
                        mainAppName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Application',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Loading Indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer Credits
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FooterSignature(
                  textColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

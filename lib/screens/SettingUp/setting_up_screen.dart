import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Utils/app_constants.dart';
import '../../main.dart';
import '../Permission/permissions_screen.dart';
import '../Login/LoginScreen.dart';
import '../navigation_screen.dart';

class SettingUpScreen extends StatefulWidget {
  const SettingUpScreen({super.key});

  @override
  State<SettingUpScreen> createState() => _SettingUpScreenState();
}

class _SettingUpScreenState extends State<SettingUpScreen> {
  bool isDeviceVerified = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await sharedHelper.setAppVersionToPref();
    await sharedHelper.refreshAppSettings();
    await moduleService.refreshModuleSettings();

    await checkDeviceByUid();

    if (getBoolAsync(isLoggedInPref)) {
      if (!mounted) return;

      // Go to main app - permission check handled in NavigationScreen
      const NavigationScreen().launch(context, isNewTask: true);
    } else {
      if (!mounted) return;
      LoginScreen(
        isDeviceVerified: isDeviceVerified,
      ).launch(context, isNewTask: true);
    }
  }

  Future checkDeviceByUid() async {
    if (!moduleService.isUidLoginModuleEnabled()) return;
    try {
      var deviceId = await sharedHelper.getDeviceId();
      if (!deviceId.isEmptyOrNull) {
        isDeviceVerified = await apiService.checkDeviceUid(deviceId!);
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          final isDark = appStore.isDarkModeOn;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Section (56px fixed height)
                  _buildHeader(isDark),
                  // Content Area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: Container(
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                        child: _buildContent(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              language.lblSettingUp,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          width: context.width() * 0.9,
          padding: const EdgeInsets.all(24),
          child: _buildLoadingCard(isDark),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie Animation with purple gradient background
            Stack(
              alignment: Alignment.center,
              children: [
                // Purple gradient circular background
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF696CFF).withOpacity(0.2),
                        const Color(0xFF5457E6).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Lottie Animation
                SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/system-setting.json',
                    repeat: false,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Status Text
            Text(
              '${language.lblSettingThingsUpPleaseWait}...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${language.lblThisWillOnlyTakeAFewSeconds}.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Purple Circular Progress Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF696CFF) : const Color(0xFF5457E6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

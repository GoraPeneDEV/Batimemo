import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Utils/app_constants.dart';
import '../Utils/app_widgets.dart';
import '../main.dart';
import 'Permission/permissions_screen.dart';
import 'Login/LoginScreen.dart';
import 'navigation_screen.dart';

class ServerUnreachableScreen extends StatefulWidget {
  const ServerUnreachableScreen({super.key});

  @override
  State<ServerUnreachableScreen> createState() =>
      _ServerUnreachableScreenState();
}

class _ServerUnreachableScreenState extends State<ServerUnreachableScreen> {
  bool isLoading = false;

  void checkStatus() async {
    setState(() {
      isLoading = true;
    });
    try {
      setState(() {});
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      if (getBoolAsync(isLoggedInPref)) {
        await sharedHelper.refreshAppSettings();
        toast(language.lblBackOnline);

        if (!mounted) return;

        // Go to main app - permission check handled in NavigationScreen
        const NavigationScreen().launch(context, isNewTask: true);
      } else {
        const LoginScreen().launch(context, isNewTask: true);
        return;
      }
    } catch (e) {
      toast(language.lblServerUnreachable);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        backgroundColor: appStore.isDarkModeOn
            ? const Color(0xFF111827)
            : const Color(0xFFF3F4F6),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            language.lblServerUnreachable,
            style: TextStyle(
              color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Main Card Container
                  Container(
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
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            appStore.isDarkModeOn ? 0.3 : 0.1
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Lottie Animation
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Lottie.asset(
                            'assets/animations/offline_server.json',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          language.lblServerUnreachable,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          language.lblWeAreUnableToConnectToTheServerPleaseTryAgainLater,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tips Card
                  Container(
                    decoration: BoxDecoration(
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF1F2937)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            appStore.isDarkModeOn ? 0.3 : 0.04
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF696CFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF696CFF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              language.lblTips,
                              style: TextStyle(
                                color: appStore.isDarkModeOn
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTipItem(
                          language.lblCheckYourInternetConnection,
                          Icons.wifi_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildTipItem(
                          language.lblMakeSureServerIsRunning,
                          Icons.dns_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildTipItem(
                          language.lblContactITAdministrator,
                          Icons.support_agent_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Retry Button
                  SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: appStore.isDarkModeOn
                                    ? const Color(0xFF1F2937)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      appStore.isDarkModeOn ? 0.3 : 0.04
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        appStore.isDarkModeOn
                                            ? const Color(0xFF696CFF)
                                            : const Color(0xFF696CFF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    language.lblReconnecting,
                                    style: TextStyle(
                                      color: appStore.isDarkModeOn
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: checkStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF696CFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              shadowColor: const Color(0xFF696CFF).withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.refresh_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  language.lblRetry,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: appStore.isDarkModeOn
              ? Colors.grey[400]
              : const Color(0xFF6B7280),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

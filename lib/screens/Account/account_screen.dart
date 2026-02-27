import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/ChangePassword/change_password_screen.dart';
import 'package:open_core_hr/screens/Settings/modules_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_widgets.dart';
import '../DigitalId/digital_id_card_screen.dart';
import '../Support/support_screen.dart';
import '../language_screen.dart';
import '../navigation_screen.dart';

class AccountScreen extends StatefulWidget {
  static String tag = '/AccountScreen';
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late double width;
  bool isNotificationEnabled = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    sharedHelper.refreshUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Observer(
      builder: (_) => Scaffold(
        body: isLoading
            ? Center(child: loadingWidgetMaker())
            : Container(
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
                      // Merged Header with Profile
                      _buildHeaderWithProfile(),

                      // Content with rounded corners
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          child: Container(
                            color: appStore.isDarkModeOn
                                ? const Color(0xFF111827)
                                : const Color(0xFFF3F4F6),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                          20.height,
                          _buildSectionHeader(language.lblGeneral),
                          8.height,

                    // General Settings
                    _buildSettingsItem(
                      title: language.lblChangeLanguage,
                      icon: Iconsax.language_square,
                      onTap: () => const LanguageScreen().launch(context),
                    ),
                    _buildSettingsItem(
                      title: language.lblDarkMode,
                      icon:
                          appStore.isDarkModeOn ? Iconsax.sun_1 : Iconsax.moon,
                      trailing: Switch(
                        value: appStore.isDarkModeOn,
                        onChanged: (s) => appStore.toggleDarkMode(value: s),
                        activeTrackColor: appStore.appColorPrimary,
                        activeColor: white,
                      ),
                    ),
                    _buildSettingsItem(
                      title: language.lblNotification,
                      icon: Iconsax.notification,
                      trailing: Switch(
                        value: isNotificationEnabled,
                        onChanged: (value) async {
                          var instance = FirebaseMessaging.instance;
                          if (value) {
                            instance.subscribeToTopic('announcement');
                          } else {
                            instance.unsubscribeFromTopic('announcement');
                          }
                          setState(() => isNotificationEnabled = value);
                        },
                        activeTrackColor: appStore.appColorPrimary,
                        activeColor: white,
                      ),
                    ),
                    _buildSettingsItem(
                      title: language.lblSupport,
                      icon: Iconsax.support,
                      onTap: () => const SupportScreen().launch(context),
                    ),
                    _buildSettingsItem(
                      title: language.lblRateUs,
                      icon: Iconsax.star,
                      onTap: () async {
                        PackageInfo.fromPlatform().then((value) async {
                          String package = value.packageName;
                          launchUrl(Uri.parse('$playStoreUrl$package'));
                        });
                      },
                    ),
                    _buildSettingsItem(
                      title: language.lblShareApp,
                      icon: Iconsax.share,
                      onTap: () async {
                        PackageInfo.fromPlatform().then((value) async {
                          String package = value.packageName;
                          await Share.share(
                              'Download $mainAppName from Play Store\n\n\n$playStoreUrl$package');
                        });
                      },
                    ),

                          20.height,
                          _buildSectionHeader(language.lblSettings),
                          8.height,

                          // Settings Items Integrated
                    _buildSettingsItem(
                      title: language.lblRefreshAppConfiguration,
                      icon: Iconsax.refresh,
                      onTap: () async {
                        await sharedHelper.refreshAppSettings();
                        toast(language.lblSettingsRefreshed);
                      },
                    ),
                    _buildSettingsItem(
                      title: language.lblModulesStatus,
                      icon: Iconsax.setting_2,
                      onTap: () => const ModulesScreen().launch(context),
                    ),
                    _buildSettingsItem(
                      title: language.lblChangePassword,
                      icon: Iconsax.lock,
                      onTap: () => const ChangePasswordScreen().launch(context),
                    ),

                          40.height,

                          // Logout Button
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  showConfirmDialog(
                                    context,
                                    language.lblDoYouWantToLogoutFromTheApp,
                                    positiveText: language.lblYes,
                                    negativeText: language.lblNo,
                                    onAccept: () {
                                      if (!mounted) return;
                                      sharedHelper.logout(context);
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Iconsax.logout,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    10.width,
                                    Text(
                                      language.lblLogout,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          30.height,

                          // App Version
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  getStringAsync(appVersionPref),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: appStore.isDarkModeOn
                                        ? Colors.grey[500]
                                        : const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (getStringAsync('organization').isNotEmpty) ...[
                                  4.height,
                                  Text(
                                    '${language.lblOrganization}: ${getStringAsync('organization')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[600]
                                          : const Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                                    30.height,
                                  ],
                                ),
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

  // Merged Header with Profile Widget
  Widget _buildHeaderWithProfile() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            language.lblAccount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          20.height,

          // Profile Card on gradient background
          Container(
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile Image with white border (no gradient)
                    Hero(
                      tag: 'profile',
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: profileImageWidget(size: 20),
                        ),
                      ),
                    ),
                    14.width,

                    // Employee Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sharedHelper.getFullName(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: appStore.isDarkModeOn
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          4.height,
                          Text(
                            getStringAsync(designationPref),
                            style: TextStyle(
                              fontSize: 13,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    // ID Card Icon Button
                    if (moduleService.isDigitalIdCardModuleEnabled())
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF696CFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.card,
                              color: Color(0xFF696CFF), size: 22),
                          onPressed: () {
                            DigitalIDCardScreen().launch(context);
                          },
                        ),
                      ),
                  ],
                ),

                16.height,

                // Divider
                Container(
                  height: 1,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]
                      : const Color(0xFFE5E7EB),
                ),

                16.height,

                // Contact Details
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Iconsax.call,
                        label: language.lblPhone,
                        value: sharedHelper.getPhoneNumber(),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: _buildInfoItem(
                        icon: Iconsax.user_tag,
                        label: language.lblEmployeeCode,
                        value: sharedHelper.getEmployeeCode(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: const Color(0xFF696CFF),
            ),
            6.width,
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        4.height,
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: appStore.isDarkModeOn
              ? Colors.white
              : const Color(0xFF111827),
        ),
      ),
    );
  }

  // Reusable Settings Item Widget
  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                14.width,
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[500]
                          : const Color(0xFF9CA3AF),
                      size: 20,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

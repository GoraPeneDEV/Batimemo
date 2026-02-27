import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/main.dart';
import 'package:open_core_hr/api/network_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Utils/app_constants.dart';

class DemoModeBanner extends StatefulWidget {
  const DemoModeBanner({Key? key}) : super(key: key);

  @override
  State<DemoModeBanner> createState() => _DemoModeBannerState();
}

class _DemoModeBannerState extends State<DemoModeBanner>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _isExpanded = false;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: _isExpanded
              ? const EdgeInsets.all(16)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF696CFF),
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
        child: _isExpanded
            ? Column(
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
                          Icons.info_outline,
                          color: Color(0xFF696CFF),
                          size: 20,
                        ),
                      ),
                      10.width,
                      Text(
                        language.lblDemoModeActive,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                      ),
                    ],
                  ),
                  12.height,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF111827)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: appStore.isDarkModeOn
                            ? Colors.grey[700]!
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF696CFF),
                              size: 16,
                            ),
                            6.width,
                            Expanded(
                              child: Text(
                                getStringAsync(emailPref),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: appStore.isDarkModeOn
                                      ? Colors.grey[300]
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  10.height,
                  Text(
                    language.lblLoginToAdminPanel,
                    style: TextStyle(
                      fontSize: 12,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  8.height,
                  Text(
                    language.lblUseTenantLoginButton,
                    style: TextStyle(
                      fontSize: 12,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  12.height,
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final adminPanelUrl = getServerBaseUrl();
                        log(adminPanelUrl);
                        launchUrl(Uri.parse(adminPanelUrl),
                            mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(
                        Icons.open_in_browser,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        language.lblVisitAdminPanel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF696CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF696CFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF696CFF),
                        size: 18,
                      ),
                    ),
                    8.width,
                    Text(
                      language.lblDemoDetails,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.expand_more,
                      color: Color(0xFF696CFF),
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

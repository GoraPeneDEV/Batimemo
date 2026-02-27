import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../utils/app_constants.dart';

class SupportComponent extends StatefulWidget {
  const SupportComponent({super.key});

  @override
  State<SupportComponent> createState() => _SupportComponentState();
}

//TODO: Link not opening issue need to fix
class _SupportComponentState extends State<SupportComponent> {
  String supportEmail = '';
  String supportPhone = '';
  String supportWhatsApp = '';
  String website = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() => isLoading = true);

    supportEmail = getStringAsync(appSupportEmailPref);
    supportPhone = getStringAsync(appSupportPhonePref);
    supportWhatsApp = getStringAsync(appSupportWhatsAppPref);
    website = getStringAsync(appWebsiteUrlPref);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(color: appStore.appPrimaryColor),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Row - 2 buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildSupportButton(
                      icon: Icons.call,
                      label: language.lblCallSupport,
                      onTap: () => _makePhoneCall(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSupportButton(
                      icon: Icons.email,
                      label: language.lblMailSupport,
                      onTap: () => _sendEmail(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Second Row - 2 buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildSupportButton(
                      icon: Icons.message,
                      label: language.lblWhatsApp,
                      onTap: () => _openWhatsApp(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSupportButton(
                      icon: Icons.web,
                      label: language.lblVisitWebsite,
                      onTap: () => _openWebsite(),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  // Reusable Support Button
  Widget _buildSupportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appStore.appPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: primaryTextStyle(size: 14)),
      ],
    );
  }

  // Open Phone Call
  Future<void> _makePhoneCall() async {
    final Uri url = Uri.parse("tel:$supportPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      toast(language.lblUnableToMakePhoneCall);
    }
  }

  // Send Email
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: Uri.encodeComponent(
        'subject=I need help from $mainAppName Employee App',
      ),
    );
    try {
      await launchUrl(emailUri);
    } catch (e) {
      toast(language.lblUnableToSendEmail);
    }
  }

  // Open WhatsApp
  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/$supportWhatsApp");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      toast(language.lblUnableToOpenWhatsApp);
    }
  }

  // Open Website
  Future<void> _openWebsite() async {
    final Uri url = Uri.parse(website);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      toast(language.lblUnableToOpenWebsite);
    }
  }
}

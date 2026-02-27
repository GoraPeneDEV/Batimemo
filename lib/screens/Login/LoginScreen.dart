import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Permission/permissions_screen.dart';

import '../../Utils/app_widgets.dart';
import '../../main.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_data_provider.dart';
import '../../utils/app_images.dart';
import '../ForgotPassword/ForgotPassword.dart';
import '../org_choose_screen.dart';
import 'LoginStore.dart';

class LoginScreen extends StatefulWidget {
  final bool isDeviceVerified;
  static String tag = '/LoginScreen';

  const LoginScreen({super.key, this.isDeviceVerified = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final LoginStore _loginStore = LoginStore();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    init();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  init() async {
    await sharedHelper.refreshAppSettings();
    await moduleService.refreshModuleSettings();
    _loginStore.setupValidations();
  }

  void _showLanguageSelector() {
    final languages = languageList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Observer(
        builder: (_) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF696CFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Color(0xFF696CFF),
                        size: 24,
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.lblLanguage,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: appStore.isDarkModeOn
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          4.height,
                          Text(
                            language.lblSupportLanguage,
                            style: TextStyle(
                              fontSize: 13,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: appStore.isDarkModeOn
                    ? Colors.grey[700]
                    : const Color(0xFFE5E7EB),
              ),
              // Language list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected =
                        appStore.selectedLanguageCode == lang.languageCode;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await appStore.setLanguage(
                            lang.languageCode!,
                            context: context,
                          );
                          setState(() {});
                          if (mounted) {
                            Navigator.pop(context);
                            toast(language.lblLanguageChanged);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF696CFF).withOpacity(0.08)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              // Flag
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  lang.flag.validate(),
                                  width: 28,
                                  height: 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 28,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.flag,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              16.width,
                              // Language name
                              Expanded(
                                child: Text(
                                  lang.name.validate(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF696CFF)
                                        : appStore.isDarkModeOn
                                            ? Colors.white
                                            : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              // Check mark for selected
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF696CFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget demoModeWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB44F), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.science_outlined,
            color: Colors.white,
            size: 36,
          ),
          10.height,
          const Text(
            'App is in demo mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          6.height,
          const Text(
            'You can login with demo employee id and password',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          16.height,
          Observer(
            builder: (_) => _loginStore.isDemoRegisterBtnLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          var result = await _loginStore.createDemoUser();
                          if (result.toLowerCase() == 'active') {
                            if (!mounted) return;
                            sharedHelper.refreshAppSettings();
                            PermissionScreen().launch(context, isNewTask: true);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Text(
                            'Register as a demo employee',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: context.width(),
        height: context.height(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Login form content
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Observer(
                        builder: (_) => Column(
                          children: [
                            // App Logo with modern design
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                appLogoImg,
                                height: 60,
                                width: 60,
                              ),
                            ),
                            16.height,

                            // Modern Login Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Name
                                    Text(
                                      mainAppName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF696CFF),
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    6.height,
                                    Text(
                                      language.lblPleaseLoginToContinue,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    24.height,

                                    // **Device Verified Case**
                                    widget.isDeviceVerified
                                        ? Column(
                                            children: [
                                              Lottie.asset(
                                                'assets/animations/screen_tap.json',
                                                height: 150,
                                                repeat: true,
                                              ),
                                              16.height,
                                              Text(
                                                language
                                                    .lblLooksLikeYouAlreadyRegisteredThisDeviceYouCanUseOneTapLogin,
                                                textAlign: TextAlign.center,
                                                style: secondaryTextStyle(size: 14),
                                              ),
                                              20.height,
                                              _loginStore.isLoginWithUidBtnLoading
                                                  ? loadingWidgetMaker()
                                                  : AppButton(
                                                      text: language.lblOneTapLogin,
                                                      color: appStore.appColorPrimary,
                                                      elevation: 4,
                                                      textColor: Colors.white,
                                                      shapeBorder: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      onTap: () async {
                                                        hideKeyboard(context);
                                                        var result =
                                                            await _loginStore.loginWithUid();
                                                        sharedHelper.routeBasedOnStatus(
                                                            context, result);
                                                      },
                                                    ),
                                              12.height,
                                              Text(
                                                language
                                                    .lblIfYouWantToLoginWithDifferentAccountPleaseContactAdministrator,
                                                textAlign: TextAlign.center,
                                                style: secondaryTextStyle(size: 12),
                                              ),
                                            ],
                                          )
                                        // **Regular Login Form**
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Email/Username Field
                                              Observer(
                                                builder: (_) => Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF9FAFB),
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(
                                                      color: _loginStore.error.employeeId !=
                                                                  null &&
                                                              _loginStore
                                                                  .error.employeeId!.isNotEmpty
                                                          ? const Color(0xFFEF4444)
                                                          : const Color(0xFFE5E7EB),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: TextField(
                                                    onChanged: (value) =>
                                                        _loginStore.employeeId = value,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF111827),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: language.lblEmail,
                                                      hintStyle: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[500],
                                                      ),
                                                      prefixIcon: const Icon(
                                                        Icons.email_outlined,
                                                        color: Color(0xFF696CFF),
                                                        size: 20,
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14,
                                                      ),
                                                      errorText:
                                                          _loginStore.error.employeeId,
                                                      errorStyle: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFFEF4444),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              16.height,

                                              // Password Field
                                              Observer(
                                                builder: (_) => Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF9FAFB),
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(
                                                      color: _loginStore.error.password !=
                                                                  null &&
                                                              _loginStore
                                                                  .error.password!.isNotEmpty
                                                          ? const Color(0xFFEF4444)
                                                          : const Color(0xFFE5E7EB),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: TextField(
                                                    onChanged: (value) =>
                                                        _loginStore.password = value,
                                                    obscureText: !_isPasswordVisible,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF111827),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: language.lblPassword,
                                                      hintStyle: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[500],
                                                      ),
                                                      prefixIcon: const Icon(
                                                        Icons.lock_outline,
                                                        color: Color(0xFF696CFF),
                                                        size: 20,
                                                      ),
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                          _isPasswordVisible
                                                              ? Icons.visibility_outlined
                                                              : Icons.visibility_off_outlined,
                                                          color: Colors.grey[400],
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _isPasswordVisible =
                                                                !_isPasswordVisible;
                                                          });
                                                          HapticFeedback.lightImpact();
                                                        },
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14,
                                                      ),
                                                      errorText: _loginStore.error.password,
                                                      errorStyle: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFFEF4444),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              12.height,

                                              // Forgot Password
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    HapticFeedback.lightImpact();
                                                    const ForgotPassword().launch(context);
                                                  },
                                                  child: Text(
                                                    language.lblForgotPassword,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF696CFF),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              24.height,

                                              // Login Button
                                              _loginStore.isLoading ||
                                                      _loginStore.isDemoRegisterBtnLoading ||
                                                      _loginStore.isLoginWithUidBtnLoading
                                                  ? Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF696CFF)
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius.circular(14),
                                                      ),
                                                      child: const Center(
                                                        child: SizedBox(
                                                          width: 22,
                                                          height: 22,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<Color>(
                                                              Color(0xFF696CFF),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: double.infinity,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        gradient: const LinearGradient(
                                                          colors: [
                                                            Color(0xFF696CFF),
                                                            Color(0xFF8B7EFF)
                                                          ],
                                                          begin: Alignment.centerLeft,
                                                          end: Alignment.centerRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(14),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(0xFF696CFF)
                                                                .withOpacity(0.25),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            HapticFeedback.mediumImpact();
                                                            hideKeyboard(context);
                                                            _loginStore.validateAll();
                                                            if (_loginStore.canLogin) {
                                                              var result =
                                                                  await _loginStore.login();
                                                              sharedHelper.routeBasedOnStatus(
                                                                  context, result);
                                                            }
                                                          },
                                                          borderRadius:
                                                              BorderRadius.circular(14),
                                                          child: Center(
                                                            child: Text(
                                                              language.lblLogin,
                                                              style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.white,
                                                                letterSpacing: 0.3,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),

                            // Demo Mode Widget
                            if (getIsDemoMode() && !widget.isDeviceVerified) ...[
                              16.height,
                              demoModeWidget(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Company Switcher (SaaS mode)
                  if (getIsSaaSMode())
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            10.width,
                            Text(
                              appStore.centralDomainURL,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            10.width,
                            const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          ],
                        ),
                      ).onTap(() {
                        HapticFeedback.lightImpact();
                        OrgChooseScreen().launch(context);
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
              // Language Switcher Button - Top Right
              Positioned(
                top: 8,
                right: 8,
                child: Observer(
                  builder: (_) {
                    final currentLang = languageList().firstWhere(
                      (l) => l.languageCode == appStore.selectedLanguageCode,
                      orElse: () => languageList().first,
                    );
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showLanguageSelector();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  currentLang.flag.validate(),
                                  width: 20,
                                  height: 14,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.language,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              8.width,
                              Text(
                                currentLang.name.validate(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              4.width,
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

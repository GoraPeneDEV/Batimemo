import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Permission/permissions_screen.dart';
import '../../utils/design_system.dart';
import '../../main.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_images.dart';
import '../ForgotPassword/ForgotPassword.dart';
import '../language_screen.dart';
import '../org_choose_screen.dart';
import 'LoginStore.dart';

class ModernLoginScreen extends StatefulWidget {
  final bool isDeviceVerified;
  static String tag = '/ModernLoginScreen';

  const ModernLoginScreen({super.key, this.isDeviceVerified = false});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with TickerProviderStateMixin {
  final LoginStore _loginStore = LoginStore();
  var selectedLanguage = getSelectedLanguageModel();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Focus nodes for better UX
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    init();
    _initAnimations();
  }

  void _initAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Slide animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  init() async {
    await sharedHelper.refreshAppSettings();
    await moduleService.refreshModuleSettings();
    _loginStore.setupValidations();
  }

  Widget _buildLanguageSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppDesignSystem.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusRound),
        border: Border.all(
          color: AppDesignSystem.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            selectedLanguage != null && selectedLanguage!.flag != null
                ? selectedLanguage!.flag!
                : 'images/flags/ic_us.png',
            height: 20,
            width: 20,
          ),
          8.width,
          Text(
            selectedLanguage != null ? selectedLanguage!.name! : 'English',
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.width,
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppDesignSystem.white,
            size: 20,
          ),
        ],
      ),
    ).onTap(() async {
      HapticFeedback.lightImpact();
      const LanguageScreen().launch(context);
    });
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppDesignSystem.white,
          shape: BoxShape.circle,
          boxShadow: AppDesignSystem.shadowXLarge,
        ),
        child: getStringAsync(appCompanyLogoPref).isNotEmpty
            ? Image.network(
                getStringAsync(appCompanyLogoPref),
                height: 80,
                width: 80,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppDesignSystem.neutral100,
                            shape: BoxShape.circle,
                          ),
                        );
                },
              )
            : Image.asset(
                appLogoImg,
                height: 80,
                width: 80,
              ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String hint,
    required String? Function(String?) validator,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    VoidCallback? onFieldSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppDesignSystem.shadowSmall,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: AppDesignSystem.bodyLarge.copyWith(
          color: AppDesignSystem.neutral900,
        ),
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: (_) => onFieldSubmitted?.call(),
        decoration: AppDesignSystem.modernInputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            prefixIcon,
            color: AppDesignSystem.neutral400,
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppDesignSystem.neutral400,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                    HapticFeedback.lightImpact();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Observer(
      builder: (_) => AnimatedContainer(
        duration: AppDesignSystem.animationFast,
        width: double.infinity,
        height: 56,
        child: _loginStore.isLoading
            ? Container(
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryLight.withOpacity(0.3),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppDesignSystem.primaryColor,
                      ),
                    ),
                  ),
                ),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    hideKeyboard(context);
                    _loginStore.employeeId = _usernameController.text;
                    _loginStore.password = _passwordController.text;
                    var result = await _loginStore.login();
                    if (result?.toLowerCase() == 'active') {
                      if (!mounted) return;
                      sharedHelper.refreshAppSettings();
                      const OrgChooseScreen().launch(context, isNewTask: true);
                    } else {
                      sharedHelper.routeBasedOnStatus(context, result);
                    }
                  },
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMedium),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppDesignSystem.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppDesignSystem.radiusMedium),
                      boxShadow: AppDesignSystem.shadowMedium,
                    ),
                    child: Center(
                      child: Text(
                        language.lblLogin,
                        style: AppDesignSystem.labelLarge.copyWith(
                          color: AppDesignSystem.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOneTapLogin() {
    return Column(
      children: [
        // Animated illustration
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Lottie.asset(
                'assets/animations/screen_tap.json',
                height: 180,
                repeat: true,
              ),
            );
          },
        ),
        24.height,
        Text(
          language.lblWelcomeBack,
          style: AppDesignSystem.headlineMedium.copyWith(
            color: AppDesignSystem.neutral900,
          ),
        ),
        12.height,
        Text(
          language.lblLooksLikeYouAlreadyRegisteredThisDeviceYouCanUseOneTapLogin,
          textAlign: TextAlign.center,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        32.height,
        Observer(
          builder: (_) => AnimatedContainer(
            duration: AppDesignSystem.animationFast,
            width: double.infinity,
            height: 56,
            child: _loginStore.isLoginWithUidBtnLoading
                ? Container(
                    decoration: BoxDecoration(
                      color: AppDesignSystem.primaryLight.withOpacity(0.3),
                      borderRadius:
                          BorderRadius.circular(AppDesignSystem.radiusMedium),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppDesignSystem.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        hideKeyboard(context);
                        var result = await _loginStore.loginWithUid();
                        sharedHelper.routeBasedOnStatus(context, result);
                      },
                      borderRadius:
                          BorderRadius.circular(AppDesignSystem.radiusMedium),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppDesignSystem.primaryGradient,
                          borderRadius: BorderRadius.circular(
                              AppDesignSystem.radiusMedium),
                          boxShadow: AppDesignSystem.shadowMedium,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fingerprint_rounded,
                              color: AppDesignSystem.white,
                              size: 24,
                            ),
                            12.width,
                            Text(
                              language.lblOneTapLogin,
                              style: AppDesignSystem.labelLarge.copyWith(
                                color: AppDesignSystem.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        20.height,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppDesignSystem.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
            border: Border.all(
              color: AppDesignSystem.infoColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppDesignSystem.infoColor,
                size: 20,
              ),
              12.width,
              Expanded(
                child: Text(
                  language.lblIfYouWantToLoginWithDifferentAccountPleaseContactAdministrator,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblWelcomeTo,
          style: AppDesignSystem.bodyLarge.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        4.height,
        Text(
          getStringAsync(appCompanyNamePref).isEmpty
              ? 'Open Core Employee'
              : getStringAsync(appCompanyNamePref),
          style: AppDesignSystem.headlineMedium.copyWith(
            color: AppDesignSystem.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.height,
        Text(
          'Please login to continue',
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral500,
          ),
        ),
        40.height,
        Observer(
          builder: (_) => Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username',
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.neutral700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.height,
                _buildModernTextField(
                  hint: 'Enter your username',
                  validator: (_) => _loginStore.error.employeeId,
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => _loginStore.employeeId = value,
                  onFieldSubmitted: () {
                    _passwordFocus.requestFocus();
                  },
                ),
                24.height,
                Text(
                  'Password',
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.neutral700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.height,
                _buildModernTextField(
                  hint: 'Enter your password',
                  validator: (_) => _loginStore.error.password,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  onChanged: (value) => _loginStore.password = value,
                  onFieldSubmitted: () async {
                    _loginStore.employeeId = _usernameController.text;
                    _loginStore.password = _passwordController.text;
                    var result = await _loginStore.login();
                    if (result?.toLowerCase() == 'active') {
                      if (!mounted) return;
                      sharedHelper.refreshAppSettings();
                      const OrgChooseScreen().launch(context, isNewTask: true);
                    } else {
                      sharedHelper.routeBasedOnStatus(context, result);
                    }
                  },
                ),
                16.height,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      const ForgotPassword().launch(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: AppDesignSystem.labelMedium.copyWith(
                        color: AppDesignSystem.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                32.height,
                _buildLoginButton(),
                if (appStore.isDemoMode) ...[
                  24.height,
                  _buildDemoSection(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignSystem.warningColor.withOpacity(0.1),
            AppDesignSystem.warningColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
        border: Border.all(
          color: AppDesignSystem.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.developer_mode_rounded,
            color: AppDesignSystem.warningColor,
            size: 32,
          ),
          12.height,
          Text(
            language.lblDemoModeActive,
            style: AppDesignSystem.titleMedium.copyWith(
              color: AppDesignSystem.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.height,
          Text(
            'You can login with demo credentials or create a new demo account',
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          16.height,
          Observer(
            builder: (_) => _loginStore.isDemoRegisterBtnLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppDesignSystem.warningColor,
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      var result = await _loginStore.createDemoUser();
                      if (result.toLowerCase() == 'active') {
                        if (!mounted) return;
                        sharedHelper.refreshAppSettings();
                        // Skip device verification for Employee App
                        PermissionScreen()
                            .launch(context, isNewTask: true);
                      }
                    },
                    icon: Icon(
                      Icons.person_add_outlined,
                      size: 20,
                    ),
                    label: Text(language.lblCreateDemoAccount),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppDesignSystem.warningColor,
                      side: BorderSide(
                        color: AppDesignSystem.warningColor,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDesignSystem.radiusMedium,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesignSystem.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPatternPainter(),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with language switcher
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildLanguageSwitcher(),
                        ),
                      ],
                    ),
                  ),

                  // Main login content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Column(
                                children: [
                                  _buildLogo(),
                                  32.height,
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: AppDesignSystem.white,
                                      borderRadius: BorderRadius.circular(
                                        AppDesignSystem.radiusXLarge,
                                      ),
                                      boxShadow: AppDesignSystem.shadowLarge,
                                    ),
                                    child: widget.isDeviceVerified
                                        ? _buildOneTapLogin()
                                        : _buildLoginForm(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppDesignSystem.primaryColor.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawCircle(
          Offset(i * size.width / 4, j * size.height / 7),
          30,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
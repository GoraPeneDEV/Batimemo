import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isLoading = false;
  bool isOldPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  var oldPasswordCont = TextEditingController();
  var newPasswordCont = TextEditingController();
  var confirmNewPasswordCont = TextEditingController();

  var oldPasswordNode = FocusNode();
  var newPasswordNode = FocusNode();
  var confirmNewPasswordNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    oldPasswordCont.dispose();
    newPasswordCont.dispose();
    confirmNewPasswordCont.dispose();
    oldPasswordNode.dispose();
    newPasswordNode.dispose();
    confirmNewPasswordNode.dispose();
    super.dispose();
  }

  Future changePassword() async {
    var result = await apiService.changePassword(
        oldPasswordCont.text, confirmNewPasswordCont.text);
    if (result) {
      toast(language.lblPasswordChangedSuccessfully);
      if (!mounted) return;
      finish(context);
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
                  // Header Section (56px)
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          language.lblChangePassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

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
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 450,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Form Card
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1F2937)
                                              : Colors.white,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.grey[700]!
                                                : const Color(0xFFE5E7EB),
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Card Header
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0xFF696CFF)
                                                            .withOpacity(0.2),
                                                        const Color(0xFF5457E6)
                                                            .withOpacity(0.1)
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Icon(
                                                    Iconsax.lock,
                                                    color: Color(0xFF696CFF),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  language.lblPasswordSettings,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1F2937),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),

                                            // Old Password Field
                                            Text(
                                              language.lblOldPassword,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF374151),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF1F2937)
                                                    : const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isDark
                                                      ? Colors.grey[700]!
                                                      : const Color(0xFFE5E7EB),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: oldPasswordCont,
                                                focusNode: oldPasswordNode,
                                                obscureText:
                                                    !isOldPasswordVisible,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF111827),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                    Iconsax.lock_1,
                                                    color: Color(0xFF696CFF),
                                                    size: 20,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      isOldPasswordVisible
                                                          ? Iconsax.eye
                                                          : Iconsax.eye_slash,
                                                      color: Colors.grey[500],
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        isOldPasswordVisible =
                                                            !isOldPasswordVisible;
                                                      });
                                                    },
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                                  hintText: language.lblEnterOldPassword,
                                                  hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                validator: (s) {
                                                  if (s.isEmptyOrNull) {
                                                    return language
                                                        .lblOldPasswordIsRequired;
                                                  }

                                                  if (s!.length < 5) {
                                                    return language
                                                        .lblInvalidPassword;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            // New Password Field
                                            Text(
                                              language.lblNewPassword,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF374151),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF1F2937)
                                                    : const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isDark
                                                      ? Colors.grey[700]!
                                                      : const Color(0xFFE5E7EB),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: newPasswordCont,
                                                focusNode: newPasswordNode,
                                                obscureText:
                                                    !isNewPasswordVisible,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF111827),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                    Iconsax.lock,
                                                    color: Color(0xFF696CFF),
                                                    size: 20,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      isNewPasswordVisible
                                                          ? Iconsax.eye
                                                          : Iconsax.eye_slash,
                                                      color: Colors.grey[500],
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        isNewPasswordVisible =
                                                            !isNewPasswordVisible;
                                                      });
                                                    },
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                                  hintText: language.lblEnterNewPassword,
                                                  hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                validator: (s) {
                                                  if (s.isEmptyOrNull) {
                                                    return language
                                                        .lblNewPasswordIsRequired;
                                                  }

                                                  if (s!.length < 5) {
                                                    return '${language.lblMinimumLengthIs} 5';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            // Confirm Password Field
                                            Text(
                                              language.lblConfirmNewPassword,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF374151),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF1F2937)
                                                    : const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isDark
                                                      ? Colors.grey[700]!
                                                      : const Color(0xFFE5E7EB),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller:
                                                    confirmNewPasswordCont,
                                                focusNode:
                                                    confirmNewPasswordNode,
                                                obscureText:
                                                    !isConfirmPasswordVisible,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF111827),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                    Iconsax.password_check,
                                                    color: Color(0xFF696CFF),
                                                    size: 20,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      isConfirmPasswordVisible
                                                          ? Iconsax.eye
                                                          : Iconsax.eye_slash,
                                                      color: Colors.grey[500],
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        isConfirmPasswordVisible =
                                                            !isConfirmPasswordVisible;
                                                      });
                                                    },
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                                  hintText:
                                                      language.lblConfirmNewPasswordPlaceholder,
                                                  hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                validator: (s) {
                                                  if (s.isEmptyOrNull) {
                                                    return language
                                                        .lblConfirmPasswordIsRequired;
                                                  }

                                                  if (s != newPasswordCont.text) {
                                                    return language
                                                        .lblPasswordDoesNotMatch;
                                                  }

                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Requirements Info Card
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFBFDBFE),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Iconsax.info_circle,
                                              color: Color(0xFF3B82F6),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    language.lblPasswordRequirements,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1E3A8A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    language.lblMinimumCharactersRequired,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Submit Button
                                      InkWell(
                                        onTap: isLoading
                                            ? null
                                            : () async {
                                                hideKeyboard(context);
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  await changePassword();
                                                  if (mounted) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  }
                                                }
                                              },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF696CFF),
                                                Color(0xFF5457E6)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF696CFF)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        language.lblChange,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Icon(
                                                        Iconsax.shield_tick,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
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
                        ),
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
}

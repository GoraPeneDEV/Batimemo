import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart'; /*
import 'package:local_auth_ios/local_auth_ios.dart';*/
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/main.dart';
import 'package:open_core_hr/screens/FaceAttendance/face_attendance_screen.dart';
import 'package:open_core_hr/screens/Scanner/qr_scanner_screen.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../../Utils/app_constants.dart';
import '../../../Utils/app_widgets.dart';
import '../../../Widgets/button_widget.dart';
import '../../../store/global_attendance_store.dart';

class InOutComponent extends StatefulWidget {
  final bool showCard;
  const InOutComponent({super.key, this.showCard = true});

  @override
  State<InOutComponent> createState() => _InOutComponentState();
}

class _InOutComponentState extends State<InOutComponent> {
  bool isBreakModuleEnabled = false;

  final lateReasonController = TextEditingController();
  final lateReasonFocus = FocusNode();

  final earlyCheckOutReasonController = TextEditingController();
  final earlyCheckOutReasonFocus = FocusNode();

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  //Local Auth
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  bool _isAuthenticating = false;
  bool _authorized = false;

  // Loading overlay tracking
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    isBreakModuleEnabled = moduleService.isBreakModuleEnabled();
    init();
    refreshTimer();
  }

  void init() {
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  Future _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });

      authenticated = await auth.authenticate(
          localizedReason: language.lblScanYourFingerprintToCheckIn,
          authMessages: <AuthMessages>[
            /*        IOSAuthMessages(
              cancelButton: language.lblCancel,
              goToSettingsButton: language.lblSettings,
              goToSettingsDescription: language.lblPleaseSetUpYourTouchId,
              lockOut: language.lblPleaseReEnableYourTouchId,
            ),*/
            AndroidAuthMessages(
                signInTitle: language.lblFingerprintAuthentication,
                //fingerprintRequiredTitle: "Connect to Login",
                cancelButton: language.lblCancel,
                goToSettingsButton: language.lblSettings,
                goToSettingsDescription: 'Please setup your fingerprint',
                biometricRequiredTitle:
                    language.lblAuthenticateWithFingerprintOrPasswordToProceed
                //fingerprintSuccess: "Authentication Successfully authenticated",
                ),
          ]);
      _authorized = authenticated;
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      log('Auth error $e');
      toast(language.lblPleaseSetupYourFingerprint);
    }
    if (!mounted) return false;

    setState(() {
      _authorized = authenticated;
    });
  }

  refreshTimer() async {
    if (globalAttendanceStore.isOnBreak) {
      var startTime = globalAttendanceStore.breakStartAt;
      var now = DateTime.now();

      var diff = now.difference(startTime);

      _stopWatchTimer.setPresetTime(mSec: diff.inMilliseconds);
      _stopWatchTimer.onStartTimer();
    } else {
      _stopWatchTimer.setPresetTime(mSec: 0);
      _stopWatchTimer.onStopTimer();
    }
  }

  void _showLoadingDialog(String message) {
    if (!mounted || _overlayEntry != null) return;

    // Determine icon based on message content
    IconData icon;
    if (message.contains('Check In')) {
      icon = Iconsax.login;
    } else if (message.contains('Check Out')) {
      icon = Iconsax.logout;
    } else if (message.contains('Break') || message.contains('Starting')) {
      icon = Iconsax.pause;
    } else if (message.contains('Resume') || message.contains('Resuming')) {
      icon = Iconsax.play;
    } else {
      icon = Iconsax.clock;
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Material(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsating Circle Animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF696CFF),
                              Color(0xFF5457E6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF696CFF).withOpacity(0.3),
                              blurRadius: 20 * value,
                              spreadRadius: 5 * value,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotating spinner
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.5),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            // Center icon
                            Icon(
                              icon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Animation loop - no context needed
                  },
                ),
                24.height,
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                8.height,
                Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 13,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
            ),
          ),
        );
      },
    );

    // Insert the overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _hideLoadingDialog() async {
    if (_overlayEntry == null) return;

    try {
      // Small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 100));

      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      print('Error hiding dialog: $e');
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    // Clean up overlay if it still exists
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void checkIn() async {
    hideKeyboard(context);

    try {
      // Show loading dialog
      _showLoadingDialog('${language.lblCheckIn}...');

      // Biometric Verification
      if (moduleService.isBioMetricVerificationModuleEnabled()) {
        await _authenticate();
        if (!_authorized) {
          await _hideLoadingDialog();
          return;
        }
      }

      //Face Verification
      if (globalAttendanceStore.attendanceType == AttendanceType.face) {
        await _hideLoadingDialog();
        if (!mounted) return;

        var result = await FaceAttendanceScreen().launch(context);

        if (!result) {
          return;
        }
        _showLoadingDialog('${language.lblCheckIn}...');
      }

      // Geofence Validation
      if (globalAttendanceStore.attendanceType == AttendanceType.geofence) {
        var result = await globalAttendanceStore.validateGeofence();
        if (!result) {
          await _hideLoadingDialog();
          return;
        }
      }

      // IP Address Validation
      if (globalAttendanceStore.attendanceType == AttendanceType.ipAddress) {
        var result = await globalAttendanceStore.validateIpAddress();
        if (!result) {
          await _hideLoadingDialog();
          return;
        }
      }

      // QR Validation
      if (globalAttendanceStore.attendanceType == AttendanceType.qr) {
        await _hideLoadingDialog();
        var result = await verifyQr();
        if (!result) {
          return;
        }
        _showLoadingDialog('${language.lblCheckIn}...');
      }

      // Dynamic QR Validation
      if (globalAttendanceStore.attendanceType == AttendanceType.dynamicQr) {
        await _hideLoadingDialog();
        var result = await verifyDynamicQr();
        if (!result) {
          return;
        }
        _showLoadingDialog('${language.lblCheckIn}...');
      }

      // Hide loading before confirmation
      await _hideLoadingDialog();

      // Confirmation Dialog
      if (!mounted) {
        return;
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(language.lblCheckIn),
            content: Text(language.lblAreYouSureYouWantToCheckIn),
            actions: [
              TextButton(
                child: Text(
                  language.lblNo,
                  style: primaryTextStyle(color: appStore.textPrimaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appStore.appColorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  language.lblYes,
                  style: primaryTextStyle(color: white),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _showLoadingDialog('${language.lblCheckIn}...');
                  await globalAttendanceStore.checkInOut(
                    AttendanceStatus.checkIn,
                    lateCheckInReason: lateReasonController.text,
                  );
                  if (mounted) {
                    await _hideLoadingDialog();
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      await _hideLoadingDialog();
      toast(language.lblSomethingWentWrong);
    }
  }

  Future<bool> verifyQr() async {
    var result = await const BarcodeScannerWithOverlay().launch(context);
    if (result == null) {
      return false;
    }
    String resultString = result as String;
    if (resultString.isEmptyOrNull) {
      toast('${language.lblInvalid} QR');
      return false;
    }
    var verificationResult =
        await globalAttendanceStore.validateQrCode(resultString);
    if (verificationResult) {
      return true;
    }
    return false;
  }

  Future<bool> verifyDynamicQr() async {
    var result = await const BarcodeScannerWithOverlay().launch(context);
    if (result == null) {
      return false;
    }
    String resultString = result as String;
    if (resultString.isEmptyOrNull) {
      toast('${language.lblInvalid} QR');
      return false;
    }
    var verificationResult =
        await globalAttendanceStore.validateDynamicQrCode(resultString);
    if (verificationResult) {
      return true;
    }
    return false;
  }

  void checkOut() async {
    try {
      _showLoadingDialog('${language.lblCheckOut}...');

      if (moduleService.isBioMetricVerificationModuleEnabled()) {
        await _authenticate();
        if (!_authorized) {
          await _hideLoadingDialog();
          return;
        }
      }

      if (globalAttendanceStore.attendanceType == AttendanceType.geofence) {
        var result = await globalAttendanceStore.validateGeofence();
        if (!result) {
          await _hideLoadingDialog();
          return;
        }
      }

      if (globalAttendanceStore.attendanceType == AttendanceType.ipAddress) {
        var result = await globalAttendanceStore.validateIpAddress();
        if (!result) {
          await _hideLoadingDialog();
          return;
        }
      }

      //Face Verification
      if (globalAttendanceStore.attendanceType == AttendanceType.face) {
        await _hideLoadingDialog();
        if (!mounted) return;

        var result = await FaceAttendanceScreen().launch(context);

        if (!result) {
          return;
        }
        _showLoadingDialog('${language.lblCheckOut}...');
      }

      if (globalAttendanceStore.attendanceType == AttendanceType.qr) {
        await _hideLoadingDialog();
        var result = await verifyQr();
        if (!result) {
          return;
        }
        _showLoadingDialog('${language.lblCheckOut}...');
      }

      if (globalAttendanceStore.attendanceType == AttendanceType.dynamicQr) {
        await _hideLoadingDialog();
        var result = await verifyDynamicQr();
        if (!result) {
          return;
        }
        _showLoadingDialog('${language.lblCheckOut}...');
      }

      await _hideLoadingDialog();

      if (!mounted) {
        return;
      }

      AlertDialog checkOutAlert = AlertDialog(
        title: Text(language.lblCheckOut),
        content: Text(language.lblAreYouSureYouWantToCheckOut),
        actions: [
          TextButton(
            child: Text(
              language.lblNo,
              style: primaryTextStyle(color: appStore.textPrimaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appStore.appColorPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              language.lblYes,
              style: primaryTextStyle(color: white),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              _showLoadingDialog('${language.lblCheckOut}...');
              await globalAttendanceStore.checkInOut(AttendanceStatus.checkOut);
              if (mounted) {
                await _hideLoadingDialog();
              }
            },
          ),
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return checkOutAlert;
        },
      );
    } catch (e) {
      await _hideLoadingDialog();
      toast(language.lblSomethingWentWrong);
    }
  }

  void startBreak() async {
    if (!isBreakModuleEnabled) {
      toast(language.lblBreakModuleIsNotEnabled);
      return;
    }
    //Show alert confirmation
    AlertDialog alert = AlertDialog(
      title: Text(language.lblBreak),
      content: Text(language.lblAreYouSureYouWantToTakeABreak),
      actions: [
        TextButton(
          child: Text(
            language.lblNo,
            style: primaryTextStyle(color: appStore.textPrimaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appStore.appColorPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            language.lblYes,
            style: primaryTextStyle(color: white),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            _showLoadingDialog('Starting Break...');
            var result = await globalAttendanceStore.startStopBreak();
            if (mounted) {
              await _hideLoadingDialog();
              if (result) {
                _stopWatchTimer.setPresetTime(mSec: 0);
                _stopWatchTimer.onStartTimer();
              }
            }
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void earlyCheckOutReason() async {
    AlertDialog alert = AlertDialog(
      title: Text(language.lblEarlyCheckOut),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.lblPleaseEnterYourEarlyCheckOutReason),
          10.height,
          TextFormField(
            controller: earlyCheckOutReasonController,
            focusNode: earlyCheckOutReasonFocus,
            style: TextStyle(
                fontSize: fontSizeLargeMedium,
                fontFamily: fontRegular,
                color: appStore.textPrimaryColor),
            onChanged: (value) => {},
            decoration: newEditTextDecoration(
                Icons.text_fields, language.lblEarlyCheckOutReason,
                borderColor: white, bgColor: white),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(language.lblConfirm),
          onPressed: () async {
            if (earlyCheckOutReasonController.text.isEmptyOrNull) {
              toast(language.lblPleaseEnterYourEarlyCheckOutReason);
              earlyCheckOutReasonFocus.requestFocus();
              return;
            }

            var result = await globalAttendanceStore
                .setEarlyCheckoutReason(earlyCheckOutReasonController.text);
            if (!mounted) return;
            if (result) {
              globalAttendanceStore.checkInOut(AttendanceStatus.checkOut);
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            language.lblCancel,
            style: primaryTextStyle(color: appStore.textPrimaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void stopBreak() async {
    if (!isBreakModuleEnabled) {
      toast(language.lblBreakModuleIsNotEnabled);
      return;
    }
    AlertDialog alert = AlertDialog(
      title: Text(language.lblResume),
      content: Text(language.lblAreYouSureYouWantToResume),
      actions: [
        TextButton(
          child: Text(
            language.lblNo,
            style: primaryTextStyle(color: appStore.textPrimaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appStore.appColorPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            language.lblYes,
            style: primaryTextStyle(color: white),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            _showLoadingDialog('Resuming from Break...');
            var result = await globalAttendanceStore.startStopBreak();
            if (mounted) {
              await _hideLoadingDialog();
              if (result) {
                refreshTimer();
              }
            }
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        child: globalAttendanceStore.isNew
            ? checkInWidget()
            : globalAttendanceStore.isOnBreak
                ? onBreakWidget()
                : globalAttendanceStore.isCheckedIn
                    ? checkOutWidget()
                    : allDoneWidget(),
      ),
    );
  }

  Widget checkInWidget() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shift Info
        Text(
          '${language.lblYourShiftStartsAt} ${globalAttendanceStore.shiftStartAt}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
        ),
        12.height,

        // Check-in Button
        _cleanButton(
          label: globalAttendanceStore.attendanceType == AttendanceType.qr ||
                  globalAttendanceStore.attendanceType == AttendanceType.dynamicQr
              ? language.lblScanQRToCheckIn
              : globalAttendanceStore.attendanceType == AttendanceType.face
                  ? language.lblScanFace
                  : language.lblCheckIn,
          icon: globalAttendanceStore.attendanceType == AttendanceType.qr ||
                  globalAttendanceStore.attendanceType == AttendanceType.dynamicQr
              ? Icons.qr_code_scanner_rounded
              : globalAttendanceStore.attendanceType == AttendanceType.face
                  ? Icons.face
                  : Iconsax.login,
          onTap: checkIn,
        ),
      ],
    );

    return Observer(
      builder: (_) => widget.showCard
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
              child: content,
            )
          : content,
    );
  }

  Widget checkOutWidget() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Check-in time info
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF696CFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Iconsax.tick_circle,
                color: Color(0xFF696CFF),
                size: 16,
              ),
              8.width,
              Expanded(
                child: Text(
                  '${language.lblYouCheckedInAt} ${globalAttendanceStore.currentStatus!.checkInAt.toString()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF696CFF),
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        12.height,

        // Buttons Row
        Row(
          children: [
            // Check-out Button
            Expanded(
              flex: isBreakModuleEnabled ? 3 : 1,
              child: _cleanButton(
                label: language.lblCheckOut,
                icon: globalAttendanceStore.attendanceType == AttendanceType.qr ||
                        globalAttendanceStore.attendanceType == AttendanceType.dynamicQr
                    ? Icons.qr_code_scanner_rounded
                    : Iconsax.logout,
                onTap: checkOut,
              ),
            ),

            // Break Button
            if (isBreakModuleEnabled) ...[
              8.width,
              Expanded(
                flex: 2,
                child: _cleanButton(
                  label: language.lblBreak,
                  icon: Iconsax.pause,
                  onTap: startBreak,
                  isSecondary: true,
                ),
              ),
            ],
          ],
        ),
      ],
    );

    return Observer(
      builder: (_) => widget.showCard
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
              child: content,
            )
          : content,
    );
  }

  Widget onBreakWidget() {
    final content = Column(
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
                Iconsax.pause,
                color: Color(0xFF696CFF),
                size: 18,
              ),
            ),
            10.width,
            Text(
              language.lblYouAreOnBreak,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
        16.height,
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF111827)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: appStore.isDarkModeOn
                  ? Colors.grey[700]!
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: 0,
                builder: (context, snap) {
                  final value = snap.data;
                  final displayTime =
                      StopWatchTimer.getDisplayTime(value!, milliSecond: false);
                  return Text(
                    displayTime,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF696CFF),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF696CFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: stopBreak,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.play,
                            color: Colors.white,
                            size: 16,
                          ),
                          6.width,
                          Text(
                            language.lblResume,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Observer(
      builder: (_) => widget.showCard
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
              child: content,
            )
          : content,
    );
  }

  Widget allDoneWidget() {
    final content = Column(
      children: [
        // Success Icon
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF696CFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.tick_circle,
            color: Color(0xFF696CFF),
            size: 36,
          ),
        ),
        12.height,

        // All Done Text
        Text(
          language.lblAllDoneForToday,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
          textAlign: TextAlign.center,
        ),
        12.height,

        // Time Cards
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF111827)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: appStore.isDarkModeOn
                  ? Colors.grey[700]!
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Iconsax.login, color: Color(0xFF696CFF), size: 16),
                  8.width,
                  Expanded(
                    child: Text(
                      '${language.lblYouCheckedInAt}${globalAttendanceStore.currentStatus!.checkInAt.toString()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[300]
                            : const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              8.height,
              Row(
                children: [
                  const Icon(Iconsax.logout, color: Color(0xFF696CFF), size: 16),
                  8.width,
                  Expanded(
                    child: Text(
                      '${language.lblYouCheckedOutAt}${globalAttendanceStore.currentStatus!.checkOutAt.toString()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[300]
                            : const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Observer(
      builder: (_) => widget.showCard
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
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
              child: content,
            )
          : content,
    );
  }

  // Clean Button Widget
  Widget _cleanButton({
    required String label,
    required IconData icon,
    required Function onTap,
    bool isSecondary = false,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isSecondary
            ? (appStore.isDarkModeOn ? const Color(0xFF111827) : Colors.white)
            : const Color(0xFF696CFF),
        borderRadius: BorderRadius.circular(10),
        border: isSecondary
            ? Border.all(
                color: appStore.isDarkModeOn
                    ? Colors.grey[700]!
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSecondary ? const Color(0xFF696CFF) : Colors.white,
                size: 18,
              ),
              6.width,
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSecondary ? const Color(0xFF696CFF) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Text shiftText() {
  return Text(
    '${language.lblYourShiftStartsAt} ${globalAttendanceStore.shiftStartAt}',
  );
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

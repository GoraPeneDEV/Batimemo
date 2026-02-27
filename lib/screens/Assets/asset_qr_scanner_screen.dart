import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../store/asset_store.dart';
import '../../main.dart';

class AssetQRScannerScreen extends StatefulWidget {
  const AssetQRScannerScreen({super.key});

  @override
  State<AssetQRScannerScreen> createState() => _AssetQRScannerScreenState();
}

class _AssetQRScannerScreenState extends State<AssetQRScannerScreen> {
  late AssetStore _assetStore;
  late MobileScannerController controller;
  bool _isProcessing = false;
  bool _hasScanned = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _assetStore = Provider.of<AssetStore>(context, listen: false);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      _handleScan(code);
    }
  }

  Future<void> _handleScan(String qrCode) async {
    if (_hasScanned) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    controller.stop();

    try {
      final asset = await _assetStore.scanQRCode(qrCode);

      if (!mounted) return;

      if (asset != null) {
        toast('${language.lblAssetFound}: ${asset.name}');
        Navigator.pop(context, asset);
      } else {
        _showErrorDialog(
          language.lblError,
          language.lblNoAssetFoundWithQR,
        );
        setState(() {
          _hasScanned = false;
        });
        controller.start();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        language.lblError,
        _assetStore.errorMessage ?? language.lblFailedToScanQR,
      );
      setState(() {
        _hasScanned = false;
      });
      controller.start();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              language.lblOk,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF696CFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanArea = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mobile Scanner View
          MobileScanner(controller: controller, onDetect: _onDetect),

          // Custom Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QRScannerOverlayShape(
                borderColor: const Color(0xFF696CFF),
                borderRadius: 16,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: scanArea,
                overlayColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Observer(
                    builder: (_) => _isProcessing
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF696CFF),
                            ),
                          )
                        : const Icon(
                            Icons.qr_code_scanner,
                            size: 48,
                            color: Color(0xFF696CFF),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isProcessing
                        ? language.lblScanningAsset
                        : language.lblPositionQRCodeInFrame,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isProcessing
                        ? language.lblPleaseWait
                        : language.lblScannerWillAutoDetect,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom overlay shape for QR scanner
class QRScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QRScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 8.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.borderRadius = 16.0,
    this.borderLength = 30.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize;
    final cutOutHeight = cutOutSize;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + width / 2 - cutOutWidth / 2,
            rect.top + height / 2 - cutOutHeight / 2,
            cutOutWidth,
            cutOutHeight,
          ),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, Paint()..color = overlayColor);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final left = width / 2 - cutOutWidth / 2;
    final top = height / 2 - cutOutHeight / 2;
    final right = width / 2 + cutOutWidth / 2;
    final bottom = height / 2 + cutOutHeight / 2;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top + borderRadius)
        ..quadraticBezierTo(left, top, left + borderRadius, top)
        ..lineTo(left + borderLength, top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, top)
        ..lineTo(right - borderRadius, top)
        ..quadraticBezierTo(right, top, right, top + borderRadius)
        ..lineTo(right, top + borderLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - borderLength)
        ..lineTo(left, bottom - borderRadius)
        ..quadraticBezierTo(left, bottom, left + borderRadius, bottom)
        ..lineTo(left + borderLength, bottom),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, bottom)
        ..lineTo(right - borderRadius, bottom)
        ..quadraticBezierTo(right, bottom, right, bottom - borderRadius)
        ..lineTo(right, bottom - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => QRScannerOverlayShape(
    borderColor: borderColor,
    borderWidth: borderWidth,
    overlayColor: overlayColor,
    borderRadius: borderRadius,
    borderLength: borderLength,
    cutOutSize: cutOutSize,
  );
}

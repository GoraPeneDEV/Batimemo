import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/dio_api/repositories/payroll_repository.dart';
import '../../main.dart';
import '../../models/payslip_model.dart';
import '../../utils/app_constants.dart';

/// Payslip Detail Screen
///
/// Displays detailed information about a specific payslip including:
/// - Basic salary information
/// - Earnings breakdown
/// - Deductions breakdown
/// - Net salary
/// - Download PDF functionality
class PayslipDetailScreen extends StatefulWidget {
  final PayslipModel payslip;

  const PayslipDetailScreen({
    super.key,
    required this.payslip,
  });

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  final PayrollRepository _payrollRepository = PayrollRepository();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: appStore.isDarkModeOn
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Content
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Payslip Header Card
                            _buildPayslipHeaderCard(),
                            const SizedBox(height: 16),

                            // Salary Summary
                            _buildSalarySummary(),
                            const SizedBox(height: 16),

                            // Earnings
                            if (widget.payslip.totalBenefits != null &&
                                widget.payslip.totalBenefits! > 0)
                              _buildEarnings(),
                            if (widget.payslip.totalBenefits != null &&
                                widget.payslip.totalBenefits! > 0)
                              const SizedBox(height: 16),

                            // Deductions
                            if (widget.payslip.totalDeductions != null &&
                                widget.payslip.totalDeductions! > 0)
                              _buildDeductions(),
                            if (widget.payslip.totalDeductions != null &&
                                widget.payslip.totalDeductions! > 0)
                              const SizedBox(height: 16),

                            // Attendance Summary
                            _buildAttendanceSummary(),
                            const SizedBox(height: 100),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isDownloading ? null : _downloadPayslip,
        backgroundColor: _isDownloading
            ? Colors.grey
            : const Color(0xFF696CFF),
        foregroundColor: Colors.white,
        icon: _isDownloading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                ),
              )
            : const Icon(Iconsax.document_download),
        label: Text(_isDownloading
            ? '${language.lblDownloadingPayslip} ${(_downloadProgress * 100).toStringAsFixed(0)}%'
            : language.lblDownloadPayslip),
      ),
    );
  }

  Future<void> _downloadPayslip() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Check and request storage permission
      if (Platform.isAndroid) {
        PermissionStatus status;

        // For Android 13+ (API 33+), we don't need storage permission for Downloads
        if (await _getAndroidVersion() >= 33) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        }

        if (!status.isGranted) {
          toast(language.lblStoragePermissionRequired);
          setState(() => _isDownloading = false);
          return;
        }
      }

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find downloads directory');
      }

      // Generate filename
      final fileName = 'Payslip-${widget.payslip.code}-${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savePath = '${directory.path}/$fileName';

      // Download the PDF
      await _payrollRepository.downloadPayslip(
        widget.payslip.id!,
        savePath,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      setState(() => _isDownloading = false);

      // Show success message
      if (!mounted) return;

      // Determine user-friendly directory name
      String locationText = Platform.isAndroid ? language.lblDownloadsFolder : language.lblDocumentsFolder;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${language.lblPayslipDownloadedTo} $locationText'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Automatically open the PDF
      await _openPdf(savePath);

    } catch (e) {
      setState(() => _isDownloading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${language.lblFailedToDownloadPayslip}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  Future<void> _openPdf(String path) async {
    try {
      final result = await OpenFilex.open(path);

      // Handle result types
      if (result.type == ResultType.noAppToOpen) {
        toast(language.lblNoAppToOpenPDF);
      } else if (result.type == ResultType.fileNotFound) {
        toast(language.lblPDFFileNotFound);
      } else if (result.type == ResultType.error) {
        toast('${language.lblFailedToOpenPDF}: ${result.message}');
      }
      // ResultType.done means success - no action needed
    } catch (e) {
      toast('${language.lblFailedToOpenPDF}: $e');
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Iconsax.arrow_left,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lblPayslipDetails,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.payslip.payrollPeriod ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipHeaderCard() {
    Color statusColor = Colors.green;
    if (widget.payslip.status?.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else if (widget.payslip.status?.toLowerCase() == 'draft') {
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language.lblPayslipCode,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.payslip.status?.toUpperCase() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.payslip.code ?? 'N/A',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: appStore.isDarkModeOn
                ? Colors.grey[700]
                : const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Iconsax.calendar,
                size: 16,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                '${language.lblCreatedOn}: ${widget.payslip.createdAt ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF696CFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.lblNetSalary,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${getStringAsync(appCurrencySymbolPref)}${(widget.payslip.netSalary?.toDouble() ?? 0.0).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  language.lblBasicSalary,
                  '${getStringAsync(appCurrencySymbolPref)}${(widget.payslip.basicSalary?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                  Iconsax.wallet_3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  language.lblBenefits,
                  '${getStringAsync(appCurrencySymbolPref)}${(widget.payslip.totalBenefits?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                  Iconsax.arrow_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            language.lblDeductions,
            '${getStringAsync(appCurrencySymbolPref)}${(widget.payslip.totalDeductions?.toDouble() ?? 0.0).toStringAsFixed(2)}',
            Iconsax.arrow_down,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.arrow_up,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language.lblEarningsAndBenefits,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            language.lblTotalBenefits,
            '${getStringAsync(appCurrencySymbolPref)}${(widget.payslip.totalBenefits?.toDouble() ?? 0.0).toStringAsFixed(2)}',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDeductions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.arrow_down,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language.lblDeductions,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            language.lblTotalDeductions,
            '${getStringAsync(appCurrencySymbolPref)}${(widget.payslip.totalDeductions?.toDouble() ?? 0.0).toStringAsFixed(2)}',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  Iconsax.calendar,
                  color: Color(0xFF696CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language.lblAttendanceSummary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.0,
            children: [
              _buildAttendanceItem(
                language.lblWorkedDays,
                widget.payslip.totalWorkedDays?.toString() ?? '0',
                Iconsax.calendar_tick,
                Colors.green,
              ),
              _buildAttendanceItem(
                language.lblAbsentDays,
                widget.payslip.totalAbsentDays?.toString() ?? '0',
                Iconsax.calendar_remove,
                Colors.red,
              ),
              _buildAttendanceItem(
                language.lblLeaveDays,
                widget.payslip.totalLeaveDays?.toString() ?? '0',
                Iconsax.calendar_1,
                Colors.orange,
              ),
              _buildAttendanceItem(
                language.lblHolidays,
                widget.payslip.totalHolidays?.toString() ?? '0',
                Iconsax.calendar_search,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/store/global_attendance_store.dart';
import 'package:public_ip_address/public_ip_address.dart';

import '../../../main.dart';
import '../../../service/map_helper.dart';

class AttendanceTypeWidget extends StatefulWidget {
  final AttendanceType type;
  final bool showCard;
  const AttendanceTypeWidget({
    super.key,
    required this.type,
    this.showCard = true,
  });

  @override
  State<AttendanceTypeWidget> createState() => _AttendanceTypeWidgetState();
}

class _AttendanceTypeWidgetState extends State<AttendanceTypeWidget> {
  String ipAddress = language.lblGettingYourIPAddress;
  String address = language.lblGettingYourAddress;
  String attendanceType = '...';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (widget.type == AttendanceType.ipAddress) {
      attendanceType = 'IP Based';
      var ip = IpAddress();
      var ipAdd = await ip.getIp();
      ipAddress = '$ipAdd ${language.lblIsYourIPAddress}';
    } else if (widget.type == AttendanceType.geofence) {
      attendanceType = 'Geofence';
      var mapHelper = MapHelper();
      address =
          await mapHelper.getCurrentAddress() ?? language.lblUnableToGetAddress;
    } else if (widget.type == AttendanceType.qr) {
      attendanceType = 'QR Code';
    } else if (widget.type == AttendanceType.dynamicQr) {
      attendanceType = 'Dynamic QR Code';
    } else if (widget.type == AttendanceType.face) {
      attendanceType = 'Face';
    } else {
      attendanceType = 'Open';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Site Employee Information
        if (globalAttendanceStore.isSiteEmployee)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF696CFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.building,
                  color: Color(0xFF696CFF),
                  size: 16
                ),
                6.width,
                Text(
                  '${language.lblSite}: ${globalAttendanceStore.siteName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF696CFF),
                  ),
                ),
              ],
            ),
          ).paddingBottom(12),

        // Attendance Type Header with Refresh
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.lblAttendanceType,
                    style: TextStyle(
                      fontSize: 11,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[500]
                          : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  4.height,
                  Text(
                    attendanceType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                appStore.refreshAttendanceStatus();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF696CFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.refresh,
                      color: Colors.white,
                      size: 14,
                    ),
                    4.width,
                    Text(
                      language.lblRefresh,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        12.height,

        // Dynamic Content Based on Attendance Type
        _buildAttendanceDetails(),
      ],
    );

    return Observer(
      builder: (_) => widget.showCard
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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

  Widget _buildAttendanceDetails() {
    Widget _detailRow(IconData icon, String text) {
      return Container(
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
                size: 18,
              ),
            ),
            12.width,
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[300]
                      : const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.type == AttendanceType.ipAddress) {
      return _detailRow(Iconsax.global, ipAddress);
    } else if (widget.type == AttendanceType.geofence) {
      return _detailRow(Iconsax.location, address);
    } else if (widget.type == AttendanceType.qr) {
      return _detailRow(Iconsax.scan, language.lblScanQRCodeToMarkAttendance);
    } else if (widget.type == AttendanceType.dynamicQr) {
      return _detailRow(Icons.qr_code, language.lblDynamicQRCodeIsEnabled);
    } else if (widget.type == AttendanceType.face) {
      return _detailRow(Icons.face, language.lblFaceRecognitionIsEnabled);
    } else {
      return _detailRow(Iconsax.unlock, language.lblOpenAttendance);
    }
  }
}

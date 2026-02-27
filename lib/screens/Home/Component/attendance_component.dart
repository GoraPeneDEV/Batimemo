import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../Widgets/home_attendance_loading_widget.dart';
import '../../../main.dart';
import 'attendance_type_widget.dart';
import 'in_out_component.dart';

class AttendanceComponent extends StatefulWidget {
  const AttendanceComponent({super.key});

  @override
  State<AttendanceComponent> createState() => _AttendanceComponentState();
}

class _AttendanceComponentState extends State<AttendanceComponent> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => appStore.isStatusCheckLoading
          ? CustomLoadingWidget()
          : globalAttendanceStore.isNew ||
                  globalAttendanceStore.isCheckedIn ||
                  globalAttendanceStore.isCheckedOut
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Attendance Type Section
                      AttendanceTypeWidget(
                        type: globalAttendanceStore.attendanceType,
                        showCard: false, // Don't show card wrapper
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

                      // Check-in/out Section
                      const InOutComponent(
                        showCard: false, // Don't show card wrapper
                      ),
                    ],
                  ),
                )
              : Container(),
    );
  }
}

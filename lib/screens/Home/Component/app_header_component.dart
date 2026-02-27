import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/Utils/app_constants.dart';
import 'package:open_core_hr/Utils/app_widgets.dart';
import 'package:open_core_hr/screens/Account/account_screen.dart';

import '../../../main.dart';
import '../../Notification/notification_screen.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Profile Image
              Hero(
                tag: 'profile',
                child: GestureDetector(
                  onTap: () {
                    AccountScreen().launch(context);
                  },
                  child: profileImageWidget(),
                ),
              ),
              12.width,

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sharedHelper.getFullName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.height,
                    Text(
                      getStringAsync(designationPref),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ).onTap(() {
                  AccountScreen().launch(context);
                }),
              ),

              // Notification Icon
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF696CFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Iconsax.notification,
                    color: Color(0xFF696CFF),
                    size: 22,
                  ),
                  onPressed: () {
                    NotificationScreen().launch(context);
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

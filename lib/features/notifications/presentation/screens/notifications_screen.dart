import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_body.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: const SafeArea(
        bottom: false,
        child: Column(
          children: [
            NotificationsHeader(),
            Expanded(child: NotificationsBody()),
          ],
        ),
      ),
    );
  }
}

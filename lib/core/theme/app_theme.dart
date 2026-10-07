import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.grey0,
    primaryColor: AppColors.primary,
    fontFamily: 'cairo',
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.black0,
      displayColor: AppColors.black0,
      fontFamily: 'cairo',
    ),
  );
}

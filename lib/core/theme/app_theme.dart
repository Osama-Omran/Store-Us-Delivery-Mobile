import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.grey0,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white0,
      secondary: AppColors.primary,
      onSecondary: AppColors.white0,
      surface: AppColors.white0,
      onSurface: AppColors.black1,
      error: AppColors.red1,
      onError: AppColors.white0,
      outline: AppColors.grey3,
    ),
    fontFamily: 'cairo',
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.black0,
      displayColor: AppColors.black0,
      fontFamily: 'cairo',
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white0,
        minimumSize: const Size(0, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.grey3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white0,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white0,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.black1,
      actionTextColor: AppColors.blue3,
      elevation: 0,
    ),
  );
}

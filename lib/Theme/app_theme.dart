import 'package:flutter/material.dart';
import 'package:t_h_m/Constants/colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light, // 🌞 ضروري عشان يفرق بين الثيمات
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textColor),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      iconTheme: IconThemeData(color: AppColors.backgroundColor),
    ),
    colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.backgroundColor,
        background: AppColors.backgroundColor,
        onBackground: AppColors.primaryColor,
        error: AppColors.warningColor),

    dialogTheme: DialogTheme(
      backgroundColor: AppColors.AlertDialogColor, // الخلفية في الوضع الفاتح
    ),
  );

////////////////////////////////////////////////////////////////////
  static final darkTheme = ThemeData(
    brightness: Brightness.dark, // 🌙 ضروري عشان يفرق بين الثيمات
    primaryColor: AppColors.darkPrimaryColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.darkTextColor),
    ),
    iconTheme: const IconThemeData(color: AppColors.darkTextColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkPrimaryColor,
      iconTheme: IconThemeData(color: AppColors.darkBackgroundColor),
    ),
    colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimaryColor,
        onPrimary: AppColors.darkTextColor,
        background: AppColors.darkAlertDialogColor,
        onBackground: AppColors.darkTextColor,
        error: AppColors.darkWarningColor),
    dialogTheme: DialogTheme(
      backgroundColor:
          AppColors.darkAlertDialogColor, // الخلفية في الوضع الفاتح
    ),
  );
}

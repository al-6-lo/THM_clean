import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeHelper {
  static void setNavigationBarColor(BuildContext context) {
    Future.delayed(Duration.zero, () {
      final theme = Theme.of(context);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            theme.scaffoldBackgroundColor, // ✅ استخدام لون الثيم مباشرة
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ));
    });
  }
}

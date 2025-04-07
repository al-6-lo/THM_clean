import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('English'); // اللغة الافتراضية إنجليزي

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // تحميل اللغة من SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language'); // جلب اللغة المحفوظة
    if (langCode != null) {
      _locale = Locale(langCode); // تحويل النص إلى Locale
      notifyListeners();
    }
  }

  // تعيين اللغة وحفظها في SharedPreferences
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode); // حفظ اللغة كنص
    _locale = Locale(languageCode); // تحويل النص إلى Locale
    notifyListeners();
  }
}

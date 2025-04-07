import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Providers/localization_provider.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelector extends StatelessWidget {
  void _updateLanguage(BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", languageCode);
    Provider.of<LocaleProvider>(context, listen: false).setLocale(languageCode);
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).select_language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text("English"),
                value: "en",
                groupValue:
                    Provider.of<LocaleProvider>(context).locale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    _updateLanguage(context, value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<String>(
                title: Text("العربية"),
                value: "ar",
                groupValue:
                    Provider.of<LocaleProvider>(context).locale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    _updateLanguage(context, value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
      title: Text(S.of(context).language),
      subtitle: Text(
          Provider.of<LocaleProvider>(context).locale.languageCode == 'en'
              ? 'English'
              : 'العربية'),
      onTap: () => _showLanguageDialog(context),
    );
  }
}

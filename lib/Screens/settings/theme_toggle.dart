import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:t_h_m/generated/l10n.dart';

class ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return ListTile(
      leading:
          Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
      title: Text(S.of(context).dark_mode),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
      ),
    );
  }
}

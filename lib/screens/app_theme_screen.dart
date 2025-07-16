// lib/screens/app_theme_screen.dart

import 'package:chronictech/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppThemeScreen extends StatelessWidget {
  const AppThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('App Theme'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildThemeOption(
              context: context,
              title: 'Light',
              subtitle: 'Use the light theme',
              value: ThemeMode.light,
              currentValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
            ),
            const Divider(height: 1),
            _buildThemeOption(
              context: context,
              title: 'Dark',
              subtitle: 'Use the dark theme',
              value: ThemeMode.dark,
              currentValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
            ),
            const Divider(height: 1),
            _buildThemeOption(
              context: context,
              title: 'System Default',
              subtitle: 'Follow your device\'s theme setting',
              value: ThemeMode.system,
              currentValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode currentValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      value: value,
      groupValue: currentValue,
      onChanged: onChanged,
      activeColor: Colors.teal,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:standstock_app/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Apariencia",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<ThemeMode>(
            title: const Text("Usar configuración del sistema"),
            value: ThemeMode.system,
            groupValue: themeService.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeService.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Tema claro"),
            value: ThemeMode.light,
            groupValue: themeService.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeService.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Tema oscuro"),
            value: ThemeMode.dark,
            groupValue: themeService.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeService.setThemeMode(value);
              }
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Nota: El cambio de tema se aplica inmediatamente.",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

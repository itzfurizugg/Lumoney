import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppColorSeed {
  original('Warna Asli', Color(0xFF006A60)),
  blue('Biru', Color(0xFF1565C0)),
  purple('Ungu', Color(0xFF6750A4)),
  green('Hijau', Color(0xFF2E7D32)),
  orange('Oranye', Color(0xFFEF6C00)),
  pink('Pink', Color(0xFFD81B60));

  const AppColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

class ThemeSettings {
  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.colorSeed = AppColorSeed.original,
  });

  final ThemeMode themeMode;
  final AppColorSeed colorSeed;

  ThemeSettings copyWith({ThemeMode? themeMode, AppColorSeed? colorSeed}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorSeed: colorSeed ?? this.colorSeed,
    );
  }
}

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  static const _modeKey = 'theme_mode';
  static const _colorKey = 'theme_color';

  @override
  ThemeSettings build() {
    _load();
    return const ThemeSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey);
    final colorName = prefs.getString(_colorKey);
    final mode = ThemeMode.values.where((m) => m.name == modeName).firstOrNull ?? ThemeMode.system;
    final color = AppColorSeed.values.where((c) => c.name == colorName).firstOrNull ?? AppColorSeed.original;
    state = ThemeSettings(themeMode: mode, colorSeed: color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  Future<void> setColorSeed(AppColorSeed seed) async {
    state = state.copyWith(colorSeed: seed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, seed.name);
  }
}

final themeSettingsProvider = NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(ThemeSettingsNotifier.new);

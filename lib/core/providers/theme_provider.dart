import 'package:eism/core/liquid_glass_config.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _frostKey = 'liquid_glass_frost';
  static const String _blurKey = 'liquid_glass_blur';
  static const String _enabledKey = 'liquid_glass_enabled';
  static const String _fidelityKey = 'liquid_glass_fidelity';
  
  ThemeMode _themeMode = ThemeMode.system;
  LiquidGlassConfig _glassConfig = const LiquidGlassConfig();

  ThemeMode get themeMode => _themeMode;
  LiquidGlassConfig get glassConfig => _glassConfig;

  LiquidGlassTheme get glassTheme {
    return LiquidGlassTheme(
      isEnabled: _glassConfig.isEnabled,
      blurIntensity: _glassConfig.blurIntensity,
      frostAmount: _glassConfig.frostAmount,
      transparency: _glassConfig.transparency,
      borderOpacity: _glassConfig.borderOpacity,
      highlightIntensity: _glassConfig.highlightIntensity,
      cornerRadius: _glassConfig.cornerRadius,
      noiseOpacity: _glassConfig.noiseOpacity,
      rimIntensity: _glassConfig.rimIntensity,
      specularComplexity: _glassConfig.specularComplexity,
      refractionDistortion: _glassConfig.refractionDistortion,
      chromaticIntensity: _glassConfig.chromaticIntensity,
      interactiveSensitivity: _glassConfig.interactiveSensitivity,
      breathingScale: _glassConfig.breathingScale,
      breathingSpeed: _glassConfig.breathingSpeed,
      fidelity: _glassConfig.fidelity,
    );
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    final frost = prefs.getDouble(_frostKey);
    final blur = prefs.getDouble(_blurKey);
    final enabled = prefs.getBool(_enabledKey);
    final fidelityIndex = prefs.getInt(_fidelityKey);
    
    if (frost != null || blur != null || enabled != null || fidelityIndex != null) {
      _glassConfig = _glassConfig.copyWith(
        frostAmount: frost,
        blurIntensity: blur,
        isEnabled: enabled,
        fidelity: fidelityIndex != null ? LiquidFidelity.values[fidelityIndex] : null,
      );
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void updateGlassConfig(LiquidGlassConfig config) async {
    _glassConfig = config;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_frostKey, config.frostAmount);
    await prefs.setDouble(_blurKey, config.blurIntensity);
    await prefs.setBool(_enabledKey, config.isEnabled);
    await prefs.setInt(_fidelityKey, config.fidelity.index);
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}

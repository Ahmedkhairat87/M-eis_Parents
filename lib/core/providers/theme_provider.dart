import 'package:eism/core/liquid_glass_config.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _frostKey = 'ethereal_frost';
  static const String _blurKey = 'ethereal_blur';
  static const String _enabledKey = 'ethereal_enabled';
  static const String _fidelityKey = 'ethereal_fidelity';
  static const String _animationSpeedKey = 'ethereal_animation_speed';
  static const String _breathingScaleKey = 'ethereal_breathing_scale';
  
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
      animationSpeed: _glassConfig.animationSpeed,
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
    final animationSpeed = prefs.getDouble(_animationSpeedKey);
    final breathingScale = prefs.getDouble(_breathingScaleKey);
    
    if (frost != null || blur != null || enabled != null || fidelityIndex != null || animationSpeed != null || breathingScale != null) {
      _glassConfig = _glassConfig.copyWith(
        frostAmount: frost,
        blurIntensity: blur,
        isEnabled: enabled,
        fidelity: fidelityIndex != null ? LiquidFidelity.values[fidelityIndex] : null,
        animationSpeed: animationSpeed,
        breathingScale: breathingScale,
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
    await prefs.setDouble(_animationSpeedKey, config.animationSpeed);
    await prefs.setDouble(_breathingScaleKey, config.breathingScale);
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}

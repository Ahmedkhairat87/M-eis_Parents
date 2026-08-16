import 'package:eism/core/liquid_glass_config.dart';
import 'package:flutter/material.dart';

class LiquidGlassTheme extends ThemeExtension<LiquidGlassTheme> {
  final double blurIntensity;
  final double frostAmount;
  final double transparency;
  final double borderOpacity;
  final double highlightIntensity;
  final double cornerRadius;
  final bool isEnabled;
  
  // New Ultra Fidelity Properties
  final double noiseOpacity;
  final double rimIntensity;
  final int specularComplexity;
  final double refractionDistortion;
  final double chromaticIntensity;
  final double interactiveSensitivity;
  final double breathingScale;
  final double breathingSpeed;
  final LiquidFidelity fidelity;

  const LiquidGlassTheme({
    this.blurIntensity = 20.0,
    this.frostAmount = 0.5,
    this.transparency = 0.2,
    this.borderOpacity = 0.1,
    this.highlightIntensity = 0.1,
    this.cornerRadius = 24.0,
    this.isEnabled = false,
    this.noiseOpacity = 0.03,
    this.rimIntensity = 0.4,
    this.specularComplexity = 3,
    this.refractionDistortion = 0.05,
    this.chromaticIntensity = 0.02,
    this.interactiveSensitivity = 1.0,
    this.breathingScale = 1.02,
    this.breathingSpeed = 1.0,
    this.fidelity = LiquidFidelity.high,
  });

  @override
  LiquidGlassTheme copyWith({
    double? blurIntensity,
    double? frostAmount,
    double? transparency,
    double? borderOpacity,
    double? highlightIntensity,
    double? cornerRadius,
    bool? isEnabled,
    double? noiseOpacity,
    double? rimIntensity,
    int? specularComplexity,
    double? refractionDistortion,
    double? chromaticIntensity,
    double? interactiveSensitivity,
    double? breathingScale,
    double? breathingSpeed,
    LiquidFidelity? fidelity,
  }) {
    return LiquidGlassTheme(
      blurIntensity: blurIntensity ?? this.blurIntensity,
      frostAmount: frostAmount ?? this.frostAmount,
      transparency: transparency ?? this.transparency,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      highlightIntensity: highlightIntensity ?? this.highlightIntensity,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      isEnabled: isEnabled ?? this.isEnabled,
      noiseOpacity: noiseOpacity ?? this.noiseOpacity,
      rimIntensity: rimIntensity ?? this.rimIntensity,
      specularComplexity: specularComplexity ?? this.specularComplexity,
      refractionDistortion: refractionDistortion ?? this.refractionDistortion,
      chromaticIntensity: chromaticIntensity ?? this.chromaticIntensity,
      interactiveSensitivity: interactiveSensitivity ?? this.interactiveSensitivity,
      breathingScale: breathingScale ?? this.breathingScale,
      breathingSpeed: breathingSpeed ?? this.breathingSpeed,
      fidelity: fidelity ?? this.fidelity,
    );
  }

  @override
  LiquidGlassTheme lerp(ThemeExtension<LiquidGlassTheme>? other, double t) {
    if (other is! LiquidGlassTheme) return this;
    return LiquidGlassTheme(
      blurIntensity: _lerpDouble(blurIntensity, other.blurIntensity, t)!,
      frostAmount: _lerpDouble(frostAmount, other.frostAmount, t)!,
      transparency: _lerpDouble(transparency, other.transparency, t)!,
      borderOpacity: _lerpDouble(borderOpacity, other.borderOpacity, t)!,
      highlightIntensity: _lerpDouble(highlightIntensity, other.highlightIntensity, t)!,
      cornerRadius: _lerpDouble(cornerRadius, other.cornerRadius, t)!,
      isEnabled: t < 0.5 ? isEnabled : other.isEnabled,
      noiseOpacity: _lerpDouble(noiseOpacity, other.noiseOpacity, t)!,
      rimIntensity: _lerpDouble(rimIntensity, other.rimIntensity, t)!,
      specularComplexity: (t < 0.5 ? specularComplexity : other.specularComplexity),
      refractionDistortion: _lerpDouble(refractionDistortion, other.refractionDistortion, t)!,
      chromaticIntensity: _lerpDouble(chromaticIntensity, other.chromaticIntensity, t)!,
      interactiveSensitivity: _lerpDouble(interactiveSensitivity, other.interactiveSensitivity, t)!,
      breathingScale: _lerpDouble(breathingScale, other.breathingScale, t)!,
      breathingSpeed: _lerpDouble(breathingSpeed, other.breathingSpeed, t)!,
      fidelity: t < 0.5 ? fidelity : other.fidelity,
    );
  }

  double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0;
    b ??= 0;
    return a + (b - a) * t;
  }
}

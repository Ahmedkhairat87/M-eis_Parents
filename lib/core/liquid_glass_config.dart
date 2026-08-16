
enum LiquidFidelity { standard, high, ultra }

class LiquidGlassConfig {
  final bool isEnabled;
  final double blurIntensity;
  final double frostAmount;
  final double transparency;
  final double borderOpacity;
  final double reflectionIntensity;
  final double highlightIntensity;
  final double shadowIntensity;
  final double cornerRadius;
  final double glassSaturation;
  final double glassBrightness;
  final double animationSpeed;
  
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

  const LiquidGlassConfig({
    this.isEnabled = false,
    this.blurIntensity = 20.0,
    this.frostAmount = 0.5,
    this.transparency = 0.2,
    this.borderOpacity = 0.1,
    this.reflectionIntensity = 0.1,
    this.highlightIntensity = 0.1,
    this.shadowIntensity = 0.05,
    this.cornerRadius = 24.0,
    this.glassSaturation = 1.0,
    this.glassBrightness = 1.0,
    this.animationSpeed = 1.0,
    
    // Default Ultra Fidelity Values
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

  LiquidGlassConfig copyWith({
    bool? isEnabled,
    double? blurIntensity,
    double? frostAmount,
    double? transparency,
    double? borderOpacity,
    double? reflectionIntensity,
    double? highlightIntensity,
    double? shadowIntensity,
    double? cornerRadius,
    double? glassSaturation,
    double? glassBrightness,
    double? animationSpeed,
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
    return LiquidGlassConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      frostAmount: frostAmount ?? this.frostAmount,
      transparency: transparency ?? this.transparency,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      reflectionIntensity: reflectionIntensity ?? this.reflectionIntensity,
      highlightIntensity: highlightIntensity ?? this.highlightIntensity,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      glassSaturation: glassSaturation ?? this.glassSaturation,
      glassBrightness: glassBrightness ?? this.glassBrightness,
      animationSpeed: animationSpeed ?? this.animationSpeed,
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
}

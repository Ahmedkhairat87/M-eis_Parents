import 'dart:math';
import 'dart:ui';
import 'package:eism/core/liquid_glass_config.dart';
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:eism/ui/widgets/glass/liquid_glass_controller.dart';
import 'package:eism/ui/widgets/glass/liquid_glass_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? color;
  final double? blur;
  final double? opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.color,
    this.blur,
    this.opacity,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> with TickerProviderStateMixin {
  late LiquidGlassController _controller;
  FragmentShader? _shader;
  bool _isShaderLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = LiquidGlassController(vsync: this);
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset('assets/shaders/liquid_glass.frag');
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
          _isShaderLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Shader failed to load, falling back to Painter: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>() ?? 
                       themeProvider.glassTheme;
    final isDarkMode = themeProvider.isDarkMode;

    if (!glassTheme.isEnabled) {
      return _buildSimpleContainer(isDarkMode);
    }

    final config = themeProvider.glassConfig;
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(glassTheme.cornerRadius);

    return MouseRegion(
      onHover: (event) => _controller.updatePointer(event.localPosition, context.size ?? Size.zero),
      child: GestureDetector(
        onPanUpdate: (details) => _controller.updatePointer(details.localPosition, context.size ?? Size.zero),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final breathing = 1.0 + (config.breathingScale - 1.0) * ((sin(_controller.time * config.breathingSpeed) + 1) / 2);
            
            return Transform.scale(
              scale: breathing,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                decoration: BoxDecoration(
                  borderRadius: effectiveRadius,
                  boxShadow: widget.boxShadow ?? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: effectiveRadius,
                  child: Stack(
                    children: [
                      // Layer 1: Backdrop Blur (Static-ish)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: widget.blur ?? glassTheme.blurIntensity, 
                              sigmaY: widget.blur ?? glassTheme.blurIntensity
                            ),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ),

                      // Layer 2: Refraction Shader (Ultra Fidelity)
                      if (config.fidelity == LiquidFidelity.ultra && _isShaderLoaded)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ShaderPainter(
                              shader: _shader!,
                              time: _controller.time,
                              refraction: config.refractionDistortion,
                              chromatic: config.chromaticIntensity,
                              noise: config.noiseOpacity,
                            ),
                          ),
                        ),

                      // Layer 3: Base Tint
                      Positioned.fill(
                        child: Container(
                          color: (widget.color ?? (isDarkMode ? Colors.black : Colors.white))
                              .withValues(alpha: widget.opacity ?? glassTheme.transparency),
                        ),
                      ),

                      // Layer 4: Liquid Painter (Dynamic Reflections)
                      if (config.fidelity != LiquidFidelity.standard)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: LiquidGlassPainter(
                              controller: _controller,
                              config: config,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ),

                      // Layer 5: Foreground Content
                      Padding(
                        padding: widget.padding ?? EdgeInsets.zero,
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimpleContainer(bool isDarkMode) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color ?? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.0),
        border: Border.all(
          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: widget.boxShadow,
      ),
      child: widget.child,
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final double refraction;
  final double chromatic;
  final double noise;

  _ShaderPainter({
    required this.shader,
    required this.time,
    required this.refraction,
    required this.chromatic,
    required this.noise,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, refraction);
    shader.setFloat(4, chromatic);
    shader.setFloat(5, noise);
    
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:eism/core/liquid_glass_config.dart';
import 'package:eism/ui/widgets/glass/liquid_glass_controller.dart';
import 'package:flutter/material.dart';

class LiquidGlassPainter extends CustomPainter {
  final LiquidGlassController controller;
  final LiquidGlassConfig config;
  final bool isDarkMode;

  LiquidGlassPainter({
    required this.controller,
    required this.config,
    required this.isDarkMode,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromLTRBR(
      0, 0, size.width, size.height,
      Radius.circular(config.cornerRadius),
    );

    // 1. Premium Outer Rim
    _paintOuterRim(canvas, size, rrect);

    // 2. Layered Reflections
    _paintReflections(canvas, size, rrect);

    // 3. Internal Accents (Sparkles)
    _paintSparkles(canvas, size, rrect);
    
    // 4. Subtle Glow
    _paintInnerGlow(canvas, size, rrect);
  }

  void _paintOuterRim(Canvas canvas, Size size, RRect rrect) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: config.rimIntensity),
          Colors.white.withValues(alpha: config.rimIntensity * 0.2),
          Colors.white.withValues(alpha: config.rimIntensity * 0.5),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(controller.time * 0.1),
      ).createShader(Offset.zero & size);

    canvas.drawRRect(rrect, paint);
  }

  void _paintReflections(Canvas canvas, Size size, RRect rrect) {
    final pointer = controller.pointerPosition;
    
    // Primary Highlight
    _drawReflectionLayer(
      canvas, size, rrect,
      opacity: 0.15 * config.highlightIntensity * 10,
      offset: Offset(
        pointer.dx * 20 + controller.getOrganicValue(0) * 50,
        pointer.dy * 20 + controller.getOrganicValue(1) * 50,
      ),
      blur: 40.0,
      scale: 0.8,
    );

    // Secondary Soft Reflection
    _drawReflectionLayer(
      canvas, size, rrect,
      opacity: 0.1 * config.highlightIntensity * 10,
      offset: Offset(
        -pointer.dx * 10 + controller.getOrganicValue(2) * 80,
        -pointer.dy * 10 + controller.getOrganicValue(3) * 80,
      ),
      blur: 60.0,
      scale: 1.2,
    );
  }

  void _drawReflectionLayer(
    Canvas canvas, Size size, RRect rrect, 
    {required double opacity, required Offset offset, required double blur, required double scale}
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(scale);
    
    final path = Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: size.width * 1.5, height: size.height * 0.4));
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _paintSparkles(Canvas canvas, Size size, RRect rrect) {
    final random = Random(42);
    for (int i = 0; i < config.specularComplexity * 2; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparkleOpacity = (sin(controller.time * 2 + i) + 1) / 2 * 0.3;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: sparkleOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  void _paintInnerGlow(Canvas canvas, Size size, RRect rrect) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0)
      ..color = (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.02);
      
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidGlassPainter oldDelegate) => true;
}

import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:flutter/material.dart';

/// Legacy wrapper for the new GlassContainer system to maintain compatibility
/// while providing the enhanced iOS 26 Liquid Glass appearance.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double? blur;
  final double? opacity;
  final double? borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const LiquidGlass({
    super.key,
    required this.child,
    this.blur,
    this.opacity,
    this.borderRadius,
    this.color,
    this.border,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: width,
      height: height,
      padding: padding,
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
      color: color,
      border: border,
      child: child,
    );
  }
}

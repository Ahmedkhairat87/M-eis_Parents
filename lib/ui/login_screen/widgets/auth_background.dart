import 'dart:math' as math;
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/ui/widgets/glass/liquid_glass_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthBackground extends StatefulWidget {
  final Widget child;
  final bool isCenter;

  const AuthBackground({
    super.key,
    required this.child,
    this.isCenter = false,
  });

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground> with TickerProviderStateMixin {
  late LiquidGlassController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LiquidGlassController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;
    final config = themeProvider.glassConfig;

    _controller.updateSpeed(config.animationSpeed);

    return Stack(
      children: [
        // Main Dynamic Gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [
                    const Color(0xFF0F2027),
                    const Color(0xFF203A43),
                    const Color(0xFF2C5364),
                  ]
                : [
                    const Color(0xFFE0EAFC),
                    const Color(0xFFCFDEF3),
                    const Color(0xFFF5F7FA),
                  ],
            ),
          ),
        ),
        // Ethereal decorative elements - Only this part rebuilds
        if (config.isEnabled)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final breathingAmount = (config.breathingScale - 1.0) * 
                    ((math.sin(_controller.time * config.breathingSpeed * 1.5) + 1) / 2);

                return Stack(
                  children: [
                    Positioned(
                      top: -size.width * 0.2 + _controller.getOrganicValue(0) * 100,
                      right: -size.width * 0.1 + _controller.getOrganicValue(1) * 100,
                      child: _LiquidBlob(
                        size: size.width * 0.8 * (1 + breathingAmount),
                        color: (isDark ? Colors.blue.shade900 : Colors.blue.shade200).withValues(alpha: 0.3),
                        blurRadius: 100,
                      ),
                    ),
                    Positioned(
                      bottom: size.height * 0.1 + _controller.getOrganicValue(3) * 80,
                      left: -size.width * 0.2 + _controller.getOrganicValue(4) * 80,
                      child: _LiquidBlob(
                        size: size.width * 0.7 * (1 + breathingAmount),
                        color: (isDark ? Colors.purple.shade900 : Colors.purple.shade100).withValues(alpha: 0.25),
                        blurRadius: 120,
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.3 + _controller.getOrganicValue(2) * 60,
                      left: size.width * 0.5 + _controller.getOrganicValue(0) * 60,
                      child: _LiquidBlob(
                        size: size.width * 0.5 * (1 + breathingAmount),
                        color: (isDark ? Colors.teal.shade900 : Colors.teal.shade50).withValues(alpha: 0.2),
                        blurRadius: 80,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        SafeArea(
          child: widget.isCenter ? Center(child: widget.child) : widget.child,
        ),
      ],
    );
  }
}

class _LiquidBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double blurRadius;

  const _LiquidBlob({required this.size, required this.color, required this.blurRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: blurRadius,
            spreadRadius: blurRadius / 2,
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool isCenter;

  const AuthBackground({
    super.key,
    required this.child,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

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
        // Liquid Glass decorative elements
        Positioned(
          top: -size.width * 0.2,
          right: -size.width * 0.1,
          child: _LiquidBlob(
            size: size.width * 0.8,
            color: (isDark ? Colors.blue.shade900 : Colors.blue.shade200).withValues(alpha: 0.3),
            blurRadius: 100,
          ),
        ),
        Positioned(
          bottom: size.height * 0.1,
          left: -size.width * 0.2,
          child: _LiquidBlob(
            size: size.width * 0.7,
            color: (isDark ? Colors.purple.shade900 : Colors.purple.shade100).withValues(alpha: 0.25),
            blurRadius: 120,
          ),
        ),
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.5,
          child: _LiquidBlob(
            size: size.width * 0.5,
            color: (isDark ? Colors.teal.shade900 : Colors.teal.shade50).withValues(alpha: 0.2),
            blurRadius: 80,
          ),
        ),
        SafeArea(
          child: isCenter ? Center(child: child) : child,
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

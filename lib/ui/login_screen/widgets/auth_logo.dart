import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthLogo extends StatefulWidget {
  final double size;
  
  const AuthLogo({
    super.key,
    this.size = 150,
  });

  @override
  State<AuthLogo> createState() => _AuthLogoState();
}

class _AuthLogoState extends State<AuthLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Image.asset(
          'assets/images/logo.png',
          width: widget.size.w,
          height: widget.size.h,
        ),
      ),
    );
  }
}

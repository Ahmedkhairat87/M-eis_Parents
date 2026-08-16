import 'dart:async';
import 'package:eism/core/app_style.dart';
import 'package:eism/ui/login_screen/login_screen.dart';
import 'package:eism/ui/login_screen/profileSelection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    // Start animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Navigate to next screen
    Timer(const Duration(seconds: 4), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (mounted) {
          if (token != null && token.isNotEmpty) {
            Navigator.pushReplacementNamed(context, ProfileSelectionScreen.routeName);
          } else {
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 1500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200.w,
                  height: 200.h,
                ),
                SizedBox(height: 20.h),
                CircularProgressIndicator(
                  color: AppStyle.primaryBlue,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

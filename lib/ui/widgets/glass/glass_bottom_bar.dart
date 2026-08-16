import 'dart:ui';
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GlassBottomBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>() ?? 
                       themeProvider.glassTheme;
    final isDarkMode = themeProvider.isDarkMode;

    final bottomNav = BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      elevation: 0,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.5),
      selectedLabelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 10.sp),
      iconSize: 22.sp,
    );

    if (!glassTheme.isEnabled) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(glassTheme.cornerRadius.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(glassTheme.cornerRadius.r),
          child: bottomNav,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(glassTheme.cornerRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: glassTheme.blurIntensity, sigmaY: glassTheme.blurIntensity),
        child: Container(
          decoration: BoxDecoration(
            color: (isDarkMode ? Colors.black : Colors.white).withValues(alpha: glassTheme.transparency),
            borderRadius: BorderRadius.circular(glassTheme.cornerRadius.r),
            border: Border.all(
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: glassTheme.borderOpacity),
              width: 0.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: glassTheme.highlightIntensity),
                Colors.transparent,
              ],
            ),
          ),
          child: bottomNav,
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>() ?? 
                       themeProvider.glassTheme;
    final isDarkMode = themeProvider.isDarkMode;

    if (!glassTheme.isEnabled) {
      return AppBar(
        title: title,
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        elevation: elevation,
        backgroundColor: backgroundColor ?? (isDarkMode ? Colors.black : Colors.white),
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: glassTheme.blurIntensity, sigmaY: glassTheme.blurIntensity),
        child: AppBar(
          title: title,
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          elevation: elevation,
          backgroundColor: (backgroundColor ?? (isDarkMode ? Colors.black : Colors.white))
              .withValues(alpha: glassTheme.transparency),
          surfaceTintColor: Colors.transparent,
          shape: Border(
            bottom: BorderSide(
              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: glassTheme.borderOpacity),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:eism/ui/widgets/glass/liquid_glass_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GlassScaffold extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.backgroundColor,
  });

  @override
  State<GlassScaffold> createState() => _GlassScaffoldState();
}

class _GlassScaffoldState extends State<GlassScaffold> with TickerProviderStateMixin {
  late LiquidGlassController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = LiquidGlassController(vsync: this);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>() ?? 
                       themeProvider.glassTheme;
    final isDarkMode = themeProvider.isDarkMode;

    if (!glassTheme.isEnabled) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        appBar: widget.appBar,
        drawer: widget.drawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        body: widget.body,
      );
    }

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            // Dynamic Background (Full Screen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode 
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
            ),
            
            // Animated decorative blobs
            Positioned(
              top: -50.h + _backgroundController.getOrganicValue(0) * 100,
              right: -50.w + _backgroundController.getOrganicValue(1) * 100,
              child: _DecorativeBlob(
                size: 300.w + _backgroundController.getOrganicValue(2) * 50,
                color: (isDarkMode ? Colors.blue : Colors.blue.shade200).withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              bottom: 50.h + _backgroundController.getOrganicValue(3) * 80,
              left: -30.w + _backgroundController.getOrganicValue(4) * 80,
              child: _DecorativeBlob(
                size: 250.w + _backgroundController.getOrganicValue(0) * 40,
                color: (isDarkMode ? Colors.purple : Colors.purple.shade200).withValues(alpha: 0.1),
              ),
            ),

            // Main Scaffold
            Scaffold(
              extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
              extendBody: widget.extendBody,
              appBar: widget.appBar,
              drawer: widget.drawer,
              bottomNavigationBar: widget.bottomNavigationBar,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              backgroundColor: Colors.transparent,
              body: widget.body,
            ),
          ],
        );
      },
    );
  }
}

class _DecorativeBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

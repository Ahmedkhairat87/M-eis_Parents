import 'package:eism/core/app_style.dart';
import 'package:eism/ui/under_construction/uc.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_bottom_bar.dart';
import 'package:eism/ui/widgets/glass/specular_glass_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/home_screen/home_screen.dart';
import 'package:eism/ui/massages_screen/massages_screen.dart';
import 'package:eism/ui/profile_screen/profile_screen.dart';
import 'package:eism/ui/Student/newsletter_screen/newsletter_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const routeName = '/MainNavigationScreen';
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isHome = _selectedIndex == 0;
    
    return GlassScaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Content Area - Stable IndexedStack
          IndexedStack(
            index: _selectedIndex,
            children: const [
              HomeScreen(),
              MassagesScreen(),
              NewsletterScreen(),
              UnderConstructionScreen(),
              /*CreativityActivityService(),*/
              ProfileScreen(),
            ],
          ),

          // Home-specific Floating Navigation Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: !isHome,
              child: AnimatedOpacity(
                opacity: isHome ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: isHome ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h + MediaQuery.of(context).padding.bottom),
                    child: _buildHomeNavigation(context),
                  ),
                ),
              ),
            ),
          ),

          // ONE CONTINUOUS FULL-WIDTH MOTION-RESPONSIVE GLASS SURFACE LAYER
          // Begins around the vertical middle region of the floating navigation capsule,
          // spans the FULL SCREEN WIDTH (left: 0, right: 0), and extends to bottom of screen!
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AbsorbPointer(
              absorbing: !isHome,
              child: AnimatedOpacity(
                opacity: isHome ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: isHome ? const Offset(0, 0.2) : Offset.zero,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: SpecularGlassLayer(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                    height: 56.h + MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ),
            ),
          ),

          // Standard GlassBottomBar Overlay (Positioned IN FRONT)
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: isHome,
              child: AnimatedOpacity(
                opacity: isHome ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: isHome ? const Offset(0, 0.2) : Offset.zero,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h + MediaQuery.of(context).padding.bottom),
                    child: GlassBottomBar(
                      currentIndex: _selectedIndex,
                      onTap: _onItemTapped,
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.home_outlined),
                          activeIcon: const Icon(Icons.home),
                          label: AppStrings.home.tr(),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.message_outlined),
                          activeIcon: const Icon(Icons.message),
                          label: AppStrings.messages.tr(),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.newspaper_outlined),
                          activeIcon: const Icon(Icons.newspaper),
                          label: AppStrings.newsletter.tr(),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.brush_outlined),
                          activeIcon: const Icon(Icons.brush),
                          label: AppStrings.cas.tr(),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.person_outline),
                          activeIcon: const Icon(Icons.person),
                          label: AppStrings.profile.tr(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeNavigation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavButton(context, 0, Icons.home_rounded, AppStrings.home.tr()),
        _buildNavButton(context, 1, Icons.message_rounded, AppStrings.messages.tr()),
        _buildNavButton(context, 2, Icons.newspaper_rounded, AppStrings.newsletter.tr()),
        _buildNavButton(context, 3, Icons.brush_rounded, AppStrings.cas.tr()),
        _buildNavButton(context, 4, Icons.person_rounded, AppStrings.profile.tr()),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected ? AppStyle.primaryBlue : (isDark ? Colors.white60 : Colors.blueGrey.shade400);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            width: 54.w,
            height: 54.w,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            borderRadius: BorderRadius.circular(16.r),
            color: isSelected 
                ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.9))
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4)),
            border: Border.all(
              color: isSelected 
                  ? AppStyle.primaryBlue.withValues(alpha: 0.5) 
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: 60.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/cas_screen/cas_screen.dart';
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const MassagesScreen(),
    const NewsletterScreen(),
    const CreativityActivityService(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
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
    );
  }
}


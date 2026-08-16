import 'dart:async';
import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/login_screen/widgets/auth_background.dart';
import 'package:eism/ui/login_screen/widgets/auth_logo.dart';
import 'package:eism/ui/login_screen/widgets/profile_icon_box.dart';
import 'package:eism/ui/login_screen/widgets/profile_models.dart';
import 'package:eism/ui/login_screen/widgets/profile_transition.dart';
import 'package:eism/ui/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/ui/Student/landing_screen/landing_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data/api/api_client.dart';
import '../../core/data/models/student_model.dart';
import '../../core/data/models/login_response.dart';
import '../../core/data/repositories/student_repository.dart';

import '../../core/data/repositories/parent_repository.dart';
import '../../core/providers/parent_provider.dart';
import 'package:provider/provider.dart';

class ProfileSelectionScreen extends StatefulWidget {
  static const routeName = '/ProfileSelectionScreen';
  
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> with SingleTickerProviderStateMixin {
  final StudentRepository _studentRepository = StudentRepository(ApiClient());
  final ParentRepository _parentRepository = ParentRepository(ApiClient());
  List<AppProfile> _profiles = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fetchInitialData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final deviceID = prefs.getString('device_id') ?? '';
      final deviceType = prefs.getString('device_type') ?? '';

      // Fetch parent data and students in parallel
      final results = await Future.wait([
        _parentRepository.getParentProfile(token),
        _studentRepository.getRegisteredStudents(
          token: token,
          deviceID: deviceID,
          deviceType: deviceType,
        ),
      ]);

      final FamilyData? parentData = results[0] as FamilyData?;
      final List<StudentModel> students = results[1] as List<StudentModel>;

      if (parentData != null && mounted) {
        Provider.of<ParentProvider>(context, listen: false).setParentData(parentData);
      }

      // Map API data to UI Profiles
      final List<AppProfile> loadedProfiles = [
        AppProfile(
          name: AppStrings.parentHome, 
          color: AppStyle.accentGreen, 
          isParent: true,
          targetRoute: MainNavigationScreen.routeName,
        ),
      ];

      for (var student in students) {
        loadedProfiles.add(
          AppProfile(
            name: student.name ?? 'Student', 
            color: AppStyle.primaryBlue, 
            targetRoute: LandingScreen.routeName,
            student: student,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _profiles = loadedProfiles;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback to parent portal only on error
        setState(() {
          _profiles = [
            AppProfile(
              name: AppStrings.parentHome, 
              color: AppStyle.accentGreen, 
              isParent: true,
              targetRoute: MainNavigationScreen.routeName,
            ),
          ];
        });
        _animationController.forward();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AuthBackground(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AuthLogo(size: 120),
                          SizedBox(height: 40.h),
                          Text(
                            AppStrings.selectProfile.tr(),
                            style: theme.textTheme.headlineLarge,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            AppStrings.chooseProfile.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white.withAlpha(180) : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          
                          SizedBox(
                            height: 165.h,
                            child: Center(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _profiles.length,
                                itemBuilder: (context, index) {
                                  final profile = _profiles[index];
                                  
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(milliseconds: 400 + (index * 200)),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Opacity(
                                          opacity: value.clamp(0.0, 1.0),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 85.w,
                                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            ProfileTransitionRoute(profile: profile),
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Hero(
                                                tag: 'profile_icon_${profile.name}',
                                                flightShuttleBuilder: (
                                                  flightContext,
                                                  animation,
                                                  flightDirection,
                                                  fromHeroContext,
                                                  toHeroContext,
                                                ) {
                                                  return ProfileIconBox(profile: profile, isExpanding: true);
                                                },
                                                child: ProfileIconBox(profile: profile),
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              profile.name.tr(),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 60.h),
                          Text(
                            AppStrings.appTitle.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white.withAlpha(100) : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

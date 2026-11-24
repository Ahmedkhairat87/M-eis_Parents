import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:eism/ui/login_screen/login_screen.dart';

// Added from ProfileSelectionScreen
import 'package:eism/ui/login_screen/widgets/auth_background.dart';
import 'package:eism/ui/login_screen/widgets/auth_logo.dart';
import 'package:eism/ui/login_screen/widgets/profile_icon_box.dart';
import 'package:eism/ui/login_screen/widgets/profile_models.dart';
import 'package:eism/ui/login_screen/widgets/profile_transition.dart';
import 'package:eism/ui/Student/landing_screen/landing_screen.dart';
import '../../core/data/api/api_client.dart';
import '../../core/data/models/student_model.dart';
import '../../core/data/models/login_response.dart';
import '../../core/data/repositories/student_repository.dart';
import '../../core/data/repositories/parent_repository.dart';
import '../../core/providers/parent_provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/HomeScreenContent';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final StudentRepository _studentRepository = StudentRepository(ApiClient());
  final ParentRepository _parentRepository = ParentRepository(ApiClient());
  List<AppProfile> _profiles = [];
  bool _isLoading = true;
  bool _hasError = false;

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
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

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

      // Map API data to UI Profiles (Students only - no parent button as Home IS the parent portal)
      final List<AppProfile> loadedProfiles = [];

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
          _hasError = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error fetching initial data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        _animationController.forward();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.loadError.tr()),
            action: SnackBarAction(
              label: AppStrings.retry.tr(),
              onPressed: _fetchInitialData,
            ),
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        content: GlassContainer(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.logout.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppStyle.primaryDarkBlue,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppStrings.logoutConfirm.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      minimumSize: Size(100.w, 48.h),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(
                      AppStrings.cancel.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppStyle.primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GlassButton(
                    width: 140.w,
                    height: 48.h,
                    color: AppStyle.errorRed,
                    borderRadius: 16.r,
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('auth_token');
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
                      }
                    },
                    child: Text(
                      AppStrings.logout.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(AppStrings.home.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: AppStrings.notifications.tr(),
            onPressed: () {
              // Notification logic
            },
          ),
        ],
      ),
      drawer: const AppDrawer(contextRole: DrawerContext.parent),
      body: AuthBackground(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 150.h), // Increased bottom padding for floating nav
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AuthLogo(size: 100),
                          SizedBox(height: 30.h),
                          Text(
                            AppStrings.welcomeBack.tr(),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            AppStrings.parentHome.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white.withAlpha(180) : Colors.grey.shade600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 50.h),
                          
                          if (_profiles.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.w),
                              child: GlassContainer(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  children: [
                                    Text(
                                      _hasError 
                                        ? AppStrings.loadError.tr()
                                        : "No registered children found under your account.", 
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    if (_hasError) ...[
                                      SizedBox(height: 16.h),
                                      TextButton.icon(
                                        onPressed: _fetchInitialData,
                                        icon: const Icon(Icons.refresh, color: AppStyle.primaryBlue),
                                        label: Text(
                                          AppStrings.retry.tr(),
                                          style: const TextStyle(color: AppStyle.primaryBlue, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 180.h,
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
                                        width: 90.w,
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

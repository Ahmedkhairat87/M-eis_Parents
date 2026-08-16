import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/login_screen/widgets/auth_background.dart';
import 'package:eism/ui/login_screen/widgets/profile_icon_box.dart';
import 'package:eism/ui/login_screen/widgets/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ProfileTransitionRoute extends PageRouteBuilder {
  final AppProfile profile;

  ProfileTransitionRoute({required this.profile})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoadingGateScreen(profile: profile),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class LoadingGateScreen extends StatefulWidget {
  final AppProfile profile;
  const LoadingGateScreen({super.key, required this.profile});

  @override
  State<LoadingGateScreen> createState() => _LoadingGateScreenState();
}

class _LoadingGateScreenState extends State<LoadingGateScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() async {
    // Ensure the provider update happens after the current frame to avoid "setState during build" error
    if (widget.profile.student != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final studentProvider = Provider.of<StudentProvider>(context, listen: false);
          studentProvider.setSelectedStudent(widget.profile.student!);
        }
      });
    }

    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(widget.profile.targetRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AuthBackground(
        isCenter: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 130.w,
              height: 130.h,
              child: Hero(
                tag: 'profile_icon_${widget.profile.name}',
                child: ProfileIconBox(profile: widget.profile, isExpanding: true),
              ),
            ),
            SizedBox(height: 50.h),
            SizedBox(
              width: 35.w,
              height: 35.h,
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : AppStyle.primaryBlue,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              '${AppStrings.opening.tr()} ${widget.profile.name.tr()}',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

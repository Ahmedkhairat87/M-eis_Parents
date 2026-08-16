import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/core/app_style.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: isDark ? AppStyle.darkPrimaryBlue : AppStyle.primaryBlue,
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : AppStyle.primaryBlue.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:eism/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LandingMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const LandingMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppStyle.primaryDarkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

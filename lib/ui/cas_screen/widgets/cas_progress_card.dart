import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class CASProgressCard extends StatelessWidget {
  final int totalPointsAchieved;
  final int targetPoints;

  const CASProgressCard({
    super.key,
    required this.totalPointsAchieved,
    required this.targetPoints,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalPointsAchieved / targetPoints;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.familyCasProgress.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppStyle.primaryBlue,
                ),
              ),
              Text(
                '$totalPointsAchieved / $targetPoints',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12.h,
              backgroundColor: isDark ? Colors.white10 : AppStyle.lightBlueBg,
              color: AppStyle.primaryBlue,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            AppStrings.earnPointsInfo.tr(),
            style: TextStyle(
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

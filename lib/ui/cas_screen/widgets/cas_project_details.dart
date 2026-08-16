import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/cas_screen/widgets/cas_project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class CASProjectDetails extends StatelessWidget {
  final CASProject project;

  const CASProjectDetails({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: isDark ? Colors.white12 : AppStyle.lightBlueBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppStyle.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                AppStrings.projectBrief.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppStyle.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            project.brief,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white60 : Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

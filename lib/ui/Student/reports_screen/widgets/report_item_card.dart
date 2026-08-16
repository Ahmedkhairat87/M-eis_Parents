import 'package:eism/core/app_style.dart';
import 'package:eism/ui/Student/reports_screen/widgets/report_model.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportItemCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const ReportItemCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppStyle.accentOrange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.assessment_rounded, color: AppStyle.accentOrange, size: 24.sp),
        ),
        title: Text(
          report.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
          ),
        ),
        subtitle: report.date.isNotEmpty ? Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 12.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                report.date,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ) : null,
        trailing: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppStyle.primaryBlue,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14.sp),
        ),
        onTap: onTap,
      ),
    );
  }
}

import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/Student/weeklyPlan_screen/widgets/weekly_plan_model.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class PlanDetailsCard extends StatelessWidget {
  final WeeklyPlan selectedPlan;
  final VoidCallback onViewPlan;

  const PlanDetailsCard({
    super.key,
    required this.selectedPlan,
    required this.onViewPlan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppStyle.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today_rounded, color: AppStyle.primaryBlue, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPlan.weekDescription ?? '${AppStrings.week.tr()} ${selectedPlan.weekNumber}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                        ),
                      ),
                      Text(
                        '${selectedPlan.startDate} - ${selectedPlan.endDate}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  onPressed: onViewPlan,
                  height: 36.h,
                  width: 80.w,
                  borderRadius: 8,
                  color: AppStyle.primaryBlue,
                  child: Text(
                    AppStrings.viewPlan.tr(),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

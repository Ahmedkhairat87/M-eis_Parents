import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/data/models/homework_model.dart';

class HomeworkCard extends StatelessWidget {
  final HomeworkModel homework;
  final VoidCallback onViewDetails;

  const HomeworkCard({
    super.key,
    required this.homework,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.subject ?? '',
                        style: TextStyle(
                          color: AppStyle.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      if (homework.subtopic != null && homework.subtopic!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            homework.subtopic!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : AppStyle.primaryDarkBlue.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      homework.date ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (homework.hasAttachment)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Icon(Icons.attach_file_rounded, size: 16.sp, color: Colors.green),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              homework.body ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            AppButton(
              onPressed: onViewDetails,
              width: double.infinity,
              height: 40.h,
              borderRadius: 12,
              color: AppStyle.primaryBlue,
              child: Text(
                AppStrings.viewHomework.tr(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

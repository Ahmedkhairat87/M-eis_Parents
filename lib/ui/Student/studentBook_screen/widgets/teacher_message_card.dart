import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/models/student_book_message_model.dart';
import '../../../../core/data/repositories/student_book_repository.dart';

class TeacherMessageCard extends StatelessWidget {
  final StudentBookMessageModel message;
  final bool isSent;
  final VoidCallback onRefresh;
  
  const TeacherMessageCard({
    super.key, 
    required this.message, 
    this.isSent = false,
    required this.onRefresh,
  });

  void _showDetails(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Mark as read if it's an inbox message and unread
    if (!isSent && !message.isRead) {
      final repository = StudentBookRepository(ApiClient());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      await repository.markAsRead(token: token, taSer: message.taSer.toString());
      onRefresh(); // Refresh to update UI (remove bold/indicator)
    }

    if (!context.mounted) return;

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300, 
                  borderRadius: BorderRadius.circular(2.r)
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              message.subject ?? AppStrings.noMessages.tr(),
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppStyle.primaryBlue),
            ),
            SizedBox(height: 8.h),
            Text(
              '${message.category ?? ""} - ${message.teacherName ?? ""}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            Text(
              message.date ?? '',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            const Divider(height: 32),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Text(
                  message.body ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(
              onPressed: () => Navigator.pop(context),
              width: double.infinity,
              child: Text(
                AppStrings.close.tr(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool showUnreadIndicator = !isSent && !message.isRead;

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: AppStyle.primaryBlue.withValues(alpha: 0.1),
                    child: Text(
                      (message.teacherName?.isNotEmpty == true ? message.teacherName![0] : 'T'),
                      style: const TextStyle(color: AppStyle.primaryBlue, fontWeight: FontWeight.bold)
                    ),
                  ),
                  if (showUnreadIndicator)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            message.subject ?? AppStrings.noMessages.tr(), 
                            style: TextStyle(
                              fontWeight: showUnreadIndicator ? FontWeight.bold : FontWeight.w600, 
                              fontSize: 14.sp, 
                              color: isDark ? Colors.white : Colors.black87
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                        Text(
                          message.date?.split(' ').first ?? '',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${message.category ?? ""} - ${message.teacherName ?? ""}',
                      style: TextStyle(
                        color: AppStyle.primaryBlue, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 11.sp
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      message.body ?? '', 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:eism/core/managers/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class EmptyMessagesState extends StatelessWidget {
  const EmptyMessagesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 64.sp, color: Colors.grey.withAlpha(50)),
          SizedBox(height: 16.h),
          Text(AppStrings.noMessages.tr(), style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
}

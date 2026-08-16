import 'package:eism/ui/Student/newsletter_screen/widgets/newsletter_model.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/core/app_style.dart';

class NewsletterTile extends StatelessWidget {
  final Newsletter newsletter;
  final VoidCallback onTap;

  const NewsletterTile({
    super.key,
    required this.newsletter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.newspaper_outlined,
                  color: Colors.orange,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsletter.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppStyle.primaryBlue.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class PrivacySecurityScreen extends StatelessWidget {
  static const routeName = '/PrivacySecurityScreen';
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.privacySecurity.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        child: AppCard(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text("🔒", style: TextStyle(fontSize: 24.sp)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      AppStrings.privacyMattersTitle.tr(),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                AppStrings.privacyMattersSubtitle.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),

              _buildDivider(isDark),

              // Privacy Section
              _buildSectionHeader(context, "🛡", AppStrings.privacySectionTitle.tr()),
              _buildBulletPoint(context, AppStrings.privacyPoint1.tr()),
              _buildBulletPoint(context, AppStrings.privacyPoint2.tr()),
              _buildBulletPoint(context, AppStrings.privacyPoint3.tr()),

              _buildDivider(isDark),

              // Secure Connection Section
              _buildSectionHeader(context, "🔐", AppStrings.secureConnectionTitle.tr()),
              _buildBulletPoint(context, AppStrings.secureConnectionPoint1.tr()),
              _buildBulletPoint(context, AppStrings.secureConnectionPoint2.tr()),

              _buildDivider(isDark),

              // App Permissions Section
              _buildSectionHeader(context, "📂", AppStrings.appPermissionsTitle.tr()),
              
              Text(
                "🌐 ${AppStrings.internetTitle.tr()}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppStyle.primaryBlue),
              ),
              SizedBox(height: 4.h),
              Text(AppStrings.internetDesc.tr(), style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
              _buildBulletPoint(context, AppStrings.internetPoint1.tr()),
              _buildBulletPoint(context, AppStrings.internetPoint2.tr()),
              _buildBulletPoint(context, AppStrings.internetPoint3.tr()),
              _buildBulletPoint(context, AppStrings.internetPoint4.tr()),
              _buildBulletPoint(context, AppStrings.internetPoint5.tr()),

              SizedBox(height: 16.h),
              Text(
                "📎 ${AppStrings.filesStorageTitle.tr()}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppStyle.primaryBlue),
              ),
              SizedBox(height: 4.h),
              Text(AppStrings.filesStorageDesc.tr(), style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
              _buildBulletPoint(context, AppStrings.filesStoragePoint1.tr()),
              _buildBulletPoint(context, AppStrings.filesStoragePoint2.tr()),
              _buildBulletPoint(context, AppStrings.filesStoragePoint3.tr()),
              
              SizedBox(height: 12.h),
              Text(
                AppStrings.filesPermissionNote.tr(),
                style: TextStyle(fontSize: 13.sp, fontStyle: FontStyle.italic, color: isDark ? Colors.white60 : Colors.black54),
              ),

              _buildDivider(isDark),

              // Your Data Section
              _buildSectionHeader(context, "👨‍👩‍👧", AppStrings.yourDataTitle.tr()),
              Text(AppStrings.yourDataDesc.tr(), style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
              _buildBulletPoint(context, AppStrings.yourDataPoint1.tr()),
              _buildBulletPoint(context, AppStrings.yourDataPoint2.tr()),
              _buildBulletPoint(context, AppStrings.yourDataPoint3.tr()),
              _buildBulletPoint(context, AppStrings.yourDataPoint4.tr()),
              _buildBulletPoint(context, AppStrings.yourDataPoint5.tr()),
              _buildBulletPoint(context, AppStrings.yourDataPoint6.tr()),
              _buildBulletPoint(context, AppStrings.yourDataPoint7.tr()),
              
              SizedBox(height: 12.h),
              Text(
                AppStrings.yourDataNote.tr(),
                style: TextStyle(fontSize: 13.sp, fontStyle: FontStyle.italic, color: isDark ? Colors.white60 : Colors.black54),
              ),

              _buildDivider(isDark),

              // Protect Your Account Section
              _buildSectionHeader(context, "🔑", AppStrings.protectAccountTitle.tr()),
              _buildBulletPoint(context, AppStrings.protectAccountPoint1.tr()),
              _buildBulletPoint(context, AppStrings.protectAccountPoint2.tr()),
              _buildBulletPoint(context, AppStrings.protectAccountPoint3.tr()),
              _buildBulletPoint(context, AppStrings.protectAccountPoint4.tr()),

              _buildDivider(isDark),

              // Security Status Section
              _buildSectionHeader(context, "✔", AppStrings.securityStatusTitle.tr()),
              _buildStatusPoint(context, AppStrings.statusSecureHttps.tr()),
              _buildStatusPoint(context, AppStrings.statusProtectedAuth.tr()),
              _buildStatusPoint(context, AppStrings.statusNoTracking.tr()),
              _buildStatusPoint(context, AppStrings.statusPermissionsOnDemand.tr()),
              
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
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String icon, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: AppStyle.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPoint(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.greenAccent, blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Divider(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        thickness: 1,
      ),
    );
  }
}

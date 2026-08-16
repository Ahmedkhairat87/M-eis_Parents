import 'package:eism/core/providers/parent_provider.dart';
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/ui/login_screen/login_screen.dart';
import 'package:eism/ui/setting_screen/setting.dart';
import 'package:eism/ui/main_navigation_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eism/core/app_style.dart';
import 'package:url_launcher/url_launcher.dart';

enum DrawerContext { parent, student }

class AppDrawer extends StatelessWidget {
  final DrawerContext contextRole;
  
  const AppDrawer({
    super.key, 
    this.contextRole = DrawerContext.parent,
  });

  void _showLogoutDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showAppDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.logout.tr(), 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18.sp,
                color: isDarkMode ? Colors.white : AppStyle.primaryDarkBlue,
              )
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.logoutConfirm.tr(), 
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.white70 : AppStyle.primaryBlue.withValues(alpha: 0.7),
              )
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text(
                    AppStrings.cancel.tr(), 
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? AppStyle.darkPrimaryBlue : AppStyle.primaryBlue,
                    )
                  )
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('auth_token');
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
                    }
                  },
                  child: Text(
                    AppStrings.logout.tr(), 
                    style: TextStyle(color: Colors.red, fontSize: 14.sp, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail(BuildContext context, String email) async {
    final Uri emailLaunchUri = Uri.parse('mailto:$email');
    try {
      bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        launched = await launchUrl(emailLaunchUri);
      }
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No email app found to send email to $email.'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening email client: $e')),
        );
      }
    }
  }

  void _showContactUsNotice(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showAppDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orangeAccent, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    AppStrings.contactNoticeTitle.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDarkMode ? Colors.white : AppStyle.primaryDarkBlue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.contactNoticePoints.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: isDarkMode ? Colors.white70 : AppStyle.primaryBlue.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(
              onPressed: () {
                Navigator.pop(context);
                _sendEmail(context, 'contact@m-eis.com');
              },
              color: AppStyle.primaryBlue,
              width: double.infinity,
              child: Text(
                AppStrings.proceed.tr(),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final parentProvider = Provider.of<ParentProvider>(context);
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>() ?? 
                       themeProvider.glassTheme;
    final isDarkMode = themeProvider.isDarkMode;
    final isArabic = context.locale.languageCode == 'ar';

    final textColor = isDarkMode ? Colors.white : AppStyle.primaryDarkBlue;
    final subTextColor = isDarkMode ? Colors.white70 : AppStyle.primaryBlue.withValues(alpha: 0.7);
    final iconColor = isDarkMode ? Colors.white70 : AppStyle.primaryBlue;
    final dividerColor = isDarkMode ? Colors.white24 : AppStyle.primaryBlue.withValues(alpha: 0.1);

    final parentName = isArabic 
        ? (parentProvider.parentData?.fatherFullnameA ?? '') 
        : (parentProvider.parentData?.fatherFullname ?? '');

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.fromLTRB(8.w, 60.h, 0, 100.h),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(glassTheme.cornerRadius.r),
          border: Border.all(color: dividerColor, width: 0.5),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: dividerColor,
                      child: Icon(Icons.person, size: 40.sp, color: textColor),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contextRole == DrawerContext.parent 
                              ? AppStrings.parentHome.tr() 
                              : AppStrings.studentDashboard.tr(),
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
                          ),
                          Text(
                            parentName.isNotEmpty ? parentName : 'Parent', 
                            style: TextStyle(color: subTextColor, fontSize: 12.sp)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            Divider(color: dividerColor),
            
            if (contextRole == DrawerContext.student)
              _buildDrawerTile(
                icon: Icons.home_work_rounded,
                title: AppStrings.returnToParent.tr(),
                color: Colors.greenAccent,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.routeName, (route) => false);
                },
              ),

            _buildDrawerTile(
              icon: Icons.settings_outlined,
              title: AppStrings.settings.tr(),
              textColor: textColor,
              iconColor: iconColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingScreen.routeName);
              },
            ),
            _buildDrawerTile(
              icon: Icons.support_agent_outlined,
              title: AppStrings.appSupport.tr(),
              textColor: textColor,
              iconColor: iconColor,
              onTap: () => _sendEmail(context, 'app@m-eis.com'),
            ),
            _buildDrawerTile(
              icon: Icons.contact_mail_outlined,
              title: AppStrings.contactUs.tr(),
              textColor: textColor,
              iconColor: iconColor,
              onTap: () => _showContactUsNotice(context),
            ),
            
            const Spacer(),
            Divider(color: dividerColor),

            _buildDrawerTile(
              icon: Icons.logout,
              title: AppStrings.logout.tr(),
              color: Colors.redAccent,
              textColor: textColor,
              iconColor: iconColor,
              onTap: () => _showLogoutDialog(context),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    VoidCallback? onTap,
    Color? color,
    required Color textColor,
    required Color iconColor,
    Color? subTextColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? iconColor, size: 24.sp),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14.sp)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: subTextColor ?? textColor.withValues(alpha: 0.6), fontSize: 11.sp)) : null,
      onTap: onTap,
    );
  }
}

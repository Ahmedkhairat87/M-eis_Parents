import 'package:eism/core/app_style.dart';
import 'package:eism/core/liquid_glass_config.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:eism/ui/setting_screen/privacy_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart'; // <-- Added import

import '../../core/data/api/api_client.dart';
import '../../core/data/repositories/parent_repository.dart';

class SettingScreen extends StatelessWidget {
  static const routeName = '/SettingScreen';
  const SettingScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showAppDialog(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.changePassword.tr(),
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  hintText: AppStrings.currentPassword.tr(),
                  prefixIcon: Icons.lock_outline,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: newPasswordController,
                  obscureText: true,
                  hintText: AppStrings.newPassword.tr(),
                  prefixIcon: Icons.lock_reset_outlined,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hintText: AppStrings.confirmPassword.tr(),
                  prefixIcon: Icons.check_circle_outline,
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: Text(AppStrings.cancel.tr()),
                    ),
                    SizedBox(width: 12.w),
                    AppButton(
                      width: 120.w,
                      height: 48.h,
                      onPressed: isLoading ? () {} : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('auth_token') ?? '';
                            final repository = ParentRepository(ApiClient());

                            final success = await repository.changePassword(
                                token,
                                currentPasswordController.text,
                                newPasswordController.text
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success
                                    ? AppStrings.passwordChanged.tr()
                                    : 'Failed to change password')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(AppStrings.confirm.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showAppDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppStrings.language.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(AppStrings.english.tr()),
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppStyle.primaryBlue)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(AppStrings.arabic.tr()),
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: AppStyle.primaryBlue)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showAppDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppStrings.selectAppearance.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: Text(AppStrings.systemDefault.tr()),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
              trailing: themeProvider.themeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: AppStyle.primaryBlue)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: Text(AppStrings.lightMode.tr()),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
              trailing: themeProvider.themeMode == ThemeMode.light
                  ? const Icon(Icons.check, color: AppStyle.primaryBlue)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(AppStrings.darkMode.tr()),
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
              trailing: themeProvider.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: AppStyle.primaryBlue)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    String themeLabel;
    switch (themeProvider.themeMode) {
      case ThemeMode.system:
        themeLabel = AppStrings.systemDefault.tr();
        break;
      case ThemeMode.light:
        themeLabel = AppStrings.lightMode.tr();
        break;
      case ThemeMode.dark:
        themeLabel = AppStrings.darkMode.tr();
        break;
    }

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.settings.tr()),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        children: [
          _buildSectionHeader(context, "Account & Preferences"),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  Icons.language,
                  AppStrings.language.tr(),
                  context.locale.languageCode == 'en' ? AppStrings.english.tr() : AppStrings.arabic.tr(),
                  onTap: () => _showLanguageDialog(context),
                  showDivider: true,
                ),
                _buildSettingTile(
                  context,
                  Icons.lock_outline,
                  AppStrings.changePassword.tr(),
                  '',
                  onTap: () => _showChangePasswordDialog(context),
                  showDivider: true,
                ),
                /*_buildSettingTile(context, Icons.notifications_active_outlined, AppStrings.notifications.tr(), AppStrings.enabled.tr(), showDivider: true),*/
                _buildSettingTile(
                  context,
                  Icons.security,
                  AppStrings.privacySecurity.tr(),
                  '',
                  onTap: () => Navigator.pushNamed(context, PrivacySecurityScreen.routeName),
                  showDivider: true,
                ),
                // <-- Updated Version Tile Using FutureBuilder -->
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    String version = 'Loading...';
                    if (snapshot.hasData) {
                      version = 'v${snapshot.data!.version}';
                    } else if (snapshot.hasError) {
                      version = 'Error';
                    }

                    return _buildSettingTile(
                        context,
                        Icons.info_outline,
                        AppStrings.aboutApp.tr(),
                        version,
                        showDivider: false,
                        showArrow: false
                    );
                  },
                ),              ],
            ),
          ),

          SizedBox(height: 24.h),
          _buildSectionHeader(context, "Theme & Appearance"),
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined, color: AppStyle.primaryBlue),
                  title: Text(
                    AppStrings.appearance.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        themeLabel,
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                  onTap: () => _showThemeDialog(context),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppStyle.primaryBlue),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "Enable Liquid Glass",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                        ),
                      ),
                    ),
                    Switch(
                      value: themeProvider.glassConfig.isEnabled,
                      onChanged: (value) {
                        themeProvider.updateGlassConfig(
                          themeProvider.glassConfig.copyWith(isEnabled: value),
                        );
                      },
                    ),
                  ],
                ),
                if (themeProvider.glassConfig.isEnabled) ...[
                  const Divider(height: 32),
                  _buildFidelitySelector(context),
                  const Divider(height: 32),
                  _buildSliderControl(
                    context,
                    icon: Icons.blur_on,
                    label: "Frosting Amount",
                    value: themeProvider.glassConfig.frostAmount,
                    onChanged: (val) => themeProvider.updateGlassConfig(
                      themeProvider.glassConfig.copyWith(frostAmount: val),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildSliderControl(
                    context,
                    icon: Icons.auto_awesome_motion,
                    label: "Liquid Animation Speed",
                    value: themeProvider.glassConfig.animationSpeed,
                    max: 2.0,
                    onChanged: (val) => themeProvider.updateGlassConfig(
                      themeProvider.glassConfig.copyWith(animationSpeed: val),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildSliderControl(
                    context,
                    icon: Icons.animation,
                    label: "Breathing Intensity",
                    value: themeProvider.glassConfig.breathingScale - 1.0,
                    max: 0.1,
                    onChanged: (val) => themeProvider.updateGlassConfig(
                      themeProvider.glassConfig.copyWith(breathingScale: 1.0 + val),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFidelitySelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.high_quality, color: AppStyle.primaryBlue),
            SizedBox(width: 12.w),
            Text(
              "Visual Fidelity",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SegmentedButton<LiquidFidelity>(
          segments: const [
            ButtonSegment(value: LiquidFidelity.standard, label: Text("Standard")),
            ButtonSegment(value: LiquidFidelity.high, label: Text("High")),
            ButtonSegment(value: LiquidFidelity.ultra, label: Text("Ultra")),
          ],
          selected: {themeProvider.glassConfig.fidelity},
          onSelectionChanged: (Set<LiquidFidelity> newSelection) {
            themeProvider.updateGlassConfig(
              themeProvider.glassConfig.copyWith(fidelity: newSelection.first),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: isDark ? Colors.white54 : AppStyle.primaryBlue.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildSliderControl(
      BuildContext context, {
        required IconData icon,
        required String label,
        required double value,
        double min = 0.0,
        double max = 1.0,
        required ValueChanged<double> onChanged,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppStyle.primaryBlue, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: isDark ? Colors.white70 : AppStyle.primaryDarkBlue,
                ),
              ),
            ),
            Text(
              max == 1.0 ? "${(value * 100).toInt()}%" : value.toInt().toString(),
              style: TextStyle(color: Colors.grey, fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppStyle.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSettingTile(
      BuildContext context,
      IconData icon,
      String title,
      String trailing,
      {VoidCallback? onTap, bool showDivider = true, bool showArrow = true}
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppStyle.primaryBlue),
          title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
              )
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing.isNotEmpty)
                Text(
                    trailing,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)
                ),
              if (showArrow)
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(indent: 56.w, height: 1, color: isDark ? Colors.white10 : Colors.black12),
      ],
    );
  }
}
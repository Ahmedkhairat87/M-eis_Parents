import 'package:eism/core/app_style.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnderConstructionScreen extends StatelessWidget {
  static const routeName = '/UnderConstructionScreen';

  final String title;
  final String message;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showAppBar;
  final String? featureName;

  const UnderConstructionScreen({
    super.key,
    this.title = 'Under Construction',
    this.message = "We're working on this section and it will be available soon.",
    this.subtitle = 'Thank you for your patience.',
    this.onBack,
    this.showAppBar = true,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppStyle.darkPrimaryBlue : AppStyle.primaryDarkBlue;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return GlassScaffold(
      appBar: showAppBar
          ? GlassAppBar(
              title: Text(
                featureName ?? 'Page Under Construction',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              leading: (onBack != null || canPop)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    )
                  : null,
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate actual usable vertical space above the floating bottom navigation bar
            final double bottomNavClearance = 100.h + MediaQuery.of(context).padding.bottom;
            final double availableHeight = (constraints.maxHeight - bottomNavClearance).clamp(200.0, 1000.0);

            // Responsive element dimensions derived from available usable height
            final bool isCompact = availableHeight < 380;
            final bool isModerate = availableHeight >= 380 && availableHeight < 520;

            final double logoHeight = isCompact ? 36.h : (isModerate ? 52.h : 68.h);
            final double illustrationMaxHeight = isCompact ? 80.h : (isModerate ? 130.h : 180.h);
            final double gapSize = (availableHeight * 0.02).clamp(4.0, 16.0);

            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomNavClearance),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500.w, // Tablet width constraint
                    maxHeight: availableHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Prominent School Logo / Branding Header
                      _buildSchoolBranding(context, isDark, logoHeight),

                      SizedBox(height: gapSize),

                      // 2. Refined Under Construction Illustration Card
                      _buildIllustrationCard(context, isDark, illustrationMaxHeight),

                      SizedBox(height: gapSize),

                      // 3. Modern Status Badge
                      _buildStatusBadge(context, isDark, isCompact),

                      SizedBox(height: gapSize),

                      // 4. Main Heading
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 18.sp : 22.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: -0.4,
                        ),
                      ),

                      // 5. Short Explanatory Message
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 400.w),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          maxLines: isCompact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 12.sp : 14.sp,
                            height: 1.4,
                            color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
                          ),
                        ),
                      ),

                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 10.sp : 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : AppStyle.primaryBlue.withAlpha(160),
                          ),
                        ),

                      // 6. Optional Action Button (Go Back)
                      if (onBack != null || canPop) ...[
                        SizedBox(height: gapSize),
                        AppButton(
                          width: 170.w,
                          height: isCompact ? 40.h : 46.h,
                          color: AppStyle.primaryBlue,
                          borderRadius: 16.r,
                          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_rounded, size: isCompact ? 16.sp : 18.sp, color: Colors.white),
                              SizedBox(width: 8.w),
                              Text(
                                'Go Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCompact ? 13.sp : 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSchoolBranding(BuildContext context, bool isDark, double logoHeight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : Colors.white.withAlpha(120),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : AppStyle.primaryBlue).withAlpha(15),
          width: 0.8,
        ),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: logoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildIllustrationCard(BuildContext context, bool isDark, double maxHeight) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16.w),
      borderRadius: 20.r,
      color: isDark ? Colors.white.withAlpha(12) : Colors.white.withAlpha(180),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: 320.w,
        ),
        child: Image.asset(
          'lib/ui/under_construction/assets/UC.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 48.sp,
                  color: AppStyle.primaryBlue.withAlpha(150),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12.w : 16.w,
        vertical: isCompact ? 4.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: AppStyle.primaryBlue.withAlpha(isDark ? 35 : 20),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: AppStyle.primaryBlue.withAlpha(isDark ? 70 : 40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6.w : 8.w,
            height: isCompact ? 6.w : 8.w,
            decoration: BoxDecoration(
              color: AppStyle.accentOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppStyle.accentOrange.withAlpha(120),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'IN DEVELOPMENT',
            style: TextStyle(
              fontSize: isCompact ? 10.sp : 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? AppStyle.darkPrimaryBlue : AppStyle.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

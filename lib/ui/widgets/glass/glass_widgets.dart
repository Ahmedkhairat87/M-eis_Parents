import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/core/app_style.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>();
    final isGlassEnabled = glassTheme?.isEnabled ?? false;

    if (!isGlassEnabled) {
      return Card(
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius?.r ?? 20.r),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.w),
          child: child,
        ),
      );
    }

    return GlassContainer(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: padding ?? EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(borderRadius?.r ?? glassTheme?.cornerRadius ?? 20.r),
      color: color,
      child: child,
    );
  }
}

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>();
    final isGlassEnabled = glassTheme?.isEnabled ?? false;

    if (!isGlassEnabled) {
      return SizedBox(
        width: width,
        height: height ?? 52.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppStyle.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius?.r ?? 18.r),
            ),
          ),
          child: child,
        ),
      );
    }

    return GlassContainer(
      width: width,
      height: height ?? 52.h,
      padding: EdgeInsets.zero,
      color: color,
      borderRadius: BorderRadius.circular(borderRadius?.r ?? glassTheme?.cornerRadius ?? 18.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius?.r ?? glassTheme?.cornerRadius ?? 18.r),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: child,
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTheme = Theme.of(context).extension<LiquidGlassTheme>();
    final isGlassEnabled = glassTheme?.isEnabled ?? false;

    if (!isGlassEnabled) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null,
        ),
      );
    }

    return GlassContainer(
      height: 55.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      borderRadius: BorderRadius.circular(12.r),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white60 : AppStyle.primaryBlue.withValues(alpha: 0.5),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// Deprecated aliases for compatibility
typedef GlassCard = AppCard;
typedef GlassButton = AppButton;
typedef GlassTextField = AppTextField;

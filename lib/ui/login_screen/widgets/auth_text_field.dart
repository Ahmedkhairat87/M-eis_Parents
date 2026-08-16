import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/core/app_style.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
        prefixIcon: Icon(prefixIcon, size: 22.sp),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      validator: validator,
    );
  }
}

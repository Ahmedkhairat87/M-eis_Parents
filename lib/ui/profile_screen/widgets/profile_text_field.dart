import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? hint;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label, 
            style: TextStyle(
              fontSize: 11.sp, 
              color: isDark ? Colors.white60 : Colors.grey.shade600, 
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            )
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14.sp, 
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic, color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            filled: true,
            fillColor: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : (enabled ? Colors.black.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.01)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), 
              borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), 
              borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05))
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), 
              borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3))
            ),
          ),
        ),
      ],
    );
  }
}

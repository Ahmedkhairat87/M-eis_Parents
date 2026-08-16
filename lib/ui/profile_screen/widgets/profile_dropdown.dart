import 'package:eism/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const ProfileDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          style: TextStyle(
            fontSize: 14.sp, 
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            filled: true,
            fillColor: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.03),
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
              borderSide: BorderSide(color: AppStyle.primaryBlue.withValues(alpha: 0.3))
            ),
          ),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

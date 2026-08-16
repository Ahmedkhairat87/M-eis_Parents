import 'package:eism/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CASParticipantCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const CASParticipantCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppStyle.primaryBlue : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: isSelected ? AppStyle.primaryBlue : AppStyle.lightBlueBg),
          boxShadow: isSelected
              ? [BoxShadow(color: AppStyle.primaryBlue.withAlpha(50), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppStyle.primaryBlue,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppStyle.primaryDarkBlue,
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: Colors.white,
              checkColor: AppStyle.primaryBlue,
              side: BorderSide(color: isSelected ? Colors.white : AppStyle.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}

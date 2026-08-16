import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const MessageDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white70 : Colors.grey.shade700, fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: items.map((i) => DropdownMenuItem(
              value: i,
              child: Text(i, style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : Colors.black))
            )).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

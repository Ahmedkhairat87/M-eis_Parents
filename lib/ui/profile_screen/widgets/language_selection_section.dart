import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/profile_screen/widgets/profile_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionSection extends StatefulWidget {
  final String label;
  final Map<String, bool> languages;
  final TextEditingController otherController;

  const LanguageSelectionSection({
    super.key,
    required this.label,
    required this.languages,
    required this.otherController,
  });

  @override
  State<LanguageSelectionSection> createState() => _LanguageSelectionSectionState();
}

class _LanguageSelectionSectionState extends State<LanguageSelectionSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white70 : Colors.grey.shade700, fontWeight: FontWeight.w500)),
        Wrap(
          spacing: 8.w,
          children: widget.languages.keys.map((lang) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: widget.languages[lang],
                  onChanged: (val) => setState(() => widget.languages[lang] = val!),
                ),
                Text(
                  lang.toLowerCase().tr() == lang.toLowerCase() ? lang : lang.toLowerCase().tr(),
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            );
          }).toList(),
        ),
        ProfileTextField(label: AppStrings.otherLanguage.tr(), controller: widget.otherController),
      ],
    );
  }
}

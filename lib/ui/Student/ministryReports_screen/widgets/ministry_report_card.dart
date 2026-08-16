import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/data/models/ministry_report_model.dart';

class MinistryReportCard extends StatelessWidget {
  final ActiveMinistryTerm term;

  const MinistryReportCard({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // We assume the first item in results has the academic year if results exist
    final academicYear = term.results.isNotEmpty ? term.results.first.AcademicYearName : null;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.brown.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_rounded, color: Colors.brown, size: 24.sp),
          ),
          title: Text(
            term.description,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
            ),
          ),
          subtitle: academicYear != null ? Text(
            academicYear,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ) : null,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: _buildResultTable(context, term.results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTable(BuildContext context, List<MinistrySubjectMark> results) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13.sp,
      color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
    );
    final cellStyle = TextStyle(
      fontSize: 12.sp,
      color: isDark ? Colors.white70 : Colors.black87,
    );

    // Filter results to only show subjects with marks
    final List<MinistrySubjectResult> filteredResults = [];
    for (var res in results) {
      filteredResults.addAll(res.filteredSubjects);
    }

    if (filteredResults.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            AppStrings.noReports.tr(),
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(3),
          },
          border: TableBorder.symmetric(
            inside: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : AppStyle.lightBlueBg.withAlpha(100),
              ),
              children: [
                _buildTableCell(AppStrings.subject.tr(), headerStyle, padding: 12),
                _buildTableCell(AppStrings.reports.tr(), headerStyle, padding: 12), 
                _buildTableCell(AppStrings.comment.tr(), headerStyle, padding: 12), 
              ],
            ),
            ...filteredResults.map((res) => TableRow(
              children: [
                _buildTableCell(res.name, cellStyle.copyWith(fontWeight: FontWeight.w600)),
                _buildTableCell(res.mark.toString(), cellStyle),
                _buildTableCell(res.comment ?? '-', cellStyle),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, TextStyle style, {double padding = 10}) {
    return Padding(
      padding: EdgeInsets.all(padding.w),
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }
}

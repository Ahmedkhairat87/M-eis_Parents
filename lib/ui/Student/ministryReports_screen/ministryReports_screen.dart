import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/ministryReports_screen/widgets/ministry_report_card.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/models/ministry_report_model.dart';
import '../../../core/data/repositories/ministry_report_repository.dart';

class MinistryreportsScreen extends StatefulWidget {
  static const routeName = '/MinistryreportsScreen';
  const MinistryreportsScreen({super.key});

  @override
  State<MinistryreportsScreen> createState() => _MinistryreportsScreenState();
}

class _MinistryreportsScreenState extends State<MinistryreportsScreen> {
  final MinistryReportRepository _repository = MinistryReportRepository(ApiClient());
  List<ActiveMinistryTerm> _activeTerms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString();
      
      if (studentId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await _repository.getMinistryReports(
        token: token,
        studentId: studentId,
      );

      if (mounted) {
        setState(() {
          _activeTerms = response?.activeTerms ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.ministryReports.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchReports();
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _activeTerms.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  itemCount: _activeTerms.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return MinistryReportCard(term: _activeTerms[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80.sp, color: Colors.grey.withAlpha(100)),
          SizedBox(height: 16.h),
          Text(
            AppStrings.noReports.tr(),
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

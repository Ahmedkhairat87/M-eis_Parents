import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/weeklyPlan_screen/widgets/plan_details_card.dart';
import 'package:eism/ui/Student/weeklyPlan_screen/widgets/weekly_plan_model.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/models/weekly_plan_model.dart';
import '../../../core/data/repositories/weekly_plan_repository.dart';

class WeeklyPlanScreen extends StatefulWidget {
  static const routeName = '/WeeklyPlanScreen';
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  final WeeklyPlanRepository _repository = WeeklyPlanRepository(ApiClient());
  List<WeeklyPlanWeekModel> _weeks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeeks();
  }

  Future<void> _fetchWeeks() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString();
      
      if (studentId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final weeks = await _repository.getWeeklyPlanWeeks(
        token: token,
        studentId: studentId,
      );

      if (mounted) {
        setState(() {
          _weeks = weeks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading weeks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.weeklyPlan.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchWeeks();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weeks.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(0, 20.h, 0, 100.h),
                  itemCount: _weeks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final week = _weeks[index];
                    return PlanDetailsCard(
                      selectedPlan: WeeklyPlan(
                        weekNumber: week.weekNo ?? 0,
                        weekDescription: week.description,
                        startDate: week.startDate ?? '',
                        endDate: week.endDate ?? '',
                        url: '',
                      ),
                      onViewPlan: () => _handleViewPlan(context, week),
                    );
                  },
                ),
    );
  }

  Future<void> _handleViewPlan(BuildContext context, WeeklyPlanWeekModel week) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString() ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final redirectUrl = await _repository.getViewWeeklyPlanUrl(
        token: token,
        studentId: studentId,
        weekNo: week.weekNo.toString(),
      );

      if (context.mounted) Navigator.pop(context); // Close loading dialog

      if (redirectUrl != null && context.mounted) {
        _openWeeklyPlanWebView(context, redirectUrl, week.weekNo ?? 0);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not retrieve plan URL')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80.sp, color: Colors.grey.withAlpha(100)),
          SizedBox(height: 16.h),
          Text(
            AppStrings.noReports.tr(), // Reusing no reports or add no plans
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  void _openWeeklyPlanWebView(BuildContext context, String url, int weekNo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeeklyPlanWebView(url: url, weekNo: weekNo),
      ),
    );
  }
}

class WeeklyPlanWebView extends StatefulWidget {
  final String url;
  final int weekNo;
  const WeeklyPlanWebView({super.key, required this.url, required this.weekNo});

  @override
  State<WeeklyPlanWebView> createState() => _WeeklyPlanWebViewState();
}

class _WeeklyPlanWebViewState extends State<WeeklyPlanWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          '${AppStrings.week.tr()} ${widget.weekNo} ${AppStrings.weeklyPlan.tr()}',
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

import 'package:eism/core/data/api/api_client.dart';
import 'package:eism/core/data/repositories/student_repository.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/reports_screen/widgets/report_item_card.dart';
import 'package:eism/ui/Student/reports_screen/widgets/report_model.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportsScreen extends StatefulWidget {
  static const routeName = '/ReportsScreen';
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final StudentRepository _studentRepository = StudentRepository(ApiClient());
  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final stdID = studentProvider.selectedStudent?.id?.toString() ?? '';

      if (stdID.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await _studentRepository.getStudentLinks(token: token, stdID: stdID);
      final List<dynamic> data = response['Data'] ?? [];

      if (mounted) {
        setState(() {
          _reports = data
              .where((item) => item['sublink_desc_e'] == 'Report')
              .map((item) => Report(
                    title: item['sublink_desc_e'] ?? 'Report',
                    date: '', // Date not provided in the new API
                    url: item['sublink_urlname_e'] ?? '',
                  ))
              .toList();
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
        title: Text(AppStrings.reports.tr()),
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
          : _reports.isEmpty
              ? Center(
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
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  itemCount: _reports.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return ReportItemCard(
                      report: report,
                      onTap: () => _openReportWebView(context, report),
                    );
                  },
                ),
    );
  }

  void _openReportWebView(BuildContext context, Report report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportWebView(report: report),
      ),
    );
  }
}

class ReportWebView extends StatefulWidget {
  final Report report;
  const ReportWebView({super.key, required this.report});

  @override
  State<ReportWebView> createState() => _ReportWebViewState();
}

class _ReportWebViewState extends State<ReportWebView> {
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
      ..loadRequest(Uri.parse(widget.report.url));
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          widget.report.title,
          style: TextStyle(fontSize: 14.sp),
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

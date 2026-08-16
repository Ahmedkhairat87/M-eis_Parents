import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/homework_screen/widgets/homework_card.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/core/app_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/models/homework_model.dart';
import '../../../core/data/repositories/homework_repository.dart';

class HomeworkScreen extends StatefulWidget {
  static const routeName = '/HomeworkScreen';
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final HomeworkRepository _repository = HomeworkRepository(ApiClient());
  List<HomeworkModel> _homeworks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomework();
  }

  Future<void> _fetchHomework() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString();
      
      if (studentId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final homeworks = await _repository.getHomework(
        token: token,
        studentId: studentId,
      );

      if (mounted) {
        setState(() {
          _homeworks = homeworks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading homework: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.homework.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchHomework();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _homeworks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  itemCount: _homeworks.length,
                  itemBuilder: (context, index) {
                    return HomeworkCard(
                      homework: _homeworks[index],
                      onViewDetails: () => _showHomeworkDetails(context, _homeworks[index]),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80.sp, color: Colors.grey.withAlpha(100)),
          SizedBox(height: 16.h),
          Text(
            AppStrings.noHomework.tr(),
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  void _showHomeworkDetails(BuildContext context, HomeworkModel homework) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300, 
                      borderRadius: BorderRadius.circular(2.r)
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Icon(Icons.assignment_rounded, color: AppStyle.primaryBlue, size: 24.sp),
                    SizedBox(width: 10.w),
                    Text(
                      AppStrings.homeworkDetails.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildDetailRow(context, AppStrings.subject.tr(), homework.subject ?? ''),
                _buildDetailRow(context, AppStrings.assignedOn.tr(), homework.date ?? ''),
                if (homework.hasAttachment)
                  _buildAttachmentsSection(homework),
                const Divider(),
                SizedBox(height: 16.h),
                Text(
                  '${AppStrings.instructions.tr()}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      homework.body ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.6,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                AppButton(
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                  child: Text(
                    AppStrings.close.tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildAttachmentsSection(HomeworkModel homework) {
    return FutureBuilder<List<HomeworkAttachmentModel>>(
      future: _fetchAttachments(homework.divSer.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(
              '${AppStrings.attachments.tr()}:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            ...snapshot.data!.map((attachment) => ListTile(
              dense: true,
              leading: const Icon(Icons.file_present, color: Colors.blue),
              title: Text(attachment.fileName ?? 'Attachment', style: TextStyle(fontSize: 12.sp)),
              onTap: () => _openUrl(attachment.filePath),
            )),
          ],
        );
      },
    );
  }

  Future<List<HomeworkAttachmentModel>> _fetchAttachments(String divSer) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return await _repository.getHomeworkAttachments(token: token, divSer: divSer);
  }

  Future<void> _openUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

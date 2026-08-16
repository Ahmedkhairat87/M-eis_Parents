import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/widgets/message_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/models/student_book_message_model.dart';
import '../../../../core/data/repositories/student_book_repository.dart';

class ComposeTeacherMessageSheet extends StatefulWidget {
  const ComposeTeacherMessageSheet({super.key});

  @override
  State<ComposeTeacherMessageSheet> createState() => _ComposeTeacherMessageSheetState();
}

class _ComposeTeacherMessageSheetState extends State<ComposeTeacherMessageSheet> {
  final StudentBookRepository _repository = StudentBookRepository(ApiClient());
  
  List<StudentBookSubjectModel> _subjects = [];
  StudentBookSubjectModel? _selectedSubject;
  
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString();
      
      if (studentId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final subjects = await _repository.getSubjects(token: token, studentId: studentId);
      
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSend() async {
    if (_selectedSubject == null || _subjectController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString();
      
      if (studentId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final success = await _repository.sendMessage(
        token: token,
        studentId: studentId,
        matNo: _selectedSubject!.id ?? '',
        subject: _subjectController.text,
        body: _bodyController.text,
      );

      if (mounted) {
        setState(() => _isSending = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.messageSentToTeacher.tr())),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 20.h, 
        left: 16.w, 
        right: 16.w, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: _isLoading 
        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)))),
                SizedBox(height: 20.h),
                Text(AppStrings.composeToTeacher.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppStyle.primaryBlue)),
                SizedBox(height: 20.h),

                MessageDropdown(
                  label: AppStrings.selectSubject.tr(), 
                  value: _selectedSubject?.name, 
                  items: _subjects.map((s) => s.name ?? '').toList(), 
                  onChanged: (val) {
                    setState(() {
                      _selectedSubject = _subjects.firstWhere((s) => s.name == val);
                    });
                  }
                ),

                if (_selectedSubject != null) ...[
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _subjectController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: AppStrings.emailSubject.tr(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _bodyController,
                    maxLines: 5,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: AppStrings.body.tr(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _handleSend,
                      child: _isSending 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(AppStrings.sendMessage.tr(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }
}

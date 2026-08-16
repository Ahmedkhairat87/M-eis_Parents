import 'package:dio/dio.dart';
import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/message_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/repositories/message_repository.dart';

class ComposeMessageSheet extends StatefulWidget {
  const ComposeMessageSheet({super.key});

  @override
  State<ComposeMessageSheet> createState() => _ComposeMessageSheetState();
}

class _ComposeMessageSheetState extends State<ComposeMessageSheet> {
  final MessageRepository _messageRepository = MessageRepository(ApiClient());
  
  String? _coordinatorProgram;
  String? _selectedChild;
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  List<PlatformFile> _attachments = [];
  bool _isLoading = true;
  bool _isSending = false;

  List<String> _programs = [];
  List<String> _children = [];
  Map<String, dynamic>? _prepData;

  @override
  void initState() {
    super.initState();
    _fetchPrepData();
  }

  Future<void> _fetchPrepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final data = await _messageRepository.prepareNewMessage(token);
      
      final List<dynamic> allRecipients = data['toTypes'] ?? [];
      final List<dynamic> allStudents = data['forStudents'] ?? [];
      
      final List<dynamic> filteredRecipients = allRecipients.where((e) {
        final serNo = e['serNo']?.toString();
        return serNo == '2' || serNo == '3';
      }).toList();

      if (mounted) {
        setState(() {
          _prepData = data;
          _programs = filteredRecipients.map((e) => e['EnDesc']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
          _children = allStudents.map((e) => e['std_firstname']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _pickFiles() async {
    if (_attachments.isNotEmpty) { // User specified "file : file" (singular)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only one attachment is supported.')));
      }
      return;
    }
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_subjectController.text.isEmpty || _bodyController.text.isEmpty || _coordinatorProgram == null || _selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final List<dynamic> toTypes = _prepData?['toTypes'] ?? [];
      final List<dynamic> forStudents = _prepData?['forStudents'] ?? [];

      final selectedRecipient = toTypes.firstWhere((e) => e['EnDesc'] == _coordinatorProgram, orElse: () => {});
      final selectedStudent = forStudents.firstWhere((e) => e['std_firstname'] == _selectedChild, orElse: () => {});

      MultipartFile? multipartFile;
      if (_attachments.isNotEmpty && _attachments.first.path != null) {
        multipartFile = await MultipartFile.fromFile(
          _attachments.first.path!,
          filename: _attachments.first.name,
        );
      }

      final success = await _messageRepository.sendMessage(
        token: token,
        gradeID: int.tryParse(selectedStudent['gradeID']?.toString() ?? '0') ?? 0,
        toType: int.tryParse(selectedRecipient['serNo']?.toString() ?? '0') ?? 0,
        subject: _subjectController.text,
        body: _bodyController.text,
        file: multipartFile,
      );

      if (mounted) {
        setState(() => _isSending = false);
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.messageSentSuccessfully.tr())));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send message')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(top: 20.h, left: 16.w, right: 16.w, bottom: MediaQuery.of(context).viewInsets.bottom + 20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: _isLoading 
        ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)))),
                SizedBox(height: 20.h),
                Text(AppStrings.composeToCoordinator.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppStyle.primaryBlue)),
                SizedBox(height: 20.h),

                MessageDropdown(
                  label: AppStrings.coordinatorProgram.tr(), 
                  value: _coordinatorProgram, 
                  items: _programs, 
                  onChanged: (val) {
                    setState(() => _coordinatorProgram = val);
                  }
                ),

                if (_coordinatorProgram != null)
                  MessageDropdown(
                    label: AppStrings.aboutStudent.tr(), 
                    value: _selectedChild, 
                    items: _children, 
                    onChanged: (val) {
                      setState(() => _selectedChild = val);
                    }
                  ),

                if (_selectedChild != null) ...[
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _subjectController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: AppStrings.subject.tr(),
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
                  SizedBox(height: 12.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${AppStrings.attachments.tr()} (${_attachments.length}/1)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: isDark ? Colors.white70 : Colors.black54)),
                      TextButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: Text(AppStrings.addFile.tr()),
                      ),
                    ],
                  ),
                  if (_attachments.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      children: _attachments.map((file) => Chip(
                        label: Text(file.name, style: TextStyle(fontSize: 10.sp)),
                        onDeleted: () => setState(() => _attachments.clear()),
                      )).toList(),
                    ),

                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendMessage,
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

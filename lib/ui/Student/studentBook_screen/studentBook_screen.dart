import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/studentBook_screen/widgets/compose_teacher_message_sheet.dart';
import 'package:eism/ui/Student/studentBook_screen/widgets/teacher_message_list.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/models/student_book_message_model.dart';
import '../../../core/data/repositories/student_book_repository.dart';

class StudentbookScreen extends StatefulWidget {
  static const routeName = '/StudentbookScreen';
  const StudentbookScreen({super.key});

  @override
  State<StudentbookScreen> createState() => _StudentbookScreenState();
}

class _StudentbookScreenState extends State<StudentbookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentBookRepository _repository = StudentBookRepository(ApiClient());
  
  List<StudentBookMessageModel> _inbox = [];
  List<StudentBookMessageModel> _sent = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final studentId = studentProvider.selectedStudent?.id?.toString();
      
      if (studentId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final messages = await _repository.getMessages(
        token: token,
        studentId: studentId,
      );

      if (mounted) {
        setState(() {
          _inbox = messages['inbox'] ?? [];
          _sent = messages['sent'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openComposeDialog() {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      child: const ComposeTeacherMessageSheet(),
    ).then((_) => _fetchMessages()); // Refresh after composing
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.studentBook.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMessages();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openComposeDialog,
        backgroundColor: AppStyle.primaryBlue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppStyle.primaryDarkBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppStyle.primaryBlue,
            tabs: [
              Tab(icon: const Icon(Icons.inbox), text: AppStrings.inbox.tr()),
              Tab(icon: const Icon(Icons.send), text: AppStrings.sent.tr()),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      TeacherMessageList(messages: _inbox, onRefresh: _fetchMessages),
                      TeacherMessageList(messages: _sent, isSentTab: true, onRefresh: _fetchMessages),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

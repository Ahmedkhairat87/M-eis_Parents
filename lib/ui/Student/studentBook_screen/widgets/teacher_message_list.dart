import 'package:eism/ui/widgets/empty_messages_state.dart';
import 'package:eism/ui/Student/studentBook_screen/widgets/teacher_message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/data/models/student_book_message_model.dart';

class TeacherMessageList extends StatelessWidget {
  final List<StudentBookMessageModel> messages;
  final bool isSentTab;
  final VoidCallback onRefresh;
  
  const TeacherMessageList({
    super.key, 
    required this.messages, 
    this.isSentTab = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const EmptyMessagesState();
    }
    
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: messages.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return TeacherMessageCard(
          message: messages[index], 
          isSent: isSentTab,
          onRefresh: onRefresh,
        );
      },
    );
  }
}

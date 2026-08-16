import 'package:eism/ui/widgets/empty_messages_state.dart';
import 'package:eism/ui/massages_screen/widgets/message_card.dart';
import 'package:eism/ui/massages_screen/widgets/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageList extends StatefulWidget {
  final List<Message> messages;
  final VoidCallback onLoadMore;
  final VoidCallback? onMessageRead;
  
  const MessageList({super.key, required this.messages, required this.onLoadMore, this.onMessageRead});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return const EmptyMessagesState();
    }
    
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      itemCount: widget.messages.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return MessageCard(
          message: widget.messages[index],
          onRead: widget.onMessageRead,
        );
      },
    );
  }
}

import 'package:eism/core/app_style.dart';
import 'package:eism/ui/massages_screen/widgets/message_detail_dialog.dart';
import 'package:eism/ui/massages_screen/widgets/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  final VoidCallback? onRead;
  
  const MessageCard({super.key, required this.message, this.onRead});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    _isRead = widget.message.isRead;
  }

  @override
  void didUpdateWidget(MessageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.isRead != widget.message.isRead) {
      _isRead = widget.message.isRead;
    }
  }

  void _showDetails(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => MessageDetailDialog(message: widget.message),
    );
    
    if (result == true && !_isRead) {
      setState(() {
        _isRead = true;
      });
      widget.onRead?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // We only show unread indicators for Inbox messages (where isSent is false)
    final bool showUnreadIndicator = !widget.message.isSent && !_isRead;

    return Card(
      elevation: showUnreadIndicator ? 4 : 1,
      shadowColor: AppStyle.primaryBlue.withValues(alpha: 0.2),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: showUnreadIndicator 
          ? BorderSide(color: AppStyle.primaryBlue.withValues(alpha: 0.5), width: 1.5)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(12.w),
              leading: CircleAvatar(
                backgroundColor: AppStyle.primaryBlue.withAlpha(showUnreadIndicator ? 50 : 25),
                child: Text(
                  widget.message.sender.isNotEmpty 
                      ? (widget.message.sender.startsWith('To: ') ? widget.message.sender.substring(4)[0] : widget.message.sender[0]) 
                      : '?', 
                  style: TextStyle(color: AppStyle.primaryBlue, fontWeight: FontWeight.bold)
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.message.sender, 
                      style: TextStyle(
                        fontWeight: showUnreadIndicator ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14.sp, 
                        color: isDark ? Colors.white : Colors.black87
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                  Text(
                    '${widget.message.date.day}/${widget.message.date.month}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    widget.message.subject, 
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppStyle.primaryDarkBlue, 
                      fontWeight: showUnreadIndicator ? FontWeight.w900 : FontWeight.w500, 
                      fontSize: 13.sp
                    )
                  ),
                  SizedBox(height: 2.h),
                  Text(widget.message.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
            ),
            if (showUnreadIndicator)
              Positioned(
                top: 12.h,
                right: 45.w,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: AppStyle.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

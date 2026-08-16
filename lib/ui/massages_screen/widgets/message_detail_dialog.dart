import 'package:eism/core/app_style.dart';
import 'package:eism/ui/massages_screen/widgets/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/repositories/message_repository.dart';

class MessageDetailDialog extends StatefulWidget {
  final Message message;
  const MessageDetailDialog({super.key, required this.message});

  @override
  State<MessageDetailDialog> createState() => _MessageDetailDialogState();
}

class _MessageDetailDialogState extends State<MessageDetailDialog> {
  final MessageRepository _messageRepository = MessageRepository(ApiClient());
  bool _isLoading = true;
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (widget.message.msgSer == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final data = await _messageRepository.getMessageDetails(
        token, 
        widget.message.msgSer.toString(), 
        widget.message.serNo.toString(),
      );
      
      if (mounted) {
        setState(() {
          _details = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // According to your sample, the data is inside 'msgDetails'
    final Map<String, dynamic> msgDetails = _details?['msgDetails'] ?? {};
    final String subject = msgDetails['note_subject'] ?? widget.message.subject;
    String body = (msgDetails['note_body'] ?? widget.message.body).toString();
    final List<dynamic> attachments = msgDetails['msgAttach'] ?? [];

    // Basic HTML cleaning
    body = body
        .replaceAll('<br/>', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'<[^>]*>'), '');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: _isLoading 
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppStyle.primaryBlue),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.message.sender,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: isDark ? Colors.white70 : Colors.black87),
                ),
                Text(
                  'Date: ${widget.message.date.day}/${widget.message.date.month}/${widget.message.date.year}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                const Divider(),
                SizedBox(height: 8.h),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      body.trim().isEmpty ? 'No content' : body.trim(),
                      style: TextStyle(fontSize: 14.sp, height: 1.5, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
                if (attachments.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text('Attachments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppStyle.primaryBlue)),
                  ...attachments.map((att) {
                    final String fileName = att['note_file'] ?? 'File';
                    final String fileUrl = att['note_fileLink'] ?? '';
                    
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                      title: Text(fileName, style: TextStyle(fontSize: 12.sp, decoration: TextDecoration.underline, color: AppStyle.primaryBlue)),
                      onTap: fileUrl.isNotEmpty ? () => _launchUrl(fileUrl) : null,
                    );
                  }),
                ],
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, true), // Return true to indicate it was read
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}


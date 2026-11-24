import 'package:eism/core/app_style.dart';
import 'package:eism/ui/massages_screen/widgets/message_model.dart';
import 'package:eism/ui/widgets/attachment_viewer_screen.dart';
import 'package:eism/ui/widgets/in_app_web_view_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<TapGestureRecognizer> _gestureRecognizers = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _disposeGestureRecognizers();
    super.dispose();
  }

  void _disposeGestureRecognizers() {
    for (final recognizer in _gestureRecognizers) {
      recognizer.dispose();
    }
    _gestureRecognizers.clear();
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

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.toLowerCase().startsWith('www.')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  void _openWebLink(String url) {
    if (url.isEmpty) return;
    final finalUrl = _normalizeUrl(url);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(
          url: finalUrl,
        ),
      ),
    );
  }

  Widget _buildMessageBodyWithLinks(String text, TextStyle defaultStyle, bool isDark) {
    _disposeGestureRecognizers();

    if (text.trim().isEmpty) {
      return Text('No content', style: defaultStyle);
    }

    final RegExp urlRegex = RegExp(
      r'((?:https?:\/\/|www\.)[^\s<>{}\[\]]+)',
      caseSensitive: false,
    );

    final linkStyle = defaultStyle.copyWith(
      color: isDark ? const Color(0xFF64B5F6) : AppStyle.primaryBlue,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in urlRegex.allMatches(text)) {
      final String rawMatch = match.group(0)!;
      final int matchStart = match.start;

      if (matchStart > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, matchStart),
          style: defaultStyle,
        ));
      }

      String url = rawMatch;
      String trailingPunctuation = '';

      final punctuationRegex = RegExp(r'[.,;:!?\)\],،؟۔]+$');
      final pMatch = punctuationRegex.firstMatch(rawMatch);
      if (pMatch != null) {
        trailingPunctuation = pMatch.group(0)!;
        url = rawMatch.substring(0, rawMatch.length - trailingPunctuation.length);
      }

      if (url.isNotEmpty) {
        final String finalUrl = url;
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _openWebLink(finalUrl);
        _gestureRecognizers.add(recognizer);

        spans.add(TextSpan(
          text: finalUrl,
          style: linkStyle,
          recognizer: recognizer,
        ));
      }

      if (trailingPunctuation.isNotEmpty) {
        spans.add(TextSpan(
          text: trailingPunctuation,
          style: defaultStyle,
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: defaultStyle,
    );
  }

  void _openAttachment(String fileName, String fileUrl) {
    if (fileUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttachmentViewerScreen(
          title: fileName,
          url: fileUrl,
        ),
      ),
    );
  }

  IconData _getAttachmentIcon(String fileName, String fileUrl) {
    final ext = (fileName.contains('.') ? fileName.split('.').last : fileUrl.split('.').last).toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['mp4', 'mov', 'm4v', 'webm', 'avi', 'mkv'].contains(ext)) return Icons.video_library_rounded;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return Icons.image_rounded;
    if (['doc', 'docx', 'xls', 'xlsx', 'csv', 'ppt', 'pptx'].contains(ext)) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
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
                    child: _buildMessageBodyWithLinks(
                      body.trim(),
                      TextStyle(fontSize: 14.sp, height: 1.5, color: isDark ? Colors.white : Colors.black87),
                      isDark,
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
                      leading: Icon(_getAttachmentIcon(fileName, fileUrl), color: AppStyle.primaryBlue, size: 24.sp),
                      title: Text(fileName, style: TextStyle(fontSize: 12.sp, decoration: TextDecoration.underline, color: AppStyle.primaryBlue)),
                      onTap: fileUrl.isNotEmpty ? () => _openAttachment(fileName, fileUrl) : null,
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


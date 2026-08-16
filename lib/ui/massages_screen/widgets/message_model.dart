class Message {
  final String sender;
  final String subject;
  final String body;
  final DateTime date;
  final bool isSent;
  final List<String> attachments;
  final dynamic msgSer;
  final dynamic serNo;
  final bool isRead;

  Message({
    required this.sender,
    required this.subject,
    required this.body,
    required this.date,
    this.isSent = false,
    this.attachments = const [],
    this.msgSer,
    this.serNo,
    this.isRead = true,
  });

  factory Message.fromJson(Map<String, dynamic> json, {bool isSent = false}) {
    // Extensive mapping based on the provided JSON structure
    final msgSer = json['msg_ser'] ?? 
                  json['MsgSer'] ?? 
                  json['NoteSer'] ?? 
                  json['note_ser'] ?? 
                  json['serno'] ?? 
                  json['ser_no'] ?? 
                  json['SerNo'] ??
                  json['Msg_Ser'];

    // Determine Sender display name
    String senderName = 'School';
    if (isSent) {
      // For sent messages, we show who we sent it TO
      final recipient = json['to_type'] ?? json['RecipientName'] ?? json['recipient'] ?? 'Recipient';
      senderName = 'To: $recipient';
    } else {
      // For inbox messages, we show who it is FROM
      // If SenderName is "0" or missing, we try other fields or fallback to "School"
      final sender = json['SenderName'] ?? json['from_type'] ?? json['sender'] ?? json['from_parent_name'];
      if (sender != null && sender.toString() != '0' && sender.toString().trim().isNotEmpty) {
        senderName = sender.toString();
      } else if (json['to_type'] != null && json['from_parent'] != null && json['from_parent'].toString() == '0') {
        senderName = 'School Admin';
      } else if (json['to_type'] != null) {
        // Fallback for some school messages where sender name is not provided
        senderName = 'School (${json['to_type']})';
      }
    }

    return Message(
      sender: senderName,
      subject: (json['note_subject'] ?? json['Msg_Subject'] ?? json['subject'] ?? 'No Subject').toString(),
      body: (json['note_body'] ?? json['Msg_Body'] ?? json['body'] ?? '')
          .toString()
          .replaceAll('<br/>', '\n')
          .replaceAll('<br>', '\n')
          .replaceAll('<br />', '\n')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'<[^>]*>'), ''), // Clean any remaining HTML
      date: _parseDate(json['actual_editdate'] ?? json['Msg_Date'] ?? json['Column1']),
      isSent: isSent,
      msgSer: msgSer,
      serNo: json['serNo'] ?? json['ser_no'] ?? json['SerNo'] ?? 0,
      isRead: json['viewed_flag'] == 1 || json['viewed_flag'] == "1" || json['isRead'] == true || (json['Msg_Status'] != null && json['Msg_Status'].toString() == '1'),
    );
  }

  static DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    final String dateStr = dateVal.toString().trim();
    if (dateStr.isEmpty) return DateTime.now();
    
    // Try ISO format first
    final isoDate = DateTime.tryParse(dateStr);
    if (isoDate != null) return isoDate;
    
    // Try manual parse for "DD MMM YYYY" (e.g., "01 May 2024")
    try {
      final parts = dateStr.split(' ');
      if (parts.length >= 3) {
        final dayStr = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
        final day = int.tryParse(dayStr) ?? 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;
        final monthStr = parts[1].toLowerCase();
        
        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
        };
        
        final month = months[monthStr.length >= 3 ? monthStr.substring(0, 3) : monthStr] ?? 1;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    
    return DateTime.now();
  }
}

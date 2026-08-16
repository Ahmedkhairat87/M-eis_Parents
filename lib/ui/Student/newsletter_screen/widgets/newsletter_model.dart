class Newsletter {
  final String date;
  final String pdfUrl;
  final String title;

  const Newsletter({
    required this.date,
    required this.pdfUrl,
    required this.title,
  });

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    return Newsletter(
      date: json['news_date'] ?? '',
      pdfUrl: json['full_path_e'] ?? '',
      title: json['news_date'] ?? 'School Newsletter', // Using date as title if no specific title
    );
  }
}

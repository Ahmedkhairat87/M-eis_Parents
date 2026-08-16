class WeeklyPlan {
  final int weekNumber;
  final String? weekDescription;
  final String startDate;
  final String endDate;
  final String url;

  const WeeklyPlan({
    required this.weekNumber,
    this.weekDescription,
    required this.startDate,
    required this.endDate,
    required this.url,
  });
}

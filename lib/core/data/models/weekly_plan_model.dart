import 'package:json_annotation/json_annotation.dart';

part 'weekly_plan_model.g.dart';

@JsonSerializable()
class WeeklyPlanWeekModel {
  @JsonKey(name: 'Week_no')
  final int? weekNo;
  @JsonKey(name: 'week_desc_FR')
  final String? description;
  @JsonKey(name: 'week_start_FR')
  final String? startDate;
  @JsonKey(name: 'week_end_FR')
  final String? endDate;

  WeeklyPlanWeekModel({
    this.weekNo,
    this.description,
    this.startDate,
    this.endDate,
  });

  factory WeeklyPlanWeekModel.fromJson(Map<String, dynamic> json) => _$WeeklyPlanWeekModelFromJson(json);
  Map<String, dynamic> toJson() => _$WeeklyPlanWeekModelToJson(this);
}

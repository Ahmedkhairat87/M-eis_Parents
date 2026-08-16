// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyPlanWeekModel _$WeeklyPlanWeekModelFromJson(Map<String, dynamic> json) =>
    WeeklyPlanWeekModel(
      weekNo: (json['Week_no'] as num?)?.toInt(),
      description: json['week_desc_FR'] as String?,
      startDate: json['week_start_FR'] as String?,
      endDate: json['week_end_FR'] as String?,
    );

Map<String, dynamic> _$WeeklyPlanWeekModelToJson(
  WeeklyPlanWeekModel instance,
) => <String, dynamic>{
  'Week_no': instance.weekNo,
  'week_desc_FR': instance.description,
  'week_start_FR': instance.startDate,
  'week_end_FR': instance.endDate,
};

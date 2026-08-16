// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentStatusModel _$ParentStatusModelFromJson(Map<String, dynamic> json) =>
    ParentStatusModel(
      serNo: (json['ser_no'] as num?)?.toInt(),
      parentStatus: json['parentstatus'] as String?,
    );

Map<String, dynamic> _$ParentStatusModelToJson(ParentStatusModel instance) =>
    <String, dynamic>{
      'ser_no': instance.serNo,
      'parentstatus': instance.parentStatus,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_domain_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobDomainModel _$JobDomainModelFromJson(Map<String, dynamic> json) =>
    JobDomainModel(
      serno: (json['serno'] as num?)?.toInt(),
      jobdomain: json['jobdomain'] as String?,
      jobdomainEn: json['jobdomain_en'] as String?,
    );

Map<String, dynamic> _$JobDomainModelToJson(JobDomainModel instance) =>
    <String, dynamic>{
      'serno': instance.serno,
      'jobdomain': instance.jobdomain,
      'jobdomain_en': instance.jobdomainEn,
    };

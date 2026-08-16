// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ministry_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinistryReportResponse _$MinistryReportResponseFromJson(
  Map<String, dynamic> json,
) => MinistryReportResponse(
  termStatus1: json['termStatus1'] as bool?,
  termDesc1: json['termDesc1'] as String?,
  termResult1: (json['termResult1'] as List<dynamic>?)
      ?.map((e) => MinistrySubjectMark.fromJson(e as Map<String, dynamic>))
      .toList(),
  termStatus2: json['termStatus2'] as bool?,
  termDesc2: json['ermDesc2'] as String?,
  termResult2: (json['termResult2'] as List<dynamic>?)
      ?.map((e) => MinistrySubjectMark.fromJson(e as Map<String, dynamic>))
      .toList(),
  termStatus3: json['termStatus3'] as bool?,
  termDesc3: json['ermDesc3'] as String?,
  termResult3: (json['termResult3'] as List<dynamic>?)
      ?.map((e) => MinistrySubjectMark.fromJson(e as Map<String, dynamic>))
      .toList(),
  termStatus4: json['termStatus4'] as bool?,
  termDesc4: json['ermDesc4'] as String?,
  termResult4: (json['termResult4'] as List<dynamic>?)
      ?.map((e) => MinistrySubjectMark.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MinistryReportResponseToJson(
  MinistryReportResponse instance,
) => <String, dynamic>{
  'termStatus1': instance.termStatus1,
  'termDesc1': instance.termDesc1,
  'termResult1': instance.termResult1,
  'termStatus2': instance.termStatus2,
  'ermDesc2': instance.termDesc2,
  'termResult2': instance.termResult2,
  'termStatus3': instance.termStatus3,
  'ermDesc3': instance.termDesc3,
  'termResult3': instance.termResult3,
  'termStatus4': instance.termStatus4,
  'ermDesc4': instance.termDesc4,
  'termResult4': instance.termResult4,
};

MinistrySubjectMark _$MinistrySubjectMarkFromJson(Map<String, dynamic> json) =>
    MinistrySubjectMark(
      AcademicYearName: json['AcademicYearName'] as String?,
      arabicName: json['arabicName'] as String?,
      arabicMark: (json['arabicMark'] as num?)?.toDouble(),
      arabicComment: json['arabicComment'] as String?,
      religionName: json['religionName'] as String?,
      religionMark: (json['religionMark'] as num?)?.toDouble(),
      religionComment: json['religionComment'] as String?,
      socialName: json['socialName'] as String?,
      socialMark: (json['socialMark'] as num?)?.toDouble(),
      socialComment: json['socialComment'] as String?,
      GoghName: json['GoghName'] as String?,
      GoghMark: (json['GoghMark'] as num?)?.toDouble(),
      GoghComment: json['GoghComment'] as String?,
      HisName: json['HisName'] as String?,
      HisMark: (json['HisMark'] as num?)?.toDouble(),
      HisComment: json['HisComment'] as String?,
      TarbyaName: json['TarbyaName'] as String?,
      TarbyaMark: (json['TarbyaMark'] as num?)?.toDouble(),
      TarbyaComment: json['TarbyaComment'] as String?,
    );

Map<String, dynamic> _$MinistrySubjectMarkToJson(
  MinistrySubjectMark instance,
) => <String, dynamic>{
  'AcademicYearName': instance.AcademicYearName,
  'arabicName': instance.arabicName,
  'arabicMark': instance.arabicMark,
  'arabicComment': instance.arabicComment,
  'religionName': instance.religionName,
  'religionMark': instance.religionMark,
  'religionComment': instance.religionComment,
  'socialName': instance.socialName,
  'socialMark': instance.socialMark,
  'socialComment': instance.socialComment,
  'GoghName': instance.GoghName,
  'GoghMark': instance.GoghMark,
  'GoghComment': instance.GoghComment,
  'HisName': instance.HisName,
  'HisMark': instance.HisMark,
  'HisComment': instance.HisComment,
  'TarbyaName': instance.TarbyaName,
  'TarbyaMark': instance.TarbyaMark,
  'TarbyaComment': instance.TarbyaComment,
};

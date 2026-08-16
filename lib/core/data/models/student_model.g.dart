// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
  id: (json['std_id'] as num?)?.toInt(),
  name: json['std_firstname'] as String?,
  nameArabic: json['std_name_a'] as String?,
  grade: (json['current_grade'] as num?)?.toInt(),
  classId: (json['current_classe'] as num?)?.toInt(),
);

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'std_id': instance.id,
      'std_firstname': instance.name,
      'std_name_a': instance.nameArabic,
      'current_grade': instance.grade,
      'current_classe': instance.classId,
    };

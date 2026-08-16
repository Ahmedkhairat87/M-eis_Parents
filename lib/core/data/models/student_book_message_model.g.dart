// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_book_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentBookMessageModel _$StudentBookMessageModelFromJson(
  Map<String, dynamic> json,
) => StudentBookMessageModel(
  taSer: json['taSer'],
  teacherName: json['emp_name'] as String?,
  category: json['mat_desc'] as String?,
  subject: json['subject'] as String?,
  body: json['body'] as String?,
  date: json['editDate'] as String?,
  viewedFlag: json['viewedIMG'],
);

Map<String, dynamic> _$StudentBookMessageModelToJson(
  StudentBookMessageModel instance,
) => <String, dynamic>{
  'taSer': instance.taSer,
  'emp_name': instance.teacherName,
  'mat_desc': instance.category,
  'subject': instance.subject,
  'body': instance.body,
  'editDate': instance.date,
  'viewedIMG': instance.viewedFlag,
};

StudentBookSubjectModel _$StudentBookSubjectModelFromJson(
  Map<String, dynamic> json,
) => StudentBookSubjectModel(
  name: json['mat_desc'] as String?,
  id: json['mat_no'] as String?,
);

Map<String, dynamic> _$StudentBookSubjectModelToJson(
  StudentBookSubjectModel instance,
) => <String, dynamic>{'mat_desc': instance.name, 'mat_no': instance.id};

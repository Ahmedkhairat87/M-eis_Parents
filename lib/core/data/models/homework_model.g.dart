// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeworkModel _$HomeworkModelFromJson(Map<String, dynamic> json) =>
    HomeworkModel(
      divSer: (json['DivSer'] as num?)?.toInt(),
      subject: json['mat_desc'] as String?,
      subtopic: json['supject'] as String?,
      body: json['body'] as String?,
      date: json['editedDate'] as String?,
      attachFlag: json['attachFlag'] as String?,
    );

Map<String, dynamic> _$HomeworkModelToJson(HomeworkModel instance) =>
    <String, dynamic>{
      'DivSer': instance.divSer,
      'mat_desc': instance.subject,
      'supject': instance.subtopic,
      'body': instance.body,
      'editedDate': instance.date,
      'attachFlag': instance.attachFlag,
    };

HomeworkAttachmentModel _$HomeworkAttachmentModelFromJson(
  Map<String, dynamic> json,
) => HomeworkAttachmentModel(
  fileName: json['FileName'] as String?,
  filePath: json['FilePath'] as String?,
);

Map<String, dynamic> _$HomeworkAttachmentModelToJson(
  HomeworkAttachmentModel instance,
) => <String, dynamic>{
  'FileName': instance.fileName,
  'FilePath': instance.filePath,
};

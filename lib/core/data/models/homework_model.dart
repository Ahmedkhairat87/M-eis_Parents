import 'package:json_annotation/json_annotation.dart';

part 'homework_model.g.dart';

@JsonSerializable()
class HomeworkModel {
  @JsonKey(name: 'DivSer')
  final int? divSer;
  @JsonKey(name: 'mat_desc')
  final String? subject;
  @JsonKey(name: 'supject')
  final String? subtopic;
  @JsonKey(name: 'body')
  final String? body;
  @JsonKey(name: 'editedDate')
  final String? date;
  @JsonKey(name: 'attachFlag')
  final String? attachFlag;

  HomeworkModel({
    this.divSer,
    this.subject,
    this.subtopic,
    this.body,
    this.date,
    this.attachFlag,
  });

  bool get hasAttachment => attachFlag == '1';

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => _$HomeworkModelFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkModelToJson(this);
}

@JsonSerializable()
class HomeworkAttachmentModel {
  @JsonKey(name: 'FileName')
  final String? fileName;
  @JsonKey(name: 'FilePath')
  final String? filePath;

  HomeworkAttachmentModel({this.fileName, this.filePath});

  factory HomeworkAttachmentModel.fromJson(Map<String, dynamic> json) => _$HomeworkAttachmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkAttachmentModelToJson(this);
}

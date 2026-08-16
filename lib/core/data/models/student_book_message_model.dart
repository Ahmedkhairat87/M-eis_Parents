import 'package:json_annotation/json_annotation.dart';

part 'student_book_message_model.g.dart';

@JsonSerializable()
class StudentBookMessageModel {
  @JsonKey(name: 'taSer')
  final dynamic taSer;
  @JsonKey(name: 'emp_name')
  final String? teacherName;
  @JsonKey(name: 'mat_desc')
  final String? category;
  @JsonKey(name: 'subject')
  final String? subject;
  @JsonKey(name: 'body')
  final String? body;
  @JsonKey(name: 'editDate')
  final String? date;
  @JsonKey(name: 'viewedIMG')
  final dynamic viewedFlag;

  StudentBookMessageModel({
    this.taSer,
    this.teacherName,
    this.category,
    this.subject,
    this.body,
    this.date,
    this.viewedFlag,
  });

  bool get isRead => viewedFlag == 1 || viewedFlag == "1";

  factory StudentBookMessageModel.fromJson(Map<String, dynamic> json) => _$StudentBookMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentBookMessageModelToJson(this);
}

@JsonSerializable()
class StudentBookSubjectModel {
  @JsonKey(name: 'mat_desc')
  final String? name;
  @JsonKey(name: 'mat_no')
  final String? id;

  StudentBookSubjectModel({this.name, this.id});

  factory StudentBookSubjectModel.fromJson(Map<String, dynamic> json) => _$StudentBookSubjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentBookSubjectModelToJson(this);
}

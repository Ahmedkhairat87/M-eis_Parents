import 'package:json_annotation/json_annotation.dart';

part 'parent_status_model.g.dart';

@JsonSerializable()
class ParentStatusModel {
  @JsonKey(name: 'ser_no')
  final int? serNo;
  @JsonKey(name: 'parentstatus')
  final String? parentStatus;

  ParentStatusModel({this.serNo, this.parentStatus});

  factory ParentStatusModel.fromJson(Map<String, dynamic> json) => _$ParentStatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$ParentStatusModelToJson(this);
}

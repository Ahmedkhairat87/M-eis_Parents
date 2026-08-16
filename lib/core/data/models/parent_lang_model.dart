import 'package:json_annotation/json_annotation.dart';

part 'parent_lang_model.g.dart';

@JsonSerializable()
class ParentLangModel {
  @JsonKey(name: 'serno')
  final int? serno;
  @JsonKey(name: 'parentlang')
  final String? parentLang;

  ParentLangModel({this.serno, this.parentLang});

  factory ParentLangModel.fromJson(Map<String, dynamic> json) => _$ParentLangModelFromJson(json);
  Map<String, dynamic> toJson() => _$ParentLangModelToJson(this);
}

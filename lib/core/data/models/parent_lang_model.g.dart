// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_lang_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentLangModel _$ParentLangModelFromJson(Map<String, dynamic> json) =>
    ParentLangModel(
      serno: (json['serno'] as num?)?.toInt(),
      parentLang: json['parentlang'] as String?,
    );

Map<String, dynamic> _$ParentLangModelToJson(ParentLangModel instance) =>
    <String, dynamic>{
      'serno': instance.serno,
      'parentlang': instance.parentLang,
    };

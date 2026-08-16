import 'package:json_annotation/json_annotation.dart';

part 'job_domain_model.g.dart';

@JsonSerializable()
class JobDomainModel {
  final int? serno;
  final String? jobdomain;
  @JsonKey(name: 'jobdomain_en')
  final String? jobdomainEn;

  JobDomainModel({
    this.serno,
    this.jobdomain,
    this.jobdomainEn,
  });

  factory JobDomainModel.fromJson(Map<String, dynamic> json) => _$JobDomainModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobDomainModelToJson(this);
}

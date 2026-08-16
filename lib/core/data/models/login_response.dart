import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'token')
  final String? token;
  @JsonKey(name: 'data')
  final List<FamilyData>? data;
  @JsonKey(name: 'IntStatus')
  final int? intStatus;
  @JsonKey(name: 'NatStatus')
  final int? natStatus;
  @JsonKey(name: 'PQStatus')
  final int? pqStatus;
  @JsonKey(name: 'UnReadedCount')
  final int? unReadedCount;

  LoginResponse({
    this.token,
    this.data,
    this.intStatus,
    this.natStatus,
    this.pqStatus,
    this.unReadedCount,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class FamilyData {
  @JsonKey(name: 'father_id')
  final int? fatherId;
  @JsonKey(name: 'father_fullname')
  final String? fatherFullname;
  @JsonKey(name: 'father_fullname_a')
  final String? fatherFullnameA;
  @JsonKey(name: 'father_tuteur')
  final String? fatherTuteur;
  @JsonKey(name: 'father_address')
  final String? fatherAddress;
  @JsonKey(name: 'father_hometel')
  final String? fatherHometel;
  @JsonKey(name: 'father_mobile')
  final String? fatherMobile;
  @JsonKey(name: 'father_profession')
  final String? fatherProfession;
  @JsonKey(name: 'father_domain')
  final dynamic fatherDomain; // API returns int sometimes
  @JsonKey(name: 'father_company')
  final String? fatherCompany;
  @JsonKey(name: 'father_workplace')
  final String? fatherWorkplace;
  @JsonKey(name: 'father_school')
  final String? fatherSchool;
  @JsonKey(name: 'father_diplome')
  final String? fatherDiplome;
  @JsonKey(name: 'father_1lang')
  final String? father1lang;
  @JsonKey(name: 'father_2lang')
  final String? father2lang;
  @JsonKey(name: 'father_3lang')
  final String? father3lang;
  @JsonKey(name: 'father_autreslang')
  final String? fatherAutreslang;
  @JsonKey(name: 'father_email')
  final String? fatherEmail;
  @JsonKey(name: 'mother_fullname')
  final String? motherFullname;
  @JsonKey(name: 'mother_address')
  final String? motherAddress;
  @JsonKey(name: 'mother_tuteur')
  final String? motherTuteur;
  @JsonKey(name: 'mother_hometel')
  final String? motherHometel;
  @JsonKey(name: 'mother_mobile')
  final String? motherMobile;
  @JsonKey(name: 'mother_profession')
  final String? motherProfession;
  @JsonKey(name: 'mother_domain')
  final dynamic motherDomain; // API returns int sometimes
  @JsonKey(name: 'mother_company')
  final String? motherCompany;
  @JsonKey(name: 'mother_workplace')
  final String? motherWorkplace;
  @JsonKey(name: 'mother_school')
  final String? motherSchool;
  @JsonKey(name: 'mother_diplome')
  final String? motherDiplome;
  @JsonKey(name: 'mother_1lang')
  final String? mother1lang;
  @JsonKey(name: 'mother_2lang')
  final String? mother2lang;
  @JsonKey(name: 'mother_3lang')
  final String? mother3lang;
  @JsonKey(name: 'mother_autreslang')
  final String? motherAutreslang;
  @JsonKey(name: 'mother_email')
  final String? motherEmail;
  @JsonKey(name: 'bar_code')
  final dynamic barCode; // Can be string or int if numbers only
  @JsonKey(name: 'parent_pwd')
  final dynamic parentPwd; // Can be string or int if numbers only
  
  // Emergency contacts
  @JsonKey(name: 'urgent_name1')
  final String? urgentName1;
  @JsonKey(name: 'urgent_parentrelation1')
  final String? urgentRelation1;
  @JsonKey(name: 'urgent_tel1')
  final dynamic urgentTel1;
  @JsonKey(name: 'urgent_mobile1')
  final dynamic urgentMobile1;
  @JsonKey(name: 'urgent_name2')
  final String? urgentName2;
  @JsonKey(name: 'urgent_parentrelation2')
  final String? urgentRelation2;
  @JsonKey(name: 'urgent_tel2')
  final dynamic urgentTel2;
  @JsonKey(name: 'urgent_mobile2')
  final dynamic urgentMobile2;

  @JsonKey(name: 'family_situation')
  final dynamic familySituation;
  @JsonKey(name: 'parent_status')
  final dynamic parentStatus;
  @JsonKey(name: 'parentstatus')
  final dynamic parentstatus;

  FamilyData({
    this.fatherId,
    this.fatherFullname,
    this.fatherFullnameA,
    this.fatherTuteur,
    this.fatherAddress,
    this.fatherHometel,
    this.fatherMobile,
    this.fatherProfession,
    this.fatherDomain,
    this.fatherCompany,
    this.fatherWorkplace,
    this.fatherSchool,
    this.fatherDiplome,
    this.father1lang,
    this.father2lang,
    this.father3lang,
    this.fatherAutreslang,
    this.fatherEmail,
    this.motherFullname,
    this.motherAddress,
    this.motherTuteur,
    this.motherHometel,
    this.motherMobile,
    this.motherProfession,
    this.motherDomain,
    this.motherCompany,
    this.motherWorkplace,
    this.motherSchool,
    this.motherDiplome,
    this.mother1lang,
    this.mother2lang,
    this.mother3lang,
    this.motherAutreslang,
    this.motherEmail,
    this.barCode,
    this.parentPwd,
    this.urgentName1,
    this.urgentRelation1,
    this.urgentTel1,
    this.urgentMobile1,
    this.urgentName2,
    this.urgentRelation2,
    this.urgentTel2,
    this.urgentMobile2,
    this.familySituation,
    this.parentStatus,
    this.parentstatus,
  });

  factory FamilyData.fromJson(Map<String, dynamic> json) => _$FamilyDataFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyDataToJson(this);
}

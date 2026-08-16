import 'package:json_annotation/json_annotation.dart';

part 'ministry_report_model.g.dart';

@JsonSerializable()
class MinistryReportResponse {
  final bool? termStatus1;
  final String? termDesc1;
  final List<MinistrySubjectMark>? termResult1;

  final bool? termStatus2;
  @JsonKey(name: 'ermDesc2')
  final String? termDesc2;
  final List<MinistrySubjectMark>? termResult2;

  final bool? termStatus3;
  @JsonKey(name: 'ermDesc3')
  final String? termDesc3;
  final List<MinistrySubjectMark>? termResult3;

  final bool? termStatus4;
  @JsonKey(name: 'ermDesc4')
  final String? termDesc4;
  final List<MinistrySubjectMark>? termResult4;

  MinistryReportResponse({
    this.termStatus1,
    this.termDesc1,
    this.termResult1,
    this.termStatus2,
    this.termDesc2,
    this.termResult2,
    this.termStatus3,
    this.termDesc3,
    this.termResult3,
    this.termStatus4,
    this.termDesc4,
    this.termResult4,
  });

  List<ActiveMinistryTerm> get activeTerms {
    final List<ActiveMinistryTerm> terms = [];
    if (termStatus1 == true && termDesc1 != null) {
      terms.add(ActiveMinistryTerm(description: termDesc1!, results: termResult1 ?? []));
    }
    if (termStatus2 == true && termDesc2 != null) {
      terms.add(ActiveMinistryTerm(description: termDesc2!, results: termResult2 ?? []));
    }
    if (termStatus3 == true && termDesc3 != null) {
      terms.add(ActiveMinistryTerm(description: termDesc3!, results: termResult3 ?? []));
    }
    if (termStatus4 == true && termDesc4 != null) {
      terms.add(ActiveMinistryTerm(description: termDesc4!, results: termResult4 ?? []));
    }
    return terms;
  }

  factory MinistryReportResponse.fromJson(Map<String, dynamic> json) => _$MinistryReportResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MinistryReportResponseToJson(this);
}

class ActiveMinistryTerm {
  final String description;
  final List<MinistrySubjectMark> results;

  ActiveMinistryTerm({required this.description, required this.results});
}

@JsonSerializable()
class MinistrySubjectMark {
  final String? AcademicYearName;
  final String? arabicName;
  final double? arabicMark;
  final String? arabicComment;
  final String? religionName;
  final double? religionMark;
  final String? religionComment;
  final String? socialName;
  final double? socialMark;
  final String? socialComment;
  final String? GoghName;
  final double? GoghMark;
  final String? GoghComment;
  final String? HisName;
  final double? HisMark;
  final String? HisComment;
  final String? TarbyaName;
  final double? TarbyaMark;
  final String? TarbyaComment;

  MinistrySubjectMark({
    this.AcademicYearName,
    this.arabicName,
    this.arabicMark,
    this.arabicComment,
    this.religionName,
    this.religionMark,
    this.religionComment,
    this.socialName,
    this.socialMark,
    this.socialComment,
    this.GoghName,
    this.GoghMark,
    this.GoghComment,
    this.HisName,
    this.HisMark,
    this.HisComment,
    this.TarbyaName,
    this.TarbyaMark,
    this.TarbyaComment,
  });

  List<MinistrySubjectResult> get filteredSubjects {
    final List<MinistrySubjectResult> subjects = [];
    if (arabicMark != null) subjects.add(MinistrySubjectResult(name: arabicName ?? 'Arabic', mark: arabicMark!, comment: arabicComment));
    if (religionMark != null) subjects.add(MinistrySubjectResult(name: religionName ?? 'Religion', mark: religionMark!, comment: religionComment));
    if (socialMark != null) subjects.add(MinistrySubjectResult(name: socialName ?? 'Social Studies', mark: socialMark!, comment: socialComment));
    if (GoghMark != null) subjects.add(MinistrySubjectResult(name: GoghName ?? 'Geography', mark: GoghMark!, comment: GoghComment));
    if (HisMark != null) subjects.add(MinistrySubjectResult(name: HisName ?? 'History', mark: HisMark!, comment: HisComment));
    if (TarbyaMark != null) subjects.add(MinistrySubjectResult(name: TarbyaName ?? 'Civics', mark: TarbyaMark!, comment: TarbyaComment));
    return subjects;
  }

  factory MinistrySubjectMark.fromJson(Map<String, dynamic> json) => _$MinistrySubjectMarkFromJson(json);
  Map<String, dynamic> toJson() => _$MinistrySubjectMarkToJson(this);
}

class MinistrySubjectResult {
  final String name;
  final double mark;
  final String? comment;

  MinistrySubjectResult({required this.name, required this.mark, this.comment});
}

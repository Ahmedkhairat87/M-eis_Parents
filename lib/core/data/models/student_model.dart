import 'package:json_annotation/json_annotation.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel {
  @JsonKey(name: 'std_id')
  final int? id;
  @JsonKey(name: 'std_firstname') // API uses std_firstname for the label
  final String? name;
  @JsonKey(name: 'std_name_a')
  final String? nameArabic;
  @JsonKey(name: 'current_grade')
  final int? grade;
  @JsonKey(name: 'current_classe')
  final int? classId;

  StudentModel({
    this.id,
    this.name,
    this.nameArabic,
    this.grade,
    this.classId,
  });

  String get gradeName {
    switch (grade) {
      case 1: return 'Grade 1 : Baby Class';
      case 2: return 'Grade 2 : KG 1';
      case 3: return 'Grade 3 : KG 2';
      case 4: return 'Grade 4 : PYP 1';
      case 5: return 'Grade 5 : PYP 2';
      case 6: return 'Grade 6 : PYP 3';
      case 7: return 'Grade 7 : PYP 4';
      case 8: return 'Grade 8 : PYP 5';
      case 9: return 'Grade 9 : MYP 1';
      case 10: return 'Grade 10 : MYP 2';
      case 11: return 'Grade 11 : MYP 3';
      case 12: return 'Grade 12 : MYP 4';
      case 13: return 'Grade 13 : MYP 5';
      case 14: return 'Grade 14 : DP 1';
      case 15: return 'Grade 15 : DP 2';
      default: return grade != null ? 'Grade $grade' : '';
    }
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) => _$StudentModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);
}

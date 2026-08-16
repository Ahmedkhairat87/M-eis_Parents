
import 'package:flutter/material.dart';

import '../../../core/data/models/student_model.dart';

class AppProfile {
  final String name;
  final Color color;
  final bool isParent;
  final String targetRoute;
  final StudentModel? student;

  const AppProfile({
    required this.name,
    required this.color,
    this.isParent = false,
    required this.targetRoute,
    this.student,
  });
}

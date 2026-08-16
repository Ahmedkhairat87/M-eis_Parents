import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  static const String _studentKey = 'selected_student_data';
  
  StudentModel? _selectedStudent;

  StudentModel? get selectedStudent => _selectedStudent;

  StudentProvider() {
    _loadSelectedStudent();
  }

  Future<void> _loadSelectedStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStudentJson = prefs.getString(_studentKey);
    if (savedStudentJson != null) {
      try {
        _selectedStudent = StudentModel.fromJson(jsonDecode(savedStudentJson));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading student: $e');
      }
    }
  }

  Future<void> setSelectedStudent(StudentModel student) async {
    _selectedStudent = student;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentKey, jsonEncode(student.toJson()));
    notifyListeners();
  }

  void clearSelectedStudent() async {
    _selectedStudent = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentKey);
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/login_response.dart';

class ParentProvider extends ChangeNotifier {
  static const String _parentKey = 'parent_data';
  
  FamilyData? _parentData;

  FamilyData? get parentData => _parentData;

  ParentProvider() {
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedParentJson = prefs.getString(_parentKey);
    if (savedParentJson != null) {
      try {
        _parentData = FamilyData.fromJson(jsonDecode(savedParentJson));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading parent data: $e');
      }
    }
  }

  Future<void> setParentData(FamilyData data) async {
    _parentData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_parentKey, jsonEncode(data.toJson()));
    notifyListeners();
  }

  void clearParentData() async {
    _parentData = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_parentKey);
  }
}

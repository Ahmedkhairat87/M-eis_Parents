import 'dart:convert';


import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/student_model.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository(this._apiClient);

  Future<List<StudentModel>> getRegisteredStudents({
    required String token,
    required String deviceID,
    required String deviceType,
  }) async {
    final response = await _apiClient.post(
      EndPoints.regstd,
      data: {
        'token': token,
        'deviceID': deviceID,
        'DeviceType': deviceType,
      },
    );
    
    // Robust parsing for both Map and String responses
    Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    // Try finding "Data" or "data" (the API seems inconsistent with casing)
    final list = responseData['Data'] ?? responseData['data'];
    
    if (list is List) {
      return list
          .map((json) => StudentModel.fromJson(json))
          .toList();
    }
    
    return [];
  }

  Future<Map<String, dynamic>> getStudentLinks({
    required String token,
    required String stdID,
  }) async {
    final response = await _apiClient.post(
      EndPoints.studentLinks,
      data: {
        'token': token,
        'stdID': stdID,
      },
    );
    
    if (response.data is String) {
      return jsonDecode(response.data);
    } else if (response.data is Map) {
      return response.data;
    }
    
    return {};
  }
}

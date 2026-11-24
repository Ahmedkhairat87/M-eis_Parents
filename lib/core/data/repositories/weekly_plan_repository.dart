import 'dart:convert';


import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/weekly_plan_model.dart';

class WeeklyPlanRepository {
  final ApiClient _apiClient;

  WeeklyPlanRepository(this._apiClient);

  Future<List<WeeklyPlanWeekModel>> getWeeklyPlanWeeks({
    required String token,
    required String studentId,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.weeklyPlanWeeks,
        data: {
          'token': token,
          'stdID': studentId,
        },
      );

      if (response.statusCode == 204 || response.data == null) {
        return [];
      }

      Map<String, dynamic> responseData;
      if (response.data is String) {
        if (response.data.isEmpty) return [];
        responseData = jsonDecode(response.data);
      } else if (response.data is Map) {
        responseData = response.data;
      } else {
        return [];
      }

      final list = responseData['Weeks'] ?? [];
      return (list as List).map((e) => WeeklyPlanWeekModel.fromJson(e)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 500 &&
          e.responseData is Map &&
          e.responseData['ExceptionMessage'] == "There is no row at position 0.") {
        return [];
      }
      rethrow;
    }
  }

  Future<String?> getViewWeeklyPlanUrl({
    required String token,
    required String studentId,
    required String weekNo,
  }) async {
    final response = await _apiClient.post(
      EndPoints.viewWeeklyPlan,
      data: {
        'token': token,
        'stdID': studentId,
        'week_no': weekNo,
      },
    );

    if (response.data is Map) {
      return response.data['RedirectURL']?.toString();
    } else if (response.data is String) {
      try {
        final data = jsonDecode(response.data);
        return data['RedirectURL']?.toString();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

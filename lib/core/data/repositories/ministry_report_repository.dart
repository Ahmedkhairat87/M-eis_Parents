import 'dart:convert';


import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/ministry_report_model.dart';

class MinistryReportRepository {
  final ApiClient _apiClient;

  MinistryReportRepository(this._apiClient);

  Future<MinistryReportResponse?> getMinistryReports({
    required String token,
    required String studentId,
  }) async {
    final response = await _apiClient.post(
      EndPoints.ministryReports,
      data: {
        'token': token,
        'stdID': studentId,
      },
    );

    if (response.statusCode == 204 || response.data == null) {
      return null;
    }

    Map<String, dynamic> responseData;
    if (response.data is String) {
      if (response.data.isEmpty) return null;
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return null;
    }

    return MinistryReportResponse.fromJson(responseData);
  }
}

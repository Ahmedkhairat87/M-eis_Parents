import 'dart:convert';


import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/homework_model.dart';

class HomeworkRepository {
  final ApiClient _apiClient;

  HomeworkRepository(this._apiClient);

  Future<List<HomeworkModel>> getHomework({
    required String token,
    required String studentId,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.homework,
        data: {
          'token': token,
          'stdID': studentId,
        },
      );

      if (response.statusCode == 204 || response.data == null || (response.data is String && response.data.isEmpty)) {
        return [];
      }

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data);
      } else if (response.data is Map) {
        responseData = response.data;
      } else {
        return [];
      }

      final list = responseData['Data'] ?? responseData['data'];
      if (list is List) {
        return list.map((json) => HomeworkModel.fromJson(json)).toList();
      }
      return [];
    } on ApiException catch (e) {
      if (e.statusCode == 500 &&
          e.responseData is Map &&
          e.responseData['ExceptionMessage'] == "There is no row at position 0.") {
        return [];
      }
      rethrow;
    }
  }

  Future<List<HomeworkAttachmentModel>> getHomeworkAttachments({
    required String token,
    required String divSer,
  }) async {
    final response = await _apiClient.post(
      EndPoints.homeworkAttach,
      data: {
        'token': token,
        'divSer': divSer,
      },
    );

    if (response.statusCode == 204 || response.data == null || (response.data is String && response.data.isEmpty)) {
      return [];
    }

    Map<String, dynamic> responseData;
    if (response.data is String) {
      try {
        responseData = jsonDecode(response.data);
      } catch (e) {
        return [];
      }
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    final list = responseData['Data'] ?? responseData['data'];
    if (list is List) {
      return list.map((json) => HomeworkAttachmentModel.fromJson(json)).toList();
    }
    return [];
  }
}

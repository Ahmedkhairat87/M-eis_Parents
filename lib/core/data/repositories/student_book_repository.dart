import 'dart:convert';


import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/student_book_message_model.dart';

class StudentBookRepository {
  final ApiClient _apiClient;

  StudentBookRepository(this._apiClient);

  Future<Map<String, List<StudentBookMessageModel>>> getMessages({
    required String token,
    required String studentId,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.studentBook,
        data: {
          'token': token,
          'stdID': studentId,
        },
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        if (response.data.isEmpty) return {'inbox': [], 'sent': []};
        responseData = jsonDecode(response.data);
      } else if (response.data is Map) {
        responseData = response.data;
      } else {
        return {'inbox': [], 'sent': []};
      }

      final inboxList = responseData['Data'] ?? [];
      final sentList = responseData['Data2'] ?? [];

      return {
        'inbox': (inboxList as List).map((e) => StudentBookMessageModel.fromJson(e)).toList(),
        'sent': (sentList as List).map((e) => StudentBookMessageModel.fromJson(e)).toList(),
      };
    } on ApiException catch (e) {
      if (e.statusCode == 500 &&
          e.responseData is Map &&
          e.responseData['ExceptionMessage'] == "There is no row at position 0.") {
        return {
          'inbox': <StudentBookMessageModel>[],
          'sent': <StudentBookMessageModel>[],
        };
      }
      rethrow;
    }
  }

  Future<bool> markAsRead({
    required String token,
    required String taSer,
  }) async {
    final response = await _apiClient.post(
      EndPoints.updateStudentMessageRead,
      data: {
        'token': token,
        'taSer': taSer,
      },
    );

    if (response.data is Map) {
      return response.data['Update'] == '1' || response.data['Update'] == 1;
    } else if (response.data is String) {
      try {
        final data = jsonDecode(response.data);
        return data['Update'] == '1' || data['Update'] == 1;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<List<StudentBookSubjectModel>> getSubjects({
    required String token,
    required String studentId,
  }) async {
    final response = await _apiClient.post(
      EndPoints.studentBookPrepare,
      data: {
        'token': token,
        'stdID': studentId,
      },
    );

    Map<String, dynamic> responseData;
    if (response.data is String) {
      if (response.data.isEmpty) return [];
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    final list = responseData['Data'] ?? [];
    return (list as List).map((e) => StudentBookSubjectModel.fromJson(e)).toList();
  }

  Future<bool> sendMessage({
    required String token,
    required String studentId,
    required String matNo,
    required String subject,
    required String body,
  }) async {
    final response = await _apiClient.post(
      EndPoints.studentBookSend,
      data: {
        'token': token,
        'stdID': studentId,
        'matNo': matNo,
        'Subject': subject,
        'Body': body,
      },
    );

    // Assuming a successful response indicates success if no specific status is provided
    return response.statusCode == 200;
  }
}

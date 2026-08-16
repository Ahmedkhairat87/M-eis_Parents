import 'dart:convert';
import 'package:dio/dio.dart';


import '../api/api_client.dart';
import '../api/end_points.dart';

class MessageRepository {
  final ApiClient _apiClient;

  MessageRepository(this._apiClient);

  Future<Map<String, dynamic>> getMessages(String token) async {
    final response = await _apiClient.post(
      EndPoints.messages,
      data: {'token': token},
    );
    if (response.data is String) {
      return jsonDecode(response.data);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> loadMoreInbox(String token, int count) async {
    final response = await _apiClient.post(
      EndPoints.loadInboxMessages,
      data: {'token': token, 'count': count},
    );
    if (response.data is String) {
      return jsonDecode(response.data);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> loadMoreSent(String token, int count) async {
    final response = await _apiClient.post(
      EndPoints.loadSentMessages,
      data: {'token': token, 'count': count},
    );
    if (response.data is String) {
      return jsonDecode(response.data);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> getMessageDetails(String token, dynamic msgSer, dynamic serNo) async {
    final response = await _apiClient.post(
      EndPoints.updateMessage,
      data: {
        'token': token,
        'MsgSer': msgSer,
        'serNo': serNo,
      },
    );
    if (response.data is String) {
      return jsonDecode(response.data);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> prepareNewMessage(String token) async {
    final response = await _apiClient.post(
      EndPoints.newMessagePrepare,
      data: {'token': token},
    );
    if (response.data is String) {
      return jsonDecode(response.data);
    }
    return response.data;
  }

  Future<bool> sendMessage({
    required String token,
    required int gradeID,
    required int toType,
    required String subject,
    required String body,
    MultipartFile? file,
  }) async {
    final Map<String, dynamic> formDataMap = {
      'token': token,
      'gradeID': gradeID,
      'toType': toType,
      'subject': subject,
      'body': body,
    };

    if (file != null) {
      formDataMap['file'] = file;
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _apiClient.post(
      EndPoints.sendMessageWithAttachment,
      data: formData,
    );
    
    final responseData = response.data.toString();
    return responseData.contains('1') || responseData.toLowerCase().contains('success');
  }
}

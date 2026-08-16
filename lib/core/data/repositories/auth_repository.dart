import 'dart:convert';


import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login({
    required String username,
    required String password,
    String? deviceID,
    String? deviceType,
  }) async {
    final response = await _apiClient.post(
      EndPoints.login,
      data: {
        'user': username,
        'pass': password,
        'FCM': '', // To be configured later
        'deviceID': deviceID ?? '',
        'DeviceType': deviceType ?? '',
      },
    );

    Map<String, dynamic> responseData;
    if (response.statusCode == 204 || response.data == null) {
      return LoginResponse(intStatus: 0); // Return a response with fail status
    }

    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      throw Exception('Unexpected response format');
    }

    return LoginResponse.fromJson(responseData);
  }
}

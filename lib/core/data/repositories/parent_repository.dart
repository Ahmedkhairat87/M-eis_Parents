import 'dart:convert';

import 'package:eism/ui/Student/newsletter_screen/widgets/newsletter_model.dart';

import '../api/api_client.dart';
import '../api/end_points.dart';
import '../models/job_domain_model.dart';
import '../models/login_response.dart';
import '../models/parent_lang_model.dart';
import '../models/parent_status_model.dart';

class ParentRepository {
  final ApiClient _apiClient;

  ParentRepository(this._apiClient);

  Future<FamilyData?> getParentProfile(String token) async {
    final response = await _apiClient.post(
      EndPoints.getParentData,
      data: {
        'token': token,
      },
    );

    Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return null;
    }

    final list = responseData['Data'] ?? responseData['data'];
    if (list is List && list.isNotEmpty) {
      return FamilyData.fromJson(list.first);
    }
    
    return null;
  }

  Future<List<JobDomainModel>> getJobDomains(String token) async {
    final response = await _apiClient.post(
      EndPoints.jobDomain,
      data: {
        'token': token,
      },
    );

    Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    final list = responseData['data'] ?? responseData['Data'];
    if (list is List) {
      return list.map((json) => JobDomainModel.fromJson(json)).toList();
    }
    
    return [];
  }

  Future<List<ParentStatusModel>> getParentStatuses(String token) async {
    final response = await _apiClient.post(
      EndPoints.parentStatus,
      data: {
        'token': token,
      },
    );

    Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    final list = responseData['data'] ?? responseData['Data'];
    if (list is List) {
      return list.map((json) => ParentStatusModel.fromJson(json)).toList();
    }
    
    return [];
  }

  Future<List<ParentLangModel>> getParentLanguages(String token) async {
    final response = await _apiClient.post(
      EndPoints.parentLang,
      data: {
        'token': token,
      },
    );

    Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    final list = responseData['data'] ?? responseData['Data'];
    if (list is List) {
      return list.map((json) => ParentLangModel.fromJson(json)).toList();
    }
    
    return [];
  }

  Future<bool> updateParentProfile(String token, Map<String, dynamic> profileData) async {
    final response = await _apiClient.post(
      EndPoints.profile,
      data: {
        'token': token,
        ...profileData,
      },
    );

    Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return false;
    }

    final intStatus = responseData['IntStatus'] ?? responseData['status'] ?? responseData['success'];
    return intStatus == 1 || intStatus == true || intStatus == 'success';
  }

  Future<bool> updateGeneralInfo({
    required String token,
    required String fatherTuteur,
    required String fatherAddress,
    required String motherTuteur,
    required String motherAddress,
    required String parentStatus,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.updateGeneralInfo,
        data: {
          'token': token,
          'father_tuteur': fatherTuteur,
          'father_address': fatherAddress,
          'mother_tuteur': motherTuteur,
          'mother_address': motherAddress,
          'parent_status': parentStatus,
        },
      );

      final responseData = response.data;
      if (responseData is String) {
        return responseData.contains("1");
      } else if (responseData is List) {
        return responseData.contains("1") || responseData.contains(1);
      } else if (responseData is Map) {
        return responseData.values.contains("1") || responseData.values.contains(1);
      }
      
      return responseData.toString().contains("1");
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateContactInfo({
    required String token,
    required String fatherEmail,
    required String fatherHomeTel,
    required String fatherMobile,
    required String motherEmail,
    required String motherHomeTel,
    required String motherMobile,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.updateContactInfo,
        data: {
          'token': token,
          'father_email': fatherEmail,
          'father_hometel': fatherHomeTel,
          'father_mobile': fatherMobile,
          'mother_email': motherEmail,
          'mother_hometel': motherHomeTel,
          'mother_mobile': motherMobile,
        },
      );

      final responseData = response.data;
      if (responseData is String) {
        return responseData.contains("1");
      } else if (responseData is List) {
        return responseData.contains("1") || responseData.contains(1);
      } else if (responseData is Map) {
        return responseData.values.contains("1") || responseData.values.contains(1);
      }

      return responseData.toString().contains("1");
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWorkInfo({
    required String token,
    required String fatherProfession,
    required String fatherCompany,
    required String fatherWorkplace,
    required dynamic fatherDomain,
    required String motherProfession,
    required String motherCompany,
    required String motherWorkplace,
    required dynamic motherDomain,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.updateWorkInfo,
        data: {
          'token': token,
          'father_profession': fatherProfession,
          'father_company': fatherCompany,
          'father_workplace': fatherWorkplace,
          'father_domain': fatherDomain,
          'mother_profession': motherProfession,
          'mother_company': motherCompany,
          'mother_workplace': motherWorkplace,
          'mother_domain': motherDomain,
        },
      );

      final responseData = response.data;
      if (responseData is String) {
        return responseData.contains("1");
      } else if (responseData is List) {
        return responseData.contains("1") || responseData.contains(1);
      } else if (responseData is Map) {
        return responseData.values.contains("1") || responseData.values.contains(1);
      }

      return responseData.toString().contains("1");
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateEducationInfo({
    required String token,
    required String fatherSchool,
    required String fatherDiplome,
    required String father1lang,
    required String father2lang,
    required String father3lang,
    required String fatherAutreslang,
    required String motherSchool,
    required String motherDiplome,
    required String mother1lang,
    required String mother2lang,
    required String mother3lang,
    required String motherAutreslang,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.updateEducationInfo,
        data: {
          'token': token,
          'father_school': fatherSchool,
          'father_diplome': fatherDiplome,
          'father_1lang': father1lang,
          'father_2lang': father2lang,
          'father_3lang': father3lang,
          'father_autreslang': fatherAutreslang,
          'mother_school': motherSchool,
          'mother_diplome': motherDiplome,
          'mother_1lang': mother1lang,
          'mother_2lang': mother2lang,
          'mother_3lang': mother3lang,
          'mother_autreslang': motherAutreslang,
        },
      );

      final responseData = response.data;
      if (responseData is String) {
        return responseData.contains("1");
      } else if (responseData is List) {
        return responseData.contains("1") || responseData.contains(1);
      } else if (responseData is Map) {
        return responseData.values.contains("1") || responseData.values.contains(1);
      }

      return responseData.toString().contains("1");
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUrgentInfo({
    required String token,
    required String urgentName1,
    required String urgentParentrelation1,
    required String urgentTel1,
    required String urgentMobile1,
    required String urgentName2,
    required String urgentParentrelation2,
    required String urgentTel2,
    required String urgentMobile2,
  }) async {
    try {
      final response = await _apiClient.post(
        EndPoints.updateUrgentInfo, 
        data: {
          'token': token,
          'urgent_name1': urgentName1,
          'urgent_parentrelation1': urgentParentrelation1,
          'urgent_tel1': urgentTel1,
          'urgent_mobile1': urgentMobile1,
          'urgent_name2': urgentName2,
          'urgent_parentrelation2': urgentParentrelation2,
          'urgent_tel2': urgentTel2,
          'urgent_mobile2': urgentMobile2,
        },
      );

      final responseData = response.data;
      if (responseData is String) {
        return responseData.contains("1");
      } else if (responseData is Map) {
        return responseData.values.contains("1") || responseData.values.contains(1);
      }
      return responseData.toString().contains("1");
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String token, String currentPassword, String newPassword) async {
    final response = await _apiClient.post(
      EndPoints.changePassword,
      data: {
        'token': token,
        'currentPass': currentPassword,
        'newPass': newPassword,
      },
    );

    final responseData = response.data;
    if (responseData is String) {
      return responseData.contains("OK") || responseData.contains("1");
    } else if (responseData is Map) {
      return responseData.values.contains("OK") || 
             responseData.values.contains("1") || 
             responseData.values.contains(1) ||
             responseData['Message'] == "OK";
    }
    return responseData.toString().contains("OK") || responseData.toString().contains("1");
  }

  Future<List<Newsletter>> getNewsletters(String token) async {
    final response = await _apiClient.post(
      EndPoints.newsletters,
      data: {
        'token': token,
        'Flag': '0',
      },
    );

    if (response.statusCode == 204) {
      return [];
    }

    Map<String, dynamic> responseData;
    if (response.data is String) {
      final String dataString = response.data as String;
      if (dataString.trim().isEmpty) {
        return [];
      }
      responseData = jsonDecode(dataString);
    } else if (response.data is Map) {
      responseData = response.data;
    } else {
      return [];
    }

    final list = responseData['Data'] ?? responseData['data'];
    if (list is List) {
      return list.map((json) => Newsletter.fromJson(json)).toList();
    }
    
    return [];
  }
}

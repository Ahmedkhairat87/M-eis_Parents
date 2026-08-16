class EndPoints {
  // Base URL for the parent portal APIs
  static const String baseUrl = 'https://api1.oasisdemaadi.com/MEISapi/';

  // Endpoints
  static const String login = 'Parent/Login';
  static const String regstd = 'regstd';
  static const String getParentData = 'Parent/getdata';
  static const String jobDomain = 'Parent/jobDomain';
  static const String parentStatus = 'Parent/parentStatus';
  static const String parentLang = 'Parent/parentLang';
  
  static const String profile = 'Parent/profile';
  static const String changePassword = 'Parent/ChangePassword';
  static const String updateGeneralInfo = 'Parent/UGeneralInfo';
  static const String updateContactInfo = 'Parent/UContactInfo';
  static const String updateWorkInfo = 'Parent/UworkInfo';
  static const String updateEducationInfo = 'Parent/UEducationInfo';
  static const String updateUrgentInfo = 'Parent/UUrgentInfo';
  static const String newsletters = 'IntNewsLetter';
  static const String bulletins = 'Parent/bulletins';
  static const String homework = 'std/GetHW';
  static const String homeworkAttach = 'std/GetHWAttach';
  static const String reports = 'Parent/reports';
  static const String ministryReports = 'std/GetMinistryReports';
  static const String weeklyPlanWeeks = 'std/GetWeeklyPlanWeeks';
  static const String viewWeeklyPlan = 'std/ViewWeeklyPlan';
  static const String casProjects = 'Parent/cas-projects';
  static const String messages = 'ParentMSGS';
  static const String loadInboxMessages = 'ParentLoadMSGSIN';
  static const String loadSentMessages = 'ParentLoadMSGSSENT';
  static const String updateMessage = 'updateMSG';
  static const String newMessagePrepare = 'newMSGPrepare';
  static const String sendMessage = 'SendNewMSG';
  static const String sendMessageWithAttachment = 'SendNewMSGWithATT';
  static const String studentBook = 'std/stdBookX';
  static const String studentLinks = 'stdLinks';
  static const String updateStudentMessageRead = 'std/updateStdMSGNEW';
  static const String studentBookPrepare = 'std/stdBookPrepareNew';
  static const String studentBookSend = 'std/stdBookSendNew';
}

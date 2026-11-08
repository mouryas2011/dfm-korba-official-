class AppConstants {
  static const String appName = 'DFM Korba';
  static const String appFullName = 'DFM KORBA OFFICIAL';
  static const String appTagline = 'Skill Development Learning & Competition Management Platform';
  static const String missionSlogan = 'Learn > Practice > Create > Compete > Share > Grow';
  
  // Storage Keys
  static const String keySessionToken = 'dfm_session_token';
  static const String keyUserRole = 'dfm_user_role';
  static const String keyUserId = 'dfm_user_id';
  static const String keyUserData = 'dfm_user_data';
  static const String keyLanguage = 'dfm_language';
  static const String keyReducedMotion = 'dfm_reduced_motion';

  // Default Roles
  static const String roleStudent = 'STUDENT';
  static const String roleTeacher = 'TEACHER';
  static const String roleTeam = 'TEAM';
  static const String roleAdmin = 'ADMIN';

  // File Upload Constraints
  static const int maxUploadSizeMb = 500;
  static const List<String> allowedExtensions = [
    'mp4', 'mov', 'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'mp3', 'wav'
  ];
}


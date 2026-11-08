class ApiEndpoints {
  // Configurable Google Apps Script Web App Endpoint
  // Replace DEPLOYMENT_ID with deployed script ID in production
  static const String defaultBaseUrl = 'https://script.google.com/macros/s/AKfycbx_PLACEHOLDER_DEPLOYMENT_ID/exec';
  
  static String activeBaseUrl = defaultBaseUrl;

  // Actions
  static const String actionHealthCheck = 'HEALTH_CHECK';
  static const String actionLogin = 'LOGIN';
  static const String actionChangePassword = 'CHANGE_PASSWORD';
  static const String actionRequestOtpReset = 'REQUEST_OTP_RESET';
  static const String actionVerifyOtpAndReset = 'VERIFY_OTP_AND_RESET';
  static const String actionGetPublicHomeData = 'GET_PUBLIC_HOME_DATA';
  
  // Dashboard Actions
  static const String actionGetStudentDashboard = 'GET_STUDENT_DASHBOARD';
  static const String actionGetTeamDashboard = 'GET_TEAM_DASHBOARD';
  static const String actionGetTeacherDashboard = 'GET_TEACHER_DASHBOARD';
  static const String actionGetAdminDashboard = 'GET_ADMIN_DASHBOARD';

  // Tasks & Submissions
  static const String actionCreateTask = 'CREATE_TASK';
  static const String actionGetTasks = 'GET_TASKS';
  static const String actionUploadSubmissionFile = 'UPLOAD_SUBMISSION_FILE';
  static const String actionReviewSubmission = 'REVIEW_SUBMISSION';

  // Attendance & Daily Review
  static const String actionGetBatchStudentsForAttendance = 'GET_BATCH_STUDENTS_FOR_ATTENDANCE';
  static const String actionSaveAttendance = 'SAVE_ATTENDANCE';
  static const String actionSubmitDailyReview = 'SUBMIT_DAILY_REVIEW';

  // AI Quiz
  static const String actionGenerateAiQuiz = 'GENERATE_AI_QUIZ_QUESTIONS';
  static const String actionApproveScheduleQuiz = 'APPROVE_AND_SCHEDULE_QUIZ';
  static const String actionSubmitQuizAttempt = 'SUBMIT_QUIZ_ATTEMPT';

  // Chat & Moderation
  static const String actionGetChatRooms = 'GET_CHAT_ROOMS';
  static const String actionGetMessages = 'GET_MESSAGES';
  static const String actionSendMessage = 'SEND_MESSAGE';
  static const String actionReportMessage = 'REPORT_MESSAGE';

  // Administration & Course Management
  static const String actionRegisterStudent = 'REGISTER_STUDENT';
  static const String actionCreateCourse = 'CREATE_COURSE';
  static const String actionUpdateCourse = 'UPDATE_COURSE';
  static const String actionGetCourses = 'GET_COURSES';
  static const String actionCreateBatch = 'CREATE_BATCH';
  static const String actionGetBatches = 'GET_BATCHES';
  static const String actionCreateTeam = 'CREATE_TEAM';
  static const String actionCreateCompetition = 'CREATE_COMPETITION';
  static const String actionGetCompetitions = 'GET_COMPETITIONS';
  static const String actionUploadStudyMaterial = 'UPLOAD_STUDY_MATERIAL';
  static const String actionGetStudyMaterials = 'GET_STUDY_MATERIALS';
  static const String actionGetNotifications = 'GET_NOTIFICATIONS';
  static const String actionMarkNotificationRead = 'MARK_NOTIFICATION_READ';
  static const String actionGetActivityLogs = 'GET_ACTIVITY_LOGS';
  static const String actionConfigureExternalSheetMapping = 'CONFIGURE_EXTERNAL_SHEET_MAPPING';
  static const String actionImportExternalAttendance = 'IMPORT_EXTERNAL_ATTENDANCE';
}


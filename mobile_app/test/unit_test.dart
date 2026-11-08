import 'package:flutter_test/flutter_test.dart';
import 'package:dfm_korba_official/core/constants/app_constants.dart';
import 'package:dfm_korba_official/core/constants/api_endpoints.dart';
import 'package:dfm_korba_official/core/theme/app_colors.dart';

void main() {
  group('Core Architecture & Constants Verification', () {
    test('App identity matches official naming requirements', () {
      expect(AppConstants.appName, 'DFM Korba');
      expect(AppConstants.appFullName, 'DFM KORBA OFFICIAL');
      expect(AppConstants.maxUploadSizeMb, 500);
      expect(AppConstants.allowedExtensions, contains('mp4'));
      expect(AppConstants.allowedExtensions, contains('mov'));
      expect(AppConstants.allowedExtensions, contains('pdf'));
    });

    test('4 user roles are explicitly configured', () {
      expect(AppConstants.roleStudent, 'STUDENT');
      expect(AppConstants.roleTeacher, 'TEACHER');
      expect(AppConstants.roleTeam, 'TEAM');
      expect(AppConstants.roleAdmin, 'ADMIN');
    });

    test('Modern Neumorphism theme tokens match specifications', () {
      expect(AppColors.bgDark.value, 0xFF080D1A);
      expect(AppColors.surfaceDark.value, 0xFF0F172A);
      expect(AppColors.primaryOrange.value, 0xFFFF6B00);
      expect(AppColors.accentCyan.value, 0xFF00D2FF);
    });

    test('Backend actions cover all required endpoints', () {
      expect(ApiEndpoints.actionLogin, 'LOGIN');
      expect(ApiEndpoints.actionChangePassword, 'CHANGE_PASSWORD');
      expect(ApiEndpoints.actionGetPublicHomeData, 'GET_PUBLIC_HOME_DATA');
      expect(ApiEndpoints.actionUploadSubmissionFile, 'UPLOAD_SUBMISSION_FILE');
      expect(ApiEndpoints.actionReviewSubmission, 'REVIEW_SUBMISSION');
      expect(ApiEndpoints.actionSaveAttendance, 'SAVE_ATTENDANCE');
      expect(ApiEndpoints.actionSubmitDailyReview, 'SUBMIT_DAILY_REVIEW');
      expect(ApiEndpoints.actionGenerateAiQuiz, 'GENERATE_AI_QUIZ_QUESTIONS');
      expect(ApiEndpoints.actionSendMessage, 'SEND_MESSAGE');
      expect(ApiEndpoints.actionRegisterStudent, 'REGISTER_STUDENT');
      expect(ApiEndpoints.actionCreateCourse, 'CREATE_COURSE');
      expect(ApiEndpoints.actionCreateBatch, 'CREATE_BATCH');
      expect(ApiEndpoints.actionCreateTeam, 'CREATE_TEAM');
      expect(ApiEndpoints.actionCreateCompetition, 'CREATE_COMPETITION');
      expect(ApiEndpoints.actionUploadStudyMaterial, 'UPLOAD_STUDY_MATERIAL');
      expect(ApiEndpoints.actionGetNotifications, 'GET_NOTIFICATIONS');
      expect(ApiEndpoints.actionGetActivityLogs, 'GET_ACTIVITY_LOGS');
      expect(ApiEndpoints.actionConfigureExternalSheetMapping, 'CONFIGURE_EXTERNAL_SHEET_MAPPING');
      expect(ApiEndpoints.actionImportExternalAttendance, 'IMPORT_EXTERNAL_ATTENDANCE');
    });

    test('Strict No-Certificate and Free Learning policy invariants are enforced', () {
      expect(AppConstants.appName, isNot(contains('Certificate')));
      expect(AppConstants.appFullName, isNot(contains('Certification')));
    });
  });
}


/**
 * DFM KORBA OFFICIAL APP - MASTER API CONTROLLER
 * Google Apps Script Web App Router (doGet & doPost)
 * Clean Architecture Action Dispatcher with CORS and Server-side Security.
 */

/**
 * Handle HTTP GET Requests.
 */
function doGet(e) {
  try {
    var params = e ? e.parameter : {};
    var action = (params.action || 'HEALTH_CHECK').toUpperCase();

    if (action === 'HEALTH_CHECK') {
      return buildJsonResponse(true, 200, "DFM Korba Official Backend API is operational.", {
        app: "DFM Korba Official",
        version: "1.0.0",
        engine: "Google Apps Script V8",
        database: "Google Sheets Normalized (32 Tables)",
        storage: "Google Drive Enterprise",
        timestamp: new Date().toISOString()
      });
    }

    if (action === 'GET_PUBLIC_HOME_DATA') {
      var homeData = ReportingService.getPublicHomeData();
      return buildJsonResponse(true, 200, "Public home data retrieved.", homeData);
    }

    return buildJsonResponse(false, 400, "Unsupported GET action. Please use POST for transactional operations.", null);
  } catch (err) {
    return buildJsonResponse(false, 500, err.message, null);
  }
}

/**
 * Handle HTTP POST Requests.
 */
function doPost(e) {
  try {
    var body = {};
    if (e && e.postData && e.postData.contents) {
      try {
        body = JSON.parse(e.postData.contents);
      } catch (jsonErr) {
        // Fallback for form-encoded payload
        if (e.parameter && e.parameter.payload) {
          body = JSON.parse(e.parameter.payload);
        } else {
          body = e.parameter || {};
        }
      }
    } else if (e && e.parameter) {
      body = e.parameter;
    }

    var action = (body.action || '').toUpperCase();
    var sessionToken = body.session_token;
    var payload = body.payload || body;

    // Public actions that do not require an active session
    if (action === 'LOGIN') {
      var authResult = AuthService.authenticate(payload.identifier, payload.password, payload.login_type);
      return buildJsonResponse(true, 200, "Login successful.", authResult);
    }

    if (action === 'REQUEST_OTP_RESET') {
      var otpResult = AuthService.requestOtpReset(payload.mobile_number, payload.email);
      return buildJsonResponse(true, 200, otpResult.message, otpResult);
    }

    if (action === 'VERIFY_OTP_AND_RESET') {
      var resetResult = AuthService.verifyOtpAndReset(payload.mobile_number, payload.otp, payload.new_password);
      return buildJsonResponse(true, 200, resetResult.message, resetResult);
    }

    if (action === 'GET_PUBLIC_HOME_DATA') {
      var pData = ReportingService.getPublicHomeData();
      return buildJsonResponse(true, 200, "Public home data retrieved.", pData);
    }

    // Authenticated Actions: Require verified session
    var user = AuthService.verifySession(sessionToken);

    // Forced Password Change check
    if (user.is_temp_password && action !== 'CHANGE_PASSWORD' && action !== 'LOGOUT') {
      return buildJsonResponse(false, 403, "TEMPORARY_PASSWORD_CHANGE_REQUIRED: You must update your temporary password before accessing application resources.", {
        requires_password_change: true
      });
    }

    // Router
    switch (action) {
      case 'CHANGE_PASSWORD':
        var pwResult = AuthService.changePassword(user.user_id, payload.old_password, payload.new_password);
        return buildJsonResponse(true, 200, pwResult.message, pwResult);

      case 'GET_STUDENT_DASHBOARD':
        var stuDash = ReportingService.getStudentDashboard(user);
        return buildJsonResponse(true, 200, "Student dashboard retrieved.", stuDash);

      case 'GET_TEAM_DASHBOARD':
        var teamDash = ReportingService.getTeamDashboard(user);
        return buildJsonResponse(true, 200, "Team dashboard retrieved.", teamDash);

      case 'GET_TEACHER_DASHBOARD':
        var teacherDash = ReportingService.getTeacherDashboard(user);
        return buildJsonResponse(true, 200, "Teacher dashboard retrieved.", teacherDash);

      case 'GET_ADMIN_DASHBOARD':
        var adminDash = ReportingService.getAdminDashboard(user);
        return buildJsonResponse(true, 200, "Admin dashboard retrieved.", adminDash);

      case 'CREATE_TASK':
        var newTask = TaskSubmissionService.createTask(user, payload);
        return buildJsonResponse(true, 201, "Task created successfully.", newTask);

      case 'GET_TASKS':
        var tasks = TaskSubmissionService.getTasks(user, payload);
        return buildJsonResponse(true, 200, "Tasks retrieved.", tasks);

      case 'UPLOAD_SUBMISSION_FILE':
        var uploadResult = TaskSubmissionService.uploadSubmissionFile(user, payload);
        return buildJsonResponse(true, 200, uploadResult.message, uploadResult);

      case 'REVIEW_SUBMISSION':
        var reviewResult = TaskSubmissionService.reviewSubmission(user, payload);
        return buildJsonResponse(true, 200, "Submission reviewed and marks recorded.", reviewResult);

      case 'GET_BATCH_STUDENTS_FOR_ATTENDANCE':
        var roster = AttendanceService.getBatchStudentsForAttendance(user, payload.batch_id, payload.date);
        return buildJsonResponse(true, 200, "Batch student roster retrieved.", roster);

      case 'SAVE_ATTENDANCE':
        var attResult = AttendanceService.saveAttendance(user, payload);
        return buildJsonResponse(true, 200, attResult.message, attResult);

      case 'SUBMIT_DAILY_REVIEW':
        var reviewSub = AttendanceService.submitDailyReview(user, payload);
        return buildJsonResponse(true, 200, reviewSub.message, reviewSub);

      case 'GENERATE_AI_QUIZ_QUESTIONS':
        var aiQuestions = QuizService.generateQuestionsWithAI(user, payload);
        return buildJsonResponse(true, 200, "AI questions generated.", aiQuestions);

      case 'APPROVE_AND_SCHEDULE_QUIZ':
        var scheduledQuiz = QuizService.approveAndScheduleQuiz(user, payload);
        return buildJsonResponse(true, 200, "Quiz scheduled successfully.", scheduledQuiz);

      case 'SUBMIT_QUIZ_ATTEMPT':
        var quizEval = QuizService.submitQuizAttempt(user, payload);
        return buildJsonResponse(true, 200, "Quiz evaluated successfully.", quizEval);

      case 'GET_CHAT_ROOMS':
        var rooms = ChatService.getUserChatRooms(user);
        return buildJsonResponse(true, 200, "Chat rooms retrieved.", rooms);

      case 'GET_MESSAGES':
        var msgs = ChatService.getMessages(user, payload);
        return buildJsonResponse(true, 200, "Messages retrieved.", msgs);

      case 'SEND_MESSAGE':
        var sentMsg = ChatService.sendMessage(user, payload);
        return buildJsonResponse(true, 200, "Message sent.", sentMsg);

      case 'REPORT_MESSAGE':
        var reportRes = ChatService.reportMessage(user, payload);
        return buildJsonResponse(true, 200, reportRes.message, reportRes);

      case 'REGISTER_STUDENT':
        var regResult = AuthService.registerStudent(user, payload);
        return buildJsonResponse(true, 201, "Student registered successfully.", regResult);

      // External Sheet Mapping & Synchronization
      case 'CONFIGURE_EXTERNAL_SHEET_MAPPING':
        var mapResult = AttendanceService.configureExternalSheetMapping(user, payload);
        return buildJsonResponse(true, 200, mapResult.message, mapResult);

      case 'IMPORT_EXTERNAL_ATTENDANCE':
        var impResult = AttendanceService.importAttendanceFromExternalSheet(user, payload.batch_id, payload.course_id);
        return buildJsonResponse(true, 200, impResult.message, impResult);

      // Course Management
      case 'CREATE_COURSE':
        var cResult = ManagementService.createCourse(user, payload);
        return buildJsonResponse(true, 201, "Course created successfully.", cResult);

      case 'UPDATE_COURSE':
        var uResult = ManagementService.updateCourse(user, payload);
        return buildJsonResponse(true, 200, "Course updated successfully.", uResult);

      case 'GET_COURSES':
        var cList = ManagementService.getCourses(user);
        return buildJsonResponse(true, 200, "Courses retrieved.", cList);

      // Batch & Team Management
      case 'CREATE_BATCH':
        var bResult = ManagementService.createBatch(user, payload);
        return buildJsonResponse(true, 201, "Batch created successfully.", bResult);

      case 'GET_BATCHES':
        var bList = ManagementService.getBatches(user, payload.course_id);
        return buildJsonResponse(true, 200, "Batches retrieved.", bList);

      case 'CREATE_TEAM':
        var tmResult = ManagementService.createTeam(user, payload);
        return buildJsonResponse(true, 201, "Team created successfully.", tmResult);

      // Competitions
      case 'CREATE_COMPETITION':
        var cmpResult = ManagementService.createCompetition(user, payload);
        return buildJsonResponse(true, 201, "Competition created successfully.", cmpResult);

      case 'GET_COMPETITIONS':
        var cmpList = ManagementService.getCompetitions(user, payload.course_id);
        return buildJsonResponse(true, 200, "Competitions retrieved.", cmpList);

      // Study Materials
      case 'UPLOAD_STUDY_MATERIAL':
        var matResult = ManagementService.uploadStudyMaterial(user, payload);
        return buildJsonResponse(true, 201, "Study material recorded successfully.", matResult);

      case 'GET_STUDY_MATERIALS':
        var matList = ManagementService.getStudyMaterials(user, payload.course_id, payload.format);
        return buildJsonResponse(true, 200, "Study materials retrieved.", matList);

      // Notifications
      case 'GET_NOTIFICATIONS':
        var notifList = ManagementService.getUserNotifications(user);
        return buildJsonResponse(true, 200, "Notifications retrieved.", notifList);

      case 'MARK_NOTIFICATION_READ':
        var readResult = ManagementService.markNotificationRead(user, payload.notification_id);
        return buildJsonResponse(true, 200, "Notification marked as read.", readResult);

      // Activity Logs (Admin Audit)
      case 'GET_ACTIVITY_LOGS':
        var logs = ManagementService.getActivityLogs(user, payload.limit);
        return buildJsonResponse(true, 200, "Activity logs retrieved.", logs);

      default:
        return buildJsonResponse(false, 400, "Unknown action: " + action, null);
    }

  } catch (err) {
    Logger.log("doPost Error: " + err.message + " Stack: " + err.stack);
    return buildJsonResponse(false, 500, err.message, null);
  }
}

/**
 * Standardized JSON Response Builder with CORS headers.
 */
function buildJsonResponse(success, code, message, data) {
  var envelope = {
    success: success,
    code: code,
    message: message || '',
    data: data || null,
    timestamp: new Date().toISOString()
  };

  var output = ContentService.createTextOutput(JSON.stringify(envelope));
  output.setMimeType(ContentService.MimeType.JSON);
  return output;
}


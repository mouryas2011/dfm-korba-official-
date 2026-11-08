/**
 * DFM KORBA OFFICIAL APP - DATABASE SETUP & SEED ENGINE
 * One-click initialization for all 32 normalized Google Sheets tables.
 * Formats headers, colors, freezes rows, and seeds initial development records.
 */

function initializeAllDatabaseSheets() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  var tables = [
    {
      name: "Users",
      headers: ["user_id", "mobile_number", "email", "password_hash", "salt", "role", "full_name", "avatar_url", "is_temp_password", "failed_login_attempts", "lockout_until", "session_token", "token_expiry", "created_at", "updated_at", "status"]
    },
    {
      name: "Admins",
      headers: ["admin_id", "user_id", "super_admin", "department", "created_at", "updated_at"]
    },
    {
      name: "Teachers",
      headers: ["teacher_id", "user_id", "specialization", "designation", "assigned_courses", "can_create_quiz", "can_moderate_chat", "created_at", "updated_at", "status"]
    },
    {
      name: "Students",
      headers: ["student_id", "user_id", "primary_course_id", "batch_id", "team_id", "enrollment_date", "guardian_contact", "cumulative_marks", "attendance_pct", "rank_in_batch", "created_at", "updated_at", "status"]
    },
    {
      name: "Courses",
      headers: ["course_id", "course_name", "code", "description", "course_image", "total_modules", "duration_weeks", "is_free", "created_at", "updated_at", "status"]
    },
    {
      name: "TeacherAssignments",
      headers: ["assignment_id", "teacher_id", "course_id", "can_grade", "can_publish_gallery", "created_at", "status"]
    },
    {
      name: "Batches",
      headers: ["batch_id", "batch_name", "course_id", "teacher_id", "start_date", "end_date", "max_capacity", "created_at", "updated_at", "status"]
    },
    {
      name: "BatchStudents",
      headers: ["id", "batch_id", "student_id", "assigned_at", "status"]
    },
    {
      name: "Teams",
      headers: ["team_id", "team_name", "user_id", "course_id", "batch_id", "leader_student_id", "team_logo", "total_team_marks", "performance_pct", "rank", "created_at", "updated_at", "status"]
    },
    {
      name: "TeamMembers",
      headers: ["id", "team_id", "student_id", "role_in_team", "joined_at", "status"]
    },
    {
      name: "Tasks",
      headers: ["task_id", "title", "description", "course_id", "batch_id", "task_type", "target_scope", "assigned_by", "start_date", "deadline", "max_marks", "attachment_url", "allowed_formats", "max_file_size_mb", "created_at", "status"]
    },
    {
      name: "TaskAssignments",
      headers: ["assignment_id", "task_id", "assignee_type", "assignee_id", "submission_status", "assigned_at"]
    },
    {
      name: "Submissions",
      headers: ["submission_id", "task_id", "submitter_type", "submitter_id", "uploaded_by_user_id", "drive_file_id", "drive_web_view_link", "file_name", "file_size_bytes", "mime_type", "contribution_notes", "submission_status", "submitted_at", "version"]
    },
    {
      name: "SubmissionReviews",
      headers: ["review_id", "submission_id", "reviewed_by", "awarded_marks", "feedback_comments", "decision", "publish_to_gallery", "reviewed_at"]
    },
    {
      name: "Competitions",
      headers: ["competition_id", "title", "description", "course_id", "rules", "start_date", "end_date", "max_marks", "created_by", "status"]
    },
    {
      name: "CompetitionParticipants",
      headers: ["id", "competition_id", "participant_type", "participant_id", "submission_id", "final_rank", "total_score", "registered_at"]
    },
    {
      name: "IndividualMarks",
      headers: ["mark_id", "student_id", "assessment_type", "source_ref_id", "max_marks", "marks_obtained", "awarded_by", "feedback", "created_at"]
    },
    {
      name: "TeamMarks",
      headers: ["team_mark_id", "team_id", "assessment_type", "source_ref_id", "max_marks", "marks_obtained", "awarded_by", "feedback", "created_at"]
    },
    {
      name: "Attendance",
      headers: ["attendance_id", "date", "course_id", "batch_id", "student_id", "student_name", "status", "marked_by", "sync_status", "created_at"]
    },
    {
      name: "StudyMaterials",
      headers: ["material_id", "course_id", "batch_id", "module_name", "chapter_name", "title", "description", "file_format", "drive_file_id", "drive_web_link", "file_size_bytes", "uploaded_by", "created_at", "status"]
    },
    {
      name: "Quizzes",
      headers: ["quiz_id", "title", "course_id", "batch_id", "topic", "source_material_id", "total_questions", "duration_minutes", "max_marks", "pass_marks", "start_window", "end_window", "ai_generated", "teacher_approved", "approved_by", "created_at", "status"]
    },
    {
      name: "QuizQuestions",
      headers: ["question_id", "quiz_id", "question_type", "question_text", "option_a", "option_b", "option_c", "option_d", "correct_answer", "explanation", "marks", "order_index"]
    },
    {
      name: "QuizAttempts",
      headers: ["attempt_id", "quiz_id", "student_id", "started_at", "submitted_at", "score_obtained", "percentage", "passed", "status"]
    },
    {
      name: "QuizAnswers",
      headers: ["answer_id", "attempt_id", "question_id", "student_answer", "is_correct", "marks_awarded"]
    },
    {
      name: "Notices",
      headers: ["notice_id", "category", "title", "content", "target_scope", "scope_id", "priority", "author_id", "start_date", "expiry_date", "created_at", "status"]
    },
    {
      name: "ChatRooms",
      headers: ["room_id", "room_type", "title", "course_id", "batch_id", "created_at", "status"]
    },
    {
      name: "ChatMembers",
      headers: ["id", "room_id", "user_id", "role_in_chat", "last_read_message_id", "joined_at", "status"]
    },
    {
      name: "Messages",
      headers: ["message_id", "room_id", "sender_user_id", "sender_name", "message_type", "content", "media_drive_id", "is_flagged", "created_at", "status"]
    },
    {
      name: "Notifications",
      headers: ["notification_id", "recipient_user_id", "notification_type", "title", "body", "action_route", "is_read", "created_at"]
    },
    {
      name: "DailyReviews",
      headers: ["review_id", "date", "course_id", "batch_id", "teacher_id", "activities_completed", "student_progress", "challenges_faced", "work_completed", "overall_remarks", "submitted_at"]
    },
    {
      name: "ActivityLogs",
      headers: ["log_id", "user_id", "user_role", "action", "details", "ip_address", "created_at"]
    },
    {
      name: "AppSettings",
      headers: ["setting_key", "setting_value", "description", "updated_by", "updated_at"]
    }
  ];

  // Create or format each sheet
  for (var i = 0; i < tables.length; i++) {
    var t = tables[i];
    var sheet = ss.getSheetByName(t.name);
    if (!sheet) {
      sheet = ss.insertSheet(t.name);
    }
    
    // Check if headers need setting
    var existingHeaders = sheet.getRange(1, 1, 1, Math.max(1, sheet.getLastColumn())).getValues()[0];
    if (sheet.getLastRow() === 0 || existingHeaders[0] === "") {
      sheet.clear();
      sheet.getRange(1, 1, 1, t.headers.length).setValues([t.headers]);
      var headerRange = sheet.getRange(1, 1, 1, t.headers.length);
      headerRange.setBackground("#0F172A");
      headerRange.setFontColor("#00D2FF");
      headerRange.setFontWeight("bold");
      sheet.setFrozenRows(1);
    }
  }

  // Remove default 'Sheet1' if exists and empty
  var sheet1 = ss.getSheetByName("Sheet1");
  if (sheet1 && ss.getSheets().length > 1) {
    try { ss.deleteSheet(sheet1); } catch (e) {}
  }

  // Seed Initial Baseline Data
  seedInitialData();

  SpreadsheetApp.flush();
  Logger.log("All 32 database tables successfully initialized and styled.");
}

/**
 * Seed initial courses, admin, instructor, batch, top team, tasks and notices.
 */
function seedInitialData() {
  var now = new Date().toISOString();

  // 1. Seed Courses
  var coursesSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Courses");
  if (coursesSheet.getLastRow() <= 1) {
    DatabaseService.insertRowsBatch("Courses", [
      {
        course_id: "CRS_DRONE",
        course_name: "Drone Film Making",
        code: "DFM",
        description: "Master cinematic aerial storytelling, DGCA flight safety regulations, gimbal control, and post-production color grading.",
        course_image: "assets/images/dfm_korba_logo.jpg",
        total_modules: 6,
        duration_weeks: 12,
        is_free: true,
        status: "ACTIVE"
      },
      {
        course_id: "CRS_MOBILE_REP",
        course_name: "Mobile Repairing & Hardware",
        code: "MRH",
        description: "Advanced smartphone micro-soldering, PCB diagnostics, display replacement, and firmware flashing.",
        course_image: "",
        total_modules: 5,
        duration_weeks: 10,
        is_free: true,
        status: "ACTIVE"
      },
      {
        course_id: "CRS_FRONT_OFFICE",
        course_name: "Front Office Executive",
        code: "FOE",
        description: "Professional hospitality management, CRM operations, business communication, and guest relations.",
        course_image: "",
        total_modules: 4,
        duration_weeks: 8,
        is_free: true,
        status: "ACTIVE"
      }
    ]);
  }

  // 2. Seed Admin User
  var usersSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Users");
  if (usersSheet.getLastRow() <= 1) {
    var adminSalt = AuthService.generateSalt(16);
    var adminHash = AuthService.hashPassword("Admin@123", adminSalt);

    var teacherSalt = AuthService.generateSalt(16);
    var teacherHash = AuthService.hashPassword("Teacher@123", teacherSalt);

    var teamSalt = AuthService.generateSalt(16);
    var teamHash = AuthService.hashPassword("Veervaan@123", teamSalt);

    var studentSalt = AuthService.generateSalt(16);
    var studentHash = AuthService.hashPassword("Student@123", studentSalt);

    DatabaseService.insertRowsBatch("Users", [
      {
        user_id: "USR_ADMIN_01",
        mobile_number: "admin",
        email: "admin@dfmkorba.org",
        password_hash: adminHash,
        salt: adminSalt,
        role: "ADMIN",
        full_name: "Super Administrator",
        avatar_url: "",
        is_temp_password: true,
        status: "ACTIVE"
      },
      {
        user_id: "USR_TCH_01",
        mobile_number: "9876500001",
        email: "vikram.sharma@dfmkorba.org",
        password_hash: teacherHash,
        salt: teacherSalt,
        role: "TEACHER",
        full_name: "Vikram Sharma",
        avatar_url: "",
        is_temp_password: false,
        status: "ACTIVE"
      },
      {
        user_id: "USR_TM_01",
        mobile_number: "TM_VEERVAAN",
        email: "veervaan@dfmkorba.org",
        password_hash: teamHash,
        salt: teamSalt,
        role: "TEAM",
        full_name: "Team Veervaan",
        avatar_url: "",
        is_temp_password: false,
        status: "ACTIVE"
      },
      {
        user_id: "USR_STU_01",
        mobile_number: "9876543210",
        email: "aman.verma@dfmkorba.org",
        password_hash: studentHash,
        salt: studentSalt,
        role: "STUDENT",
        full_name: "Aman Verma",
        avatar_url: "",
        is_temp_password: false,
        status: "ACTIVE"
      }
    ]);

    // Admin Profile
    DatabaseService.insertRow("Admins", {
      admin_id: "ADM_001",
      user_id: "USR_ADMIN_01",
      super_admin: true,
      department: "Directorate of Skill Development"
    });

    // Teacher Profile
    DatabaseService.insertRow("Teachers", {
      teacher_id: "TCH_001",
      user_id: "USR_TCH_01",
      specialization: "Cinematic Drone Pilot & Video Editor",
      designation: "Head Flight Instructor",
      assigned_courses: '["CRS_DRONE"]',
      can_create_quiz: true,
      can_moderate_chat: true,
      status: "ACTIVE"
    });
  }

  // 3. Seed Batch
  var batchSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Batches");
  if (batchSheet.getLastRow() <= 1) {
    DatabaseService.insertRow("Batches", {
      batch_id: "BTC_DFM_01",
      batch_name: "DFM Batch 01 (Morning Batch)",
      course_id: "CRS_DRONE",
      teacher_id: "TCH_001",
      start_date: "2026-10-01",
      end_date: "2026-12-31",
      max_capacity: 30,
      status: "ONGOING"
    });
  }

  // 4. Seed Team: Veervaan
  var teamSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Teams");
  if (teamSheet.getLastRow() <= 1) {
    DatabaseService.insertRow("Teams", {
      team_id: "TM_VEERVAAN",
      team_name: "Veervaan",
      user_id: "USR_TM_01",
      course_id: "CRS_DRONE",
      batch_id: "BTC_DFM_01",
      leader_student_id: "STU_DFM_001",
      team_logo: "",
      total_team_marks: 485,
      performance_pct: 97.0,
      rank: 1,
      status: "ACTIVE"
    });

    // Seed Team Members
    DatabaseService.insertRowsBatch("TeamMembers", [
      { id: "TM_M_01", team_id: "TM_VEERVAAN", student_id: "STU_DFM_001", role_in_team: "LEADER / PILOT", status: "ACTIVE" },
      { id: "TM_M_02", team_id: "TM_VEERVAAN", student_id: "STU_DFM_002", role_in_team: "CAMERA GIMBAL OPERATOR", status: "ACTIVE" },
      { id: "TM_M_03", team_id: "TM_VEERVAAN", student_id: "STU_DFM_003", role_in_team: "EDITOR & COLORIST", status: "ACTIVE" },
      { id: "TM_M_04", team_id: "TM_VEERVAAN", student_id: "STU_DFM_004", role_in_team: "SPOTTER & FLIGHT SAFETY", status: "ACTIVE" },
      { id: "TM_M_05", team_id: "TM_VEERVAAN", student_id: "STU_DFM_005", role_in_team: "SOUND DESIGNER", status: "ACTIVE" },
      { id: "TM_M_06", team_id: "TM_VEERVAAN", student_id: "STU_DFM_006", role_in_team: "SCRIPT & STORYBOARD", status: "ACTIVE" }
    ]);
  }

  // 5. Seed Student: Aman Verma
  var studentSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Students");
  if (studentSheet.getLastRow() <= 1) {
    DatabaseService.insertRow("Students", {
      student_id: "STU_DFM_001",
      user_id: "USR_STU_01",
      primary_course_id: "CRS_DRONE",
      batch_id: "BTC_DFM_01",
      team_id: "TM_VEERVAAN",
      enrollment_date: "2026-10-01",
      guardian_contact: "9876540000",
      cumulative_marks: 490,
      attendance_pct: 98.5,
      rank_in_batch: 1,
      status: "ENROLLED"
    });
  }

  // 6. Seed Tasks
  var tasksSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Tasks");
  if (tasksSheet.getLastRow() <= 1) {
    DatabaseService.insertRowsBatch("Tasks", [
      {
        task_id: "TSK_001",
        title: "Drone Cinematic Sunset Shoot",
        description: "Capture 3 smooth cinematic movements at sunset: 360-degree orbit around the subject, low-altitude reveal over water, and vertical fly-over.",
        course_id: "CRS_DRONE",
        batch_id: "BTC_DFM_01",
        task_type: "TEAM",
        target_scope: "ALL_TEAMS",
        assigned_by: "TCH_001",
        start_date: now,
        deadline: "2026-11-12T18:00:00Z",
        max_marks: 100,
        allowed_formats: '["MP4","MOV"]',
        max_file_size_mb: 500,
        status: "PUBLISHED"
      },
      {
        task_id: "TSK_002",
        title: "DGCA Pre-Flight Safety Checklist Video",
        description: "Record individual walkaround inspection of quadcopter, propeller checks, compass calibration, and IMU health status.",
        course_id: "CRS_DRONE",
        batch_id: "BTC_DFM_01",
        task_type: "INDIVIDUAL",
        target_scope: "ALL_STUDENTS",
        assigned_by: "TCH_001",
        start_date: now,
        deadline: "2026-11-15T18:00:00Z",
        max_marks: 50,
        allowed_formats: '["MP4","MOV","PDF"]',
        max_file_size_mb: 200,
        status: "PUBLISHED"
      }
    ]);
  }

  // 7. Seed Notices
  var noticesSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Notices");
  if (noticesSheet.getLastRow() <= 1) {
    DatabaseService.insertRowsBatch("Notices", [
      {
        notice_id: "NTC_001",
        category: "GENERAL_NOTICE",
        title: "Next Competition: Cinematic Drone Short Film",
        content: "Inter-batch Drone Film Making Competition scheduled for 18 Nov 2026. All teams must submit their project treatments.",
        target_scope: "ALL_COURSES",
        priority: "HIGH",
        author_id: "USR_ADMIN_01",
        start_date: now,
        expiry_date: "2026-11-19T00:00:00Z",
        status: "ACTIVE"
      },
      {
        notice_id: "NTC_002",
        category: "COMMON_TASK_NOTICE",
        title: "Practical Flight Weather Advisory",
        content: "Morning flight sessions will commence at 07:00 AM to capitalize on low wind conditions. Charge all intelligent flight batteries.",
        target_scope: "CRS_DRONE",
        priority: "NORMAL",
        author_id: "USR_TCH_01",
        start_date: now,
        expiry_date: "2026-11-15T00:00:00Z",
        status: "ACTIVE"
      }
    ]);
  }

  // 8. Seed Chat Room
  var chatRoomsSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("ChatRooms");
  if (chatRoomsSheet.getLastRow() <= 1) {
    DatabaseService.insertRow("ChatRooms", {
      room_id: "CR_TM_VEERVAAN",
      room_type: "TEAM_GROUP",
      title: "Team Veervaan Official Squad",
      course_id: "CRS_DRONE",
      batch_id: "BTC_DFM_01",
      status: "ACTIVE"
    });

    DatabaseService.insertRow("ChatMembers", {
      id: "CM_001",
      room_id: "CR_TM_VEERVAAN",
      user_id: "USR_STU_01",
      role_in_chat: "MEMBER",
      status: "ACTIVE"
    });
  }

  // 9. Seed AppSettings
  var settingsSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("AppSettings");
  if (settingsSheet.getLastRow() <= 1) {
    DatabaseService.insertRowsBatch("AppSettings", [
      { setting_key: "PUBLIC_GALLERY_ENABLED", setting_value: "true", description: "Enables public work gallery on Home screen." },
      { setting_key: "MAX_LOGIN_ATTEMPTS", setting_value: "3", description: "Account lockout threshold for failed logins." },
      { setting_key: "QUIZ_FREQUENCY_DAYS", setting_value: "15", description: "Automated AI quiz evaluation interval." }
    ]);
  }
}

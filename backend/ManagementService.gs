/**
 * DFM KORBA OFFICIAL APP - MANAGEMENT & AUDIT SERVICE
 * Handles Courses, Batches, Teams, Competitions, Study Materials, Notifications and Activity Logs.
 */

var ManagementService = (function() {

  // =========================================================================
  // 1. COURSE MANAGEMENT (Admin Role)
  // =========================================================================

  function createCourse(user, data) {
    if (user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only System Administrators can create new courses.");
    }

    if (!data.course_name || !data.code) {
      throw new Error("VAL_INVALID_INPUT: Course name and code are required.");
    }

    var courseId = 'CRS_' + data.code.toUpperCase().replace(/[^A-Z0-9]/g, '_');
    
    // Check if course already exists
    var existing = DatabaseService.findRowByKey('Courses', 'course_id', courseId);
    if (existing) {
      throw new Error("VAL_DUPLICATE_ENTRY: Course with ID " + courseId + " already exists.");
    }

    var nowIso = new Date().toISOString();
    var course = {
      course_id: courseId,
      course_name: data.course_name,
      code: data.code.toUpperCase(),
      description: data.description || '',
      course_image: data.course_image || '',
      total_modules: Number(data.total_modules || 4),
      duration_weeks: Number(data.duration_weeks || 8),
      is_free: true, // Strict Free Policy
      created_at: nowIso,
      updated_at: nowIso,
      status: 'ACTIVE'
    };

    DatabaseService.insertRow('Courses', course);
    logActivity(user.user_id, user.role, 'CREATE_COURSE', 'Created course: ' + course.course_name + ' (' + courseId + ')');

    return {
      success: true,
      course: course
    };
  }

  function updateCourse(user, data) {
    if (user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only System Administrators can update courses.");
    }

    var courseId = data.course_id;
    if (!courseId) throw new Error("VAL_INVALID_INPUT: course_id is required.");

    var updates = {
      updated_at: new Date().toISOString()
    };

    if (data.course_name) updates.course_name = data.course_name;
    if (data.description !== undefined) updates.description = data.description;
    if (data.total_modules) updates.total_modules = Number(data.total_modules);
    if (data.duration_weeks) updates.duration_weeks = Number(data.duration_weeks);
    if (data.status) updates.status = data.status;

    DatabaseService.updateRow('Courses', 'course_id', courseId, updates);
    logActivity(user.user_id, user.role, 'UPDATE_COURSE', 'Updated course: ' + courseId);

    return {
      success: true,
      course_id: courseId
    };
  }

  function getCourses(user) {
    var rows = DatabaseService.getAllRows('Courses');
    if (user && user.role === 'ADMIN') {
      return rows;
    }
    return rows.filter(function(c) { return c.status === 'ACTIVE'; });
  }

  // =========================================================================
  // 2. BATCH MANAGEMENT (Teacher & Admin Roles)
  // =========================================================================

  function createBatch(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only Teachers and Admins can create batches.");
    }

    if (!data.batch_name || !data.course_id) {
      throw new Error("VAL_INVALID_INPUT: batch_name and course_id are required.");
    }

    var batchId = DatabaseService.generateId('BTC');
    var nowIso = new Date().toISOString();

    var batch = {
      batch_id: batchId,
      batch_name: data.batch_name,
      course_id: data.course_id,
      teacher_id: data.teacher_id || user.user_id,
      start_date: data.start_date || nowIso.split('T')[0],
      end_date: data.end_date || '',
      max_capacity: Number(data.max_capacity || 30),
      created_at: nowIso,
      updated_at: nowIso,
      status: 'ACTIVE'
    };

    DatabaseService.insertRow('Batches', batch);
    logActivity(user.user_id, user.role, 'CREATE_BATCH', 'Created batch ' + batch.batch_name + ' (' + batchId + ')');

    return {
      success: true,
      batch: batch
    };
  }

  function getBatches(user, courseId) {
    var all = DatabaseService.getAllRows('Batches');
    if (courseId) {
      return all.filter(function(b) { return b.course_id === courseId; });
    }
    return all;
  }

  // =========================================================================
  // 3. TEAM MANAGEMENT (Teacher & Admin Roles)
  // =========================================================================

  function createTeam(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only Teachers and Admins can create teams.");
    }

    if (!data.team_name || !data.course_id || !data.batch_id) {
      throw new Error("VAL_INVALID_INPUT: team_name, course_id, and batch_id are required.");
    }

    var teamId = DatabaseService.generateId('TM');
    var nowIso = new Date().toISOString();

    var team = {
      team_id: teamId,
      team_name: data.team_name,
      user_id: data.user_id || '', // Linked team portal user account
      course_id: data.course_id,
      batch_id: data.batch_id,
      leader_student_id: data.leader_student_id || '',
      team_logo: data.team_logo || '',
      total_team_marks: 0,
      performance_pct: 100.0,
      rank: 99,
      created_at: nowIso,
      updated_at: nowIso,
      status: 'ACTIVE'
    };

    DatabaseService.insertRow('Teams', team);

    // If members provided, add to TeamMembers table
    if (Array.isArray(data.members) && data.members.length > 0) {
      var memberRows = [];
      for (var m = 0; m < data.members.length; m++) {
        var mem = data.members[m];
        memberRows.push({
          id: DatabaseService.generateId('TMM'),
          team_id: teamId,
          student_id: typeof mem === 'string' ? mem : mem.student_id,
          role_in_team: typeof mem === 'object' ? (mem.role || 'Member') : 'Member',
          joined_at: nowIso,
          status: 'ACTIVE'
        });

        // Update Student's team_id
        DatabaseService.updateRow('Students', 'student_id', typeof mem === 'string' ? mem : mem.student_id, {
          team_id: teamId
        });
      }
      DatabaseService.insertRowsBatch('TeamMembers', memberRows);
    }

    logActivity(user.user_id, user.role, 'CREATE_TEAM', 'Created squad ' + team.team_name + ' with ' + (data.members ? data.members.length : 0) + ' members');

    return {
      success: true,
      team: team
    };
  }

  // =========================================================================
  // 4. COMPETITIONS & TOURNAMENTS
  // =========================================================================

  function createCompetition(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only Teachers and Admins can create competitions.");
    }

    if (!data.title || !data.course_id) {
      throw new Error("VAL_INVALID_INPUT: Title and course_id are required.");
    }

    var compId = DatabaseService.generateId('CMP');
    var nowIso = new Date().toISOString();

    var comp = {
      competition_id: compId,
      title: data.title,
      description: data.description || '',
      course_id: data.course_id,
      rules: data.rules || 'Adhere strictly to DGCA drone flying guidelines. 60-second limit.',
      start_date: data.start_date || nowIso.split('T')[0],
      end_date: data.end_date || '',
      max_marks: Number(data.max_marks || 500),
      created_by: user.user_id,
      status: 'UPCOMING'
    };

    DatabaseService.insertRow('Competitions', comp);
    logActivity(user.user_id, user.role, 'CREATE_COMPETITION', 'Created competition ' + comp.title + ' (' + compId + ')');

    return {
      success: true,
      competition: comp
    };
  }

  function getCompetitions(user, courseId) {
    var all = DatabaseService.getAllRows('Competitions');
    if (courseId) {
      return all.filter(function(c) { return c.course_id === courseId; });
    }
    return all;
  }

  // =========================================================================
  // 5. STUDY MATERIALS & RESOURCES
  // =========================================================================

  function uploadStudyMaterial(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only Teachers and Admins can upload study materials.");
    }

    if (!data.title || !data.course_id) {
      throw new Error("VAL_INVALID_INPUT: Title and course_id are required.");
    }

    var matId = DatabaseService.generateId('MAT');
    var nowIso = new Date().toISOString();

    var material = {
      material_id: matId,
      course_id: data.course_id,
      batch_id: data.batch_id || '',
      module_name: data.module_name || 'Module 1: Drone Fundamentals',
      chapter_name: data.chapter_name || 'Introduction',
      title: data.title,
      description: data.description || '',
      file_format: (data.file_format || 'PDF').toUpperCase(),
      drive_file_id: data.drive_file_id || '',
      drive_web_link: data.drive_web_link || '',
      file_size_bytes: Number(data.file_size_bytes || 0),
      uploaded_by: user.user_id,
      created_at: nowIso,
      status: 'ACTIVE'
    };

    DatabaseService.insertRow('StudyMaterials', material);
    logActivity(user.user_id, user.role, 'UPLOAD_STUDY_MATERIAL', 'Uploaded resource ' + material.title + ' (' + material.file_format + ')');

    return {
      success: true,
      material: material
    };
  }

  function getStudyMaterials(user, courseId, format) {
    var rows = DatabaseService.findRows('StudyMaterials', function(m) {
      return m.status === 'ACTIVE';
    });

    if (courseId) {
      rows = rows.filter(function(m) { return m.course_id === courseId; });
    }
    if (format && format !== 'ALL') {
      rows = rows.filter(function(m) { return m.file_format === format.toUpperCase(); });
    }
    return rows;
  }

  // =========================================================================
  // 6. NOTIFICATIONS ENGINE
  // =========================================================================

  function sendNotification(recipientUserId, type, title, body, actionRoute) {
    var notifId = DatabaseService.generateId('NOT');
    var notif = {
      notification_id: notifId,
      recipient_user_id: recipientUserId,
      notification_type: type || 'SYSTEM_ALERT',
      title: title,
      body: body,
      action_route: actionRoute || '',
      is_read: false,
      created_at: new Date().toISOString()
    };

    DatabaseService.insertRow('Notifications', notif);
    return notif;
  }

  function getUserNotifications(user) {
    var rows = DatabaseService.findRows('Notifications', function(n) {
      return n.recipient_user_id === user.user_id;
    });
    // Return latest 30 sorted descending
    return rows.reverse().slice(0, 30);
  }

  function markNotificationRead(user, notificationId) {
    DatabaseService.updateRow('Notifications', 'notification_id', notificationId, {
      is_read: true
    });
    return { success: true };
  }

  // =========================================================================
  // 7. ACTIVITY AUDIT LOGGING
  // =========================================================================

  function logActivity(userId, userRole, action, details, ipAddress) {
    try {
      var logId = DatabaseService.generateId('LOG');
      var logRow = {
        log_id: logId,
        user_id: userId || 'SYSTEM',
        user_role: userRole || 'GUEST',
        action: action,
        details: typeof details === 'object' ? JSON.stringify(details) : String(details || ''),
        ip_address: ipAddress || 'INTERNAL_GAS',
        created_at: new Date().toISOString()
      };
      DatabaseService.insertRow('ActivityLogs', logRow);
    } catch (e) {
      Logger.log("Failed to write audit log: " + e.message);
    }
  }

  function getActivityLogs(user, limit) {
    if (user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only System Administrators can access activity audit logs.");
    }
    var rows = DatabaseService.getAllRows('ActivityLogs');
    limit = limit || 50;
    return rows.reverse().slice(0, limit);
  }

  return {
    createCourse: createCourse,
    updateCourse: updateCourse,
    getCourses: getCourses,
    createBatch: createBatch,
    getBatches: getBatches,
    createTeam: createTeam,
    createCompetition: createCompetition,
    getCompetitions: getCompetitions,
    uploadStudyMaterial: uploadStudyMaterial,
    getStudyMaterials: getStudyMaterials,
    sendNotification: sendNotification,
    getUserNotifications: getUserNotifications,
    markNotificationRead: markNotificationRead,
    logActivity: logActivity,
    getActivityLogs: getActivityLogs
  };
})();

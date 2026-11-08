/**
 * DFM KORBA OFFICIAL APP - TASK & SUBMISSION SERVICE
 * Drive file storage integration, dual marks engine (Individual vs Team), and review workflow.
 */

var TaskSubmissionService = (function() {

  /**
   * Get or create a nested folder in Google Drive.
   */
  function getOrCreateFolder(parentFolder, folderName) {
    var folders = parentFolder.getFoldersByName(folderName);
    if (folders.hasNext()) {
      return folders.next();
    }
    return parentFolder.createFolder(folderName);
  }

  /**
   * Get designated Drive root storage folder.
   */
  function getRootStorageFolder() {
    var props = PropertiesService.getScriptProperties();
    var folderId = props.getProperty('STORAGE_ROOT_FOLDER_ID');
    if (folderId) {
      try {
        return DriveApp.getFolderById(folderId);
      } catch (e) {
        Logger.log("Root folder error: " + e.message);
      }
    }
    var rootFolders = DriveApp.getFoldersByName('DFM_KORBA_APP_STORAGE');
    if (rootFolders.hasNext()) {
      return rootFolders.next();
    }
    return DriveApp.createFolder('DFM_KORBA_APP_STORAGE');
  }

  /**
   * Create Task by Teacher or Admin.
   */
  function createTask(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Only teachers or admins can create tasks.");
    }

    var taskId = DatabaseService.generateId('TSK');
    var task = {
      task_id: taskId,
      title: data.title,
      description: data.description || '',
      course_id: data.course_id,
      batch_id: data.batch_id,
      task_type: data.task_type || 'INDIVIDUAL', // 'INDIVIDUAL', 'TEAM', 'DAILY_CHALLENGE'
      target_scope: data.target_scope || 'ALL_STUDENTS',
      assigned_by: user.user_id,
      start_date: data.start_date || new Date().toISOString(),
      deadline: data.deadline,
      max_marks: Number(data.max_marks) || 100,
      attachment_url: data.attachment_url || '',
      allowed_formats: data.allowed_formats || '["MP4","MOV","JPG","PDF"]',
      max_file_size_mb: Number(data.max_file_size_mb) || 500,
      status: 'PUBLISHED'
    };

    DatabaseService.insertRow('Tasks', task);
    return task;
  }

  /**
   * Query Tasks.
   */
  function getTasks(user, filters) {
    var all = DatabaseService.getAllRows('Tasks');
    return all.filter(function(t) {
      if (filters.course_id && t.course_id !== filters.course_id) return false;
      if (filters.batch_id && t.batch_id !== filters.batch_id) return false;
      if (filters.task_type && filters.task_type !== 'ALL' && t.task_type !== filters.task_type) return false;
      return t.status !== 'DELETED';
    });
  }

  /**
   * Upload Work Submission to Google Drive & save record in Sheets.
   */
  function uploadSubmissionFile(user, data) {
    var taskId = data.task_id;
    var task = DatabaseService.findRowByKey('Tasks', 'task_id', taskId);
    if (!task) throw new Error("Task not found.");

    var fileName = data.file_name || 'submission_file';
    var mimeType = data.mime_type || 'application/octet-stream';
    var base64Data = data.base64_data;

    if (!base64Data) {
      throw new Error("No file content received.");
    }

    // Decode file bytes
    var decodedBytes = Utilities.base64Decode(base64Data);
    var blob = Utilities.newBlob(decodedBytes, mimeType, fileName);

    // Save into Drive Folder hierarchy:
    // Root -> Courses -> [course_id] -> Batches -> [batch_id] -> Submissions -> [task_id]
    var root = getRootStorageFolder();
    var coursesFolder = getOrCreateFolder(root, 'Courses');
    var courseFolder = getOrCreateFolder(coursesFolder, task.course_id);
    var batchesFolder = getOrCreateFolder(courseFolder, 'Batches');
    var batchFolder = getOrCreateFolder(batchesFolder, task.batch_id);
    var subsFolder = getOrCreateFolder(batchFolder, 'Submissions');
    var taskFolder = getOrCreateFolder(subsFolder, taskId);

    var driveFile = taskFolder.createFile(blob);
    driveFile.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);

    var submissionId = DatabaseService.generateId('SUB');
    var isTeam = (user.role === 'TEAM' || data.submitter_type === 'TEAM');
    var submitterId = isTeam ? (data.team_id || user.user_id) : (data.student_id || user.user_id);

    var submission = {
      submission_id: submissionId,
      task_id: taskId,
      submitter_type: isTeam ? 'TEAM' : 'STUDENT',
      submitter_id: submitterId,
      uploaded_by_user_id: user.user_id,
      drive_file_id: driveFile.getId(),
      drive_web_view_link: driveFile.getUrl(),
      file_name: fileName,
      file_size_bytes: blob.getBytes().length,
      mime_type: mimeType,
      contribution_notes: data.contribution_notes || '',
      submission_status: 'PENDING_REVIEW',
      submitted_at: new Date().toISOString(),
      version: 1
    };

    DatabaseService.insertRow('Submissions', submission);

    return {
      submission_id: submissionId,
      drive_file_id: driveFile.getId(),
      drive_web_view_link: driveFile.getUrl(),
      file_name: fileName,
      submission_status: 'PENDING_REVIEW',
      message: "Submission uploaded successfully. Awaiting teacher review."
    };
  }

  /**
   * Review submission, award dual marks, and optionally flag for public gallery.
   */
  function reviewSubmission(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Only teachers or admins can review submissions.");
    }

    var submissionId = data.submission_id;
    var submission = DatabaseService.findRowByKey('Submissions', 'submission_id', submissionId);
    if (!submission) throw new Error("Submission not found.");

    var task = DatabaseService.findRowByKey('Tasks', 'task_id', submission.task_id);
    var decision = data.decision || 'APPROVED'; // 'APPROVED', 'REJECTED', 'RESUBMISSION_REQ'
    var awardedMarks = Number(data.awarded_marks) || 0;
    var feedback = data.feedback_comments || '';
    var publishToGallery = data.publish_to_gallery === true || String(data.publish_to_gallery) === 'true';

    // Update Submission row
    DatabaseService.updateRow('Submissions', 'submission_id', submissionId, {
      submission_status: decision
    });

    // Insert Review Record
    var reviewId = DatabaseService.generateId('REV');
    DatabaseService.insertRow('SubmissionReviews', {
      review_id: reviewId,
      submission_id: submissionId,
      reviewed_by: user.user_id,
      awarded_marks: awardedMarks,
      feedback_comments: feedback,
      decision: decision,
      publish_to_gallery: publishToGallery,
      reviewed_at: new Date().toISOString()
    });

    // DUAL MARKS ENGINE:
    // If team submission: award marks to TeamMarks as a SINGLE atomic score (no multiplication)
    if (submission.submitter_type === 'TEAM') {
      var teamMarkId = DatabaseService.generateId('MRK_TM');
      DatabaseService.insertRow('TeamMarks', {
        team_mark_id: teamMarkId,
        team_id: submission.submitter_id,
        assessment_type: 'TEAM_TASK',
        source_ref_id: task ? task.task_id : submissionId,
        max_marks: task ? task.max_marks : 100,
        marks_obtained: awardedMarks,
        awarded_by: user.user_id,
        feedback: feedback
      });

      // Update Team's aggregate marks
      updateTeamAggregates(submission.submitter_id);
    }

    // Award Individual Marks if breakdown supplied
    if (data.individual_breakdown && Array.isArray(data.individual_breakdown)) {
      for (var i = 0; i < data.individual_breakdown.length; i++) {
        var item = data.individual_breakdown[i];
        if (item.student_id) {
          var markId = DatabaseService.generateId('MRK_IND');
          DatabaseService.insertRow('IndividualMarks', {
            mark_id: markId,
            student_id: item.student_id,
            assessment_type: 'TASK',
            source_ref_id: task ? task.task_id : submissionId,
            max_marks: task ? task.max_marks : 100,
            marks_obtained: Number(item.marks) || awardedMarks,
            awarded_by: user.user_id,
            feedback: item.role ? ('Role: ' + item.role + '. ' + feedback) : feedback
          });
          updateStudentAggregates(item.student_id);
        }
      }
    } else if (submission.submitter_type === 'STUDENT') {
      // Direct student submission
      var indMarkId = DatabaseService.generateId('MRK_IND');
      DatabaseService.insertRow('IndividualMarks', {
        mark_id: indMarkId,
        student_id: submission.submitter_id,
        assessment_type: 'TASK',
        source_ref_id: task ? task.task_id : submissionId,
        max_marks: task ? task.max_marks : 100,
        marks_obtained: awardedMarks,
        awarded_by: user.user_id,
        feedback: feedback
      });
      updateStudentAggregates(submission.submitter_id);
    }

    return {
      success: true,
      submission_id: submissionId,
      decision: decision,
      awarded_marks: awardedMarks,
      publish_to_gallery: publishToGallery
    };
  }

  /**
   * Recalculate team total marks without duplicate multiplication.
   */
  function updateTeamAggregates(teamId) {
    var teamMarks = DatabaseService.findRows('TeamMarks', function(m) {
      return m.team_id === teamId;
    });
    var totalMarks = 0;
    var maxPossible = 0;
    for (var i = 0; i < teamMarks.length; i++) {
      totalMarks += Number(teamMarks[i].marks_obtained) || 0;
      maxPossible += Number(teamMarks[i].max_marks) || 100;
    }
    var pct = maxPossible > 0 ? ((totalMarks / maxPossible) * 100).toFixed(1) : 0;

    DatabaseService.updateRow('Teams', 'team_id', teamId, {
      total_team_marks: totalMarks,
      performance_pct: Number(pct)
    });
  }

  /**
   * Recalculate student cumulative score.
   */
  function updateStudentAggregates(studentId) {
    var marks = DatabaseService.findRows('IndividualMarks', function(m) {
      return m.student_id === studentId;
    });
    var totalMarks = 0;
    for (var i = 0; i < marks.length; i++) {
      totalMarks += Number(marks[i].marks_obtained) || 0;
    }
    DatabaseService.updateRow('Students', 'student_id', studentId, {
      cumulative_marks: totalMarks
    });
  }

  return {
    createTask: createTask,
    getTasks: getTasks,
    uploadSubmissionFile: uploadSubmissionFile,
    reviewSubmission: reviewSubmission,
    updateTeamAggregates: updateTeamAggregates,
    updateStudentAggregates: updateStudentAggregates
  };
})();


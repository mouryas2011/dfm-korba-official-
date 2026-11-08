/**
 * DFM KORBA OFFICIAL APP - ATTENDANCE & DAILY REVIEW SERVICE
 * 
 * Synchronizes student attendance via verified Student IDs and logs daily company reviews.
 * Includes Configurable External Sheet Mapping Engine for owner-supplied legacy Google Sheets.
 */

var AttendanceService = (function() {

  /**
   * Fetch batch student roster for attendance marking on a given date.
   */
  function getBatchStudentsForAttendance(user, batchId, date) {
    date = date || new Date().toISOString().split('T')[0];

    // Get students in this batch
    var allStudents = DatabaseService.getAllRows('Students');
    var batchStudents = allStudents.filter(function(s) {
      return s.batch_id === batchId && s.status !== 'DROPPED';
    });

    // Get existing attendance records for this date & batch
    var existingRecords = DatabaseService.findRows('Attendance', function(a) {
      return a.batch_id === batchId && String(a.date).indexOf(date) === 0;
    });

    var attendanceMap = {};
    for (var i = 0; i < existingRecords.length; i++) {
      attendanceMap[existingRecords[i].student_id] = existingRecords[i].status;
    }

    var result = [];
    for (var j = 0; j < batchStudents.length; j++) {
      var stu = batchStudents[j];
      var userRecord = DatabaseService.findRowByKey('Users', 'user_id', stu.user_id);
      result.push({
        student_id: stu.student_id,
        user_id: stu.user_id,
        full_name: userRecord ? userRecord.full_name : stu.student_id,
        avatar_url: userRecord ? userRecord.avatar_url : '',
        status: attendanceMap[stu.student_id] || 'PRESENT'
      });
    }

    return {
      batch_id: batchId,
      date: date,
      students: result
    };
  }

  /**
   * Save Batch Attendance with dual-write to primary DB and optional owner external sheet.
   */
  function saveAttendance(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only teachers or admins can mark attendance.");
    }

    var date = data.date || new Date().toISOString().split('T')[0];
    var batchId = data.batch_id;
    var courseId = data.course_id;
    var records = data.records; // Array of { student_id, status }

    if (!batchId || !records || !records.length) {
      throw new Error("VAL_INVALID_INPUT: Batch ID and attendance records array are required.");
    }

    // Get existing records for this date/batch
    var existingRows = DatabaseService.findRows('Attendance', function(a) {
      return a.batch_id === batchId && String(a.date).indexOf(date) === 0;
    });

    var existingMap = {};
    for (var e = 0; e < existingRows.length; e++) {
      existingMap[existingRows[e].student_id] = existingRows[e].attendance_id;
    }

    var rowsToInsert = [];
    var processedRecords = [];
    var nowIso = new Date().toISOString();

    for (var i = 0; i < records.length; i++) {
      var rec = records[i];
      var status = rec.status || 'PRESENT';
      var studentRow = DatabaseService.findRowByKey('Students', 'student_id', rec.student_id);
      var userRow = studentRow ? DatabaseService.findRowByKey('Users', 'user_id', studentRow.user_id) : null;
      var stuName = userRow ? userRow.full_name : rec.student_id;

      if (existingMap[rec.student_id]) {
        // Update existing row
        DatabaseService.updateRow('Attendance', 'attendance_id', existingMap[rec.student_id], {
          status: status,
          marked_by: user.user_id,
          updated_at: nowIso
        });
        processedRecords.push({
          date: date,
          batch_id: batchId,
          course_id: courseId,
          student_id: rec.student_id,
          student_name: stuName,
          status: status,
          marked_by: user.user_id
        });
      } else {
        // Insert new row
        var newAtt = {
          attendance_id: DatabaseService.generateId('ATT'),
          date: date,
          course_id: courseId || (studentRow ? studentRow.primary_course_id : ''),
          batch_id: batchId,
          student_id: rec.student_id,
          student_name: stuName,
          status: status,
          marked_by: user.user_id,
          sync_status: 'SYNCED',
          created_at: nowIso
        };
        rowsToInsert.push(newAtt);
        processedRecords.push(newAtt);
      }

      // Recalculate student attendance percentage
      recalculateAttendancePct(rec.student_id);
    }

    if (rowsToInsert.length > 0) {
      DatabaseService.insertRowsBatch('Attendance', rowsToInsert);
    }

    // Attempt External Sheet Synchronization if configured by Owner
    var externalSyncResult = null;
    try {
      externalSyncResult = mirrorAttendanceToOwnerSheet(processedRecords);
    } catch (extErr) {
      Logger.log("External Attendance Sheet Sync Warning: " + extErr.message);
      externalSyncResult = { synced: false, error: extErr.message };
    }

    // Log audit activity
    ManagementService.logActivity(user.user_id, user.role, 'SAVE_ATTENDANCE', 
      'Marked attendance for ' + records.length + ' students in batch ' + batchId + ' for date ' + date);

    return {
      success: true,
      message: "Attendance saved and synchronized successfully for " + records.length + " students.",
      external_sync: externalSyncResult
    };
  }

  /**
   * Recalculate real-time attendance percentage for a student.
   */
  function recalculateAttendancePct(studentId) {
    var attendances = DatabaseService.findRows('Attendance', function(a) {
      return a.student_id === studentId;
    });

    if (attendances.length === 0) return;

    var presentCount = 0;
    for (var i = 0; i < attendances.length; i++) {
      var s = attendances[i].status;
      if (s === 'PRESENT' || s === 'EXCUSED') {
        presentCount++;
      }
    }

    var pct = ((presentCount / attendances.length) * 100).toFixed(1);
    DatabaseService.updateRow('Students', 'student_id', studentId, {
      attendance_pct: Number(pct)
    });
  }

  /**
   * Submit Daily Company Review (8 mandatory fields).
   */
  function submitDailyReview(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only teachers or admins can submit daily company reviews.");
    }

    // Server-side validation of mandatory fields
    if (!data.activities_completed || !data.student_progress || !data.work_completed) {
      throw new Error("VAL_INVALID_INPUT: Mandatory daily review fields (activities_completed, student_progress, work_completed) are required.");
    }

    var reviewId = DatabaseService.generateId('DLR');
    var review = {
      review_id: reviewId,
      date: data.date || new Date().toISOString().split('T')[0],
      course_id: data.course_id || 'CRS_DRONE',
      batch_id: data.batch_id || 'BTC_DFM_01',
      teacher_id: user.user_id,
      activities_completed: data.activities_completed || '',
      student_progress: data.student_progress || '',
      challenges_faced: data.challenges_faced || '',
      work_completed: data.work_completed || '',
      overall_remarks: data.overall_remarks || '',
      submitted_at: new Date().toISOString()
    };

    DatabaseService.insertRow('DailyReviews', review);

    // Attempt External Sheet Synchronization if configured by Owner
    var externalSyncResult = null;
    try {
      externalSyncResult = mirrorDailyReviewToOwnerSheet(review, user);
    } catch (extErr) {
      Logger.log("External Daily Review Sheet Sync Warning: " + extErr.message);
      externalSyncResult = { synced: false, error: extErr.message };
    }

    // Log audit activity
    ManagementService.logActivity(user.user_id, user.role, 'SUBMIT_DAILY_REVIEW', 
      'Submitted 8-field daily review ' + reviewId + ' for batch ' + review.batch_id);

    return {
      success: true,
      review_id: reviewId,
      message: "Daily company review submitted successfully.",
      external_sync: externalSyncResult
    };
  }

  // =========================================================================
  // CONFIGURABLE EXTERNAL SHEET MAPPING & SYNCHRONIZATION ENGINE
  // =========================================================================

  /**
   * Configure mapping parameters for an external owner-supplied Google Sheet.
   */
  function configureExternalSheetMapping(user, config) {
    if (user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only System Administrators can configure external sheet mappings.");
    }

    var targetModule = (config.target_module || '').toUpperCase(); // 'ATTENDANCE' or 'DAILY_REVIEW'
    var sheetId = config.external_spreadsheet_id;
    var sheetTabName = config.sheet_name || 'Sheet1';
    var fieldMapping = config.field_mapping; // Object mapping: { "External Header": "internal_field" }

    if (!targetModule || !sheetId || !fieldMapping) {
      throw new Error("VAL_INVALID_INPUT: target_module, external_spreadsheet_id, and field_mapping are required.");
    }

    // Test access to external spreadsheet
    try {
      var extSs = SpreadsheetApp.openById(sheetId);
      var tab = extSs.getSheetByName(sheetTabName);
      if (!tab) {
        throw new Error("Tab '" + sheetTabName + "' does not exist in the specified spreadsheet.");
      }
    } catch (openErr) {
      throw new Error("EXTERNAL_ACCESS_ERROR: Could not open external sheet (" + openErr.message + "). Ensure the service account / Apps Script has Editor access.");
    }

    // Store in AppSettings
    var prefix = 'EXT_' + targetModule + '_';
    updateSetting(prefix + 'SHEET_ID', sheetId, 'External ' + targetModule + ' Spreadsheet ID', user.user_id);
    updateSetting(prefix + 'SHEET_NAME', sheetTabName, 'External ' + targetModule + ' Sheet Tab Name', user.user_id);
    updateSetting(prefix + 'MAPPING', JSON.stringify(fieldMapping), 'Column mapping for ' + targetModule, user.user_id);
    updateSetting(prefix + 'ENABLED', 'TRUE', 'External sync status flag', user.user_id);

    ManagementService.logActivity(user.user_id, user.role, 'CONFIGURE_EXTERNAL_SHEET', 
      'Configured external sheet mapping for module: ' + targetModule + ' (ID: ' + sheetId + ')');

    return {
      success: true,
      message: "External sheet mapping successfully verified and stored for " + targetModule + "."
    };
  }

  /**
   * Mirror attendance records to the owner's external Google Sheet based on configured mappings.
   */
  function mirrorAttendanceToOwnerSheet(records) {
    var enabled = getSetting('EXT_ATTENDANCE_ENABLED') === 'TRUE';
    if (!enabled) return { synced: false, reason: "External sync not enabled" };

    var sheetId = getSetting('EXT_ATTENDANCE_SHEET_ID');
    var tabName = getSetting('EXT_ATTENDANCE_SHEET_NAME') || 'Sheet1';
    var mappingRaw = getSetting('EXT_ATTENDANCE_MAPPING');
    if (!sheetId || !mappingRaw) return { synced: false, reason: "Missing config" };

    var mapping = JSON.parse(mappingRaw);
    var extSs = SpreadsheetApp.openById(sheetId);
    var sheet = extSs.getSheetByName(tabName);
    if (!sheet) return { synced: false, reason: "Tab not found" };

    var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn() || 1).getValues()[0];
    if (!headers || headers.length === 0 || headers[0] === '') {
      // Create headers based on mapping keys
      headers = Object.keys(mapping);
      sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    }

    // Build rows to append
    var rowsToAppend = [];
    for (var r = 0; r < records.length; r++) {
      var item = records[r];
      var row = [];
      for (var h = 0; h < headers.length; h++) {
        var headerName = headers[h].toString().trim();
        var internalField = mapping[headerName];
        var val = internalField ? (item[internalField] !== undefined ? item[internalField] : '') : '';
        row.push(val);
      }
      rowsToAppend.push(row);
    }

    if (rowsToAppend.length > 0) {
      sheet.getRange(sheet.getLastRow() + 1, 1, rowsToAppend.length, headers.length).setValues(rowsToAppend);
    }

    return {
      synced: true,
      synced_rows: rowsToAppend.length,
      external_sheet_id: sheetId
    };
  }

  /**
   * Mirror daily review record to the owner's external Google Sheet.
   */
  function mirrorDailyReviewToOwnerSheet(review, user) {
    var enabled = getSetting('EXT_DAILY_REVIEW_ENABLED') === 'TRUE';
    if (!enabled) return { synced: false, reason: "External sync not enabled" };

    var sheetId = getSetting('EXT_DAILY_REVIEW_SHEET_ID');
    var tabName = getSetting('EXT_DAILY_REVIEW_SHEET_NAME') || 'Sheet1';
    var mappingRaw = getSetting('EXT_DAILY_REVIEW_MAPPING');
    if (!sheetId || !mappingRaw) return { synced: false, reason: "Missing config" };

    var mapping = JSON.parse(mappingRaw);
    var extSs = SpreadsheetApp.openById(sheetId);
    var sheet = extSs.getSheetByName(tabName);
    if (!sheet) return { synced: false, reason: "Tab not found" };

    var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn() || 1).getValues()[0];
    if (!headers || headers.length === 0 || headers[0] === '') {
      headers = Object.keys(mapping);
      sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    }

    var userRow = DatabaseService.findRowByKey('Users', 'user_id', user.user_id);
    var extendedReview = Object.assign({}, review, {
      teacher_name: userRow ? userRow.full_name : user.user_id
    });

    var row = [];
    for (var h = 0; h < headers.length; h++) {
      var headerName = headers[h].toString().trim();
      var internalField = mapping[headerName];
      var val = internalField ? (extendedReview[internalField] !== undefined ? extendedReview[internalField] : '') : '';
      row.push(val);
    }

    sheet.getRange(sheet.getLastRow() + 1, 1, 1, headers.length).setValues([row]);

    return {
      synced: true,
      external_sheet_id: sheetId
    };
  }

  /**
   * Import Historical Attendance from Owner's External Sheet into DFM Korba Database.
   */
  function importAttendanceFromExternalSheet(user, batchId, courseId) {
    if (user.role !== 'ADMIN') {
      throw new Error("AUTH_FORBIDDEN: Only admins can trigger external data imports.");
    }

    var sheetId = getSetting('EXT_ATTENDANCE_SHEET_ID');
    var tabName = getSetting('EXT_ATTENDANCE_SHEET_NAME') || 'Sheet1';
    var mappingRaw = getSetting('EXT_ATTENDANCE_MAPPING');
    if (!sheetId || !mappingRaw) {
      throw new Error("CONFIG_MISSING: External attendance sheet is not yet configured.");
    }

    var mapping = JSON.parse(mappingRaw); // { "External Header": "internal_field" }
    var extSs = SpreadsheetApp.openById(sheetId);
    var sheet = extSs.getSheetByName(tabName);
    if (!sheet) throw new Error("Tab '" + tabName + "' not found in external sheet.");

    var values = sheet.getDataRange().getValues();
    if (values.length <= 1) return { imported_count: 0, message: "No data rows found." };

    var headers = values[0];
    var rowsToInsert = [];

    for (var i = 1; i < values.length; i++) {
      var row = values[i];
      var recordObj = {};
      for (var c = 0; c < headers.length; c++) {
        var hName = headers[c].toString().trim();
        var targetField = mapping[hName];
        if (targetField) {
          recordObj[targetField] = row[c];
        }
      }

      if (recordObj.student_id && recordObj.date) {
        rowsToInsert.push({
          attendance_id: DatabaseService.generateId('ATT'),
          date: String(recordObj.date).split('T')[0],
          course_id: courseId || recordObj.course_id || 'CRS_DRONE',
          batch_id: batchId || recordObj.batch_id || 'BTC_DFM_01',
          student_id: String(recordObj.student_id).trim(),
          student_name: recordObj.student_name || '',
          status: recordObj.status || 'PRESENT',
          marked_by: user.user_id,
          sync_status: 'IMPORTED',
          created_at: new Date().toISOString()
        });
      }
    }

    if (rowsToInsert.length > 0) {
      DatabaseService.insertRowsBatch('Attendance', rowsToInsert);
    }

    ManagementService.logActivity(user.user_id, user.role, 'IMPORT_EXTERNAL_ATTENDANCE',
      'Imported ' + rowsToInsert.length + ' attendance records from external sheet ' + sheetId);

    return {
      success: true,
      imported_count: rowsToInsert.length,
      message: "Successfully imported " + rowsToInsert.length + " historical records."
    };
  }

  // AppSettings Helpers
  function getSetting(key) {
    var row = DatabaseService.findRowByKey('AppSettings', 'setting_key', key);
    return row ? row.setting_value : null;
  }

  function updateSetting(key, value, desc, updatedBy) {
    var existing = DatabaseService.findRowByKey('AppSettings', 'setting_key', key);
    var nowIso = new Date().toISOString();
    if (existing) {
      DatabaseService.updateRow('AppSettings', 'setting_key', key, {
        setting_value: value,
        updated_by: updatedBy,
        updated_at: nowIso
      });
    } else {
      DatabaseService.insertRow('AppSettings', {
        setting_key: key,
        setting_value: value,
        description: desc || '',
        updated_by: updatedBy,
        updated_at: nowIso
      });
    }
  }

  return {
    getBatchStudentsForAttendance: getBatchStudentsForAttendance,
    saveAttendance: saveAttendance,
    submitDailyReview: submitDailyReview,
    configureExternalSheetMapping: configureExternalSheetMapping,
    mirrorAttendanceToOwnerSheet: mirrorAttendanceToOwnerSheet,
    mirrorDailyReviewToOwnerSheet: mirrorDailyReviewToOwnerSheet,
    importAttendanceFromExternalSheet: importAttendanceFromExternalSheet
  };
})();

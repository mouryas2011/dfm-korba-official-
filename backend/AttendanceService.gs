/**
 * DFM KORBA OFFICIAL APP - ATTENDANCE & DAILY REVIEW SERVICE
 * Synchronizes student attendance via verified Student IDs and logs daily company reviews.
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
   * Save Batch Attendance.
   */
  function saveAttendance(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Only teachers or admins can mark attendance.");
    }

    var date = data.date || new Date().toISOString().split('T')[0];
    var batchId = data.batch_id;
    var courseId = data.course_id;
    var records = data.records; // Array of { student_id, status }

    if (!batchId || !records || !records.length) {
      throw new Error("Batch ID and attendance records array are required.");
    }

    // Delete existing records for this date/batch if overwriting
    // Or insert / update
    var existingRows = DatabaseService.findRows('Attendance', function(a) {
      return a.batch_id === batchId && String(a.date).indexOf(date) === 0;
    });

    var existingMap = {};
    for (var e = 0; e < existingRows.length; e++) {
      existingMap[existingRows[e].student_id] = existingRows[e].attendance_id;
    }

    var rowsToInsert = [];
    var nowIso = new Date().toISOString();

    for (var i = 0; i < records.length; i++) {
      var rec = records[i];
      var status = rec.status || 'PRESENT';

      if (existingMap[rec.student_id]) {
        // Update existing row
        DatabaseService.updateRow('Attendance', 'attendance_id', existingMap[rec.student_id], {
          status: status,
          marked_by: user.user_id,
          updated_at: nowIso
        });
      } else {
        // Insert new row
        var studentRow = DatabaseService.findRowByKey('Students', 'student_id', rec.student_id);
        var userRow = studentRow ? DatabaseService.findRowByKey('Users', 'user_id', studentRow.user_id) : null;
        rowsToInsert.push({
          attendance_id: DatabaseService.generateId('ATT'),
          date: date,
          course_id: courseId || (studentRow ? studentRow.primary_course_id : ''),
          batch_id: batchId,
          student_id: rec.student_id,
          student_name: userRow ? userRow.full_name : rec.student_id,
          status: status,
          marked_by: user.user_id,
          sync_status: 'SYNCED'
        });
      }

      // Recalculate student attendance percentage
      recalculateAttendancePct(rec.student_id);
    }

    if (rowsToInsert.length > 0) {
      DatabaseService.insertRowsBatch('Attendance', rowsToInsert);
    }

    return {
      success: true,
      message: "Attendance saved and synchronized successfully for " + records.length + " students."
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
   * Submit Daily Company Review.
   */
  function submitDailyReview(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Only teachers or admins can submit daily company reviews.");
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
    return {
      success: true,
      review_id: reviewId,
      message: "Daily company review submitted successfully."
    };
  }

  return {
    getBatchStudentsForAttendance: getBatchStudentsForAttendance,
    saveAttendance: saveAttendance,
    submitDailyReview: submitDailyReview
  };
})();


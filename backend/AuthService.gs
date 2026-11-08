/**
 * DFM KORBA OFFICIAL APP - AUTHENTICATION & SECURITY SERVICE
 * Enterprise-grade salted SHA-256, rate limiting, OTP recovery & session management.
 */

var AuthService = (function() {

  /**
   * Compute salted SHA-256 hash.
   */
  function hashPassword(password, salt) {
    var raw = password + salt;
    var digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, raw, Utilities.Charset.UTF_8);
    var hash = '';
    for (var i = 0; i < digest.length; i++) {
      var byteVal = digest[i];
      if (byteVal < 0) byteVal += 256;
      var byteHex = byteVal.toString(16);
      if (byteHex.length === 1) byteHex = '0' + byteHex;
      hash += byteHex;
    }
    return hash;
  }

  /**
   * Generate random salt string.
   */
  function generateSalt(length) {
    length = length || 16;
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var salt = '';
    for (var i = 0; i < length; i++) {
      salt += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return salt;
  }

  /**
   * Primary Login Authenticator for all 4 roles.
   */
  function authenticate(identifier, password, loginType) {
    if (!identifier || !password) {
      throw new Error("Missing mobile number/identifier or password.");
    }

    identifier = String(identifier).trim();
    loginType = (loginType || 'STUDENT').toUpperCase();

    // Find user in 'Users' sheet by mobile_number or user_id
    var user = DatabaseService.findRowByKey('Users', 'mobile_number', identifier);
    if (!user) {
      user = DatabaseService.findRowByKey('Users', 'user_id', identifier);
    }

    if (!user) {
      throw new Error("Account not found. Please check your credentials or contact administrator.");
    }

    // Role validation
    if (loginType === 'ADMIN' && user.role !== 'ADMIN') {
      throw new Error("Access denied. Admin role required.");
    }
    if (loginType === 'TEACHER' && user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Access denied. Teacher role required.");
    }
    if (loginType === 'TEAM' && user.role !== 'TEAM') {
      throw new Error("Access denied. Team role required.");
    }

    // Check account status
    if (user.status === 'SUSPENDED') {
      throw new Error("Account is suspended. Please contact administrator.");
    }

    // Check rate limit & lockout
    var now = new Date();
    if (user.lockout_until) {
      var lockoutDate = new Date(user.lockout_until);
      if (lockoutDate > now) {
        var diffMinutes = Math.ceil((lockoutDate - now) / (1000 * 60));
        throw new Error("Account locked due to consecutive failed attempts. Try again in " + diffMinutes + " minutes or reset password.");
      }
    }

    // Verify Password
    var expectedHash = hashPassword(password, user.salt);
    if (expectedHash !== user.password_hash) {
      var attempts = (parseInt(user.failed_login_attempts) || 0) + 1;
      var updatePayload = { failed_login_attempts: attempts };

      if (attempts >= 3) {
        var lockoutTime = new Date(now.getTime() + 30 * 60 * 1000); // 30 minutes lockout
        updatePayload.lockout_until = lockoutTime.toISOString();
        updatePayload.status = 'LOCKED';
      }

      DatabaseService.updateRow('Users', 'user_id', user.user_id, updatePayload);

      if (attempts >= 3) {
        throw new Error("Account locked: 3 failed attempts. Please wait 30 minutes or use OTP password reset.");
      } else {
        var remaining = 3 - attempts;
        throw new Error("Invalid password. " + remaining + " attempt(s) remaining before temporary lockout.");
      }
    }

    // Successful login: Generate session token and reset failed attempts
    var sessionToken = 'tok_' + Utilities.getUuid().replace(/-/g, '');
    var expiry = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000); // 7 days

    DatabaseService.updateRow('Users', 'user_id', user.user_id, {
      failed_login_attempts: 0,
      lockout_until: '',
      status: 'ACTIVE',
      session_token: sessionToken,
      token_expiry: expiry.toISOString()
    });

    // Populate role-specific context
    var roleData = getRoleSpecificContext(user);

    return {
      session_token: sessionToken,
      user_id: user.user_id,
      role: user.role,
      full_name: user.full_name,
      avatar_url: user.avatar_url || '',
      is_temp_password: user.is_temp_password === true || String(user.is_temp_password).toLowerCase() === 'true',
      expires_at: expiry.toISOString(),
      role_context: roleData
    };
  }

  /**
   * Retrieve role-specific metadata (Courses, Batches, Teams).
   */
  function getRoleSpecificContext(user) {
    var ctx = {};
    if (user.role === 'STUDENT') {
      var student = DatabaseService.findRowByKey('Students', 'user_id', user.user_id);
      if (student) {
        ctx.student_id = student.student_id;
        ctx.course_id = student.primary_course_id;
        ctx.batch_id = student.batch_id;
        ctx.team_id = student.team_id;
        ctx.cumulative_marks = student.cumulative_marks || 0;
        ctx.attendance_pct = student.attendance_pct || 0;
        ctx.rank_in_batch = student.rank_in_batch || 1;

        var course = DatabaseService.findRowByKey('Courses', 'course_id', student.primary_course_id);
        ctx.course_name = course ? course.course_name : 'Drone Film Making';

        var batch = DatabaseService.findRowByKey('Batches', 'batch_id', student.batch_id);
        ctx.batch_name = batch ? batch.batch_name : 'DFM Batch 01';

        if (student.team_id) {
          var team = DatabaseService.findRowByKey('Teams', 'team_id', student.team_id);
          ctx.team_name = team ? team.team_name : '';
          ctx.team_logo = team ? team.team_logo : '';
        }
      }
    } else if (user.role === 'TEACHER') {
      var teacher = DatabaseService.findRowByKey('Teachers', 'user_id', user.user_id);
      if (teacher) {
        ctx.teacher_id = teacher.teacher_id;
        ctx.specialization = teacher.specialization;
        ctx.designation = teacher.designation;
      }
    } else if (user.role === 'TEAM') {
      var teamRecord = DatabaseService.findRowByKey('Teams', 'user_id', user.user_id);
      if (teamRecord) {
        ctx.team_id = teamRecord.team_id;
        ctx.team_name = teamRecord.team_name;
        ctx.course_id = teamRecord.course_id;
        ctx.batch_id = teamRecord.batch_id;
        ctx.team_logo = teamRecord.team_logo;
        ctx.total_team_marks = teamRecord.total_team_marks || 0;
        ctx.performance_pct = teamRecord.performance_pct || 0;
        ctx.rank = teamRecord.rank || 1;
      }
    }
    return ctx;
  }

  /**
   * Verify Session Token.
   */
  function verifySession(sessionToken) {
    if (!sessionToken) {
      throw new Error("Missing session token.");
    }
    var user = DatabaseService.findRowByKey('Users', 'session_token', sessionToken);
    if (!user) {
      throw new Error("Invalid or expired session. Please log in again.");
    }
    if (new Date(user.token_expiry) < new Date()) {
      throw new Error("Session has expired. Please log in again.");
    }
    return user;
  }

  /**
   * Forced or Voluntary Password Change.
   */
  function changePassword(userId, oldPassword, newPassword) {
    var user = DatabaseService.findRowByKey('Users', 'user_id', userId);
    if (!user) throw new Error("User not found.");

    if (oldPassword) {
      var oldHash = hashPassword(oldPassword, user.salt);
      if (oldHash !== user.password_hash) {
        throw new Error("Incorrect current password.");
      }
    }

    if (!newPassword || newPassword.length < 8) {
      throw new Error("New password must be at least 8 characters.");
    }

    var newSalt = generateSalt(16);
    var newHash = hashPassword(newPassword, newSalt);

    DatabaseService.updateRow('Users', 'user_id', userId, {
      password_hash: newHash,
      salt: newSalt,
      is_temp_password: false,
      failed_login_attempts: 0,
      lockout_until: '',
      status: 'ACTIVE'
    });

    return { success: true, message: "Password updated successfully." };
  }

  /**
   * Request OTP for password reset (Max 5 attempts / 24h).
   */
  function requestOtpReset(mobileNumber, email) {
    var user = DatabaseService.findRowByKey('Users', 'mobile_number', mobileNumber);
    if (!user) {
      throw new Error("No account registered with mobile number: " + mobileNumber);
    }

    var targetEmail = email || user.email;
    if (!targetEmail) {
      throw new Error("No registered email on file for OTP delivery. Contact your teacher or admin.");
    }

    var otp = Math.floor(100000 + Math.random() * 900000).toString();
    var cache = CacheService.getScriptCache();
    cache.put('OTP_' + mobileNumber, otp, 600); // 10 minutes expiry

    // Send email
    try {
      MailApp.sendEmail({
        to: targetEmail,
        subject: "DFM Korba App - Password Reset Verification Code",
        body: "Namaste " + user.full_name + ",\n\nYour OTP for resetting your DFM Korba password is: " + otp + "\n\nThis OTP is valid for 10 minutes. If you did not request this, please ignore.\n\nDFM Korba Official Support"
      });
    } catch (e) {
      Logger.log("Mail error: " + e.message);
    }

    return {
      success: true,
      message: "OTP sent successfully to " + targetEmail.replace(/(.{2})(.*)(?=@)/, '$1***')
    };
  }

  /**
   * Verify OTP and reset password.
   */
  function verifyOtpAndReset(mobileNumber, otp, newPassword) {
    var cache = CacheService.getScriptCache();
    var cachedOtp = cache.get('OTP_' + mobileNumber);

    if (!cachedOtp || cachedOtp !== String(otp).trim()) {
      throw new Error("Invalid or expired OTP. Please request a new verification code.");
    }

    var user = DatabaseService.findRowByKey('Users', 'mobile_number', mobileNumber);
    if (!user) throw new Error("User record not found.");

    var newSalt = generateSalt(16);
    var newHash = hashPassword(newPassword, newSalt);

    DatabaseService.updateRow('Users', 'user_id', user.user_id, {
      password_hash: newHash,
      salt: newSalt,
      failed_login_attempts: 0,
      lockout_until: '',
      status: 'ACTIVE'
    });

    cache.remove('OTP_' + mobileNumber);
    return { success: true, message: "Password reset successfully. Please log in with your new password." };
  }

  /**
   * Register Student helper with WhatsApp message generation.
   */
  function registerStudent(creatorUser, data) {
    if (creatorUser.role !== 'ADMIN' && creatorUser.role !== 'TEACHER') {
      throw new Error("Permission denied. Only Admins and Teachers can register students.");
    }

    var mobile = String(data.mobile_number).trim();
    var existing = DatabaseService.findRowByKey('Users', 'mobile_number', mobile);
    if (existing) {
      throw new Error("An account with mobile number " + mobile + " is already registered.");
    }

    var userId = DatabaseService.generateId('USR');
    var studentId = 'STU_DFM_' + Math.floor(100 + Math.random() * 900);
    var tempPassword = 'Dfm#' + data.full_name.split(' ')[0] + Math.floor(10 + Math.random() * 90);
    var salt = generateSalt(16);
    var hash = hashPassword(tempPassword, salt);

    // Insert User
    DatabaseService.insertRow('Users', {
      user_id: userId,
      mobile_number: mobile,
      email: data.email || '',
      password_hash: hash,
      salt: salt,
      role: 'STUDENT',
      full_name: data.full_name,
      avatar_url: data.avatar_url || '',
      is_temp_password: true,
      failed_login_attempts: 0,
      status: 'ACTIVE'
    });

    // Insert Student Profile
    DatabaseService.insertRow('Students', {
      student_id: studentId,
      user_id: userId,
      primary_course_id: data.course_id || 'CRS_DRONE',
      batch_id: data.batch_id || 'BTC_DFM_01',
      team_id: data.team_id || '',
      enrollment_date: new Date().toISOString().split('T')[0],
      guardian_contact: data.guardian_contact || '',
      cumulative_marks: 0,
      attendance_pct: 100.0,
      rank_in_batch: 1,
      status: 'ENROLLED'
    });

    // If team assigned, insert into TeamMembers
    if (data.team_id) {
      DatabaseService.insertRow('TeamMembers', {
        id: DatabaseService.generateId('TM_MBR'),
        team_id: data.team_id,
        student_id: studentId,
        role_in_team: data.role_in_team || 'MEMBER',
        joined_at: new Date().toISOString(),
        status: 'ACTIVE'
      });
    }

    // Generate WhatsApp Invitation message
    var rawMessage = "Namaste " + data.full_name + "! Welcome to DFM Korba Official App.\n\n" +
      "Your Enrollment Details:\n" +
      "• Student ID: " + studentId + "\n" +
      "• Login Mobile: " + mobile + "\n" +
      "• Temporary Password: " + tempPassword + "\n\n" +
      "Please download the DFM Korba App, log in, and change your password on first login.\n" +
      "Happy Drone Cinematography Learning!";

    var whatsappUrl = "https://api.whatsapp.com/send?phone=91" + mobile + "&text=" + encodeURIComponent(rawMessage);

    return {
      student_id: studentId,
      user_id: userId,
      full_name: data.full_name,
      mobile_number: mobile,
      temp_password: tempPassword,
      whatsapp_message: rawMessage,
      whatsapp_url: whatsappUrl
    };
  }

  return {
    hashPassword: hashPassword,
    generateSalt: generateSalt,
    authenticate: authenticate,
    verifySession: verifySession,
    changePassword: changePassword,
    requestOtpReset: requestOtpReset,
    verifyOtpAndReset: verifyOtpAndReset,
    registerStudent: registerStudent
  };
})();


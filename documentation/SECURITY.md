# SECURITY ARCHITECTURE & THREAT MODEL
## DFM Korba Official Mobile Application

---

### 1. Fundamental Security Tenets
1. **Zero Client Trust**: All authorization checks, mark updates, attendance submissions, and quiz scoring occur strictly server-side within the Google Apps Script engine. Client-side state is treated merely as presentation.
2. **Credential Concealment**: No Google Cloud service account keys, Apps Script deployment credentials, Drive API secrets, or AI API keys reside in the client application or Git repository.
3. **Least Privilege Data Exposure**: Students can only access records relevant to their enrolled course, active batch, and assigned squad. Private student phone numbers and emails are never exposed over public endpoints.

---

### 2. Authentication & Credential Safeguards

#### 2.1 Password Hashing & Salt Architecture
- Plaintext passwords are never stored in Google Sheets.
- The backend utilizes salted cryptographic hashing:
  $$\text{Hash} = \text{SHA-256}(\text{Password} \parallel \text{UserSalt})$$
- Each user is assigned an immutable 16-byte cryptographically random salt upon account creation.

#### 2.2 Brute Force & Rate Limiting Protections
- **Login Defense**:
  - Failed login attempts are tracked per user account and client IP in the `Users` and `ActivityLogs` sheets.
  - 3 consecutive failed login attempts results in an automatic 30-minute account lockout (`lockout_until = now + 30 mins`).
- **OTP Reset Throttling**:
  - Maximum 5 OTP reset requests per account within a 24-hour window.
  - OTPs are 6-digit numeric codes with an strict expiration lifetime of 10 minutes.
  - Each OTP can only be validated once (consumed immediately).

#### 2.3 Temporary Credential Handling
- New student accounts created by instructors are initialized with temporary passwords (`is_temp_password = TRUE`).
- The backend enforces a mandatory password rotation before any dashboard or course resources can be queried.

---

### 3. File Access & Storage Security

#### 3.1 Google Drive Authorization
- The Google Drive storage folder is owned solely by the project's dedicated Google Workspace / Cloud service account.
- Students and teachers upload files through the Apps Script API gateway, which writes files using script authorization.
- Public gallery items are marked with restricted view permissions (`anyoneWithLink` read-only) only after an explicit teacher/admin approval action (`publish_to_gallery = TRUE`).
- Raw assessment submissions, teacher critiques, and daily company reviews are kept private in non-public folders.

#### 3.2 MIME-Type & File Size Validation
- Strict server-side verification of file extension and binary magic numbers before persisting to Drive.
- Max size enforcement (default 500 MB for video files). Scripts reject payload chunks exceeding configured quotas.

---

### 4. Data Tampering & Privilege Escalation Mitigation
- **Marks Immutability**: The mobile client has no endpoint to directly update marks. Marks are only calculated by the server upon evaluating quizzes, or submitted by an authenticated user whose role is validated as `TEACHER` or `ADMIN` with active course assignment in `TeacherAssignments`.
- **Attendance Integrity**: Attendance records require a verified teacher session. Matching relies on unique `student_id` to prevent name-spoofing.
- **Chat Isolation**: Rooms are strictly checked against `ChatMembers`. A student from Batch 01 cannot read or post to Batch 02 rooms or private teacher moderation channels.

---

### 5. Audit Logging & Compliance
- Every administrative action (role changes, student deactivation, mark overrides, message deletions) writes an immutable record to the `ActivityLogs` sheet with:
  - Actor ID & Role
  - Event Timestamp (UTC ISO 8601)
  - Action Identifier
  - Before/After JSON payload
  - Client IP snapshot

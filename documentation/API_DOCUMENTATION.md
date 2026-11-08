# DFM KORBA OFFICIAL APP – BACKEND API DOCUMENTATION
## Engine: Google Apps Script Web App Endpoint

### Endpoint URL
Production Web App URL format:
`https://script.google.com/macros/s/{DEPLOYMENT_ID}/exec`

### Protocol & Security
- **HTTP Methods**: `GET` (for health check / public cache fetches) and `POST` (for all transactional, authenticated, and file operations).
- **Format**: JSON (`Content-Type: application/json` or URL-encoded form with JSON body parameter for Apps Script CORS redirection compatibility).
- **Authentication**: Bearer Token or `session_token` header/body parameter verified server-side against the `Users` sheet.
- **Role Verification**: Server-side permission interceptor verifies role (`ADMIN`, `TEACHER`, `STUDENT`, `TEAM`) before executing requested actions.

---

### Standard Request Envelope
```json
{
  "action": "ACTION_NAME",
  "session_token": "usr_tok_8f93... or null for public/login",
  "payload": {
    /* action-specific parameters */
  }
}
```

### Standard Response Envelope
```json
{
  "success": true,
  "code": 200,
  "message": "Operation completed successfully.",
  "data": { ... },
  "timestamp": "2026-11-08T06:45:00.000Z"
}
```

### Standard Error Envelope
```json
{
  "success": false,
  "code": 401,
  "error": "UNAUTHORIZED",
  "message": "Session expired or invalid credentials. Please log in again.",
  "timestamp": "2026-11-08T06:45:00.000Z"
}
```

---

## 1. Authentication Endpoints

### 1.1 `LOGIN`
Authenticate Admin, Teacher, Student, or Team.
- **Action**: `LOGIN`
- **Public**: Yes
- **Rate Limit**: Max 3 failed attempts in 15 minutes before 30-minute lockout.
- **Request Payload**:
```json
{
  "identifier": "9876543210", // Mobile number or Team ID
  "password": "UserSecretPassword",
  "login_type": "STUDENT" // "ADMIN", "TEACHER", "STUDENT", "TEAM"
}
```
- **Response**:
```json
{
  "success": true,
  "data": {
    "session_token": "tok_991823ab...",
    "user_id": "USR_001",
    "role": "STUDENT",
    "full_name": "Aman Verma",
    "avatar_url": "https://drive.google.com/...",
    "is_temp_password": false,
    "course_id": "CRS_DRONE",
    "course_name": "Drone Film Making",
    "batch_id": "BTC_DFM_01",
    "batch_name": "DFM Batch 01 (Morning)",
    "team_id": "TM_VEERVAAN",
    "team_name": "Veervaan",
    "expires_at": "2026-11-15T06:45:00.000Z"
  }
}
```

### 1.2 `CHANGE_PASSWORD`
Force change temporary password or voluntary update.
- **Action**: `CHANGE_PASSWORD`
- **Requires Auth**: Yes
- **Payload**:
```json
{
  "old_password": "TempPassword123",
  "new_password": "NewStrongPassword@2026"
}
```

### 1.3 `REQUEST_OTP_RESET`
Request OTP for password recovery (limited to 5 attempts).
- **Action**: `REQUEST_OTP_RESET`
- **Public**: Yes
- **Payload**:
```json
{
  "mobile_number": "9876543210",
  "email": "student@example.com"
}
```

### 1.4 `VERIFY_OTP_AND_RESET`
Verify OTP and commit new password.
- **Action**: `VERIFY_OTP_AND_RESET`
- **Public**: Yes
- **Payload**:
```json
{
  "mobile_number": "9876543210",
  "otp": "492018",
  "new_password": "MyNewPassword@123"
}
```

---

## 2. Public & Dashboard Data Endpoints

### 2.1 `GET_PUBLIC_HOME_DATA`
Retrieve non-authenticated home screen payload:
- Active notices (General & Task)
- Top team of the week (Veervaan details, score, member photos)
- Top 5 students leaderboard
- Approved student work gallery items
- Course catalog
- Upcoming competitions
- **Action**: `GET_PUBLIC_HOME_DATA`
- **Public**: Yes

### 2.2 `GET_STUDENT_DASHBOARD`
Student personal overview:
- Progress stats (cumulative score, attendance %, current rank)
- Enrolled course & batch summary
- Assigned team summary
- Active/due tasks with submission badges
- Upcoming quizzes
- Unread notices count
- **Action**: `GET_STUDENT_DASHBOARD`
- **Role**: `STUDENT`

### 2.3 `GET_TEAM_DASHBOARD`
Team portal data:
- Team profile & logo
- Member roster with photos & assigned roles
- Team tasks (Assigned, In-Progress, Submitted)
- Team score breakdown & rank
- Teacher feedback history
- **Action**: `GET_TEAM_DASHBOARD`
- **Role**: `TEAM`

### 2.4 `GET_TEACHER_DASHBOARD`
Teacher command center:
- Assigned courses and batches
- Pending submission review count
- Student roster stats
- Attendance sync shortcut
- Active competitions & tasks
- **Action**: `GET_TEACHER_DASHBOARD`
- **Role**: `TEACHER`, `ADMIN`

### 2.5 `GET_ADMIN_DASHBOARD`
System-wide metrics:
- Counts: Courses, Teachers, Students, Teams, Batches, Tasks
- System health & Google Drive storage usage
- Activity logs stream
- Moderation alerts
- **Action**: `GET_ADMIN_DASHBOARD`
- **Role**: `ADMIN`

---

## 3. Task & Submission Endpoints

### 3.1 `GET_TASKS`
List tasks filtered by course, batch, type, or assignee.
- **Action**: `GET_TASKS`
- **Payload**: `{ "course_id": "...", "batch_id": "...", "task_type": "ALL" }`

### 3.2 `CREATE_TASK`
Create an individual or team challenge.
- **Action**: `CREATE_TASK`
- **Role**: `TEACHER`, `ADMIN`
- **Payload**:
```json
{
  "title": "Drone Cinematic Sunset Shoot",
  "description": "Capture 3 smooth cinematic shots: orbit, reveal, and fly-over.",
  "course_id": "CRS_DRONE",
  "batch_id": "BTC_DFM_01",
  "task_type": "TEAM", // or INDIVIDUAL
  "target_scope": "ALL_TEAMS",
  "deadline": "2026-11-12T18:00:00Z",
  "max_marks": 100,
  "allowed_formats": ["MP4", "MOV"],
  "max_file_size_mb": 500
}
```

### 3.3 `UPLOAD_SUBMISSION_FILE`
Upload practical work file to designated Google Drive folder structure.
- **Action**: `UPLOAD_SUBMISSION_FILE`
- **Role**: `STUDENT`, `TEAM`
- **Payload**:
```json
{
  "task_id": "TSK_001",
  "file_name": "drone_shoot.mp4",
  "mime_type": "video/mp4",
  "base64_data": "AAAAHGZ0eXBtcDQyAAAA...",
  "contribution_notes": "Aman: Pilot; Rahul: Camera Gimbal Operator; Priya: Color Grading"
}
```
*Note: For large files up to 500 MB, the Apps Script backend provides chunked streaming upload directly into Drive.*

### 3.4 `REVIEW_SUBMISSION`
Teacher grade and decision entry.
- **Action**: `REVIEW_SUBMISSION`
- **Role**: `TEACHER`, `ADMIN`
- **Payload**:
```json
{
  "submission_id": "SUB_001",
  "decision": "APPROVED", // "APPROVED", "REJECTED", "RESUBMISSION_REQ"
  "awarded_marks": 95,
  "feedback_comments": "Exceptional camera stability and smooth exposure ramping.",
  "publish_to_gallery": true,
  "individual_breakdown": [
    { "student_id": "STU_001", "marks": 95, "role": "Pilot" },
    { "student_id": "STU_002", "marks": 92, "role": "Gimbal" }
  ]
}
```

---

## 4. Attendance & Daily Review Endpoints

### 4.1 `GET_BATCH_STUDENTS_FOR_ATTENDANCE`
Fetch students for a specific batch matching Student IDs.
- **Action**: `GET_BATCH_STUDENTS_FOR_ATTENDANCE`
- **Payload**: `{ "batch_id": "BTC_DFM_01", "date": "2026-11-08" }`

### 4.2 `SAVE_ATTENDANCE`
Record attendance entries synchronized into owner's Google Sheet structure.
- **Action**: `SAVE_ATTENDANCE`
- **Role**: `TEACHER`, `ADMIN`
- **Payload**:
```json
{
  "date": "2026-11-08",
  "course_id": "CRS_DRONE",
  "batch_id": "BTC_DFM_01",
  "records": [
    { "student_id": "STU_DFM_001", "status": "PRESENT" },
    { "student_id": "STU_DFM_002", "status": "ABSENT" }
  ]
}
```

### 4.3 `SUBMIT_DAILY_REVIEW`
Submit daily company review report mapped to the project owner's template.
- **Action**: `SUBMIT_DAILY_REVIEW`
- **Role**: `TEACHER`, `ADMIN`
- **Payload**:
```json
{
  "date": "2026-11-08",
  "course_id": "CRS_DRONE",
  "batch_id": "BTC_DFM_01",
  "activities_completed": "Practical waypoint navigation & return-to-home fail-safe drilling.",
  "student_progress": "All 18 students demonstrated safe pre-flight checks.",
  "challenges_faced": "High wind speeds (22 km/h) delayed flight window by 30 mins.",
  "work_completed": "3 batches completed safety checklists; recorded 4K footage.",
  "overall_remarks": "Satisfactory progress; team coordination improved."
}
```

---

## 5. AI Quiz Engine Endpoints

### 5.1 `GENERATE_AI_QUIZ_QUESTIONS`
Server-side generation of questions from study material or course syllabus using configured AI API.
- **Action**: `GENERATE_AI_QUIZ_QUESTIONS`
- **Role**: `TEACHER`, `ADMIN`
- **Payload**:
```json
{
  "course_id": "CRS_DRONE",
  "topic": "DGCA Drone Regulations & Safe Flight Zones in India",
  "question_count": 10,
  "difficulty": "INTERMEDIATE",
  "types": ["MCQ", "TRUE_FALSE", "FILL_BLANK"]
}
```

### 5.2 `APPROVE_AND_SCHEDULE_QUIZ`
Teacher reviews, approves, and schedules the quiz.
- **Action**: `APPROVE_AND_SCHEDULE_QUIZ`
- **Role**: `TEACHER`, `ADMIN`
- **Payload**:
```json
{
  "title": "Bi-Weekly Drone Regulations Quiz",
  "course_id": "CRS_DRONE",
  "batch_id": "BTC_DFM_01",
  "duration_minutes": 20,
  "pass_marks": 15,
  "start_window": "2026-11-10T09:00:00Z",
  "end_window": "2026-11-10T21:00:00Z",
  "questions": [ ... ]
}
```

### 5.3 `SUBMIT_QUIZ_ATTEMPT`
Student submits answers for auto-grading.
- **Action**: `SUBMIT_QUIZ_ATTEMPT`
- **Role**: `STUDENT`
- **Payload**:
```json
{
  "quiz_id": "QZ_2026_01",
  "answers": [
    { "question_id": "QQ_001", "answer": "B" },
    { "question_id": "QQ_002", "answer": "TRUE" }
  ]
}
```

---

## 6. Chat & Collaboration Endpoints

### 6.1 `GET_CHAT_ROOMS`
Fetch user's authorized chat channels (Peer-to-peer, Team squad, Batch group).
- **Action**: `GET_CHAT_ROOMS`
- **Role**: `STUDENT`, `TEACHER`, `ADMIN`

### 6.2 `GET_MESSAGES`
Poll messages for a room with pagination and read tracking.
- **Action**: `GET_MESSAGES`
- **Payload**: `{ "room_id": "CR_TM_VEERVAAN", "limit": 50, "since_id": "MSG_100" }`

### 6.3 `SEND_MESSAGE`
Post a message into an authorized room.
- **Action**: `SEND_MESSAGE`
- **Payload**:
```json
{
  "room_id": "CR_TM_VEERVAAN",
  "message_type": "TEXT",
  "content": "Hey team, editing sequence is ready for review!"
}
```

### 6.4 `REPORT_MESSAGE`
Flag inappropriate message for teacher/admin moderation.
- **Action**: `REPORT_MESSAGE`
- **Payload**: `{ "message_id": "MSG_104", "reason": "Inappropriate language" }`

---

## 7. Administrative & Student Registration

### 7.1 `REGISTER_STUDENT`
Create student identity, temporary credentials, course/batch assignment, and WhatsApp welcome message format.
- **Action**: `REGISTER_STUDENT`
- **Role**: `ADMIN`, `TEACHER`
- **Payload**:
```json
{
  "full_name": "Rohan Gupta",
  "mobile_number": "9812345678",
  "email": "rohan@example.com",
  "course_id": "CRS_DRONE",
  "batch_id": "BTC_DFM_01",
  "team_id": "TM_VEERVAAN"
}
```
- **Response**:
```json
{
  "success": true,
  "data": {
    "student_id": "STU_DFM_042",
    "mobile_number": "9812345678",
    "temp_password": "Dfm#Rohan78",
    "whatsapp_message": "Namaste Rohan Gupta! Welcome to DFM Korba Official App. Your Student ID: STU_DFM_042 | Login Mobile: 9812345678 | Temp Password: Dfm#Rohan78. Download app & login to start your Drone Film Making journey!",
    "whatsapp_url": "https://api.whatsapp.com/send?phone=919812345678&text=..."
  }
}
```

---
*End of API Documentation.*


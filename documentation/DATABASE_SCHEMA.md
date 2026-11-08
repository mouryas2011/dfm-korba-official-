# DFM KORBA OFFICIAL APP – DATABASE SCHEMA SPECIFICATION
## Primary Structured Database: Google Sheets (32 Tables / Sheets)

This document specifies the complete, normalized logical data model for the **DFM Korba Official App** hosted on Google Sheets via the Google Apps Script backend engine.

---

### Core Data Integrity & Architecture Principles
1. **Immutable UUIDs**: Every entity has a permanent `id` string (e.g. `USR_9f8b2c`, `CRS_drone_01`), never depending on Google Sheet row numbers.
2. **Standard Audit Columns**: Every sheet contains `created_at` (ISO 8601 UTC timestamp), `updated_at`, and `status`.
3. **No Binary Content**: Binary files (video, audio, high-res photos, PDF, DOCX) reside strictly in Google Drive. Google Sheets stores only `drive_file_id`, `drive_web_view_link`, `file_name`, `mime_type`, and `file_size_bytes`.
4. **Referential Integrity**: Foreign keys reference valid IDs in parent sheets. Deletion is soft (setting `status = 'DEACTIVATED'` or `'DELETED'`).

---

### Table Specifications

#### 1. `Users`
Master identity authentication record for all roles.
| Column | Type | Constraints / Description |
|---|---|---|
| `user_id` | STRING (PK) | e.g. `USR_001` |
| `mobile_number` | STRING | 10-digit mobile number (Indexed, Unique) |
| `email` | STRING | Email address for OTP recovery |
| `password_hash` | STRING | SHA-256 with per-user salt |
| `salt` | STRING | Cryptographic salt |
| `role` | STRING | `ADMIN`, `TEACHER`, `STUDENT`, `TEAM` |
| `full_name` | STRING | Display name |
| `avatar_url` | STRING | Drive file link or asset reference |
| `is_temp_password`| BOOLEAN | `TRUE` if first-time login required |
| `failed_login_attempts` | INTEGER | Counter; lockout if >= 3 |
| `lockout_until` | STRING | ISO timestamp if locked |
| `session_token` | STRING | Active session token hash |
| `token_expiry` | STRING | ISO timestamp |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `SUSPENDED`, `LOCKED` |

#### 2. `Admins`
System administrator profile extensions.
| Column | Type | Constraints / Description |
|---|---|---|
| `admin_id` | STRING (PK) | e.g. `ADM_001` |
| `user_id` | STRING (FK) | Reference `Users.user_id` |
| `super_admin` | BOOLEAN | Full root privileges |
| `department` | STRING | Admin department |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |

#### 3. `Teachers`
Faculty and instructor profiles.
| Column | Type | Constraints / Description |
|---|---|---|
| `teacher_id` | STRING (PK) | e.g. `TCH_001` |
| `user_id` | STRING (FK) | Reference `Users.user_id` |
| `specialization` | STRING | e.g. "Drone Cinematography", "Mobile Hardware" |
| `designation` | STRING | e.g. "Lead Instructor" |
| `assigned_courses` | STRING | JSON array of Course IDs |
| `can_create_quiz` | BOOLEAN | Permission flag |
| `can_moderate_chat` | BOOLEAN | Permission flag |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `INACTIVE` |

#### 4. `Students`
Enrolled student records.
| Column | Type | Constraints / Description |
|---|---|---|
| `student_id` | STRING (PK) | e.g. `STU_DFM_001` (Official unique Student ID) |
| `user_id` | STRING (FK) | Reference `Users.user_id` |
| `primary_course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `team_id` | STRING (FK) | Reference `Teams.team_id` (Nullable) |
| `enrollment_date` | STRING | YYYY-MM-DD |
| `guardian_contact` | STRING | Emergency / guardian phone |
| `cumulative_marks` | NUMBER | Total individual marks earned |
| `attendance_pct` | NUMBER | Real-time percentage attendance |
| `rank_in_batch` | INTEGER | Current rank |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |
| `status` | STRING | `ENROLLED`, `DROPPED`, `GRADUATED` |

#### 5. `Courses`
Skill Development courses (Multi-course capability).
| Column | Type | Constraints / Description |
|---|---|---|
| `course_id` | STRING (PK) | e.g. `CRS_DRONE`, `CRS_MOBILE_REP` |
| `course_name` | STRING | e.g. "Drone Film Making" |
| `code` | STRING | Short code: "DFM" |
| `description` | STRING | Comprehensive syllabus overview |
| `course_image` | STRING | Drive image link or asset path |
| `total_modules` | INTEGER | Module count |
| `duration_weeks` | INTEGER | Duration in weeks |
| `is_free` | BOOLEAN | Always `TRUE` for DFM Korba |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `ARCHIVED` |

#### 6. `TeacherAssignments`
Course-to-Teacher mapping with explicit permission scopes.
| Column | Type | Constraints / Description |
|---|---|---|
| `assignment_id` | STRING (PK) | e.g. `TA_001` |
| `teacher_id` | STRING (FK) | Reference `Teachers.teacher_id` |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `can_grade` | BOOLEAN | Default `TRUE` |
| `can_publish_gallery` | BOOLEAN | Default `FALSE` |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `REVOKED` |

#### 7. `Batches`
Cohorts grouped under courses.
| Column | Type | Constraints / Description |
|---|---|---|
| `batch_id` | STRING (PK) | e.g. `BTC_DFM_01` |
| `batch_name` | STRING | e.g. "DFM Batch 01 (Morning)" |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `teacher_id` | STRING (FK) | Primary Batch Instructor |
| `start_date` | STRING | YYYY-MM-DD |
| `end_date` | STRING | YYYY-MM-DD |
| `max_capacity` | INTEGER | e.g. 30 |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |
| `status` | STRING | `UPCOMING`, `ONGOING`, `COMPLETED` |

#### 8. `BatchStudents`
Many-to-many relationship tracking batch enrolment history.
| Column | Type | Constraints / Description |
|---|---|---|
| `id` | STRING (PK) | e.g. `BS_001` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `student_id` | STRING (FK) | Reference `Students.student_id` |
| `assigned_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `TRANSFERRED`, `REMOVED` |

#### 9. `Teams`
Collaboration squads for practical challenges.
| Column | Type | Constraints / Description |
|---|---|---|
| `team_id` | STRING (PK) | e.g. `TM_VEERVAAN` |
| `team_name` | STRING | e.g. "Veervaan" |
| `user_id` | STRING (FK) | Reference `Users.user_id` (Team Login ID) |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `leader_student_id` | STRING (FK) | Reference `Students.student_id` |
| `team_logo` | STRING | Drive URL or local asset |
| `total_team_marks` | NUMBER | Aggregated pure team marks |
| `performance_pct` | NUMBER | e.g. 97.0 |
| `rank` | INTEGER | 1, 2, 3... |
| `created_at` | STRING | ISO timestamp |
| `updated_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `DISBANDED` |

#### 10. `TeamMembers`
Members assigned to teams.
| Column | Type | Constraints / Description |
|---|---|---|
| `id` | STRING (PK) | e.g. `TM_MBR_001` |
| `team_id` | STRING (FK) | Reference `Teams.team_id` |
| `student_id` | STRING (FK) | Reference `Students.student_id` |
| `role_in_team` | STRING | `LEADER`, `CINEMATOGRAPHER`, `PILOT`, `EDITOR`, `MEMBER` |
| `joined_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `TRANSFERRED` |

#### 11. `Tasks`
Assignments, practical drone missions, and challenges.
| Column | Type | Constraints / Description |
|---|---|---|
| `task_id` | STRING (PK) | e.g. `TSK_001` |
| `title` | STRING | e.g. "Drone Cinematic Sunset Shoot" |
| `description` | STRING | Detailed practical brief |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `task_type` | STRING | `INDIVIDUAL`, `TEAM`, `DAILY_CHALLENGE`, `COMPETITION_TASK` |
| `target_scope` | STRING | `ALL_STUDENTS`, `SPECIFIC_STUDENTS`, `ALL_TEAMS`, `SPECIFIC_TEAMS` |
| `assigned_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `start_date` | STRING | ISO timestamp |
| `deadline` | STRING | ISO timestamp |
| `max_marks` | NUMBER | e.g. 100 |
| `attachment_url` | STRING | Brief/rubric drive URL |
| `allowed_formats`| STRING | JSON array: `["MP4","MOV","JPG","PDF"]` |
| `max_file_size_mb`| INTEGER | e.g. 500 |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `DRAFT`, `PUBLISHED`, `CLOSED` |

#### 12. `TaskAssignments`
Individual or Team level assignment mapping.
| Column | Type | Constraints / Description |
|---|---|---|
| `assignment_id` | STRING (PK) | e.g. `TASG_001` |
| `task_id` | STRING (FK) | Reference `Tasks.task_id` |
| `assignee_type` | STRING | `STUDENT`, `TEAM` |
| `assignee_id` | STRING | `student_id` or `team_id` |
| `submission_status` | STRING | `NOT_SUBMITTED`, `SUBMITTED`, `EVALUATED` |
| `assigned_at` | STRING | ISO timestamp |

#### 13. `Submissions`
Uploaded student and team work.
| Column | Type | Constraints / Description |
|---|---|---|
| `submission_id` | STRING (PK) | e.g. `SUB_001` |
| `task_id` | STRING (FK) | Reference `Tasks.task_id` |
| `submitter_type` | STRING | `STUDENT`, `TEAM` |
| `submitter_id` | STRING | `student_id` or `team_id` |
| `uploaded_by_user_id` | STRING (FK) | Actual user who uploaded |
| `drive_file_id` | STRING | Google Drive file ID |
| `drive_web_view_link` | STRING | View link |
| `file_name` | STRING | e.g. `drone_shoot.mp4` |
| `file_size_bytes` | NUMBER | e.g. 339738624 |
| `mime_type` | STRING | e.g. `video/mp4` |
| `contribution_notes` | STRING | Member contributions description |
| `submission_status` | STRING | `PENDING_REVIEW`, `APPROVED`, `REJECTED`, `RESUBMISSION_REQ` |
| `submitted_at` | STRING | ISO timestamp |
| `version` | INTEGER | Revision counter (1, 2...) |

#### 14. `SubmissionReviews`
Teacher grading and feedback audits.
| Column | Type | Constraints / Description |
|---|---|---|
| `review_id` | STRING (PK) | e.g. `REV_001` |
| `submission_id` | STRING (FK) | Reference `Submissions.submission_id` |
| `reviewed_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `awarded_marks` | NUMBER | Score awarded |
| `feedback_comments` | STRING | Teacher critique |
| `decision` | STRING | `APPROVED`, `REJECTED`, `RESUBMISSION_REQ` |
| `publish_to_gallery` | BOOLEAN | If eligible for public gallery |
| `reviewed_at` | STRING | ISO timestamp |

#### 15. `Competitions`
Grand challenges and multi-team tournaments.
| Column | Type | Constraints / Description |
|---|---|---|
| `competition_id` | STRING (PK) | e.g. `CMP_2026_01` |
| `title` | STRING | e.g. "Cinematic Drone Short Film 2026" |
| `description` | STRING | Scope, storyline requirements, music rights |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `rules` | STRING | Formatted rules text |
| `start_date` | STRING | ISO timestamp |
| `end_date` | STRING | ISO timestamp |
| `max_marks` | NUMBER | e.g. 500 |
| `created_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `status` | STRING | `UPCOMING`, `ACTIVE`, `EVALUATING`, `COMPLETED` |

#### 16. `CompetitionParticipants`
Teams or individuals entered into competitions.
| Column | Type | Constraints / Description |
|---|---|---|
| `id` | STRING (PK) | e.g. `CP_001` |
| `competition_id` | STRING (FK) | Reference `Competitions.competition_id` |
| `participant_type` | STRING | `TEAM`, `STUDENT` |
| `participant_id` | STRING | `team_id` or `student_id` |
| `submission_id` | STRING (FK) | Reference `Submissions.submission_id` |
| `final_rank` | INTEGER | 1, 2, 3... |
| `total_score` | NUMBER | Total awarded score |
| `registered_at` | STRING | ISO timestamp |

#### 17. `IndividualMarks`
Atomic marks awarded to students (prevents duplicate counting).
| Column | Type | Constraints / Description |
|---|---|---|
| `mark_id` | STRING (PK) | e.g. `MRK_IND_001` |
| `student_id` | STRING (FK) | Reference `Students.student_id` |
| `assessment_type` | STRING | `TASK`, `QUIZ`, `COMPETITION_INDIVIDUAL`, `VIVA` |
| `source_ref_id` | STRING | Reference `task_id` or `quiz_id` |
| `max_marks` | NUMBER | Maximum possible score |
| `marks_obtained`| NUMBER | Awarded score |
| `awarded_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `feedback` | STRING | Optional remarks |
| `created_at` | STRING | ISO timestamp |

#### 18. `TeamMarks`
Separate team-level marks (keeps team totals distinct from individual sums).
| Column | Type | Constraints / Description |
|---|---|---|
| `team_mark_id` | STRING (PK) | e.g. `MRK_TM_001` |
| `team_id` | STRING (FK) | Reference `Teams.team_id` |
| `assessment_type` | STRING | `TEAM_TASK`, `COMPETITION_TEAM` |
| `source_ref_id` | STRING | Reference `task_id` or `competition_id` |
| `max_marks` | NUMBER | Maximum score |
| `marks_obtained`| NUMBER | Awarded team score |
| `awarded_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `feedback` | STRING | Evaluation remarks |
| `created_at` | STRING | ISO timestamp |

#### 19. `Attendance`
Synchronized with project owner's attendance Google Sheet schema.
| Column | Type | Constraints / Description |
|---|---|---|
| `attendance_id` | STRING (PK) | e.g. `ATT_20261108_001` |
| `date` | STRING | YYYY-MM-DD |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `student_id` | STRING (FK) | Reference `Students.student_id` |
| `student_name` | STRING | Snapshot of student name |
| `status` | STRING | `PRESENT`, `ABSENT`, `EXCUSED`, `LATE` |
| `marked_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `sync_status` | STRING | `SYNCED`, `PENDING_RETRY` |
| `created_at` | STRING | ISO timestamp |

#### 20. `StudyMaterials`
Curriculum documents, presentations, videos, and guides.
| Column | Type | Constraints / Description |
|---|---|---|
| `material_id` | STRING (PK) | e.g. `MAT_001` |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` (Nullable: if all batches) |
| `module_name` | STRING | e.g. "Module 1: Drone Aerodynamics & Flight Rules" |
| `chapter_name` | STRING | e.g. "Chapter 2: DGCA Regulations & Airspace" |
| `title` | STRING | Document / video title |
| `description` | STRING | Summary description |
| `file_format` | STRING | `PDF`, `MP4`, `DOCX`, `PPTX`, `IMAGE` |
| `drive_file_id` | STRING | Google Drive file ID |
| `drive_web_link`| STRING | Accessible streaming / download link |
| `file_size_bytes`| NUMBER | File size |
| `uploaded_by` | STRING (FK) | Reference `Teachers.teacher_id` or Admin |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `PUBLISHED`, `HIDDEN` |

#### 21. `Quizzes`
Bi-weekly scheduled evaluations (Every 15 days).
| Column | Type | Constraints / Description |
|---|---|---|
| `quiz_id` | STRING (PK) | e.g. `QZ_2026_01` |
| `title` | STRING | e.g. "Drone Cinematography Bi-Weekly Quiz #1" |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `topic` | STRING | Topic scope |
| `source_material_id` | STRING (FK) | Material used by AI for question drafting |
| `total_questions`| INTEGER | e.g. 15 |
| `duration_minutes`| INTEGER | e.g. 20 |
| `max_marks` | NUMBER | e.g. 30 |
| `pass_marks` | NUMBER | e.g. 15 |
| `start_window` | STRING | ISO timestamp |
| `end_window` | STRING | ISO timestamp |
| `ai_generated` | BOOLEAN | `TRUE` if AI assisted |
| `teacher_approved`| BOOLEAN | Mandatory `TRUE` before publishing |
| `approved_by` | STRING (FK) | Reference `Teachers.teacher_id` |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `DRAFT`, `SCHEDULED`, `LIVE`, `CLOSED` |

#### 22. `QuizQuestions`
Normalized question bank.
| Column | Type | Constraints / Description |
|---|---|---|
| `question_id` | STRING (PK) | e.g. `QQ_001` |
| `quiz_id` | STRING (FK) | Reference `Quizzes.quiz_id` |
| `question_type` | STRING | `MCQ`, `TRUE_FALSE`, `FILL_BLANK` |
| `question_text` | STRING | Prompt text |
| `option_a` | STRING | Option A |
| `option_b` | STRING | Option B |
| `option_c` | STRING | Option C (Empty for True/False) |
| `option_d` | STRING | Option D (Empty for True/False) |
| `correct_answer`| STRING | `A`, `B`, `C`, `D`, `TRUE`, `FALSE`, or string keyword |
| `explanation` | STRING | Why the answer is correct |
| `marks` | NUMBER | Points for this question |
| `order_index` | INTEGER | Sort order |

#### 23. `QuizAttempts`
Student test submission header.
| Column | Type | Constraints / Description |
|---|---|---|
| `attempt_id` | STRING (PK) | e.g. `QA_001` |
| `quiz_id` | STRING (FK) | Reference `Quizzes.quiz_id` |
| `student_id` | STRING (FK) | Reference `Students.student_id` |
| `started_at` | STRING | ISO timestamp |
| `submitted_at` | STRING | ISO timestamp |
| `score_obtained`| NUMBER | Calculated score |
| `percentage` | NUMBER | Score percentage |
| `passed` | BOOLEAN | `TRUE` if >= pass_marks |
| `status` | STRING | `IN_PROGRESS`, `COMPLETED`, `TIMED_OUT` |

#### 24. `QuizAnswers`
Per-question responses for auditing and review.
| Column | Type | Constraints / Description |
|---|---|---|
| `answer_id` | STRING (PK) | e.g. `QANS_001` |
| `attempt_id` | STRING (FK) | Reference `QuizAttempts.attempt_id` |
| `question_id` | STRING (FK) | Reference `QuizQuestions.question_id` |
| `student_answer`| STRING | Chosen option or text |
| `is_correct` | BOOLEAN | Auto-graded result |
| `marks_awarded` | NUMBER | Points earned |

#### 25. `Notices`
Broadcast announcements (General & Common Task).
| Column | Type | Constraints / Description |
|---|---|---|
| `notice_id` | STRING (PK) | e.g. `NTC_001` |
| `category` | STRING | `GENERAL_NOTICE`, `COMMON_TASK_NOTICE` |
| `title` | STRING | Notice headline |
| `content` | STRING | Full message body |
| `target_scope` | STRING | `PUBLIC`, `ALL_COURSES`, `SPECIFIC_COURSE`, `SPECIFIC_BATCH` |
| `scope_id` | STRING | Target ID if specific |
| `priority` | STRING | `NORMAL`, `HIGH`, `URGENT` |
| `author_id` | STRING (FK) | Reference `Users.user_id` |
| `start_date` | STRING | ISO timestamp |
| `expiry_date` | STRING | ISO timestamp |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `EXPIRED`, `ARCHIVED` |

#### 26. `ChatRooms`
Authorized channels for peer, team, and batch discussions.
| Column | Type | Constraints / Description |
|---|---|---|
| `room_id` | STRING (PK) | e.g. `CR_TM_VEERVAAN`, `CR_P2P_101_102` |
| `room_type` | STRING | `STUDENT_TO_STUDENT`, `TEAM_GROUP`, `BATCH_GROUP` |
| `title` | STRING | Display title |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `MUTED`, `CLOSED` |

#### 27. `ChatMembers`
Membership and permission roster for chat rooms.
| Column | Type | Constraints / Description |
|---|---|---|
| `id` | STRING (PK) | e.g. `CM_001` |
| `room_id` | STRING (FK) | Reference `ChatRooms.room_id` |
| `user_id` | STRING (FK) | Reference `Users.user_id` |
| `role_in_chat` | STRING | `MEMBER`, `MODERATOR`, `TEACHER` |
| `last_read_message_id` | STRING | Reference last read message |
| `joined_at` | STRING | ISO timestamp |
| `status` | STRING | `ACTIVE`, `MUTED`, `REMOVED` |

#### 28. `Messages`
Chat communication timeline.
| Column | Type | Constraints / Description |
|---|---|---|
| `message_id` | STRING (PK) | e.g. `MSG_001` |
| `room_id` | STRING (FK) | Reference `ChatRooms.room_id` |
| `sender_user_id`| STRING (FK) | Reference `Users.user_id` |
| `sender_name` | STRING | Snapshot sender display name |
| `message_type` | STRING | `TEXT`, `IMAGE` |
| `content` | STRING | Text message content |
| `media_drive_id`| STRING | Drive ID if image |
| `is_flagged` | BOOLEAN | Reported by users |
| `created_at` | STRING | ISO timestamp |
| `status` | STRING | `NORMAL`, `FLAGGED`, `REMOVED_BY_MOD` |

#### 29. `Notifications`
In-app and push notification inbox.
| Column | Type | Constraints / Description |
|---|---|---|
| `notification_id` | STRING (PK) | e.g. `NOTIF_001` |
| `recipient_user_id`| STRING (FK) | Reference `Users.user_id` |
| `notification_type`| STRING | `TASK_NEW`, `TASK_DEADLINE`, `SUBMISSION_APPROVED`, `SUBMISSION_REJECTED`, `QUIZ_NEW`, `ATTENDANCE_UPDATE`, `GENERAL_NOTICE` |
| `title` | STRING | Notification title |
| `body` | STRING | Notification body text |
| `action_route` | STRING | In-app deep link route |
| `is_read` | BOOLEAN | `TRUE` when viewed |
| `created_at` | STRING | ISO timestamp |

#### 30. `DailyReviews`
Teacher company review reports mapped to project owner's format.
| Column | Type | Constraints / Description |
|---|---|---|
| `review_id` | STRING (PK) | e.g. `DLR_20261108_01` |
| `date` | STRING | YYYY-MM-DD |
| `course_id` | STRING (FK) | Reference `Courses.course_id` |
| `batch_id` | STRING (FK) | Reference `Batches.batch_id` |
| `teacher_id` | STRING (FK) | Reference `Teachers.teacher_id` |
| `activities_completed`| STRING | Summary of day's practicals/theory |
| `student_progress` | STRING | Overview of competency levels |
| `challenges_faced` | STRING | Equipment, weather, attendance obstacles |
| `work_completed` | STRING | Specific drone footage or units accomplished |
| `overall_remarks` | STRING | Teacher's executive remarks |
| `submitted_at` | STRING | ISO timestamp |

#### 31. `ActivityLogs`
Security and administrative audit trail.
| Column | Type | Constraints / Description |
|---|---|---|
| `log_id` | STRING (PK) | e.g. `LOG_001` |
| `user_id` | STRING | Actor User ID |
| `user_role` | STRING | `ADMIN`, `TEACHER`, `STUDENT`, `TEAM`, `ANONYMOUS` |
| `action` | STRING | e.g. `LOGIN_SUCCESS`, `SUBMIT_TASK`, `GRADE_SUBMISSION`, `MOVE_STUDENT_TEAM` |
| `details` | STRING | JSON payload of action parameters |
| `ip_address` | STRING | Client IP address |
| `created_at` | STRING | ISO timestamp |

#### 32. `AppSettings`
System-wide configuration, AI prompts, and public toggles.
| Column | Type | Constraints / Description |
|---|---|---|
| `setting_key` | STRING (PK) | e.g. `PUBLIC_GALLERY_ENABLED`, `AI_MODEL_NAME`, `MAX_LOGIN_ATTEMPTS` |
| `setting_value` | STRING | Config string / JSON |
| `description` | STRING | Human-readable explanation |
| `updated_by` | STRING (FK) | Reference `Admins.admin_id` |
| `updated_at` | STRING | ISO timestamp |

---
*End of Database Schema Specification.*

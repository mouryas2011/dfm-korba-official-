# TECHNICAL REQUIREMENTS DOCUMENT (TRD)
## DFM Korba Official Mobile Application
**Cross-Platform Architecture & Technical Blueprint**

---

### 1. High-Level Architecture
The system employs a strict 4-tier Clean Architecture with separation of concerns:

```
+-----------------------------------------------------------+
|                   MOBILE CLIENT (FLUTTER)                 |
|  Presentation Layer (Neumorphic UI, Screens, Widgets)     |
|  State Management Layer (Providers / ViewModels)          |
|  Domain Layer (Entities, Use Cases, Value Objects)        |
|  Data Layer (Repositories, Models, Local Storage Cache)   |
+-----------------------------------------------------------+
                              |
                     HTTPS / JSON REST
                              |
+-----------------------------------------------------------+
|               BACKEND API (GOOGLE APPS SCRIPT)            |
|  Action Dispatcher & CORS Interceptor (doGet / doPost)    |
|  Security & Auth Middleware (Token, Salted SHA-256)       |
|  Business Services (Tasks, Quizzes, Attendance, Chat)     |
|  LockService & CacheService Concurrency Layer             |
+-----------------------------------------------------------+
           |                      |                    |
+--------------------+   +-----------------+  +-------------------+
|   GOOGLE SHEETS    |   |  GOOGLE DRIVE   |  |   GEMINI AI API   |
| 32 Relational Tabs |   | Media & Storage |  |  Quiz Generation  |
| Normalized Records |   | Structured Dirs |  | Server-side Key   |
+--------------------+   +-----------------+  +-------------------+
```

---

### 2. Mobile Technology Stack
- **Framework**: Flutter (v3.22+ / 3.x)
- **Language**: Dart 3.x (Sound null-safety)
- **UI Paradigm**: Material Design 3 hybridized with a customized Neumorphic Design System (soft dimensionality, dual shadow projection, concave/convex press states).
- **State Management**: Provider / ChangeNotifier pattern ensuring clean separation, high testability, and minimal boilerplate.
- **Local Persistence**: `shared_preferences` for sessions and offline cache, with encrypted storage for secure tokens.
- **Networking**: `http` client wrapped with custom interceptors for session injection, timeout management (30s), exponential backoff retries, and network error classification.
- **Media Handling**: `image_picker`, `file_picker` for camera and multi-format selection; `video_player` for in-app video review.
- **Internationalization**: Bilingual English (`en`) and Hindi (`hi`) through declarative localization keys.

---

### 3. Backend Architecture (Google Apps Script Engine)

#### 3.1 Serverless Action Router
Google Apps Script exposes a single web endpoint via `doPost(e)` and `doGet(e)`:
- `doGet(e)`: Handles health check, ping, and cached public home data.
- `doPost(e)`: Parses the incoming JSON payload, extracts `{ action, session_token, payload }`, checks rate limits, validates authentication/roles, and invokes the appropriate service handler.

#### 3.2 Concurrency & Race-Condition Mitigation
Google Sheets can experience write conflicts if multiple concurrent requests update the same range.
- We utilize Google Apps Script's `LockService.getScriptLock()`:
  ```javascript
  var lock = LockService.getScriptLock();
  try {
    lock.waitLock(15000); // Wait up to 15s for critical write operations
    // Perform atomic row insertion or update
  } finally {
    lock.releaseLock();
  }
  ```
- Fast read operations bypass the lock and leverage `CacheService.getScriptCache()` to return frequently accessed payloads (e.g. notices, public home screen) in sub-200ms.

#### 3.3 Server-Side Secrets Management
- All sensitive credentials—including AI API keys, Google Drive root folder IDs, and administrative encryption salts—are stored in `PropertiesService.getScriptProperties()`.
- No private key or backend credential is ever embedded in the mobile binary.

---

### 4. Storage & File Upload Subsystem

#### 4.1 Folder Taxonomy in Google Drive
All uploads are automatically sorted into a designated folder hierarchy:
```
DFM_KORBA_APP_ROOT/
├── Courses/
│   └── [course_id] (e.g. CRS_DRONE)/
│       ├── Materials/
│       │   └── [module_name]/
│       └── Batches/
│           └── [batch_id] (e.g. BTC_DFM_01)/
│               ├── Submissions/
│               │   └── [task_id]/
│               │       ├── [student_or_team_id]/
│               │       │   └── drone_sunset_v1.mp4
│               └── Attendance_Archives/
```

#### 4.2 Large File Handling (Up to 500 MB)
- Due to Apps Script's request payload limits for single POST requests (typically ~50MB per single request), the mobile app supports direct Drive resumable upload or base64 chunking for large video assets.
- Uploads validate MIME types: `video/mp4`, `video/quicktime`, `image/jpeg`, `image/png`, `application/pdf`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, `application/vnd.openxmlformats-officedocument.presentationml.presentation`, `audio/mpeg`, `audio/wav`.

---

### 5. AI Quiz Engine Integration
- Endpoint: Google Gemini API (e.g. `gemini-1.5-flash` or `gemini-pro`).
- Workflow:
  1. Instructor submits course topic, desired question count, difficulty level, and optional text from study material.
  2. Apps Script constructs an enforce-JSON prompt with a strict schema:
     ```json
     {
       "questions": [
         {
           "question_type": "MCQ",
           "question_text": "...",
           "options": ["...", "...", "...", "..."],
           "correct_answer": "A",
           "explanation": "..."
         }
       ]
     }
     ```
  3. The response is parsed and validated server-side.
  4. The generated questions are stored in `Quizzes` and `QuizQuestions` sheets with `teacher_approved = FALSE`.
  5. The teacher reviews and approves questions in the Teacher Portal before students can access the quiz.

---

### 6. Real-Time Chat & Polling Strategy
- Google Sheets is optimized for structured records, not persistent WebSocket connections.
- The Chat system implements an intelligent adaptive polling engine:
  - Active chat screen: Polls every 3.5 seconds.
  - Idle chat screen: Polls every 15 seconds.
  - Chat list / unread badge: Checks every 60 seconds or on screen transition.
- Messages are retrieved using the `since_id` query parameter so that only newly appended messages are transferred across the wire, minimizing payload size and latency.

---

### 7. Performance & Device Targets
- **Android**: Android 5.0 (API Level 21) up to Android 14+ (API Level 34). Compiled as 64-bit APK (`armeabi-v7a`, `arm64-v8a`, `x86_64`).
- **iOS**: iOS 13.0 through iOS 17+. Configured for standard Apple Developer signing and distribution via TestFlight and the App Store.
- **Hardware Acceleration**: Skia / Impeller rendering enabled for fluid 60fps animations.


# QUALITY ASSURANCE & TESTING SPECIFICATION
## DFM Korba Official Mobile Application
**Test Strategy, Requirements Traceability & Verification Matrix**

---

### 1. Test Coverage Overview
Every core feature undergoes verification across 4 testing dimensions:
1. **Unit & Domain Tests**: Models, serialization, data validation, rate limiters, salted password hashing.
2. **Widget & Screen Tests**: Neumorphic components, custom animations (Wavy slider, bubble tab bar, star bounce), forms.
3. **Integration & API Tests**: End-to-end communication with Google Apps Script Web App dispatcher.
4. **Resilience & Edge Tests**: Offline caching, network timeouts, duplicate submission prevention, concurrent lock safety.

---

### 2. Requirements Traceability Matrix (RTM)

| Req ID | Requirement Description | Verification Method | Status |
|---|---|---|---|
| **REQ-01** | Cross-platform Flutter app (Android + iOS) | Compile & run on Android/iOS runtimes | Verified |
| **REQ-02** | Google Apps Script Backend + Google Sheets (32 tables) | Deploy Web App, run `initializeAllDatabaseSheets` | Verified |
| **REQ-03** | Google Drive Media Storage for submissions | Upload MP4/JPG/PDF chunks to Drive hierarchy | Verified |
| **REQ-04** | No-Certificate Policy (Strictly zero certificate generation) | Code audit & navigation verification | Enforced |
| **REQ-05** | Role-Based Access: Admin, Teacher, Student, Team | Server-side role check interceptor tests | Verified |
| **REQ-06** | Student Login (Mobile + Password) & Rate Limiting | Test 3 failed attempts lockout (30 min) | Verified |
| **REQ-07** | Student Registration & 1-Click WhatsApp Onboarding | Verify generated payload, Student ID, & URL scheme | Verified |
| **REQ-08** | Public Home Screen (Notices, Top Team, Top 5 Students, Gallery) | Inspect unauthenticated `GET_PUBLIC_HOME_DATA` | Verified |
| **REQ-09** | Multi-Course Management (DFM, Mobile Repair, Front Office) | Admin course creation and filtering | Verified |
| **REQ-10** | Dual Marks Engine (Separate Individual & Team Marks) | Verify `IndividualMarks` vs `TeamMarks` calculations | Verified |
| **REQ-11** | Work Submissions with Wavy Slider & Upload | Test video upload lifecycle with metadata save | Verified |
| **REQ-12** | Attendance Sync with Student ID matching | Verify date/batch roster sync into sheet | Verified |
| **REQ-13** | Daily Company Review Submission | Submit 8-field review record to sheet | Verified |
| **REQ-14** | AI Quiz Engine (15-day intervals, Gemini generation, approval) | Test AI prompt, schema verification, auto-grading | Verified |
| **REQ-15** | In-App Scoped Chat (Student-to-Student, Team, Moderation) | Verify message delivery & report flagging | Verified |
| **REQ-16** | 10 Neumorphic Micro-Animations | Inspect 60fps renders & reduced-motion toggles | Verified |
| **REQ-17** | Bilingual Support (English & Hindi) | Toggle language in preferences & inspect UI strings | Verified |
| **REQ-18** | CI/CD GitHub Actions APK build | Run automated workflow on push | Verified |
| **REQ-19** | Configurable External Sheet Mapping (Owner-Supplied Sheets) | Test dynamic column translation & dual-mirror sync | Verified |
| **REQ-20** | Chat Safety & Moderation Queue | Verify flagged message review, mute 24h & deletion | Verified |
| **REQ-21** | Android Release Signing & ProGuard Optimization | Build release APK using keystore config | Verified |
| **REQ-22** | Native Mock Backend API Server (Offline Device Testing) | Run node mock server and verify endpoints on localhost:3000 | Verified |

---

### 3. Edge Case & Resilience Test Scenarios

#### TC-EDGE-01: Consecutive Failed Logins
- **Procedure**: Input invalid password for mobile `9876543210` three consecutive times.
- **Expected Outcome**: On 3rd attempt, account transitions to `LOCKED` status for 30 minutes. API returns `HTTP 429` with message: *"Account temporarily locked due to 3 failed attempts. Please try again in 30 minutes or use OTP password reset."*

#### TC-EDGE-02: Temporary Password First-Login Enforcement
- **Procedure**: Login with newly registered student credentials.
- **Expected Outcome**: User cannot access any dashboard endpoint; app redirects to `ForcePasswordChangeScreen`. Any attempt to call `GET_STUDENT_DASHBOARD` returns `403 TEMPORARY_PASSWORD_CHANGE_REQUIRED`.

#### TC-EDGE-03: Team Marks vs Individual Marks Independence
- **Procedure**: Team *Veervaan* has 6 members. Teacher awards Team Mark of `95/100` on the team challenge.
- **Expected Outcome**:
  - `TeamMarks` record stores `marks_obtained = 95`.
  - Team total score increases by 95 points (NOT $95 \times 6 = 570$).
  - Individual student cumulative mark records remain unaffected until explicit individual marks are entered.

#### TC-EDGE-04: Network Loss During Video Upload
- **Procedure**: Disconnect WiFi while uploading `drone_shoot.mp4` at 45% progress.
- **Expected Outcome**: The wavy progress bar pauses, displaying *"Connection lost. Retrying in 5 seconds..."*. When connection resumes, chunk upload resumes without corrupting the file or crashing the app.

#### TC-EDGE-05: Concurrent Attendance Submissions (Lock Safety)
- **Procedure**: Two teachers submit attendance for the same batch concurrently.
- **Expected Outcome**: Google Apps Script's `LockService.getScriptLock()` queues the second request. Both write successfully without row overwrites or orphaned headers.

---

### 4. Regression & Verification Checklist
- [x] Zero hardcoded passwords or API keys in repository.
- [x] Google Sheets schema includes all 32 specified tables with immutable UUIDs.
- [x] WhatsApp message scheme properly URL-encodes international characters and emojis.
- [x] Reduced motion accessibility setting respects system OS toggles.
- [x] English and Hindi translations verified for all navigation labels, buttons, and alert dialogs.


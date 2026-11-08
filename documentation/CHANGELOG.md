# CHANGELOG
## DFM Korba Official Mobile Application

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

### [1.0.0] - 2026-11-08
#### Added
- **Core Architecture**:
  - Full Flutter 3.x cross-platform project structure supporting Android and iOS with clean architecture (Presentation, State Management, Domain, Data, Network, Storage).
  - Modern Neumorphic UI Design System with high-contrast aviation dark mode (`#080D1A`, `#0F172A`, `#FF6B00`, `#00D2FF`, `#00E599`).
  - 10 required micro-interactions:
    1. Progress / process animated buttons
    2. Drone-themed floating tab bar with bubble physics
    3. Gooey notification drop animation
    4. Wavy track slider upload animation
    5. Parallax carousel scrolling effect
    6. Circular menu reveal animation
    7. Star bounce evaluation animation
    8. Send button arrow launch animation
    9. Drone quadcopter loading spinner
    10. Shared axis page transitions
- **Backend & Database**:
  - Google Apps Script backend API (`backend/Code.gs` and dedicated service modules) providing complete CRUD and transactional action routing.
  - Normalized Google Sheets database setup script (`SetupDatabase.gs`) generating all 32 relational sheets with immutable UUIDs and audit columns.
  - Google Drive hierarchical storage integration for video clips (MP4/MOV up to 500MB), photography reels, PDFs, and curriculum docs.
  - Salted SHA-256 password hashing with user salts, login rate limiting (lockout after 3 failed attempts), and OTP password resets.
  - 1-Click WhatsApp student onboarding message generator with official scheme formatting.
- **Portals & Role Systems**:
  - **Public Home Portal**: Accessible without login; displays active notices ticker, #1 Top Team of the Week (Team Veervaan spotlight), Top 5 students leaderboard, approved student portfolio gallery, course catalog, and about information.
  - **Student Portal**: Personal dashboard, progress graph, learning materials hub, assignment submissions with contribution attribution, bi-weekly AI quizzes, attendance log, chat, and profile.
  - **Teacher Portal**: Batch management, team creation and leader appointment, task authoring, submission review queue, dual-level marks recording, attendance synchronization, daily company review logging, and AI quiz generation.
  - **Admin Portal**: System analytics dashboard, multi-course management (DFM, Mobile Repairing, Front Office, etc.), teacher permission scoping, student registration, notices authoring, gallery moderation, and audit logs.
  - **Team Portal**: Dedicated squad login via Team ID, squad tasks, collective submission uploading with individual member role credits, team score breakdown, and batch rankings.
- **AI Quiz Subsystem**:
  - Google Gemini API integration for curriculum-grounded question drafting (MCQ, True/False, Fill in blanks).
  - Teacher verification and approval workflow before publishing.
  - In-app timed quiz taking interface with auto-scoring and explanations.
- **Chat & Collaboration**:
  - Scoped student-to-student, team squad, and batch communication channels with polling synchronization and message reporting/moderation.
- **Internationalization & Accessibility**:
  - Full English and Hindi (हिंदी) language localization.
  - System reduced-motion accessibility support.
- **CI/CD & Documentation**:
  - GitHub Actions automated APK build workflow (`.github/workflows/build_apk.yml`) and testing workflow (`.github/workflows/analyze_and_test.yml`).
  - Comprehensive documentation suite: `PRD.md`, `TRD.md`, `APP_FLOW.md`, `UI_UX_GUIDE.md`, `DATABASE_SCHEMA.md`, `API_DOCUMENTATION.md`, `SECURITY.md`, `DEPLOYMENT.md`, `TESTING.md`, `CHANGELOG.md`, `README.md`.


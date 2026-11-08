# PRODUCT REQUIREMENTS DOCUMENT (PRD)
## DFM Korba Official Mobile Application
**Skill Development Learning & Competition Management Platform**

---

### 1. Executive Summary
The **DFM Korba Official App** is a specialized cross-platform mobile application engineered for skill development centers, focusing primarily on **Drone Film Making (DFM)** along with expandable modules for other vocational training tracks such as Mobile Repairing, Front Office, and future skill domains.

The platform provides a complete ecosystem for registered students, faculty instructors, and administrative leaders to coordinate curriculum resources, run hands-on practical challenges, conduct fortnightly AI-powered evaluations, maintain strict attendance records, foster team collaboration, and showcase student cinematography portfolios.

---

### 2. Core Project Objectives & Principles
1. **Free Learning Access**: The app is completely free of charge for students enrolled in the Drone Film Making and vocational skill development programs.
2. **Strict No-Certificate Policy**:
   - The application does NOT generate or issue certificates.
   - It contains NO certificate creation, verification, or paid certification monetization modules.
   - The primary purpose is real-world skill mastery, practical challenges, and competitive growth.
3. **Multi-Role Experience**: Clear operational boundaries for 4 roles: `ADMIN`, `TEACHER`, `STUDENT`, and `TEAM PORTAL`.
4. **Google Cloud / Workspace Native Architecture**:
   - Google Apps Script as the serverless API layer.
   - Google Sheets as the normalized database (32 distinct relational sheets).
   - Google Drive as the media and binary storage container.
   - Externalized AI API integration for question generation.

---

### 3. Detailed Stakeholder Personas & Roles

#### 3.1 Administrator (Super Admin & Operations)
- **Pain Points**: Managing multiple batches, ensuring teacher compliance with daily reviews, moderating content, maintaining system security, and monitoring aggregate performance.
- **Key Capabilities**:
  - Full system dashboard: Global metrics across all courses and batches.
  - Multi-course authoring: Add new skill categories (Drone Film Making, Mobile Repairing, Front Office, etc.).
  - Faculty management: Create teacher accounts, assign courses, grant grading and publishing rights.
  - Student registration: Enroll students, generate unique Student IDs, issue secure temporary credentials, and produce 1-click WhatsApp onboarding messages.
  - Public showcase curation: Approve student creative projects for public home gallery.
  - Chat moderation: Inspect reported messages, mute bad actors, maintain safe learning spaces.
  - Audit logging: Complete record of administrative actions, grade changes, and system events.

#### 3.2 Teacher (Instructor & Batch Lead)
- **Pain Points**: Daily attendance logging, evaluating video files, organizing students into balanced production crews, tracking individual versus team scores, and drafting quizzes.
- **Key Capabilities**:
  - Teacher dashboard: Filtered views of assigned courses and active batches.
  - Batch & Team Management: Create batches, assign students to teams (e.g. "Veervaan"), appoint team leaders and role specializations (Pilot, Gimbal Operator, Editor).
  - Task Creation: Draft practical shooting assignments, flight missions, editing challenges with deadlines and rubrics.
  - Competition Management: Create multi-team tournaments with rules, maximum marks, and judging criteria.
  - Dual Marks Engine: Award independent individual scores and team-level marks without corrupting aggregate statistics.
  - Daily Company Review: Fill out mandatory end-of-day operational logs.
  - Attendance Logging: Mark batch attendance matched against official Student IDs.
  - AI Quiz Assistant: Select curriculum topics, review AI-generated questions, edit and approve bi-weekly quizzes.

#### 3.3 Student (Learner & Creative Maker)
- **Pain Points**: Accessing large video tutorials, tracking pending task deadlines, uploading high-resolution video clips, viewing honest teacher feedback, and understanding personal ranking.
- **Key Capabilities**:
  - Secure Login: Mobile number + password authentication with OTP self-service recovery.
  - Personal Dashboard: Real-time progress chart (performance percentage), today's assigned tasks, batch stats.
  - Learning Hub: Browse organized course materials (Course -> Batch -> Module -> Chapter -> File) for PDFs, video lectures, PPTs, and reference sheets.
  - Assignment Submissions: Upload videos (MP4/MOV up to 500 MB), photos, audio, and documents with contribution notes.
  - Fortnightly AI Quizzes: Take timed interactive quizzes with instant auto-grading for objective questions.
  - Team Collaboration: Internal student-to-student and squad chat.
  - Leaderboards: View batch rank, top teams, and public recognition gallery.

#### 3.4 Team Panel (Squad Account)
- **Pain Points**: Submitting group video productions without conflating individual student accounts.
- **Key Capabilities**:
  - Dedicated Team Login: Authenticate via unique Team ID & password.
  - Squad Dashboard: Display team banner, member roster, collective marks, and batch ranking.
  - Group Tasks: View challenges assigned to the entire team.
  - Team Work Upload: Submit collective drone footage, short films, and attribute specific responsibilities to each squad member.

---

### 4. Functional Specifications

#### 4.1 Onboarding & Authentication
- Separate login pathways for Admin/Teacher, Student, and Team.
- Server-side salted SHA-256 password hashing.
- Forced first-login password change for temporary passwords.
- Rate limiting: 3 failed attempts triggers a 30-minute account lockout.
- Self-service OTP reset sent via verified email address.
- Seamless WhatsApp onboarding helper for teachers/admins when enrolling new students.

#### 4.2 Public Home & Discovery
- Accessible to visitors without requiring login.
- Dynamic Notice Bar: General notices and common task alerts.
- Top Team Spotlight: Highlights current #1 team with logo, members' photos, total score, and efficiency percentage.
- Top 5 Student Leaderboard: Honors top learners across courses.
- Approved Student Work Gallery: Curated visual gallery of drone footage, photos, and project reels.
- Course catalog & program overview.

#### 4.3 Task & Dual-Level Marks Management
- Distinct storage for `IndividualMarks` vs `TeamMarks`.
- Team marks are awarded to the team entity as a single atomic score; they are NOT multiplied by the number of team members.
- Individual marks track specific member performance (e.g. flight technique vs video editing).
- Comprehensive submission lifecycle: `Draft` -> `Submitted` -> `Pending Review` -> `Approved` / `Rejected` / `Resubmission Required`.

#### 4.4 Attendance & Daily Company Review
- Attendance uses Student ID as the primary key to prevent duplicate name collisions.
- Integrates with the official Google Sheet template.
- Daily company review captures: Date, Course, Batch, Instructor, Practicals/Theory completed, Student progress, Obstacles/Weather challenges, and Teacher remarks.

#### 4.5 AI-Powered Quiz Engine
- Scheduled bi-weekly (every 15 days).
- Uses Google Gemini API on the backend to parse course study guides and generate question items (MCQs, True/False, Fill in the blanks).
- Human-in-the-loop: Teacher must review, edit, and approve questions before scheduling.
- Student test interface features countdown timers, question navigation, auto-submit on expiry, and immediate score calculation.

#### 4.6 Chat & Collaboration
- Scoped chat rooms: Student-to-Student, Team Squad, and Batch Group.
- Polling-based synchronization optimized for Apps Script execution.
- Content reporting and moderation tools for instructors and administrators.

---

### 5. Non-Functional Requirements
- **Performance**: Mobile app cold launch < 2.0s; cached dashboard load < 0.5s; smooth 60fps animations.
- **Design System**: Modern Neumorphism with tactile embossed/debossed cards, deep blue/cyan/amber palette, and drone-themed micro-interactions.
- **Bilingual**: Full support for English and Hindi (हिंदी).
- **Security**: Zero exposed secrets in client code; server-side role validation on every API endpoint.
- **Offline Resilience**: Offline caching of downloaded study materials, dashboard metrics, and optimistic submission queuing.

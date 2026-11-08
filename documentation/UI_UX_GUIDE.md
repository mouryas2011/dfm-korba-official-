# UI/UX DESIGN SYSTEM & MASTER SPECIFICATION (UI_UX_GUIDE.md)
## DFM KORBA OFFICIAL MOBILE APPLICATION
### Premium Modern Neumorphic Visual Language, Design Tokens, Screen Blueprints & 10 Drone Animations

---

| Document Metadata | Value |
|---|---|
| **System** | DFM Korba Official Mobile Application |
| **Design Paradigm** | Modern Neumorphism (Aviation Dark Mode + High-Contrast Accents) |
| **Design Grid** | 8-point geometric scale (Strict 48x48dp touch targets) |
| **Typography** | Poppins (Headings/Badges), Inter (Body/Controls), Noto Sans Devanagari (Hindi) |
| **Target Viewports** | Mobile Portrait: 360dp, 390dp, 412dp, 430dp |
| **Status** | Approved Master UI/UX Specification |

---

## 1. Visual Language & Design Philosophy

The **DFM Korba Official App** rejects generic, flat school management templates in favor of a specialized **Modern Neumorphic** design system. The visual theme blends deep midnight navy surfaces with luminous electric cyan, energetic sunrise amber, high-efficiency teal, and gold trophies—evoking high-altitude drone cinematography at dawn.

```
                      Top-Left Key Light Source (135°)
                                    \
                                     \
                                      v
    +-------------------------------------------------------------------+
    | Specular Rim Highlight: Color(0x0FFFFFFF), Offset(-2, -3), Blur(6) |
    |                                                                   |
    |                     ELEVATED CARD SURFACE                         |
    |                   Background: Color(0xFF0F172A)                   |
    |                                                                   |
    | Ambient Occlusion Shadow: Color(0xCC000000), Offset(4, 5), Blur(10)|
    +-------------------------------------------------------------------+
```

### Key Aesthetic Principles
1. **Physical Dual-Point Light Simulation**: Surfaces simulate a directional light source at top-left ($135^\circ$), projecting a subtle specular rim light on top-left edges and an ambient occlusion drop shadow on bottom-right edges.
2. **Accessible Contrast First**: Neumorphism can cause low contrast if implemented poorly; in DFM Korba, all typography and icon controls strictly maintain WCAG 2.1 AA compliance ($\ge 4.5:1$ for body copy, $\ge 3.0:1$ for large titles and interactive controls).
3. **Aviation & Telemetry Motifs**: Subtle quadcopter rotor blur discs, HUD crosshairs, altimeter pitch guides, and artificial horizon progress tracks.
4. **Haptic & Tactile Dynamics**: Interactive elements feature responsive tactile clicks (`HapticFeedback.lightImpact()`), giving tactile confirmation for every button press.

---

## 2. Global Design Tokens

### 2.1 Color System & Semantics

| Token | Hex Value | Color Name | Contrast vs #080D1A | Semantic Role |
|---|---|---|:---:|---|
| `bgDark` | `#080D1A` | Deep Void Navy | Base | Canvas scaffold background |
| `surfaceDark` | `#0F172A` | Slate Midnight | 1.4 : 1 | Standard card & tile surface |
| `surfaceDarkElevated` | `#162038` | Deep Cobalt | 1.8 : 1 | Focused cards, #1 rank highlight |
| `surfaceDarkInset` | `#0A0F1D` | Sunken Obsidian | 1.1 : 1 | Depressed text inputs, progress tracks |
| `primaryOrange` | `#FF6B00` | Sunrise Amber | 6.8 : 1 (AAA) | Primary action CTAs (Login, Submit) |
| `primaryOrangeLight` | `#FFA043` | Amber Flare | 10.2 : 1 (AAA)| Gradient end-stops & active focus glows |
| `accentCyan` | `#00D2FF` | Drone HUD Cyan | 11.5 : 1 (AAA)| Active navigation bubble, telemetry |
| `accentTeal` | `#00E599` | Flight Mint | 12.8 : 1 (AAA)| 90%+ performance badge, attendance mark |
| `accentPurple` | `#7928CA` | Faculty Royal | 4.6 : 1 (AA) | Teacher portal branding & banners |
| `accentGold` | `#FFB800` | Trophy Gold | 11.0 : 1 (AAA)| #1 Ranked team badge, star ratings |
| `accentRed` | `#FF3B30` | Safety Red | 5.2 : 1 (AA) | Account lockouts, absent tags, errors |
| `borderSubtle` | `#1E293B` | Perimeter Border| 2.1 : 1 | 1.0px fine containment border |
| `textPrimary` | `#FFFFFF` | Absolute White | 16.5 : 1 (AAA)| High-emphasis headings, titles |
| `textSecondary` | `#94A3B8` | Muted Silver | 8.2 : 1 (AAA) | Subtitles, labels, descriptions |
| `textMuted` | `#64748B` | Slate Gray | 4.8 : 1 (AA) | Timestamps, placeholder hints |

### 2.2 Gradient Tokens
- **Sunrise Flare CTA**: `LinearGradient(colors: [#FF6B00, #FFA043], begin: Alignment.topLeft, end: Alignment.bottomRight)`
- **Aviation HUD Blue**: `LinearGradient(colors: [#1C2541, #0B132B], begin: Alignment.topCenter, end: Alignment.bottomCenter)`
- **Champion Trophy Gold**: `LinearGradient(colors: [#FFD700, #FFA500], begin: Alignment.topLeft, end: Alignment.bottomRight)`
- **Teacher Royalty**: `LinearGradient(colors: [#7928CA, #4E54C8], begin: Alignment.topLeft, end: Alignment.bottomRight)`

### 2.3 Typography Scale
- **Headings & Badges**: Poppins (Bold, SemiBold)
- **Body & Controls**: Inter (Regular, Medium)
- **Hindi Localization**: Noto Sans Devanagari

| Token | Size | Line Height | Weight | Letter Spacing | Purpose |
|---|:---:|:---:|:---:|:---:|---|
| `displayLarge` | 26sp | 32sp | Bold (700) | -0.5 | Splash titles, hero banner headlines |
| `headlineMedium`| 20sp | 26sp | SemiBold (600)| -0.3 | Screen titles, modal headings |
| `titleMedium` | 16sp | 22sp | SemiBold (600)| 0.0 | Section headers, card titles |
| `titleSmall` | 14sp | 18sp | Medium (500) | 0.0 | Field labels, subheaders |
| `bodyMedium` | 14sp | 20sp | Regular (400) | 0.0 | Descriptions, chat messages |
| `bodySmall` | 12sp | 16sp | Regular (400) | 0.0 | Captions, secondary metadata |
| `labelSmall` | 11sp | 14sp | SemiBold (600)| 0.5 | Badges, tags, status pills |
| `ctaButton` | 15sp | 20sp | Bold (700) | 0.2 | Interactive button text |

### 2.4 Spacing & Sizing Grid
- Standard **8-point geometric scale**: `4dp`, `8dp`, `12dp`, `16dp`, `20dp`, `24dp`, `32dp`, `40dp`.
- **Minimum Interactive Touch Target**: $48\text{ dp} \times 48\text{ dp}$ across all tappable items.
- **Corner Radii**:
  - Small pills & tags: `8–12dp`
  - Cards, modals, dialogs: `16–18dp`
  - Bottom navigation bar: `32dp`
  - Circular buttons & avatars: `50%` ($r = \text{size} / 2$)

---

## 3. Component Library Specifications

### 3.1 Neumorphic Cards (`NeuCard`)
- **Elevated Depth**:
  - Surface: `#0F172A` (or `#162038`)
  - Border: `Border.all(color: #1E293B, width: 1.0)`
  - Dual Shadow:
    - `BoxShadow(color: rgba(0,0,0,0.8), offset: Offset(4, 5), blurRadius: 10, spreadRadius: -2)`
    - `BoxShadow(color: rgba(255,255,255,0.06), offset: Offset(-2, -3), blurRadius: 6)`
- **Inset Depth (Sunken)**:
  - Surface: `#0A0F1D`
  - Internal Shadow:
    - `BoxShadow(color: rgba(0,0,0,0.4), offset: Offset(2, 2), blurRadius: 4)`
    - `BoxShadow(color: rgba(255,255,255,0.04), offset: Offset(-1, -1), blurRadius: 2)`

### 3.2 Neumorphic Buttons (`NeuButton`)
- **Primary CTA**: Height `50dp`, Border radius `25dp`, Gradient: Sunrise Amber (`#FF6B00` to `#FFA043`), Shadow: `BoxShadow(color: rgba(255, 107, 0, 0.4), offset: Offset(0, 6), blurRadius: 14)`.
- **Secondary Action**: Height `50dp`, Surface: `#0F172A`, Border: `Border.all(color: #1E293B)`.
- **Destructive Action**: Height `50dp`, Surface: `#FF3B30`, Text: `#FFFFFF`.

### 3.3 Neumorphic Input Fields (`NeuTextField`)
- **Container**: Inset depth `#0A0F1D`, height `52dp`, corner radius `16dp`, border `#1E293B`.
- **Active Focus State**: Border transitions to `Border.all(color: #00D2FF, width: 1.4)` with an outer glow: `BoxShadow(color: rgba(0, 210, 255, 0.2), blurRadius: 8)`.
- **Icon Placement**: Prefix icon aligned left with cyan accent color (`#00D2FF`, size `20dp`).

---

## 4. The 10 Drone-Inspired Micro-Animations

```
+----------------------------------------------------------------------------------------------------+
|                                    10 DRONE-INSPIRED MICRO-ANIMATIONS                              |
+-----+-------------------------+-------------------------------+------------------------------------+
| #   | Animation Name          | Target Screen / Widget        | Core Physics & Timing Specs        |
+-----+-------------------------+-------------------------------+------------------------------------+
| 1   | Floating Bubble Nav     | Bottom Navigation Bar         | Elastic snap: Curves.easeOutBack   |
| 2   | Gooey Drop Badge        | Notifications Bell Counter    | Fluid tear: Curves.bounceOut (600ms)|
| 3   | Wavy Upload Slider      | Submit Work Screen            | Sinusoidal wave: y = A*sin(wx + f) |
| 4   | Parallax Carousel       | Public Home Screen            | 0.5x differential translation rate |
| 5   | Circular Menu Reveal    | App Navigation Drawer         | Radial clip expansion (320ms)      |
| 6   | Star Bounce Animator    | Leaderboards & Ratings        | Elastic scale: 0.2x -> 1.4x -> 1.0x|
| 7   | Arrow Launch Send CTA   | Chat & Submit Work Buttons    | 45° takeoff offset: (1.5, -0.8)    |
| 8   | Progress Process Button | NeuButton (Login / Submit)    | Full pill -> circle ring -> morph  |
| 9   | Drone Loading Spinner   | Splash & Async Operations     | 4 Counter-rotating rotors + hover  |
| 10  | Smooth Page Transitions | Global Route Navigation       | Shared axis slide + 2% depth (320ms|
+-----+-------------------------+-------------------------------+------------------------------------+
```

### 1. Floating Bubble Tab Bar
- **Trigger**: Switching tabs on bottom navigation bar.
- **Physics**: Luminous pill container glides horizontally with `Curves.easeOutBack` ($300\text{ ms}$). The selected icon bounces vertically by $3\text{ dp}$ with a brief rotor blur spin effect.

### 2. Gooey Drop Notifications
- **Trigger**: Incoming notice or grade alert.
- **Physics**: Notification badge stretches downward like a viscous liquid drop (`Curves.bounceOut`, $600\text{ ms}$) before snapping into an orange pill badge with white typography.

### 3. Wavy Upload Slider
- **Trigger**: File upload in progress on the submission screen.
- **Physics**: Mathematical sinusoidal soundwave oscillating continuously:
  $$y(x) = \frac{h}{2} + 5.0 \cdot \sin(0.04x + 2\pi \cdot t)$$
  The wave frequency increases by $15\%$ as upload progress advances from 0% to 100%.

### 4. Parallax Carousel
- **Trigger**: Horizontal scrolling of student work and top teams.
- **Physics**: Card background imagery translates at $0.5\times$ speed relative to foreground titles, imparting dynamic 3D depth.

### 5. Circular Menu Reveal
- **Trigger**: Tapping the top-left hamburger menu.
- **Physics**: An expanding circular clip path radiates outward from the tap coordinate with `Curves.easeOutCubic` ($320\text{ ms}$), fading in menu items sequentially.

### 6. Star Bounce Animator
- **Trigger**: Leaderboard and marks evaluation displays.
- **Physics**: Star icon scales down to $0.2\times$, springs up to $1.4\times$, and settles at $1.0\times$ with slight rotational wobble (`Curves.elasticOut`, $900\text{ ms}$).

### 7. Arrow Launch Send Button
- **Trigger**: Submitting a task or chat message.
- **Physics**: Navigation arrow lifts off diagonally at $45^\circ$ (`Offset(1.5, -0.8)`) with a miniature smoke puff trail before resetting.

### 8. Animated Progress Button
- **Trigger**: Tapping login or submit actions.
- **Physics**: Button smoothly contracts into a circular loader ring, displays rotating dual-color progress, and morphs into a completion checkmark.

### 9. Drone-Inspired Loading Spinner
- **Trigger**: Splash screen and async API fetches.
- **Physics**: Quadcopter silhouette hovers with vertical harmonic oscillation ($y = 6\sin(2\pi t)$), with 4 counter-rotating rotor blades spinning at $8\pi t\text{ rad/s}$ and central camera gimbal illumination.

### 10. Smooth Page Transitions
- **Trigger**: Screen navigation.
- **Physics**: Shared axis horizontal slide with $8\%$ initial offset and $2\%$ scale depth (`Curves.easeOutCubic`, $320\text{ ms}$), preventing screen flashing.

---

## 5. Screen-by-Screen UI Specifications

```
+--------------------------------------------------------------------------------------------------+
|                                  19 CORE SCREEN BLUEPRINTS INVENTORY                             |
+-----------------------------+-------------------------------+------------------------------------+
| 1. Splash Screen            | 8. Course Catalog Screen      | 14. Attendance Management Screen   |
| 2. Public Home Screen       | 9. Batch & Team Management    | 15. Study Material Hub             |
| 3. Login Screens (3 Roles)  | 10. Task Screens              | 16. Scoped Chat Channels Screen    |
| 4. Admin Dashboard          | 11. Work Submission Screen    | 17. User Profile Screen            |
| 5. Teacher Dashboard        | 12. Competition Screens       | 18. Notifications Inbox Screen     |
| 6. Student Dashboard        | 13. AI Quiz Screens           | 19. Analytical Reports Screen      |
| 7. Team Dashboard           |                               |                                    |
+-----------------------------+-------------------------------+------------------------------------+
```

### 1. Splash Screen
- **Background**: Deep void navy gradient (`#0F172A` to `#080D1A`).
- **Center**: High-resolution DFM Korba circular badge logo ($130\text{dp}$ diameter) with a cyan glow halo (`blurRadius: 30`).
- **Typography**: Display large "DFM KORBA" in bold white ($26\text{sp}$), subtitle "Drone Film Making Korba" in cyan ($13\text{sp}$).
- **Loader**: `DroneLoadingIndicator` ($54\text{dp}$) with caption: *"Loading secure environment..."*.
- **Footer**: Tagline: *"Learn > Practice > Create > Compete > Share > Grow"* ($11\text{sp}$, muted silver).

### 2. Public Home Screen
- **App Bar**: Circular logo ($28\text{dp}$), bold title "DFM KORBA", menu icon, and orange "Login" button pill.
- **Hero Banner**: Midnight blue elevated card with "100% FREE" badge in teal and drone tags (DGCA Rules, 4K Aerial Cine, Competitions).
- **Important Notice Ticker**: Bordered card with flashing icon, title, and "General" or "Task Alert" pill.
- **Top Team Spotlight**: Card featuring Team *Veervaan*, #1 gold trophy badge, 6 member avatars, score $485 / 500$, and $97.0\%$ performance star bounce.
- **Top 5 Students Leaderboard**: Vertical cards showing rank (#1 gold, #2 silver, #3 bronze), student name, squad, course, marks, and attendance percentage.
- **Student Work Gallery**: Horizontal carousel of approved drone reels with video/photo badges, marks, and teacher critique.

### 3. Login Screens (Role-Based)
- **Role Identifier**: Colored badge indicating portal (Student: Teal, Teacher: Purple, Team: Gold, Admin: Cyan).
- **Fields**: Sunken Neumorphic text inputs for Mobile Number / Team ID and Password with visibility toggle.
- **Forgot Password**: Cyan text button opening OTP email recovery modal.
- **CTA**: Full-width Sunrise Amber `NeuButton` ("Sign In ->") with process loader.
- **Security Notice**: Caption: *"Max 3 attempts before temporary account protection."*

### 4. Admin Dashboard Screen
- **Header**: "System Administrator", health badge: *"Google Sheets Database • Drive Storage Active"*.
- **Metrics Grid (2x2)**: 8 Courses, 12 Teachers, 248 Students, 28 Teams with vibrant accent icons.
- **Action List**:
  - *Register Student & WhatsApp Onboard* (Teal icon)
  - *Manage Skill Courses* (Cyan icon)
  - *Publish System Notices* (Orange icon)
  - *Security & Activity Logs* (Muted icon)

### 5. Teacher Dashboard Screen
- **Header**: Teacher profile photo, instructor name ("Vikram Sharma"), designation: *"Head Flight Instructor • Drone Film Making"*.
- **Metrics Grid (2x2)**: 4 Batches, 68 Students, 12 Tasks, 6 Competitions.
- **Operations List**:
  - *Mark Batch Attendance* (Google Sheet sync)
  - *Daily Company Review* (8-field mandatory form)
  - *AI Quiz Generator (Gemini)*
  - *Submissions Review Queue* (Dual marks grading)

### 6. Student Dashboard Screen
- **Header**: "Hello, Aman", subtitle: *"Student • DFM Batch 01"*, drone icon.
- **My Progress Card**: 92% performance bar, cumulative score (490 pts), attendance (98.5%), rank #1 badge.
- **2x3 Quick Grid**: My Course, My Tasks (badge '3'), Study Material, AI Quiz, My Team, Attendance.
- **Today's Task Spotlight**: Drone Cinematic Shoot (Due: 12 Nov | 100 Marks) with orange "Submit" button.
- **Navigation**: Floating Bubble Tab Bar (Dashboard, Learning, Tasks, Chat, Profile).

### 7. Team Dashboard Screen
- **Header Banner**: Team *Veervaan*, gold trophy emblem, "#1 RANKED SQUAD", collective score: $485 / 500$, efficiency: $97.0\%$, 6 members.
- **Action Tiles**: Team Tasks (badge '3'), Member Contribution (squad credits), Team Submissions, Team Score & Ranking.

### 8. Course Catalog Screen
- **Header**: "Skill Development Courses".
- **List Cards**: Drone Film Making (6 Modules, 12 Weeks), Mobile Repairing (5 Modules, 10 Weeks), Front Office Executive (4 Modules, 8 Weeks). All marked with 100% Free badge.

### 9. Batch & Team Management Screens
- **Batch Screen**: Cohort name, start/end dates, enrolled student count, max capacity bar ($24/30$).
- **Team Screen**: Squad roster, appoint team leader, assign crew roles (Pilot, Gimbal, Editor, Spotter, Sound, Storyboard).

### 10. Task Screens
- **List View**: Segmented tabs (Today's Tasks, Pending, Submitted, Evaluated).
- **Detail View**: Full task description, flight safety rubric, allowed formats (`MP4`, `MOV`), max file size (500 MB), deadline countdown.

### 11. Work Submission Screen
- **Cloud Upload Container**: Sunken Neumorphic container with cloud upload icon.
- **Wavy Track Slider**: Oscillating sinusoidal wave indicating upload and compression progress.
- **File Pill**: `drone_shoot.mp4 (324 MB • Ready)` with close icon.
- **Member Contribution Field**: Multi-line text field: *"Aman: Pilot; Rahul: Gimbal; Priya: Colorist"*.
- **CTA**: Arrow Launch Button ("Submit Task ->").

### 12. Competition Screens
- **Active Challenges**: Grand challenges with rules, deadline, max marks (500), enrolled squads (14).
- **Hall of Fame**: Previous tournament champions with member credits and scores.

### 13. AI Quiz Screens
- **Student View**: 15-minute countdown clock in app bar, question card with options A, B, C, D in Neumorphic radio cards, auto-grading result modal.
- **Teacher View**: Topic input field, question count dropdown (5, 10, 15), difficulty selector, Gemini AI generate button, human review & edit cards, approve & schedule button.

### 14. Attendance Management Screen
- **Roster**: Enrolled students matched to Student IDs (`STU_DFM_001`, `STU_DFM_002`...).
- **Controls**: "All Present" quick button, green/red toggle chips (`PRESENT` / `ABSENT`).
- **Commit CTA**: "Save & Sync Attendance to Sheet".

### 15. Study Material Hub
- **Search Bar**: Keywords search across titles and modules.
- **Format Chips**: Filter by `ALL`, `PDF`, `VIDEO`, `PPTX`, `DOCX`.
- **Card**: Title, module, chapter, file size, upload date, bookmark toggle, and "Access File" download action.

### 16. Chat Screens
- **Channels Selector**: Horizontal chips (Team Veervaan Squad, DFM Batch 01 Main, P2P channels).
- **Message Bubbles**: Outgoing bubbles in Sunrise Amber, incoming in Deep Cobalt `#162038`.
- **Controls**: Message input field with `ArrowLaunchButton`, message flag/report button.

### 17. User Profile Screen
- **Card**: Avatar, Student ID, Course, Batch, Squad, Emergency contact.
- **Actions**: Change Password, Language Selection (English / हिंदी), Logout.

### 18. Notification Inbox Screen
- **List**: Grouped notifications (New task, deadline reminder, grade approved, notice alert).
- **Badge**: Gooey drop animation counter.

### 19. Analytical Reports Screen
- **Charts**: Course-wise completion rate, batch attendance percentage curve, squad leaderboard rankings, submission approval distribution.

---

## 6. Accessibility & Motion Guidelines

1. **WCAG 2.1 AA Compliance**:
   - High-contrast white typography (`#FFFFFF`) against dark surfaces (`#080D1A` and `#0F172A`) yields a contrast ratio of $16.5:1$ (exceeds AAA requirement).
   - Secondary text (`#94A3B8`) yields $8.2:1$ (exceeds AAA requirement).
2. **Touch Target Size**: Every interactive button, chip, and switch has a minimum hit area of $48\text{ dp} \times 48\text{ dp}$.
3. **Screen Reader Semantic Tags**: All icons, loading states, and custom animated painters include descriptive accessibility labels (e.g. `Semantics(label: "Quadcopter loading animation", ...)`.
4. **Reduced Motion Setting**: All animation controllers check `MediaQuery.of(context).disableAnimations`. If system reduced-motion is enabled, animation durations collapse to $0\text{ ms}$ with instant state updates.

---
*End of UI/UX Design System & Master Specification (UI_UX_GUIDE.md).*

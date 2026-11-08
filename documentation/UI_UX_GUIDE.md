# UI/UX DESIGN SYSTEM & ANIMATION SPECIFICATIONS
## DFM Korba Official Mobile Application
**Modern Neumorphic Design Language & Micro-Interactions**

---

### 1. Visual Language & Design Philosophy
The visual architecture of the **DFM Korba Official App** blends **Modern Neumorphism** with high-contrast functional aesthetics. Rather than flat pastel surfaces, it employs deep midnight navy surfaces accented with electric cyan, luminous teal, and energetic sunrise amber—evoking the thrill of high-altitude drone cinematography at dawn.

Key aesthetic characteristics:
- **Soft Dimensional Surfaces**: Tactile extruded/concave surfaces achieved through dual-point light projection (top-left highlight + bottom-right shadow).
- **Accessible Contrast**: Foreground typography and icons strictly adhere to WCAG AA contrast standards (minimum 4.5:1 ratio).
- **Aviation & Drone Styling**: Subtle propeller hubs, HUD targeting lines, horizon artificial gradients, and altimeter-inspired progress indicators.

---

### 2. Design Token System

#### 2.1 Color Palette
| Token Name | Hex Code | Purpose |
|---|---|---|
| `bgDark` | `#080D1A` | Root scaffold dark background |
| `surfaceDark` | `#0F172A` | Elevated cards, containers, tiles |
| `surfaceDarkInset` | `#0A0F1D` | Depressed / sunken form fields & progress tracks |
| `primaryOrange` | `#FF6B00` | Primary action CTA (Login, Submit, Confirm) |
| `primaryOrangeLight` | `#FFA043` | Gradient end-stops & active focus glows |
| `accentCyan` | `#00D2FF` | Active tab indicator, drone HUD accents |
| `accentTeal` | `#00E599` | Success badges, 90%+ performance indicators |
| `accentPurple` | `#7928CA` | Teacher portal accents, competition badges |
| `accentGold` | `#FFB800` | #1 Top Team trophy, leaderboard ranks |
| `textPrimary` | `#FFFFFF` | High-emphasis headings, titles |
| `textSecondary` | `#94A3B8` | Subtitles, labels, metadata captions |
| `textMuted` | `#64748B` | Timestamps, placeholder hints |
| `borderSubtle` | `#1E293B` | Fine containment borders on neumorphic cards |
| `shadowLight` | `rgba(255, 255, 255, 0.05)`| Top-left specular rim light |
| `shadowDark` | `rgba(0, 0, 0, 0.65)` | Bottom-right ambient occlusion shadow |

#### 2.2 Gradients
- **Sunset Flare CTA**: `LinearGradient(colors: [#FF512F, #DD2476])` or `LinearGradient(colors: [#FF7A00, #FF9E00])`
- **Aviation HUD Blue**: `LinearGradient(colors: [#1C2541, #0B132B])`
- **Trophy Gold**: `LinearGradient(colors: [#FFE000, #799F0C])` -> `[#FFD700, #FFA500]`
- **Teacher Royalty**: `LinearGradient(colors: [#4E54C8, #8F94FB])`

#### 2.3 Typography
- **Headings & Badges**: Poppins (Bold, SemiBold, Medium)
- **Body & Controls**: Inter (Regular, Medium)
- **Hindi Typography**: Noto Sans Devanagari (Clean, legible character rendering across all density scales)
- **Scale**:
  - `Display Large`: 28sp / LineHeight 34 / Weight: 700
  - `Headline Medium`: 20sp / LineHeight 26 / Weight: 600
  - `Title Medium`: 16sp / LineHeight 22 / Weight: 600
  - `Body Medium`: 14sp / LineHeight 20 / Weight: 400
  - `Label Small`: 11sp / LineHeight 14 / Weight: 500

---

### 3. The 10 Mandatory Project Animations

#### 1. Progress / Process Button Animation
- **Trigger**: User taps an action button (e.g. "Submit Task", "Login").
- **Behavior**: The button smoothly transitions its width from full-pill into a compact circle, shows a pulsating ring loader with completion checkmark morphing, and then expands back. Prevents multiple rapid clicks.

#### 2. Drone-Themed Floating Tab Bar (Bubble Animation)
- **Trigger**: Tab switching on the bottom navigation bar.
- **Behavior**: A luminous pill "bubble" with an active cyan glow smoothly glides beneath the active icon, causing the icon to bounce slightly vertically with a tiny rotor-blur spin effect.

#### 3. Gooey Notification Drop Animation
- **Trigger**: New incoming notice, submission review, or chat notification.
- **Behavior**: A bell badge stretches with a spring-loaded viscous "gooey" tear effect from the top bar before snapping into an eye-catching pill counter.

#### 4. Wavy Track Slider Upload Animation
- **Trigger**: Video/File upload in progress on the submission screen.
- **Behavior**: Instead of a flat bar, an oscillating sine-wave soundwave/rotor-wave rhythmically ripples across the track, accelerating slightly as transfer progress increases from 0% to 100%.

#### 5. Parallax Carousel Effect
- **Trigger**: Swiping through top teams or student portfolio cards on the Home screen.
- **Behavior**: Card background imagery glides at 0.5x rate relative to foreground labels, creating realistic 3D depth and cinematic presentation.

#### 6. Circular Menu Reveal Animation
- **Trigger**: Tapping the top-left hamburger menu.
- **Behavior**: A circular clip mask expands outward from the tap coordinates with ease-out cubic velocity, revealing navigation items in staggered sequential fade-ins.

#### 7. Star Bounce Animation
- **Trigger**: Marks evaluation or leaderboard ranking display.
- **Behavior**: Rating stars and trophy emblems scale down to 0.4x and violently spring up to 1.2x before settling at 1.0x with slight rotational wobble.

#### 8. Send Button (Arrow Launch Animation)
- **Trigger**: Submitting a chat message or task submission.
- **Behavior**: The paper airplane/drone navigation icon lifts off diagonally upward with a miniature jet/exhaust puff trail before fading into the delivery checkmark.

#### 9. Drone-Inspired Loading Spinner
- **Trigger**: Screen transitions, API fetches, and splash launch.
- **Behavior**: A miniature quadcopter silhouette with four counter-rotating rotor discs and pulsating altitude sensor rings indicates active data loading.

#### 10. Smooth Page Transitions
- **Trigger**: Screen navigation.
- **Behavior**: Shared axis horizontal slide with subtle 2% depth scaling (elevated neumorphic layers gliding seamlessly without jarring screen flashes).

---

### 4. Accessibility & Motion Controls
- **Reduced Motion Setting**: All custom animation controllers query `MediaQuery.of(context).disableAnimations`. If reduced motion is requested by the OS or user preference, animation durations collapse to 0ms with instant state transitions.
- **Haptic Feedback**: Subtle tactile clicks on button presses (`HapticFeedback.lightImpact()`) and error vibrations (`HapticFeedback.heavyImpact()`).

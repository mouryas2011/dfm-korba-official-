# DEPLOYMENT & OPERATIONS GUIDE
## DFM Korba Official Mobile Application
**Backend Setup, Google Sheets Initialization & Mobile Deployment**

---

### Step 1: Google Drive & Google Sheets Initialization

1. Log into the designated Google Account for DFM Korba.
2. In Google Drive, create a root folder named:
   `DFM_KORBA_APP_STORAGE`
   Note down the Folder ID from the URL (e.g. `1AbCdEfGhIjKlMnOpQrStUvWxYz`).
3. In Google Drive, create a new Google Sheet named:
   `DFM_KORBA_DATABASE`
   Note down the Spreadsheet ID from the URL.

---

### Step 2: Google Apps Script Backend Deployment

1. Inside the Google Sheet, navigate to **Extensions > Apps Script**.
2. Copy the files from the repository's `backend/` directory into the Apps Script editor:
   - `Code.gs` (Master API Router)
   - `AuthService.gs` (Authentication & Security)
   - `DatabaseService.gs` (Data Access Layer)
   - `TaskSubmissionService.gs` (Work Submissions & Drive Upload)
   - `AttendanceService.gs` (Attendance & Daily Review)
   - `QuizService.gs` (AI Quiz & Grading)
   - `ChatService.gs` (Messaging & Moderation)
   - `ReportingService.gs` (Analytics Engine)
   - `SetupDatabase.gs` (Schema Initializer)
   - `appsscript.json` (Manifest with OAuth scopes)
3. Run the database setup function:
   - Select `initializeAllDatabaseSheets` from the function dropdown.
   - Click **Run**. Grant standard Google permissions when prompted.
   - This automatically creates all 32 normalized sheets with correct headers, styles, and initial seed data (Admin, Courses, Sample Batches, Teams, Notices).
4. Configure Script Properties (**Project Settings > Script Properties**):
   - `STORAGE_ROOT_FOLDER_ID`: `[Your Google Drive Folder ID]`
   - `GEMINI_API_KEY`: `[Your Google Gemini API Key]`
   - `JWT_SECRET`: `[A long random cryptographic string]`
5. Deploy as Web App:
   - Click **Deploy > New deployment**.
   - Select type: **Web app**.
   - Description: `DFM Korba Official Backend v1.0.0`.
   - Execute as: **Me (your account)**.
   - Who has access: **Anyone** (allows mobile app requests without requiring end-users to have Google Workspace accounts).
   - Click **Deploy** and copy the **Web app URL**:
     `https://script.google.com/macros/s/.../exec`

---

### Step 3: Mobile Application Configuration

1. Open `mobile_app/lib/core/constants/api_endpoints.dart`.
2. Set the `baseUrl` constant:
   ```dart
   class ApiEndpoints {
     static const String baseUrl = 'https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec';
     // ...
   }
   ```
3. Test locally with Flutter:
   ```bash
   cd mobile_app
   flutter pub get
   flutter run
   ```

---

### Step 4: Building Android APK & CI/CD Pipeline

#### Automated GitHub Actions
The repository includes `.github/workflows/build_apk.yml`. Every push or pull request to `main`:
1. Checks out the code.
2. Sets up Flutter.
3. Runs `flutter analyze` and `flutter test`.
4. Compiles a release universal APK:
   `flutter build apk --release --split-per-abi` and universal `flutter build apk --release`.
5. Uploads the `.apk` artifacts to the GitHub Actions Run and creates a draft GitHub Release.

#### Manual Local Build
To build release APK locally:
```bash
cd mobile_app
flutter build apk --release
# Output: mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

---

### Step 5: iOS Configuration & Distribution
1. Ensure CocoaPods is installed:
   ```bash
   cd mobile_app/ios
   pod install
   ```
2. Open `Runner.xcworkspace` in Xcode on macOS.
3. Configure your Apple Developer Team under **Signing & Capabilities**.
4. Set Bundle Identifier to: `org.dfmkorba.official`
5. Create an Archive:
   - **Product > Archive**.
   - Distribute to TestFlight or App Store Connect.


# SpotIt — Civic Issue Reporting App

> A Flutter mobile application that empowers citizens to report, track, and resolve civic issues like potholes, garbage dumps, water leakage, and broken streetlights in their city.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Install Flutter dependencies](#2-install-flutter-dependencies)
  - [3. Firebase Setup](#3-firebase-setup)
  - [4. Google Sign-In Setup](#4-google-sign-in-setup)
  - [5. Google Sheets Setup (optional)](#5-google-sheets-setup-optional)
  - [6. Run the app](#6-run-the-app)
- [Environment & Configuration](#environment--configuration)
- [Screens & Navigation](#screens--navigation)
- [Services](#services)
- [Design System](#design-system)
- [Key Dependencies](#key-dependencies)
- [Building for Release](#building-for-release)
- [Known Issues](#known-issues)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**SpotIt** is a citizen-facing civic issue reporting app built with Flutter + Firebase. Users can submit reports about problems in their area with photos, GPS location, and category tagging. Reports are stored in Firestore and tracked through a status pipeline:

```
Submitted → In Review → In Progress → Resolved
```

The app follows **Material Design 3** with a custom emerald-green design system, `NavigationBar`, hero gradient headers, and animated components.

---

## Features

| Feature | Description |
|---|---|
| Email / Password Auth | Register and sign in with Firebase Auth |
| Google Sign-In | One-tap sign in with Google account |
| Multi-step Report Form | 3-step wizard: Category → Details → Contact & Review |
| GPS Location Capture | Auto-detect coordinates via device GPS |
| Photo Evidence | Attach photo from camera or gallery |
| Report Status Tracking | Real-time status updates with visual timeline |
| My Reports | Personal report history with filter chips (All / Pending / In Progress / Resolved) |
| Profile Management | Edit display name and avatar photo |
| Google Sheets Export | Reports optionally synced to a Google Sheet |
| Shimmer Loading | Skeleton loaders while fetching data |
| Real-time Updates | Firestore `StreamBuilder` for live data |
| Responsive Layout | Stat grid adapts across screen widths |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | `setState` + `StreamBuilder` (no external state manager) |
| Database | Firebase Firestore |
| Authentication | Firebase Auth — Email/Password + Google |
| File Storage | Firebase Storage |
| Location | `location` package |
| Image Handling | `image_picker` |
| UI System | Material Design 3 (`useMaterial3: true`) |
| Loading Animations | `shimmer`, `lottie` |
| External Integration | Google Sheets API via `http` |
| Min Android SDK | API 21 (Android 5.0) |

---

## Architecture

The app uses a **Services + Screens** architecture — a lightweight pattern without heavy state management libraries.

```
User interaction
      │
      ▼
   Screen  (UI layer — lib/screens/)
      │
      ▼
   Service  (business logic / API calls — lib/services/)
      │
      ▼
   Firebase / External API
```

**Key principles:**
- **Screens** — pure UI; call services for all data operations
- **Services** — all Firebase/API logic lives here, zero UI code
- **Components** — small, reusable stateless widgets
- **Theme** — centralized design tokens (colors, typography, full ThemeData)
- **Widgets** — complex bespoke widgets (e.g. `StatusTimeline`)

Data flows via `Stream` (Firestore real-time) or `Future` (one-off async calls). Auth state is managed by `AuthGate`, which listens to `FirebaseAuth.instance.authStateChanges()` and routes accordingly.

---

## Folder Structure

```
spotit-app/
│
├── android/                               # Android platform files
│   └── app/
│       ├── google-services.json           # ⚠️ Firebase config — NOT committed
│       └── src/main/
│           └── AndroidManifest.xml        # Permissions: camera, location, internet
│
├── ios/                                   # iOS platform files
│
├── assets/
│   ├── icon/
│   │   └── app_icon.png                   # Source for flutter_launcher_icons
│   └── images/
│       ├── login_illustration.png         # Auth screen illustration
│       └── google_icon.png                # Google Sign-In button icon
│
├── lib/
│   │
│   ├── main.dart                          # Entry point — Firebase.initializeApp(), runApp()
│   │
│   ├── components/                        # Reusable stateless UI components
│   │   ├── category_chip.dart             # Animated issue category selector card
│   │   ├── report_card.dart               # Report list item (thumbnail + badges)
│   │   └── stat_card.dart                 # Stats card (icon + number + label)
│   │
│   ├── screens/                           # Full-page screens / route destinations
│   │   ├── auth_gate.dart                 # Auth state router (shows login or shell)
│   │   ├── main_shell.dart                # Material 3 NavigationBar shell (3 tabs)
│   │   ├── home_screen.dart               # Dashboard — hero, stats, quick actions, FAB
│   │   ├── my_reports_screen.dart         # Report history with status filter chips
│   │   ├── report_details_screen.dart     # Single report — hero image, timeline, map
│   │   ├── submit_report_screen.dart      # 3-step report submission wizard
│   │   ├── profile_screen.dart            # User profile, stats row, settings sections
│   │   ├── edit_profile_screen.dart       # Edit display name and avatar
│   │   ├── login_screen.dart              # Email + Google sign in
│   │   └── signup_screen.dart             # New account creation
│   │
│   ├── services/                          # Business logic / external integrations
│   │   ├── firestore_service.dart         # Firestore CRUD, streams, stats
│   │   ├── google_auth_service.dart       # Google Sign-In flow + Firebase link
│   │   ├── google_sheets_service.dart     # Google Sheets API row append
│   │   ├── storage_service.dart           # Firebase Storage image upload
│   │   └── user_service.dart              # Upsert user doc in Firestore /users
│   │
│   ├── theme/                             # Design system — single source of truth
│   │   ├── app_theme.dart                 # Global ThemeData (Material 3)
│   │   ├── colors.dart                    # Color palette, shadows, gradients
│   │   └── typography.dart                # Full Material 3 text style scale
│   │
│   └── widgets/                           # Complex single-purpose custom widgets
│       └── status_timeline.dart           # Animated report progress timeline
│
├── pubspec.yaml                           # Dependencies & asset declarations
├── pubspec.lock                           # Locked dependency versions
└── README.md
```

---

## Prerequisites

Ensure the following are installed before you begin:

- **Flutter SDK** `>=3.0.0` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** `>=3.0.0 <4.0.0` (bundled with Flutter)
- **Android Studio** or **VS Code** with Flutter + Dart extensions
- **Android SDK** (API 21+ target)
- **Firebase project** with Firestore, Auth, and Storage enabled
- **Java JDK 17+** (required by Gradle for Android builds)

Verify your setup:
```bash
flutter doctor -v
```

All items should show a green checkmark. Fix any issues before continuing.

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/sunilgoyal000/spotit-app.git
cd spotit-app
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

**Step 1 — Create a Firebase project**

1. Go to [Firebase Console](https://console.firebase.google.com/) → Add project → follow the wizard.

**Step 2 — Enable services**

In the Firebase Console, enable:
- **Authentication** → Sign-in method → Email/Password ✓
- **Authentication** → Sign-in method → Google ✓
- **Firestore Database** → Create database (start in test mode for development)
- **Storage** → Get started

**Step 3 — Add Android app**

1. Project settings → Add app → Android
2. Package name: `com.example.spotit`
3. Download `google-services.json`
4. Place the file at: `android/app/google-services.json`

**Step 4 — Firestore security rules** (recommended for production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Reports belong to the user who created them
    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read:   if request.auth.uid == resource.data.userId;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

**Step 5 — Storage security rules**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /report_images/{allPaths=**} {
      allow read:  if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024; // 5MB limit
    }
    match /profile_photos/{userId}.jpg {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### 4. Google Sign-In Setup

Google Sign-In requires your debug keystore SHA-1 to be registered in Firebase.

**Get your SHA-1 fingerprint:**

```bash
# Windows
keytool -list -v \
  -keystore "%USERPROFILE%\.android\debug.keystore" \
  -alias androiddebugkey \
  -storepass android -keypass android

# macOS / Linux
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```

Copy the `SHA1:` value and add it in:
**Firebase Console → Project Settings → Your Android app → Add fingerprint**

Then download the updated `google-services.json` and replace the existing one.

### 5. Google Sheets Setup (optional)

If you want reports exported to a Google Sheet:

1. Create a Google Sheet — note the **Sheet ID** from the URL:
   `https://docs.google.com/spreadsheets/d/<SHEET_ID>/edit`
2. [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Enable **Google Sheets API**
3. Create a **Service Account** → download JSON credentials
4. Share the Google Sheet with the service account email
5. Update `lib/services/google_sheets_service.dart` with your Sheet ID and credentials

### 6. Run the app

```bash
# See all connected devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554

# Run on a connected physical device
flutter run -d <your-device-id>

# Run in Chrome (web)
flutter run -d chrome
```

**While the app is running:**

| Key | Action |
|-----|--------|
| `r` | Hot reload — apply UI changes instantly |
| `R` | Hot restart — full app restart |
| `h` | List all available commands |
| `d` | Detach (leave app running, exit CLI) |
| `q` | Quit and kill the app |

---

## Environment & Configuration

| File | Purpose | Committed to Git? |
|---|---|---|
| `android/app/google-services.json` | Firebase Android config | **No — add to .gitignore** |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS config | **No — add to .gitignore** |
| `lib/services/google_sheets_service.dart` | Sheets credentials | Configure manually |

Add to your `.gitignore`:

```gitignore
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# Environment
*.env
.env.*
```

---

## Screens & Navigation

The app uses a **Material 3 `NavigationBar`** shell with 3 top-level tabs and push navigation for sub-screens.

```
AuthGate (listens to authStateChanges)
│
├── Not signed in → LoginScreen
│                       └── SignupScreen (push)
│
└── Signed in → MainShell (NavigationBar — 3 tabs)
                    │
                    ├── Tab 0: HomeScreen
                    │           └── SubmitReportScreen (push — 3-step wizard)
                    │
                    ├── Tab 1: MyReportsScreen
                    │           └── ReportDetailsScreen (push)
                    │
                    └── Tab 2: ProfileScreen
                                └── EditProfileScreen (push)
```

### Screen Reference

| Screen | File | Key widgets used |
|---|---|---|
| AuthGate | `auth_gate.dart` | `StreamBuilder`, `authStateChanges` |
| Login | `login_screen.dart` | `TextField`, `ElevatedButton`, `OutlinedButton` |
| Signup | `signup_screen.dart` | `TextField`, `ElevatedButton` |
| Home | `home_screen.dart` | `CustomScrollView`, `SliverToBoxAdapter`, `StatCard`, FAB |
| My Reports | `my_reports_screen.dart` | `StreamBuilder`, `FilterChip`, `Shimmer`, `ReportCard` |
| Report Details | `report_details_screen.dart` | `SliverAppBar`, `StatusTimeline`, `url_launcher` |
| Submit Report | `submit_report_screen.dart` | `PageView`, `CategoryChip`, `image_picker`, `location` |
| Profile | `profile_screen.dart` | `CustomScrollView`, `StreamBuilder`, settings tiles |
| Edit Profile | `edit_profile_screen.dart` | `ImagePicker`, `Firebase Storage`, `updateDisplayName` |

---

## Services

### `FirestoreService` — `lib/services/firestore_service.dart`

```dart
// Submit a new report
FirestoreService.submitReport(
  userId, name, phone, sharePhone,
  category, description, location, lat, lng, district, imageUrl
)

// Stream of user's reports (real-time)
Stream<QuerySnapshot> FirestoreService.myReports(String uid)

// Stream of report stats: {total, pending, resolved}
Stream<Map<String, int>> FirestoreService.reportStats(String uid)
```

**Firestore collection:** `/reports`

**Report document shape:**
```json
{
  "userId": "abc123",
  "name": "Sunil Goyal",
  "phone": "9876543210",
  "sharePhone": false,
  "category": "Pothole",
  "description": "Large pothole near bus stop...",
  "location": "30.7046, 76.7179",
  "lat": 30.7046,
  "lng": 76.7179,
  "district": "Mohali",
  "imageUrl": "https://firebasestorage...",
  "status": "pending",
  "createdAt": Timestamp
}
```

### `GoogleAuthService` — `lib/services/google_auth_service.dart`

Handles the full Google Sign-In OAuth flow and links the credential to Firebase Auth.

### `StorageService` — `lib/services/storage_service.dart`

Uploads a `File` to Firebase Storage under `/report_images/` and returns the public download URL.

### `UserService` — `lib/services/user_service.dart`

Upserts a user document to Firestore `/users/{uid}` on every sign-in (preserves existing data with `SetOptions(merge: true)`).

### `GoogleSheetsService` — `lib/services/google_sheets_service.dart`

Appends a report row to a Google Sheet via the Sheets REST API using a service account JWT.

---

## Design System

All design tokens live in `lib/theme/` — never use raw color hex values in screen/component code.

### Color Tokens (`lib/theme/colors.dart`)

| Token | Hex | Usage |
|---|---|---|
| `AppColors.primary` | `#16A34A` | Buttons, active nav, focus rings |
| `AppColors.primaryLight` | `#22C55E` | Accents, highlights |
| `AppColors.primaryContainer` | `#DCFCE7` | Chip selected bg, badge bg |
| `AppColors.secondary` | `#0EA5E9` | Info states, secondary actions |
| `AppColors.warning` | `#F59E0B` | Pending status |
| `AppColors.error` | `#DC2626` | Errors, rejected status |
| `AppColors.success` | `#16A34A` | Resolved status |
| `AppColors.background` | `#F9FAFB` | Scaffold background |
| `AppColors.surface` | `#FFFFFF` | Cards, sheets, dialogs |
| `AppColors.surfaceVariant` | `#F3F4F6` | Input fills, secondary surfaces |
| `AppColors.onSurface` | `#111827` | Primary text |
| `AppColors.onSurfaceVariant` | `#6B7280` | Secondary / muted text |
| `AppColors.outline` | `#E5E7EB` | Borders, dividers |

**Gradients available:**
- `AppColors.primaryGradient` — vertical emerald gradient (buttons, icons)
- `AppColors.heroGradient` — dark-to-deeper green (header backgrounds)

**Shadow presets:**
- `AppColors.cardShadow` — subtle card lift
- `AppColors.elevatedShadow` — strong elevation
- `AppColors.primaryShadow` — green-tinted glow (primary action cards)

### Typography (`lib/theme/typography.dart`)

Material 3 type scale. Key styles:

| Style | Size | Weight | Usage |
|---|---|---|---|
| `titleLarge` | 22px | w600 | Screen-level headings |
| `titleMedium` | 18px | w600 | Card titles, section headers |
| `bodyLarge` | 16px | w400 | Primary body text |
| `bodyMedium` | 14px | w400 | Secondary body, descriptions |
| `bodySmall` | 12px | w400 | Captions, hints |
| `labelLarge` | 14px | w500 | Buttons, filter chips |

### App Theme (`lib/theme/app_theme.dart`)

Configured `ThemeData` includes:

- `NavigationBarTheme` — pill indicator, always-show labels
- `ElevatedButtonTheme` — 0 elevation, 14px radius, w600 text
- `OutlinedButtonTheme` — matching radius and text weight
- `InputDecorationTheme` — filled style, no border, green focus ring
- `ChipTheme` — rounded `FilterChip` style
- `CardTheme` — 20px radius, 1px outline border
- `SnackBarTheme` — floating, dark bg, rounded corners
- `FloatingActionButtonTheme` — rounded 16px, primary color
- `BottomSheetTheme` — drag handle, 24px top radius

---

## Key Dependencies

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.0
  firebase_auth: ^5.3.0
  firebase_storage: ^12.3.0

  # Authentication
  google_sign_in: ^6.2.1

  # Device capabilities
  location: ^6.0.2          # GPS coordinates
  image_picker: ^1.1.2      # Camera / gallery
  url_launcher: ^6.3.0      # Open Google Maps

  # UI & animations
  shimmer: ^3.0.0           # Skeleton loading screens
  lottie: ^3.3.2            # Lottie JSON animations
  pull_to_refresh_notification: ^3.1.1

  # Networking
  http: ^1.2.2              # Google Sheets REST API

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.13.1
```

---

## Building for Release

### Android APK (sideload / testing)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

> For release builds you need a **signing keystore**. See the [Flutter Android deployment guide](https://docs.flutter.dev/deployment/android).

### Regenerate app launcher icons

After changing `assets/icon/app_icon.png`:

```bash
flutter pub run flutter_launcher_icons
```

### Analyze code for issues

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

---

## Known Issues

| Issue | Cause | Fix / Workaround |
|---|---|---|
| Slow frame rate on emulator | Software GPU rendering | Test on a real Android device |
| Google Sign-In fails | SHA-1 fingerprint not registered | Add fingerprint to Firebase project settings |
| Location permission denied | User rejected permission | Guide user to app settings to grant manually |
| `google-services.json` missing | Not committed to repo | Follow Firebase setup steps above |
| Image upload fails | Firebase Storage rules or network | Check storage rules, verify internet connection |

---

## Contributing

1. Fork the repository
2. Create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes following the existing code style:
   - Use `AppColors.*` — never raw hex values
   - Keep all Firebase calls inside `lib/services/`
   - No external state management packages
   - Use `withValues(alpha:)` instead of deprecated `.withOpacity()`
4. Commit with a descriptive message
   ```bash
   git commit -m "feat: add dark mode toggle"
   ```
5. Push and open a Pull Request against `main`

---

## License

This project is licensed under the MIT License.

---

<p align="center">
  <b>SpotIt</b> · Built with Flutter · Powered by Firebase · Making cities better
</p>

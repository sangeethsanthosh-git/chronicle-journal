# 📖 Chronicle — Personal Scrapbook & Journal for Android

<p align="center">
  <b>A tactile, offline-first personal journaling experience inspired by physical notebooks, scrapbooks, and archival typography.</b>
</p>

---

## 🌟 Overview

**Chronicle** is a production-quality, local-first Android journaling application built with **Flutter & Dart**. Moving beyond sterile digital note apps, Chronicle captures the warmth, texture, and nostalgia of physical paper journals, scrapbooks, polaroids, and vintage postal mail.

Every visual element connects directly to local persistent SQLite storage powered by **Drift**. There are zero placeholder screens, mock buttons, or hardcoded entries.

---

## 🎨 Visual Identity & Physical Aesthetic

- **Paper Textures & Edge Treatments**: Ruled notebook lines, dot grids, warm sepia parchment, and torn/deckled paper edges rendered with hardware-accelerated `CustomPainter`.
- **Washi Tape & Mounts**: Procedurally generated semi-translucent tape strips with serrated cuts and paper fibers in Kraft, Sage, Navy, Rose, and Ochre hues.
- **Polaroid Photo Cards**: Realistic polaroid frames with soft drop shadows, hand-written captions, and tape mounts.
- **Postal & Archival Stamps**: Vintage postal cancellation postmarks with circular date rings and wavy cancellation lines.
- **Binder Rings**: Open ring-binder visual mode with metallic silver rings and paper holes.
- **Handcrafted Doodles**: Whimsical vector stickers including sparkle stars, hearts, sunbursts, and laurel leaves.
- **7 Distinct Layout Modes**:
  1. *Classic Notebook*: Familiar lined pages with margin borders.
  2. *Scrapbook Collage*: Staggered polaroids, washi tape, and deckled paper cards.
  3. *Vintage Postcard*: Dual-column postcard layout with postal postmarks.
  4. *Ring Binder*: Editorial notebook with metallic ring binding.
  5. *Sanctuary Panorama*: Immersive hero photos and wide reading format.
  6. *Minimal Archival*: Clean monochrome typography focused on words.
  7. *Photo Diary*: Visual-first photo timeline with captions.

---

## 🛠️ Technology Stack

| Layer | Technologies |
|---|---|
| **Language & Framework** | **Dart 3.x** & **Flutter 3.x** (Android-first, multiplatform ready) |
| **UI & Styling** | **Material 3**, `CustomPainter` vector shaders, Slivers, Hero animations |
| **Architecture** | **Clean Architecture** (Feature-First) + MVVM + Repository Pattern |
| **State Management** | **Riverpod** (`flutter_riverpod`) with `Notifier` & reactive Streams |
| **Database** | **Drift** (SQLite), typed schema, foreign keys, migrations, reactive queries |
| **Navigation** | **go_router** with `StatefulShellRoute` persistent bottom navigation |
| **Audio** | `record` (voice note recording) & `audioplayers` (playback with waveforms) |
| **Location & Weather**| `geolocator` & Open-Meteo REST API via `dio` (with offline fallback) |
| **Security** | `flutter_secure_storage` + SHA-256 PIN hashing + Biometric auth |
| **Export & Backup** | `pdf` & `printing` (editorial PDF exports), JSON backups, TXT exports |
| **Code Quality** | `flutter_lints`, `dart format`, `flutter analyze`, `flutter test` |
| **CI/CD** | **GitHub Actions** (`.github/workflows/ci-cd.yml`) + **Dependabot** |

---

## 📁 Project Architecture

```
lib/
├── core/
│   ├── theme/          # AppColors, AppTypography, AppTheme
│   ├── utils/          # Location, Weather, Audio, Security, PDF, Backup, Notifications
│   └── widgets/        # CustomPainters: PaperBackground, WashiTape, PolaroidCard, etc.
├── data/
│   ├── local/          # Drift AppDatabase (Tables, DAOs, schema generation)
│   └── repositories/   # JournalRepositoryImpl, PreferencesRepositoryImpl
├── domain/
│   ├── models/         # Mood, PaperStyle, JournalLayout, JournalStatistics, etc.
│   ├── repositories/   # Abstract JournalRepository & PreferencesRepository
│   └── usecases/       # Streak calculation, statistics, memory retrieval
└── presentation/
    ├── providers/      # Riverpod providers (Database, Journal, Stats, Memories, etc.)
    ├── router/         # go_router configuration & route guards
    └── screens/        # Home, Timeline, Editor, Detail, Calendar, Search, Insights, etc.
```

---

## 🔒 Security & Privacy

- **100% Local-First**: No remote servers or cloud accounts required. All journal entries, audio recordings, and photos remain on the user's device.
- **PIN Lock & Biometrics**: Optional 4-digit PIN stored securely via encrypted key storage.
- **Safe Hardware Access**: Permissions for Microphone, Camera, Location, and Storage are requested contextually with graceful fallbacks.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.24.0` (Dart `^3.5.0`)
- Android SDK (API 34+ recommended, minSdk 24)
- Java Development Kit (JDK 17)

### Local Setup

```bash
# Clone the repository
git clone https://github.com/sangeethsanthosh-git/chronicle-journal.git
cd chronicle-journal

# Install dependencies
flutter pub get

# Generate Drift database files (if needed)
dart run build_runner build --delete-conflicting-outputs

# Run code analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run on an Android emulator or device
flutter run
```

---

## 🔐 Android Release Signing Setup

For continuous integration and production releases, release signing credentials must be configured securely.

### GitHub Secrets Required

Configure the following secrets in your GitHub repository (**Settings > Secrets and variables > Actions**):

| Secret Name | Description |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded string of your `.keystore` / `.jks` file |
| `ANDROID_KEYSTORE_PASSWORD`| Password for the release keystore |
| `ANDROID_KEY_ALIAS` | Alias name for the signing key |
| `ANDROID_KEY_PASSWORD` | Password for the key alias |

### Generating a Release Keystore

```bash
keytool -genkey -v -keystore release.keystore -alias chronicle-release -keyalg RSA -keysize 2048 -validity 10000
```

To encode it for GitHub Secrets on Linux/macOS:
```bash
base64 -w 0 release.keystore
```
On Windows PowerShell:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.keystore")) | Set-Clipboard
```

> **Note**: If release secrets are not configured, CI gracefully continues to test and build a debug APK.

---

## 📦 APK Size Optimization

To ensure fast downloads and minimal storage usage, Chronicle incorporates production-grade APK size reduction strategies:

1. **R8 Minification & Code Shrinking**: Unused classes and methods across all dependencies are stripped during Gradle release compilation (`isMinifyEnabled = true`).
2. **Resource Shrinking**: Unused Android XML layouts, drawables, and assets are stripped (`isShrinkResources = true`).
3. **Font & Icon Tree-Shaking**: Strips unused vector glyphs, reducing font sizes by **>99%** (e.g. `MaterialIcons` reduced from 1.6 MB to under 10 KB).
4. **Symbol Stripping & Obfuscation**: Dart symbols and debug maps are extracted to external symbol files (`--obfuscate --split-debug-info=...`).
5. **Per-Architecture Splitting (`--split-per-abi`)**: Generates targeted APKs for specific CPU architectures rather than bundling redundant native binaries.

### Size Comparison

| Build Variant | Size | Optimization Applied |
|---|---|---|
| **Unoptimized Fat Debug APK** | ~174 MB | None (includes Dart JIT, DevTools, multi-ABI fat binary) |
| **`app-armeabi-v7a-release.apk`** | **18.4 MB** | **89% smaller** (R8 + ProGuard + AOT + stripped symbols) |
| **`app-arm64-v8a-release.apk`** | **20.9 MB** | **88% smaller** (R8 + ProGuard + AOT + stripped symbols) |
| **`app-x86_64-release.apk`** | **22.2 MB** | **87% smaller** (R8 + ProGuard + AOT + stripped symbols) |
| **Google Play App Bundle (`.aab`)** | **~48.5 MB** | Dynamic feature delivery (**~10–18 MB** per device download) |

### Building Small APKs Locally

```bash
# Build optimized split APKs per architecture (~18–22 MB each)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

# Build production Android App Bundle for Google Play (~10–18 MB user install)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 🤖 Continuous Integration & Automation

- **GitHub Actions (`.github/workflows/ci-cd.yml`)**:
  - Pull Requests & Commits to `main`: Runs `dart format`, `flutter analyze`, `flutter test`, and builds the debug APK.
  - Tag Releases (`v*`): Compiles production Android App Bundle (AAB) & Release APK, creating an automated GitHub Release with attached binaries.
- **Dependabot (`.github/dependabot.yml`)**:
  - Automated weekly audits for GitHub Actions and Dart `pub` packages.

---

## 📄 License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

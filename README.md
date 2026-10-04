# Chronicle — Artisanal Offline-First Android Journaling

> *“Every day is a page in the book of your life. Make it worth reading.”*

**Chronicle** is a complete, production-grade Android journaling application crafted with Jetpack Compose and modern Android architecture. Inspired by the tactile intimacy of physical journals, scrapbooks, postal mail, polaroid film, washi tape, and vintage stationery, Chronicle blends nostalgic analog aesthetics with state-of-the-art mobile engineering.

Chronicle is **strictly offline-first and private**: zero tracking, zero mandatory cloud accounts, and zero data leakage. Your memories, photographs, and voice memos remain entirely on your device.

---

## ✨ Key Features & Experience

### 1. 🖋️ Rich Journal Editor & Auto-Save
- **Tactile Paper Surfaces:** Write on Plain Parchment, Ruled Notebook Lines, Dot Grid, or Aged Vintage Paper.
- **Draft Resilience:** Automatic background draft persistence saves your work continuously. If the app closes unexpectedly, your draft is immediately recovered on next launch.
- **Contextual Metadata:** Add location geocoding, live ambient weather (temperature, condition summary, sky icon), entry date/time picker, and favorite star status.
- **10 Expressive Moods with 5-Level Intensity:** Happy, Calm, Excited, Grateful, Neutral, Sad, Angry, Anxious, Tired, and Loved.

### 2. 📸 Multimodal Media Attachments
- **Photographs & Polaroids:** Modern Android Photo Picker and Camera integration. Photos are rendered in classic polaroid frames, taped scrapbook snapshots, or editorial layouts.
- **Voice Memos & Audio Player:** Built-in high-fidelity audio recorder (MPEG-4 / AAC) with a live timer, accompanied by an integrated playback bar with scrub position tracking.

### 3. 🎨 7 Visual Journal Modes
- **Classic:** Elegant typography with balanced margins, date postmarks, and subtle shadows.
- **Scrapbook:** Layered paper clippings, washi tape strips at varied angles, and nostalgic stickers.
- **Postcard:** Vintage postcard layout with stamped postage cancellation marks, dividers, and postal codes.
- **Ring Binder:** Authentic open dual-page notebook with metallic center binder rings, torn paper notes, polaroid snapshots, and reminder ribbon.
- **Sanctuary Panorama:** Panoramic editorial card featuring 3 curved triptych photo frames, location tag pill, action chips, and embedded mini-calendar widget.
- **Minimal:** Clean, distraction-free typographic layout focused strictly on words.
- **Photo Story:** Visual-first feed emphasizing photography with handwritten caption notes underneath.

### 4. 🧭 Journal Timeline & Interactive Calendar
- **Chronological Timeline:** Switch between Cards, Scrapbook, Postcards, Open Binder, Panorama, and Compact List views.
- **Sorting & Filtering:** Sort by newest, oldest, or recently edited. Filter instantly by mood, tags, favorites, photos, or voice recordings.
- **Calendar Browser:** Interactive month view highlighting days with entries and mood dots.

### 5. 🔍 Debounced Search
- Deep full-text query matching across titles, entry bodies, location names, and tags with debounced real-time Room queries.

### 6. 🕰️ "On This Day" Memories
- Time capsule engine looking back across past years (*"1 year ago today"*, *"3 years ago today"*), surfacing forgotten memories and nostalgic snapshots.

### 7. 📚 Collections
- Curate entries into thematic collections such as *Travel*, *Personal Growth*, *Ideas*, or *Family*, complete with custom cover images and entry cross-referencing.

### 8. 📊 Visual Insights & Statistics
- **Streak Tracker:** Calculates current consecutive writing streak and all-time record.
- **Mood Spectrum:** Visual distribution breakdown of emotional patterns over time.
- **Activity Charts:** Pure Jetpack Compose canvas bar charts showing monthly entry volume without heavy third-party graphing libraries.
- **Metrics:** Lifetime entries, photos attached, audio minutes recorded, and word count totals.

### 9. 🔒 App Lock & Privacy
- Biometric authentication (fingerprint / face unlock) and SHA-256 hashed 4-digit PIN lock.
- Configurable auto-lock delay.
- Privacy-first: no telemetry, no tracking SDKs.

### 10. 💾 Local Backup & Restore
- **ZIP Archive Export:** Complete bundle containing all entry database records (JSON) alongside all referenced images and voice recordings.
- **JSON Export / Import:** Structured format for easy programmatic data portability.
- **Plaintext TXT Export:** Human-readable compilation of all journal entries.
- **Integrity Validation:** Validates schema version and record consistency before restoring.

### 11. ⏰ Gentle Daily Reminders
- WorkManager periodic background worker with configurable reminder times and notification channels.

---

## 🏛️ Architecture & Tech Stack

Chronicle follows **Modern Android Architecture (MVI / MVVM + Clean Architecture)** with strict separation of concerns:

```
app/
 └── src/main/java/com/chronicle/journal/
      ├── core/
      │    ├── common/          # TimeUtils, extensions
      │    ├── designsystem/    # Colors, Typography, Shapes, Themes, Paper, Tape, Badges
      │    └── utils/           # AudioRecorder, AudioPlayer, Location, Weather, Security
      ├── data/
      │    ├── local/           # Room Database, DAOs, Entities, CrossRefs, Relations
      │    ├── repository/      # Repository implementations & mapping logic
      │    └── backup/          # BackupManager (ZIP, JSON, TXT export & restore)
      ├── domain/
      │    ├── model/           # Clean domain models (JournalEntry, Mood, Attachment, etc.)
      │    ├── repository/      # Repository interfaces
      │    └── usecase/         # Isolated business logic use cases (Streak, Stats, Memories, etc.)
      ├── presentation/
      │    ├── home/            # Home dashboard, daily prompt, quick actions
      │    ├── journal/         # Timeline, entry cards, and detailed entry view
      │    ├── editor/          # Journal writer, draft auto-save, media attachments
      │    ├── calendar/        # Calendar screen with month grid and mood indicators
      │    ├── search/          # Debounced search & multifaceted filters
      │    ├── insights/        # Dynamic Compose charts and journaling stats
      │    ├── memories/        # "On this day" nostalgia time capsules
      │    ├── collections/     # Custom collections and category management
      │    ├── settings/        # Theme, paper style, lock, reminders, backup/restore
      │    ├── onboarding/      # First-launch scrapbook walkthrough
      │    ├── lock/            # PIN keypad & biometric gate
      │    └── navigation/      # Navigation host, bottom bar, and route arguments
      ├── di/                   # Hilt Dependency Injection modules
      └── reminder/             # WorkManager ReminderWorker & ReminderScheduler
```

### Technology Highlights
| Component | Technology |
|---|---|
| **Language** | Kotlin 2.0.21 |
| **UI Toolkit** | Jetpack Compose + Material 3 (BOM 2024.12.01) |
| **Asynchronous** | Kotlin Coroutines & Reactive StateFlow |
| **Dependency Injection** | Dagger Hilt 2.52 with KSP |
| **Database** | Room 2.6.1 (SQLite) with relational entities & junctions |
| **Preferences** | Jetpack DataStore Preferences |
| **Image Loading** | Coil Compose 2.7.0 |
| **Background Scheduling**| AndroidX WorkManager 2.10.0 + Hilt Worker |
| **Biometrics** | AndroidX Biometric 1.2.0 |
| **Testing** | JUnit 4, Coroutines Test, MockK, Turbine, Room In-Memory, Compose UI Test |
| **Code Quality** | Android Lint, ktlint 12.1.2, detekt 1.23.7 |
| **CI / CD** | GitHub Actions Automated Build, Lint, Test & APK Release Pipeline |

---

## 🛠️ Build & Installation

### Prerequisites
- JDK 17 (Java Development Kit)
- Android SDK 35 (Installed via Android Studio or command-line tools)
- Gradle 8.14 (Included via Gradle Wrapper `gradlew`)

### Build Commands

```bash
# Clone the repository
git clone https://github.com/your-username/chronicle-journal.git
cd chronicle-journal

# Run all unit tests (41 tests covering use cases, repositories, viewmodels, security, backup)
./gradlew testDebugUnitTest

# Run Android Lint analysis
./gradlew lintDebug

# Run ktlint formatting check
./gradlew ktlintCheck

# Run detekt static analysis
./gradlew detekt

# Build the Debug APK
./gradlew assembleDebug

# Build the Release APK (requires signing credentials)
./gradlew assembleRelease
```

Generated APKs will be located at:
- `app/build/outputs/apk/debug/app-debug.apk`
- `app/build/outputs/apk/release/app-release-unsigned.apk`

---

## 🧪 Automated Testing

Chronicle includes a comprehensive automated test suite:
- **Unit Tests (`app/src/test/`):**
  - `CalculateStreakUseCaseTest`: Verifies consecutive streaks, gaps, same-day multiple entries, and streak freezes.
  - `GetStatisticsUseCaseTest`: Verifies lifetime totals, mood distributions, word counts, and monthly groupings.
  - `GetMemoriesUseCaseTest`: Verifies exact-day anniversary matching and spotlight candidates.
  - `GetEntriesUseCaseTest`: Verifies ordering (newest/oldest) and criteria filtering (favorites, moods, tags).
  - `SaveEntryUseCaseTest`: Verifies entity creation and persistence.
  - `DeleteEntryUseCaseTest`: Verifies soft delete propagation.
  - `SearchEntriesUseCaseTest`: Verifies text search and filter constraints.
  - `SecurityUtilsTest`: Verifies SHA-256 PIN hashing consistency and verification.
  - `BackupValidationTest`: Verifies JSON backup parsing, schema versioning, and corrupt file detection.
  - `JournalRepositoryImplTest`: Verifies Room DAO mapping to domain objects and transactional consistency.
  - `HomeViewModelTest`: Verifies state flow emissions for greetings, streaks, memories, and today's entry.
  - `JournalTimelineViewModelTest`: Verifies timeline view switching and sort/filter states.
  - `SearchViewModelTest`: Verifies 300ms query debouncing and filter updates.
- **Instrumented Tests (`app/src/androidTest/`):**
  - `JournalEntryDaoTest`: In-memory Room database tests for queries, tags, attachments, soft-deletes, and full-text search.
  - `HomeScreenComposeTest`: Compose UI node verification for typography, headers, and empty states.

---

## 🚀 Continuous Integration & Deployment (CI/CD)

The project includes an enterprise-ready GitHub Actions workflow (`.github/workflows/ci-cd.yml`):
1. **Quality Gate:** Executes `ktlintCheck`, `detekt`, and `lintDebug`.
2. **Test Suite:** Executes all JVM unit tests and generates test reports.
3. **Build Artifacts:** Compiles debug and release APKs, uploading them as workflow artifacts.
4. **Release Publishing:** When a Git tag matching `v*` is pushed, a GitHub Release is created automatically with the signed APK attached.

---

## 🔒 Privacy & Permissions

Chronicle requires minimal, optional permissions that serve user-initiated features only:
- `CAMERA`: Used strictly when capturing a photo directly inside the journal editor.
- `RECORD_AUDIO`: Used strictly when recording a voice memo inside the journal editor.
- `ACCESS_COARSE_LOCATION` & `ACCESS_FINE_LOCATION`: Used optionally when the user requests tagging their current location on an entry.
- `POST_NOTIFICATIONS`: Used on Android 13+ (API 33+) to dispatch user-scheduled daily journaling reminders.
- `INTERNET`: Used optionally to fetch current weather conditions from Open-Meteo when location is enabled. If offline, the app defaults smoothly with zero degradation.

**Zero Data Collection:** Chronicle contains no tracking libraries, no third-party advertisements, and no analytics SDKs.

---

## 📄 License

```
Copyright 2026 Chronicle Journal Contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

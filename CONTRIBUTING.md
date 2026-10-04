# Contributing to Chronicle

Thank you for your interest in contributing to Chronicle! We welcome bug reports, design improvements, and pull requests.

## Development Setup

1. **Prerequisites**:
   - JDK 21 or JDK 17
   - Android SDK (API 35, Build-tools 35.0.0+)
   - Android Studio Ladybug / Meerkat or later

2. **Clone and Build**:
   ```bash
   git clone https://github.com/sangeethsanthosh-git/chronicle-journal.git
   cd chronicle-journal
   ./gradlew assembleDebug
   ```

3. **Running Quality Checks**:
   ```bash
   ./gradlew ktlintCheck
   ./gradlew detekt
   ./gradlew lintDebug
   ./gradlew testDebugUnitTest
   ```

## Architecture Guidelines

- Follow clean architecture: `core`, `data`, `domain`, `presentation`.
- UI is strictly Jetpack Compose with Material 3.
- Persistence is offline-first via Room and DataStore.
- Business logic resides in Domain UseCases and Repositories.
- UI state is represented as immutable data classes observed via `StateFlow`.
- Test new use cases, repositories, and ViewModels.

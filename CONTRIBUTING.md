# Contributing to Chronicle

Thank you for your interest in contributing to Chronicle! We welcome bug reports, design suggestions, and pull requests.

---

## 🛠️ Development Setup

1. **Prerequisites**:
   - Flutter SDK `^3.24.0` (Dart `^3.5.0`)
   - Android SDK (API 34+, minSdk 24)
   - Java Development Kit (JDK 17)

2. **Clone and Install**:
   ```bash
   git clone https://github.com/sangeethsanthosh-git/chronicle-journal.git
   cd chronicle-journal
   flutter pub get
   ```

3. **Code Generation (Drift Database)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Running Quality Checks**:
   ```bash
   # Code formatting verification
   dart format --output=none --set-exit-if-changed .

   # Static analysis
   flutter analyze

   # Unit & widget tests
   flutter test
   ```

---

## 🏛️ Architecture & Code Guidelines

- **Clean Architecture & Feature-First**: Code is partitioned into `core/`, `data/`, `domain/`, and `presentation/`.
- **State Management**: Use **Riverpod** with `Notifier` / `AsyncNotifier`. Avoid mutable global state.
- **Local-First & Drift Database**: All journal entries and attachments are stored in local SQLite via Drift. Large binary media files (images, audio) must be stored in application directories with their paths persisted in Drift.
- **UI & CustomPainters**: Maintain the tactile paper journal and scrapbook aesthetic. Utilize the existing `CustomPainter` library for paper, tape, stamps, and torn card effects.
- **Testing**: Ensure that all new models, use cases, and repositories include unit tests under `test/`.

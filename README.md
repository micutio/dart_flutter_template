# Todo Monorepo

A multiplatform task management monorepo organized with Dart/Flutter native pub workspaces. Task prioritization is driven by the Eisenhower Matrix (Urgent vs. Important).

## Workspaces Architecture

The project contains three workspace members sharing a single dependency lockfile:

```
todo/
├── pubspec.yaml                 # Root workspace manifest
├── analysis_options.yaml        # Monorepo static analysis rules
├── CHANGELOG.md                 # Project version history
├── tool/
│   └── dev.dart                 # Cross-platform developer task runner
├── packages/
│   ├── core/                    # Core Dart library (todo_core)
│   │   ├── lib/
│   │   │   ├── todo_core.dart
│   │   │   └── src/models/      # TodoItem, TodoList, EisenhowerQuadrant
│   │   └── test/                # Core domain unit tests
│   ├── cli/                     # Native Dart CLI (todo_cli)
│   │   ├── bin/todo.dart        # CLI executable entrypoint
│   │   ├── lib/todo_cli.dart    # CLI argument parsing & commands
│   │   ├── tool/smoke_cli.dart  # Smoke tests against compiled binary
│   │   └── test/                # CLI unit tests
│   └── app/                     # Flutter Android App (todo_app)
│       ├── android/             # Android platform project
│       ├── lib/main.dart        # Flutter UI consuming todo_core
│       └── test/widget_test.dart# Flutter widget tests
└── .github/
    ├── dependabot.yml           # Automated pub and actions updates
    └── workflows/
        ├── dart.yml             # Main CI pipeline (format, analyze, fix, test, build)
        ├── dart-beta.yml        # Weekly beta SDK compatibility checks
        └── release.yml          # Multiplatform CLI & Android APK release pipeline
```

- **`todo_core` (`packages/core`)**: Pure Dart domain package holding task models, priority queues, and Eisenhower matrix logic. Has no Flutter dependency, enabling reuse across CLI, server, and client frontends.
- **`todo_cli` (`packages/cli`)**: Native command-line interface for fast task capture and viewing from the terminal. Compiles to native AOT binaries across Linux, macOS, and Windows.
- **`todo_app` (`packages/app`)**: Flutter Android application providing a rich Material 3 user interface on top of `todo_core`.

---

## Development Tasks Runner (`tool/dev.dart`)

To avoid OS differences with `make`, a cross-platform Dart runner script is available at `tool/dev.dart`:

```bash
# Show all available commands
dart run tool/dev.dart help

# Formatting & static analysis
dart run tool/dev.dart format           # Format all packages
dart run tool/dev.dart format --check   # Check formatting without modifying
dart run tool/dev.dart analyze          # Analyze with --fatal-infos
dart run tool/dev.dart fix              # Apply automated fixes
dart run tool/dev.dart fix --check      # Dry-run check for fixes

# Testing
dart run tool/dev.dart test             # Run all tests (core, cli, app)
dart run tool/dev.dart test:core        # Run core tests only
dart run tool/dev.dart test:cli         # Run CLI tests only
dart run tool/dev.dart test:app         # Run Flutter app tests only

# Building & Smoke Testing
dart run tool/dev.dart build:cli        # Compile native CLI bundle
dart run tool/dev.dart smoke:cli        # Smoke test compiled CLI binary
dart run tool/dev.dart build:app        # Build Android debug APK

# Full Local CI Verification Suite (format, analyze, fix, test, build, smoke)
dart run tool/dev.dart verify
```

---

## Development Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended, includes Dart 3.5+ with native pub workspace support)
- Git

### Getting Started

1. **Install dependencies across all workspaces:**
   ```bash
   flutter pub get
   ```

2. **Verify workspace membership:**
   ```bash
   dart pub workspace list
   ```

3. **Check formatting and linting:**
   ```bash
   dart format --output=none --set-exit-if-changed .
   dart analyze --fatal-infos
   dart fix --dry-run
   ```

4. **Run all tests:**
   ```bash
   # Core & CLI tests
   dart test packages/core
   dart test packages/cli

   # Flutter app tests
   flutter test packages/app
   ```

5. **Build and smoke test the native CLI:**
   ```bash
   cd packages/cli
   dart build cli
   dart run tool/smoke_cli.dart
   cd ../..
   ```

6. **Run the Flutter Android app (with an emulator or device connected):**
   ```bash
   cd packages/app
   flutter run
   ```

---

## CI/CD Pipeline

The GitHub Actions workflows mirror the established pattern from `cards_with_dart` and `ascii_renderer`:

- **Main CI (`.github/workflows/dart.yml`)**:
  - `format`: Verifies code formatting across all packages.
  - `analyze`: Runs static analysis with fatal infos.
  - `fix`: Asserts that `dart fix --dry-run` reports no pending automated fixes.
  - `test`: Multi-OS test matrix (`ubuntu-latest`, `windows-latest`, `macos-latest`) with Linux coverage collection.
  - `build-cli`: Multi-OS native CLI compilation and smoke testing.
  - `build-android`: Compiles Android debug APK and uploads artifact.
- **Beta Check (`.github/workflows/dart-beta.yml`)**: Weekly non-blocking sanity check against the beta SDK channel.
- **Release (`.github/workflows/release.yml`)**:
  - Triggered on tag `v*.*.*` or manual dispatch.
  - Validates matching `pubspec.yaml` version and `CHANGELOG.md` entry.
  - Builds Linux x64, macOS ARM64, and Windows x64 CLI binaries packaged in `.tar.gz` and `.zip`.
  - Builds Android release APK.
  - Generates `SHA256SUMS` and publishes draft GitHub Release with release notes.
- **Dependabot (`.github/dependabot.yml`)**: Weekly dependency update checks for Pub packages and GitHub Actions.

---

## Using This Repository as a Template

This repository is ready to be marked as a **GitHub Template Repository** (`Settings` -> check `Template repository`, or `gh repo edit --template`). When generating a new project from this template, follow this customization checklist:

### 1. Rename Project & Packages
- **Root**: Update `name:` and `description:` in root `pubspec.yaml`.
- **`packages/core`**:
  - Update `name:` in `packages/core/pubspec.yaml` (e.g., `myproject_core`).
  - Rename `lib/todo_core.dart` to `lib/<new_name>.dart`.
- **`packages/cli`**:
  - Update `name:` in `packages/cli/pubspec.yaml` (e.g., `myproject_cli`).
  - Update `executables:` map (e.g., `mytool: mytool`).
  - Rename `bin/todo.dart` to `bin/mytool.dart` and `lib/todo_cli.dart` to `lib/mytool_cli.dart`.
  - Update the dependency from `todo_core` to your new core package name.
  - In `tool/smoke_cli.dart`, update the binary name filter (`'todo'` -> `'mytool'`) and expected stdout checks.
- **`packages/app`**:
  - Update `name:` in `packages/app/pubspec.yaml`.
  - Update dependency from `todo_core` to your new core package name.
  - Update import directives across `lib/` and `test/`.

### 2. Configure Android Application ID & Namespace
In `packages/app/android/app/build.gradle.kts`:
- Change `namespace` and `applicationId` from `com.example.todo_app` to your reverse-domain identifier (e.g. `com.mycompany.myproject`).
- Update `packages/app/android/app/src/main/kotlin/.../MainActivity.kt` directory and package statement to match.
- Replace launcher icons under `packages/app/android/app/src/main/res/mipmap-*`.

### 3. Update CI/CD & Build Scripts
- **Workflows (`.github/workflows/dart.yml`, `release.yml`, `dart-beta.yml`)**:
  - Update artifact names and archive prefixes (e.g. `todo-` -> `myproject-`).
  - Update test paths if you change workspace folder names.
- **Task Runner (`tool/dev.dart`)**:
  - Update any command strings or paths if package directories or binary names change.
- **Changelog**: Reset `CHANGELOG.md` to `## 0.1.0` or `## 1.0.0` for your new project.

### 4. Re-resolve and Verify
```bash
flutter pub get
dart run tool/dev.dart verify
```

---

## Optional: Publishing Packages to pub.dev

By default, all workspace packages are set to `publish_to: none` to prevent accidental public release of private code or name collisions.

If you want to publish `todo_core` as an open-source library and `todo_cli` as a globally activatable command-line tool, follow these steps:

### 1. Requirements for pub.dev
1. **Remove `publish_to: none`**:
   Remove this line from `packages/core/pubspec.yaml` and `packages/cli/pubspec.yaml`. (Keep it in root `pubspec.yaml` and `packages/app/pubspec.yaml`).
2. **Ensure Globally Unique Names**:
   Check [pub.dev](https://pub.dev) to ensure your package names are available.
3. **Add Pana Metadata**:
   Each published package must have:
   ```yaml
   description: >-
     A concise description between 60 and 180 characters explaining what the package does.
   repository: https://github.com/<user>/<repo>
   issue_tracker: https://github.com/<user>/<repo>/issues
   topics:
     - cli
     - productivity
   ```
4. **Specify Explicit Dependency Versions**:
   Within a pub workspace, local packages can depend on sibling packages without version numbers. However, **pub.dev requires explicit versions**:
   ```yaml
   # In packages/cli/pubspec.yaml:
   dependencies:
     myproject_core: ^0.1.0 # Must match the published version of core
   ```
5. **Package-Level Files**:
   Pub.dev archives each package independently. Ensure each published package has its own:
   - `LICENSE`
   - `README.md` (documenting the package's API or CLI usage)
   - `CHANGELOG.md` (documenting versions for that package)

### 2. Validation & Publishing Sequence
Because `cli` depends on `core`, **`core` must be published first**:

```bash
# 1. Validate both packages with dry-run
cd packages/core && dart pub publish --dry-run
cd ../cli && dart pub publish --dry-run

# 2. Publish core
cd ../core && dart pub publish

# 3. Publish cli (after core is live on pub.dev)
cd ../cli && dart pub publish
```

Once published, end users can install your CLI globally:
```bash
dart pub global activate <cli_package_name>
<executable_name> --help
```

### 3. Automated Publishing via GitHub Actions (Trusted Publishing)
pub.dev supports **Trusted Publishing** using GitHub Actions OIDC (no stored tokens or secrets required):
1. In pub.dev package settings, configure GitHub Actions as the publisher (specifying repository and workflow).
2. Add a publishing job to `.github/workflows/release.yml`:
   ```yaml
   publish-pub-dev:
     name: Publish to pub.dev
     needs: [verify, test]
     runs-on: ubuntu-latest
     permissions:
       id-token: write # Required for pub.dev OIDC authentication
     steps:
       - uses: actions/checkout@v4
       - uses: dart-lang/setup-dart@v1
       - name: Publish Core
         run: dart pub publish --force
         working-directory: packages/core
       - name: Publish CLI
         run: dart pub publish --force
         working-directory: packages/cli
   ```

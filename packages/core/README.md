# todo_core

The shared core domain library for the Todo monorepo. It contains pure Dart business logic, entities, and priority queue ordering rules with zero dependencies on Flutter or platform-specific I/O.

---

## Domain Overview

- **`EisenhowerQuadrant`**: Enum representing the four quadrants of the Eisenhower decision matrix:
  - `urgentAndImportant` ("Do First")
  - `notUrgentAndImportant` ("Schedule")
  - `urgentAndNotImportant` ("Delegate")
  - `notUrgentAndNotImportant` ("Eliminate")
- **`TodoItem`**: Immutable task entity with id, title, optional description, due date, urgency, importance, and completion state. Automatically computes its target `EisenhowerQuadrant`.
- **`TodoList`**: Immutable collection managing tasks. Provides `prioritizedItems()` to sort tasks by:
  1. Completion status (incomplete tasks first).
  2. Eisenhower quadrant index (Q1 -> Q2 -> Q3 -> Q4).
  3. Impending due date (earliest deadlines first).
  4. Creation timestamp.

---

## Adapting for a New Project (Template Usage)

When using this monorepo as a template for a new project:

1. **Rename the Package**:
   - Update `name:` in `pubspec.yaml` (e.g., `myproject_core`).
   - Rename the main entrypoint library file `lib/todo_core.dart` to `lib/<new_name>.dart`.
   - Update `library;` and exports in `lib/<new_name>.dart`.
2. **Update Consuming Packages**:
   - Update dependencies in `packages/cli/pubspec.yaml` and `packages/app/pubspec.yaml` to reference the new package name.
   - Update import statements: `import 'package:todo_core/todo_core.dart';` -> `import 'package:myproject_core/myproject_core.dart';`.
3. **Replace Domain Models**:
   - Replace or adapt `TodoItem`, `TodoList`, and `EisenhowerQuadrant` with your project's domain models under `lib/src/`.
4. **Update Tests**:
   - Update tests in `test/todo_core_test.dart` to validate the new domain logic.

---

## Publishing to pub.dev (Optional)

If publishing `todo_core` to pub.dev as an independent open-source library:

1. **Remove `publish_to: none`** from `pubspec.yaml`.
2. **Choose a Globally Unique Name**: Ensure `name:` is available on [pub.dev](https://pub.dev).
3. **Add Pana Metadata**:
   ```yaml
   description: Core domain logic and task management models for the todo monorepo.
   repository: https://github.com/<your-username>/<your-repo>
   issue_tracker: https://github.com/<your-username>/<your-repo>/issues
   topics:
     - productivity
     - task-management
     - eisenhower-matrix
   ```
4. **Provide Documentation & License**:
   - Ensure this `README.md` clearly documents public APIs.
   - Add a `LICENSE` file in this directory (`packages/core/LICENSE`).
   - Add a `CHANGELOG.md` in this directory (`packages/core/CHANGELOG.md`).
5. **Dry-Run Validation**:
   ```bash
   dart pub publish --dry-run
   ```
6. **Publishing Order**: Publish `core` *before* `cli`, since `cli` depends on `core` at publish time.

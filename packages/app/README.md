# todo_app

The Flutter Android application frontend for the Todo monorepo, providing a task management UI powered by `todo_core`.

---

## Local Development & Execution

```bash
# Run widget tests
flutter test

# Run the app on an Android device or emulator
flutter run

# Build a debug APK locally
flutter build apk --debug

# Build an unsigned release APK locally
flutter build apk --release --no-codesign
```

---

## Adapting for a New Project (Template Usage)

When using this monorepo as a template for a new project:

1. **Rename the Package**:
   - In `pubspec.yaml`, update `name:` (e.g., `myproject_app`).
   - Update the dependency on the core library to match your renamed core package (e.g., `myproject_core:`).
   - Update import directives in `lib/` and `test/`.
2. **Configure Android Application ID & Namespace**:
   In `android/app/build.gradle.kts`, customize the unique bundle identifier:
   ```kotlin
   android {
       namespace = "com.yourcompany.myproject"
       defaultConfig {
           applicationId = "com.yourcompany.myproject"
           // ...
       }
   }
   ```
3. **Update Kotlin MainActivity**:
   - If you change the namespace, move `android/app/src/main/kotlin/com/example/todo_app/MainActivity.kt` to match your new package path (e.g., `com/yourcompany/myproject/MainActivity.kt`) and update the `package` declaration at the top of the file.
4. **App Branding & Icons**:
   - Replace launcher icons under `android/app/src/main/res/mipmap-*`.
   - Update the app display name in `android/app/src/main/AndroidManifest.xml` (`android:label="My Project"`).
5. **Release Signing**:
   - Create an upload keystore (`key.jks`) and create `android/key.properties` (kept ignored by `.gitignore`).
   - Configure signing configs in `android/app/build.gradle.kts` for Google Play deployment.
6. **Note on `publish_to: none`**:
   - End-user Flutter applications are distributed through app stores (Google Play, F-Droid) or standalone APK releases, so `publish_to: none` should remain in `pubspec.yaml`.

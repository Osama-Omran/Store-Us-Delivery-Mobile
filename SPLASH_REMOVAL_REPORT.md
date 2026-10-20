# Store Us Delivery splash removal

Implemented on 2026-10-19. The application adds no splash route, artwork, animation, minimum display time, or first-frame hold. Android and iOS retain their required native launch infrastructure.

## Modified and added files

| Path | Change |
| --- | --- |
| `android/app/src/main/res/values/styles.xml` | Plain opaque `#F2F4F6` launch and normal window backgrounds; no deleted drawable reference. |
| `android/app/src/main/res/values-night/styles.xml` | Same plain background in device dark mode. |
| `android/app/src/main/res/values-v31/styles.xml` | Plain Android 12+ background; removed custom icon and icon-background configuration. |
| `android/app/src/main/res/values-night-v31/styles.xml` | Same Android 12+ behavior in device dark mode. |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard` | Removed both image views, image constraints, and image declarations; retained the root view with plain `#F2F4F6`. |
| `ios/Runner/Base.lproj/Main.storyboard` | Matched the Flutter controller's native background to `#F2F4F6`. |
| `lib/app/main.dart` | Starts deferred work after `runApp()` only when required initialization succeeded; preserves existing initialization error handling. |
| `lib/core/helpers/functions/initializer.dart` | Retains required local/service readiness before rendering and schedules noncritical work after the first rasterized frame. |
| `lib/core/helpers/functions/deferred_startup.dart` | Added a small first-frame gate that runs independent tasks with separate error handling. |
| `lib/core/helpers/offline_sync/offline_sync_service.dart` | Initializes the notification plugin without prompting and no longer awaits initial queue replay before rendering. |
| `test/core/helpers/functions/deferred_startup_test.dart` | Added five behavior tests for frame gating, concurrency, failures, and single execution. |
| `SPLASH_REMOVAL_REPORT.md` | This file inventory and validation report. |

The two API 31 styles files already existed as untracked files at implementation start. Their existing unrelated theme settings were preserved. The existing `ios/Runner/Info.plist` and `pubspec.lock` working-tree changes were left intact.

## Deleted splash resources

- `ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md`
- `ios/Runner/Assets.xcassets/LaunchBackground.imageset/Contents.json`
- `ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png`

The LaunchBackground files were untracked generated assets. The following deletions were already staged and have been preserved:

- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`

No source splash PNGs or splash configuration file remained in the project at implementation start. No active screen assets or launcher icons were deleted.

## Dependency and startup behavior

`flutter_native_splash` was already absent from `pubspec.yaml` and `pubspec.lock`. Dependency resolution confirmed it is absent from the resolved package configuration and plugin metadata. No replacement dependency was added, no unrelated packages were upgraded, and the splash generator was not run.

Before `runApp()`, startup still prepares the Flutter binding, edge-to-edge mode, preferences, secure token, GetIt/Dio, cache connectivity, offline outbox database/pruning, persisted offline API URL, Workmanager registration, and notification plugin. Scheduler and database readiness remain mandatory before UI requests can enqueue offline work.

After `waitUntilFirstFrameRasterized` completes, three tasks start independently: notification permission requests, the initial offline sync check/replay, and Remote Config initialization. A failure or pending permission/network response does not prevent the other tasks from starting or hold the first frame. The existing periodic retry timer and lifecycle observer remain intact.

Authentication and GoRouter code were unchanged: a saved nonempty token selects the existing authenticated layout; otherwise the existing login route is selected. Legitimate loading indicators inside actual screens remain. Native manifests, launcher icons, permissions, Maps integration, delegates, Xcode launch references, and signing settings were not changed.

## Executed validation

| Check | Actual result |
| --- | --- |
| `flutter pub get` | Passed before validation and again after cleaning; no splash dependency. |
| `dart format lib` | Executed successfully. Existing formatting differences in 48 unrelated files were restored byte-for-byte to keep the change focused. Changed startup files and the new test are formatted. |
| `flutter analyze` | Passed with no issues. A subsequent `--no-pub` analysis after the clean also passed. |
| `flutter test --no-pub test/core/helpers/functions/deferred_startup_test.dart` | All five tests passed. |
| `flutter clean` | Completed successfully, followed by `flutter pub get`. |
| `flutter build apk --debug --no-pub -t lib/app/main.dart` | Passed; produced `build/app/outputs/flutter-apk/app-debug.apk`. Kotlin daemon connection errors occurred, but compilation recovered and the build completed successfully. |
| `flutter run --no-pub -t lib/app/main.dart -d emulator-5556 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk` | Installed and launched successfully after the isolated emulator finished booting. An earlier attempt while system services were still booting failed to install. |
| Native XML and resource checks | All four Android styles and both storyboards parsed; launch/normal backgrounds match; no deleted artwork references. APK resource inspection confirms the opaque backgrounds and zero splash-named archive entries. |
| Protected-code diff check | Router, app builder, authentication/session storage, offline cache/worker, native activity/delegates, and manifest files were unchanged by this implementation. |

The five automated tests verify that tasks do not start before the first frame, a pending task does not block its siblings, synchronous/asynchronous task failures are isolated, a failed frame skips deferred work, and completing tasks does not rerun them. They make no API requests.

## Device results and limits

Used a fresh, isolated Android 16 / API 36 emulator on port 5556, with AVD files and logs under ignored `build/startup-validation/`. The user's existing emulator on port 5554 was not modified.

- Fresh installation reached the existing login screen. The system notification permission prompt appeared after Flutter rendered; denying it did not prevent login from remaining usable.
- Relaunch after terminating the process reached login. An early debug `am start -W` wait timed out while the first frame completed shortly afterward; later fully booted emulator checks completed normally.
- Activity relaunch reported `LaunchState: WARM`, `Status: ok`, and 4,742 ms total time.
- With airplane mode enabled, Wi-Fi/data disabled, device dark mode enabled, and notifications denied, process-free launch reported `LaunchState: COLD`, `Status: ok`, and 6,196 ms total time. UI hierarchy and screenshot inspection confirmed the real login form with two input fields and no permission overlay.
- The offline outbox database and Workmanager job were present after startup. No AndroidRuntime crash was logged during the tested launches.

These debug/headless-emulator timings include Flutter engine and required initialization work; they are not a minimum display time or production performance guarantee. Screenshots, launch command results, and runtime logs are retained under `build/startup-validation/`.

Authenticated navigation, populated offline cache recovery, and replay of real queued requests were not device-tested because no authenticated session/test data was available. Their implementations and session isolation remain unchanged. Android 12 and older image installations were incomplete; Android 13/14 were unavailable. iOS compilation/device testing requires a macOS/Xcode environment and was not executed.

Runtime testing exposed an existing Firebase configuration issue: no default Firebase app is initialized before Remote Config is used. The deferred task catches/logs this error after the screen appears. Firebase configuration was not changed.

## Remaining operating system behavior

Android 12+ can show the existing launcher icon on its mandatory system launch surface until Flutter is ready; this was observed on API 36. No custom icon override, exit animation, transparent workaround, or additional splash Activity was added. iOS retains its required plain launch storyboard. The neutral native background matches the existing login/theme background; the authenticated layout's existing white surfaces remain unchanged.

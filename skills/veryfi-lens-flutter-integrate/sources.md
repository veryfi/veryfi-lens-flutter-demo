# Pinned source

Read this tree. Do not bump it from this skill. Do not edit it from this skill.

| | |
|--|--|
| Plugin | Flutter |
| Path | `/Users/veryfij/plugins/veryfi-lens-flutter-plugin` |
| Commit | `307c6bc6f18b502d9bec45289517099da581dc0c` |
| Package name | `veryfi` |
| Version | `2.0.59` (`pubspec.yaml`) |
| Dart | `flutter-plugin-veryfi-lens/lib/lens.dart` |
| iOS bridge | `flutter-plugin-veryfi-lens/ios/veryfi/Sources/veryfi/VeryfiPlugin.swift` |
| Android bridge | `flutter-plugin-veryfi-lens/android/src/main/kotlin/com/veryfi/flutter/VeryfiPlugin.kt` |
| Android Gradle | `flutter-plugin-veryfi-lens/android/build.gradle` |
| iOS package | `flutter-plugin-veryfi-lens/ios/veryfi/Package.swift` |

| Platform | Linked Lens |
|----------|-------------|
| iOS | `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git` from `3.0.19` |
| Android | `com.veryfi.lens:veryfi-lens-sdk:2.7.0.2` |

`veryfi-lens-spm.git` is the Full UI package. The Android coordinate has no flavor suffix and is the Full UI artifact.

## What was read

- Public methods on `Veryfi` in `lens.dart`, including the `imageSourceData` channel key
- iOS `handle`: success paths of `initLens`, `showCamera`, `setDelegate`, `retryAllPackages`, `discardAllPackages`, `shareOCRFeedback`, and `observeAnalyticsEvents` do not call `result`. `retryPackage` calls `result` only in the error branch (`imageSourceTag` missing). `discardPackage` calls `result` only when `packageID` is missing
- Android `onMethodCall`: the same success paths omit `result.success`. `retryPackage` and `discardPackage` call `result.error` only for an empty id. Unknown methods call `result.notImplemented()`
- `pubspec.yaml` Dart `^3.11.0` and Flutter `>=3.41.0`
- Gradle `minSdkVersion` 23 and the Maven username/password env vars

## Not verified by unpacking or running

- Models embedded in the resolved `VeryfiLens.xcframework`
- Android `initWithJsonObject` for every recipe key on `2.7.0.2`
- Flavor-checker strings on `2.7.0.2` (Full rules are taken from the Android SDK contract at `2.7.0.4`; see [clarifications.md](clarifications.md))
- That `flutter pub get` succeeds without the private SSH key and Maven env
- Device behavior of barcode JSON on Android

## Validate

```sh
python3 .cursor/veryfi-lens-flutter-integrate/scripts/validate.py
```

## Files in this pack

- [SKILL.md](SKILL.md)
- [install.md](install.md)
- [syntax.md](syntax.md)
- [platforms.md](platforms.md)
- [implementation.md](implementation.md)
- [recipes.md](recipes.md)
- [settings-groups.md](settings-groups.md)
- [settings-catalog.md](settings-catalog.md)
- [conflicts.md](conflicts.md)
- [clarifications.md](clarifications.md)
- [troubleshooting.md](troubleshooting.md)
- [parity.md](parity.md)
- [unbridged.md](unbridged.md)
- [sources.md](sources.md)
- [templates/full.md](templates/full.md)
- [templates/receipts.md](templates/receipts.md)
- [templates/long-receipts.md](templates/long-receipts.md)
- [templates/checks.md](templates/checks.md)
- [templates/credit-cards.md](templates/credit-cards.md)
- [templates/business-cards.md](templates/business-cards.md)
- [templates/barcodes.md](templates/barcodes.md)
- [templates/ocr-code-strips.md](templates/ocr-code-strips.md)
- [templates/ocr-code-caps.md](templates/ocr-code-caps.md)
- [templates/w2.md](templates/w2.md)
- [templates/w9.md](templates/w9.md)
- [templates/any-documents.md](templates/any-documents.md)

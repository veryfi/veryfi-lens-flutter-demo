# Install

Pinned plugin: package name `veryfi`, version `2.0.59`. Import `package:veryfi/lens.dart`. Commit in [sources.md](sources.md).

`pubspec.yaml` environment in this commit: Dart `sdk: ^3.11.0`, Flutter `>=3.41.0`. Older public docs that say Flutter `3.19.3` do not match this commit.

```yaml
dependencies:
  veryfi:
    git:
      url: git@bitbucket.org:veryfi/flutter-plugin-veryfi-lens.git
      ref: [VERSION]
```

Method channel `veryfi`. Analytics event channel `lens_analytics_events`.

## What the plugin links

| Platform | Artifact in this commit | Role |
|----------|-------------------------|------|
| iOS | SPM `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git` from `3.0.19` (`ios/veryfi/Package.swift`). Deployment target iOS 13 | Full UI package |
| Android | `com.veryfi.lens:veryfi-lens-sdk:2.7.0.2` (`android/build.gradle`) | Full UI AAR. No flavor suffix. `minSdkVersion` 23. `compileSdkVersion` 35. ABIs `armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64` |

Do not add a second Lens pod, SPM repo, or Maven artifact.

The README says Android min SDK 21 and Kotlin `1.5.31`. The plugin `android/build.gradle` sets `minSdkVersion` 23 and Kotlin `1.9.0` (`ext.kotlin_version`). Follow the Gradle file.

## Android Maven

`android/build.gradle` uses the releases repository `https://nexus.veryfi.com/repository/maven-releases/` and reads:

- `MAVEN_VERYFI_USERNAME`
- `MAVEN_VERYFI_PASSWORD`

It does not read `MAVEN_VERYFI_URL`. Veryfi provides the username and password. Keep them in the environment or CI secrets. Do not copy a password into the repo.

## iOS usage strings

The README lists camera, location always, location when in use, photo library add, photo library, contacts, and calendars. Add a usage string only for a feature the recipe turns on.

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | `showCamera` |
| `NSPhotoLibraryUsageDescription` | `galleryIsOn` |
| `NSPhotoLibraryAddUsageDescription` | only if `backupDocsToGallery` is true. Base recipe sets it false |
| `NSLocationWhenInUseUsageDescription` | only if `locationServicesIsOn` is true. Base recipe sets it false |

Leave location-always, contacts, and calendars out. Those README entries are not required by these recipes. Dictation is obsolete. Do not add microphone or speech strings to turn `dictateIsOn` on.

`backupDocsToiCloud` stays false unless the host wants every scan copied into iCloud. This plugin does not merge an iCloud entitlement. Add the entitlement only if the host turns iCloud backup on.

## Credentials

```dart
{
  'url': 'https://api.veryfi.com/',
  'clientId': clientId,
  'userName': username,
  'apiKey': apiKey,
}
```

The key is `userName`, matching Android `rawCredentials["userName"]` and iOS `Keys.userName`. A missing credentials or settings map returns Flutter error `lensInitError` (`Credentials and settings must be sent to initialize the Lens SDK`). A present map calls native `configure` and does not complete the method channel. Dispatch it with `unawaited`. See [syntax.md](syntax.md).

## After install

Continue with [syntax.md](syntax.md) and one template.

# Troubleshooting

Use the symptom. Do not add a native call this plugin does not export. Field names are in [implementation.md](implementation.md). Platform splits are in [platforms.md](platforms.md).

## Camera never opens

`invokeMethod` dispatches the native call and returns a `Future` that completes only when native calls `result`. The success paths of `initLens` and `showCamera` never do that, on iOS or Android. Awaiting `initLens` therefore never continues, and a `showCamera` written after that await never runs. Use `unawaited` for both, after `Veryfi.setDelegate`. Do not invent a timeout or a configure-success callback. The missing result is a plugin source gap, not a bad recipe key. See [syntax.md](syntax.md).

- `setDelegate` before init and show. Events are method-channel calls named `veryfiLensClose`, `veryfiLensError`, `veryfiLensSuccess`, `veryfiLensUpdate`. The Dart handler ignores any other name.
- Android Full: `credit_card` or `code` is rejected by the flavor check. The camera stays closed and there is no Lens delegate event.
- iOS `showCamera` no-ops when `getTopViewController()` is nil, and it does not return an error.
- Android empty client id is not a special plugin string here. Credentials are copied with `.toString()`, so a null value becomes the string `"null"` and native configure decides. There is no separate empty-client-id error string.
- Private git and Maven credentials must be present. Missing `MAVEN_VERYFI_USERNAME` or `MAVEN_VERYFI_PASSWORD` fails the Android build.

## Events never arrive

`setDelegate` must run so `lensEventHandler` is non-null and `setMethodCallHandler` is installed. A handler set after the camera already closed misses those calls. There is one handler, not an event emitter.

Analytics uses `analyticsStream`. Camera events are not delivered there. Call `observeAnalyticsEvents` once.

## Wrong document or no extraction

The plugin does not switch binaries per document. `documentTypes` and `dataExtractionEngine` do.

- `"mobile"` only for `credit_card`, `code`, `barcode`.
- Credit card data stays on device.
- More than one type needs `showDocumentTypes: true`.
- `"custom"` is in the README and is not an iOS engine value.
- OCR caps versus strips is `ocrType` `caps` or `strips` with `documentTypes: ["code"]`. Android Full rejects `code`.
- Checks do not gain TIFF from a setting on this Full link.

## Gallery, files, or upload

This plugin exports camera only. `galleryIsOn` and `showBrowserButton` are in-camera. `browseIsOn` does nothing useful while `moreMenuIsOn` is false.

Headless products are unsupported. Do not approximate them with `showCamera`.

## Retry returns `retryPackageError`

The Dart call already passes `packageID`, `metadata`, and `imageSourceTag`. `lens.dart` sends the tag as `imageSourceData`. iOS reads `imageSourceTag`, the `if let` fails, and the plugin calls `result` with `retryPackageError` ("Package ID must be sent to retry the upload"). That text is wrong about the cause. Do not add another argument. Android ignores the tag and, when `packageID` is non-empty, calls `retryUpload` without `result.success`, so that future stays pending. Use `unawaited` on both platforms. Do not await it: Android success never resumes.

## `showInfoButton` shows nothing

Expected. The setting is a `VeryfiInfoView` or an Android `Fragment`, not a Flutter widget. See [unbridged.md](unbridged.md).

## Local files disappear

Set `autoDeleteLocalResourcesAfterProcessing` false when the host must read `data` paths later. Copy the file in the update handler when the flag stays true. There is no `getFileBase64`. `clearLensStorage()` is not bridged. `discardPackage` does not delete retained images.

## Photos fill up

`backupDocsToGallery` was left at the native default true, or `moreMenuIsOn` is true and the user turned backup on. Set both backups false and the More menu false.

## Stale README

| README says | Source says |
|-------------|-------------|
| `VeryfiLensCredentials` / `VeryfiLensSettings` property setters | `Veryfi.initLens(Map, Map)` |
| Credit-card sample uses `:` between property and value | Not valid Dart, and those setters do not exist |
| Android min SDK 21 and Kotlin `1.5.31` | `minSdkVersion` 23 and Kotlin `1.9.0` in `android/build.gradle` |
| `dataExtractionEngine` `custom` | iOS decoder accepts `api`, `mobile`, `none` |
| Flutter `3.19.3` in older docs | This `pubspec.yaml` requires Flutter `>=3.41.0` and Dart `^3.11.0` |

## Install failures

SSH access to the Bitbucket plugin repo, and `MAVEN_VERYFI_USERNAME` / `MAVEN_VERYFI_PASSWORD`. This skill does not store those secrets.

# Call syntax

Settings values live in [recipes.md](recipes.md). This file is the call shape in `lib/lens.dart` and the native handlers behind it.

Import `package:veryfi/lens.dart`. Class `Veryfi`. There is no `VeryfiLensCredentials` or `VeryfiLensSettings` type in that file.

`setDelegate` registers the Dart handler and invokes native `setDelegate`. Call it before `initLens` and `showCamera`. `initLens` sends credentials and settings. `showCamera` presents the Lens camera. Events are maps, not JSON strings. There is no `event` field. Switch on `LensEvent`.

`invokeMethod` inside these methods dispatches the native call as soon as the Dart function runs. The returned `Future` completes only when native calls `result`. On the success path, this pinned plugin does not. Waiting on that `Future` never resumes, so a later `showCamera` that is sequenced after an awaited `initLens` never runs and the camera never opens.

Use `unawaited` from `dart:async`. That still calls `invokeMethod`. It does not wait for a result this plugin never sends. There is no configure-ready signal. Dispatch init, then show. Whether configure has finished before the camera opens is a plugin source gap. Do not invent a success callback, a delay, or a poll.

```dart
import 'dart:async';
import 'package:veryfi/lens.dart';

void onLens(LensEvent event, Map<String, dynamic> response) {
  switch (event) {
    case LensEvent.close:
      break;
    case LensEvent.update:
      final msg = response['msg'];
      final path = response['data'];
      if (msg == 'img_original_path' ||
          msg == 'img_thumbnail_path' ||
          msg == 'img_stitched_pdf_path') {
        // path is a file path. Read it with dart:io. There is no getFileBase64.
      }
      break;
    case LensEvent.success:
      break;
    case LensEvent.error:
      break;
  }
}

void startLens(Map<String, dynamic> settings) {
  Veryfi.setDelegate(onLens);
  unawaited(Veryfi.initLens({
    'url': 'https://api.veryfi.com/',
    'clientId': clientId,
    'userName': username,
    'apiKey': apiKey,
  }, settings));
  unawaited(Veryfi.showCamera());
}
```

## Which futures complete

Success means native called `result` / `result.success` after the work. Error means native called `result` with `FlutterError` / `result.error`. A blank cell is "never calls `result` on that path."

| Dart method | iOS success | iOS error | Android success | Android error | Host |
|-------------|-------------|-----------|-----------------|---------------|------|
| `initLens` | no | `lensInitError` when maps are missing | no | `lensInitError` when maps are null | `unawaited` |
| `showCamera` | no | no | no | no | `unawaited` |
| `setDelegate` | no | no | no | no | Call it. It is `void`. `lens.dart` already drops the `invokeMethod` future |
| `retryPackage` | no (branch not taken in this commit) | `retryPackageError`, because Dart sends `imageSourceData` and iOS reads `imageSourceTag` | no | `retryPackageError` when `packageID` is empty | `unawaited` |
| `retryAllPackages` | no | no | no | no | `unawaited` |
| `discardPackage` | no | `discardPackageError` when `packageID` is missing | no | `discardPackageError` when `packageID` is empty | `unawaited` |
| `discardAllPackages` | no | no | no | no | `unawaited` |
| `shareOCRFeedback` | no | no | no | no | `unawaited` |
| `observeAnalyticsEvents` | no | no | no | no | `unawaited` |
| Unknown method | `FlutterMethodNotImplemented` | — | `result.notImplemented()` | — | Do not call |

No success path in that table calls `result`. Do not await any of them. iOS `retryPackage` does complete, with an error, because the tag key never matches. Android `retryPackage` with a non-empty id does not. One `await` cannot be valid on both platforms.

`setDelegate` must stay first. It assigns `lensEventHandler` and `setMethodCallHandler` before the native camera can emit.

## Events

Native method names handled in Dart: `veryfiLensClose`, `veryfiLensError`, `veryfiLensSuccess`, `veryfiLensUpdate`. Any other name is ignored.

| Native delegate | Dart |
|-----------------|------|
| `veryfiLensClose` | `LensEvent.close` |
| `veryfiLensUpdate` | `LensEvent.update` |
| `veryfiLensSuccess` | `LensEvent.success` |
| `veryfiLensError` | `LensEvent.error` |

The handler receives `Map<String, dynamic>`. Payload fields are in [implementation.md](implementation.md). The bridge does not add an `event` string.

## Other calls

```dart
import 'dart:async';

unawaited(Veryfi.retryPackage(packageId, metadata, imageSourceTag));
unawaited(Veryfi.retryAllPackages());
unawaited(Veryfi.discardPackage(packageId));
unawaited(Veryfi.discardAllPackages());
unawaited(Veryfi.shareOCRFeedback());
unawaited(Veryfi.observeAnalyticsEvents());
Veryfi.analyticsStream.listen((event) {});
```

`lens.dart` puts the tag on the channel under the key `imageSourceData`:

```dart
'retryPackage', {
  'packageID': packageID,
  'metadata': metadata,
  'imageSourceData': imageSourceTag,
}
```

iOS `VeryfiPlugin.swift` reads `imageSourceTag`. Those names differ, so the iOS `if let` fails and the plugin returns `retryPackageError` ("Package ID must be sent to retry the upload") even when the Dart caller passed a tag and a package id. Do not add a second Dart parameter. The public method already takes `imageSourceTag` and hardcodes the channel key. Android retry uses `packageID` only and does not read `imageSourceData` or `imageSourceTag`. A non-empty id calls `retryUpload` and does not complete `result` on that success path either.

`discardPackage` on Android returns `discardPackageError` with the detail string "Package ID must be sent to retry the upload" when the id is empty. That wording is the source string. It is still the discard error.

Call `observeAnalyticsEvents` once, with `unawaited`. The Dart method subscribes to `EventChannel('lens_analytics_events')` before it waits on `invokeMethod`, so the listen is registered even though the future stays pending. Events arrive on `Veryfi.analyticsStream` as maps. iOS forwards `VeryfiLensAnalyticsEvent` notification JSON. Android registers for `com.veryfi.lens.VeryfiLensSecureAnalyticsEvent` with permission `${packageName}.permission.ANALYTICS_EVENT`.

## Not on this plugin

`showGallery`, `showDocumentBrowser`, `closeCamera`, `getFileBase64`, `uploadImages`, Headless, Lite, help-button events, `VeryfiInfoView`. Image paths still arrive on `LensEvent.update` as `data` when the native payload includes them. The host reads the file itself.

`showInfoButton` in the map is not a Flutter widget. See [unbridged.md](unbridged.md).

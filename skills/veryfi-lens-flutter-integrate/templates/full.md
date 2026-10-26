# Full UI

Use this when the host needs the widest capture list that this Flutter plugin can actually run: receipts, invoices, and `other`, with gallery and a Files button inside the Lens camera. It is the Full binary the plugin already links (`veryfi-lens-spm` from `3.0.19`, Android `veryfi-lens-sdk:2.7.0.2`). It is not a second package, and it is not a substitute for a native Checks, Credit Cards, OCR, or Headless flavor.

Android Full also allows `long_receipt` in the same binary. iOS embedding of `long_receipt` in this SPM package is **Unconfirmed**. Leave it out of `documentTypes` until support confirms, then add `'long_receipt'` and keep `showDocumentTypes` true. Narrower products have their own templates.

Client settings are the map below. Do not construct `VeryfiLensSettings` in Dart. The README classes are not in `lens.dart`.

## Install

[install.md](../install.md). Camera usage string is required. Photo library is required because this recipe sets `galleryIsOn`. Photo library add stays unnecessary because gallery backup is false. Location stays off.

## Permissions the recipe needs

| Platform | Need |
|----------|------|
| iOS | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` |
| Android | Camera permission is merged by the Lens AAR when the camera opens. Do not add location |

## Settings

Base hardening, then the Full recipe. `showBrowserButton` is the Files entry because the More menu is off, so `browseIsOn` would not show a row.

```dart
final settings = <String, dynamic>{
  // Dashboard lens_settings must not replace this object.
  'ignoreRemoteSettings': true,
  // Native default copies every scan into Photos / the gallery.
  'backupDocsToGallery': false,
  // iOS only. Android ignores iCloud. Leave false.
  'backupDocsToiCloud': false,
  'moreSettingsMenuIsOn': false,
  'moreMenuIsOn': false,
  // Default true would still auto-capture document type "other".
  'autoCaptureOtherIsOn': false,
  'showNoDocumentDetectedWarning': false,
  'dictateIsOn': false,
  'locationServicesIsOn': false,
  // Android default true. Suboptimal glare gate.
  'glareDetectionIsOn': false,
  // Device screenshots of Lens. Not the imported-screenshot policy.
  'enableScreenshots': true,

  'dataExtractionEngine': 'api',
  'documentTypes': ['receipt', 'invoice', 'other'],
  'showDocumentTypes': true,
  'defaultSelectedDocumentType': 'receipt',
  'autoSubmitDocumentOnCapture': false,
  'batchUploadOnCamera': false,
  'imagePreviewIsOn': true,
  'galleryIsOn': true,
  'browseIsOn': false,
  'showBrowserButton': true,
  'autoCaptureIsOn': false,
  'autoDocDetectionAndCropIsOn': true,
  'autoRotateIsOn': true,
  'autoSkewCorrectionIsOn': true,
  'cleanBorderIsOn': true,
  'dewarpingIsOn': false,
  'stitchIsOn': true,
  'stitchOtherIsOn': false,
  'multipleDocumentsIsOn': true,
  'multiplePagesCaptureIsOn': true,
  'singleScanPackages': false,
  'returnStitchedPDF': true,
  'packageMaxScans': 10,
  'closeCameraOnSubmit': true,
  'sameFileUploadPreventionPolicy': 'session',
  'allowSubmittingScreenshots': true,
  'webhookIsOn': false,
};
```

`multiplePagesCaptureIsOn` keeps side-by-side crops in one image. `multipleDocumentsIsOn` asks on submit whether several images are separate packages. They are not one switch.

If the host reads files after the callback or keeps several packages, also set `autoDeleteLocalResourcesAfterProcessing: false`. Otherwise copy the file at `response['data']` during `LensEvent.update`. There is no base64 helper. See [implementation.md](../implementation.md).

## Wire-up

`initLens` dispatches configure. `showCamera` dispatches the camera. Neither platform calls the method-channel success `result`, so those futures stay pending. `unawaited` sends both calls. It does not wait. There is no configure-ready signal, and this plugin does not tell the host when configure finished. Do not invent one.

```dart
import 'dart:async';
import 'package:veryfi/lens.dart';

void onLens(LensEvent event, Map<String, dynamic> response) {
  switch (event) {
    case LensEvent.update:
      final msg = response['msg'];
      final path = response['data'];
      if (msg == 'img_original_path' ||
          msg == 'img_thumbnail_path' ||
          msg == 'img_stitched_pdf_path') {
        // Read the file at path before the next capture if auto-delete stays true.
      }
      break;
    case LensEvent.success:
      // Cloud extract: status "done", msg "results", body in data.
      // Also accept status "fail" (iOS) and "failed" (Android).
      break;
    case LensEvent.error:
      break;
    case LensEvent.close:
      // session_scan_count, queue_count, framework-version, framework-build.
      break;
  }
}

void startFull() {
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

## Decoupled variant

Customer runs Process a Document. Keep the same capture keys and replace the engine:

```dart
settings['dataExtractionEngine'] = 'none';
settings['uploadWithoutProcessingIsOn'] = false;
settings['autoDeleteLocalResourcesAfterProcessing'] = false;
```

Success `data` can include `local_package_path`. For a remote package set `uploadWithoutProcessingIsOn: true` and read `bucket` and `package_path`. Lens will not extract.

## Conflicts to re-check

[conflicts.md](../conflicts.md). Residual risks: configure readiness is not signaled, so show can be dispatched before configure finishes; Android may Toast and never open if a type is illegal; iOS `retryPackage` returns `retryPackageError` because the channel key is `imageSourceData`.

## Do not

- Add `credit_card` or `code` to this list
- Add `long_receipt` on iOS before support confirms the model
- Turn on `moreMenuIsOn` to expose Browse. Use `showBrowserButton`
- Set `dictateIsOn`
- Leave gallery or iCloud backup on
- Call a Headless or Lite API. They are not on this plugin
- Copy the README sample that assigns settings with colons

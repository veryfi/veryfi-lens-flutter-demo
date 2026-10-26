# Callbacks, files, and entry points

Events are `LensEvent` plus a `Map`. Keys stay the native snake_case names. The bridge does not add `event` and does not filter the rest. Do not invent keys.

## Entry points

| Need | On this plugin |
|------|----------------|
| Lens camera | `unawaited(Veryfi.showCamera())` after `Veryfi.setDelegate` and `unawaited(Veryfi.initLens(...))` |
| In-camera gallery | `galleryIsOn: true` inside that camera. There is no `showGallery` |
| Files from the camera | `showBrowserButton: true` or `galleryIsOn` + `galleryButtonWithFilesIsOn: true`. `browseIsOn` only fills the More menu, and the base recipe turns that menu off |
| Standalone gallery or document browser | **Unavailable.** Native `showGallery` / `showDocumentBrowser` could be ported |
| Close the camera from Dart | **Unavailable.** Native `closeCamera` could be ported |
| Upload files the host already has | **Unavailable.** Native UI-SDK `uploadImages` could be ported. That method is still the UI SDK, not Headless |
| In-memory iOS `headlessUpload` | **Unavailable.** Not a Headless product either |
| Base64 helper | **Unavailable.** Read the file at `response['data']` |

Do not open two Lens cameras. A second `showCamera` starts another present on both platforms. `initLens` configures again.

## Callback moments

| `LensEvent` | When | What to do |
|-------------|------|------------|
| `update` | Often. Thumbnail path, original path, stitched PDF, upload progress | Not finished extraction. Copy files here if you need them |
| `success` | Processing finished for a package | Read the body. For cloud extract, README shape is `status` `"done"`, `msg` `"results"`, body in `data` |
| `error` | Upload, process, config, or exception | Read `status`, `error` or `exception`, `msg` |
| `close` | The Lens UI session ended | Not a substitute for success. README fields: `session_scan_count`, `queue_count`, `framework-version`, `framework-build` |

Update image fields the README names: `msg` of `img_thumbnail_path`, `img_original_path`, or `img_stitched_pdf_path`; `data` is the path; `package_id` may be present.

Flutter README progress shape: `msg` `progress`, `data` a percent, `status` `inprogress`. Cleared package: `msg` `clear_package`, `status` `removed`. Trust this plugin's README, and still tolerate extra native keys.

Success envelope for a cloud package: `msg` `results`, `data`, `package_id`, `status` `done`.

Error: `status` `error` plus `error`, or `status` `exception` plus `exception`, plus `package_id`. iOS also uses `status` `"fail"`. Android uses `"failed"`. Handle both.

Barcode and OCR successes on iOS pass `BarcodeResult` / `OCRResult` JSON directly, without the package envelope. This plugin forwards that map. Do not require `status == "done"` for those types. Android's barcode field list on `2.7.0.2` is **Unconfirmed**. Android Full rejects `code`. `barcode` is allowed on Android Full.

### Engine and the success body

| `dataExtractionEngine` | Result |
|------------------------|--------|
| `"api"` | Veryfi Cloud processes the package. Extraction is in `data` when `status` is `done` |
| `"mobile"` | On-device extract for `credit_card`, `code`, or `barcode` only. Credit card data never leaves the device |
| `"none"` | Lens does not call Process a Document. `uploadWithoutProcessingIsOn: false` keeps a local package; with auto-delete off, success `data` can include `local_package_path`. `uploadWithoutProcessingIsOn: true` uploads and returns remote `bucket` and `package_path` |

`"custom"` is in the plugin README and is not an iOS decoder value. Do not emit it.

## Local files and who deletes them

Paths in `update` point at app storage.

| Kind | Typical `msg` / key | Role |
|------|---------------------|------|
| Original image | `img_original_path` | Package image |
| Thumbnail | `img_thumbnail_path` | Preview |
| Stitched or imported PDF | `img_stitched_pdf_path` | Multi-page or PDF import |
| Retained zip | `data.local_package_path` | When auto-delete is off and the engine is `"none"` with local decoupling |

Native default `autoDeleteLocalResourcesAfterProcessing` is true. A host that shows one document at a time can copy the file at `data` during `update` immediately, using `dart:io`.

Set `autoDeleteLocalResourcesAfterProcessing: false` when the host reads paths later, or when several packages are in flight. When the flag is false, **the host owns deletion**.

Native `clearLensStorage()` is **not bridged**. `discardPackage` / `discardAllPackages` clear the **upload queue**, not retained images after a successful process. There is no Dart delete-path method. A plugin port could call `clearLensStorage`. Do not invent `Veryfi.clearStorage()`.

There is no `getFileBase64`. The path string is the integration.

Gallery backup is a second copy in Photos. Leave `backupDocsToGallery` false.

## Queue helpers

| Call | Native effect | Bridge caveat |
|------|---------------|---------------|
| `retryPackage(id, metadata, tag)` | Ask Lens to retry that upload | iOS looks up `imageSourceTag` and Dart sent `imageSourceData`, so iOS completes with `retryPackageError`. Android success does not call `result`. Use `unawaited` |
| `retryAllPackages()` | Retry the queue | Neither platform calls `result`. Use `unawaited` |
| `discardPackage(id)` | Drop one queued upload | Success does not call `result` on either platform. Use `unawaited` |
| `discardAllPackages()` | Drop the queue | Does not delete retained files |
| `shareOCRFeedback()` | Send the last OCR scan as failing feedback | No arguments |

## Decoupled capture

```dart
settings['dataExtractionEngine'] = 'none';
settings['uploadWithoutProcessingIsOn'] = false;
settings['autoDeleteLocalResourcesAfterProcessing'] = false;
```

Remote package:

```dart
settings['dataExtractionEngine'] = 'none';
settings['uploadWithoutProcessingIsOn'] = true;
```

Cloud-only response flags do not shape the customer's later Process a Document request.

## Analytics

`Veryfi.analyticsStream` after one `observeAnalyticsEvents()` call. Not `LensEvent.success`.

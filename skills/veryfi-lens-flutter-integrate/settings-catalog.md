# Settings catalog

Keys are camelCase JSON. The bridge forwards the object. Meanings are the native Lens UI SDK. Android `2.7.0.2` may ignore a key the iOS decoder accepts; that acceptance was not verified AAR-by-AAR. If a build shows the dashboard overriding the recipe, `ignoreRemoteSettings` was not applied — report that instead of inventing another key.

Defaults called out below are the native SDK defaults the recipes override.

## Credentials and engine

| Key | Values | Meaning |
|-----|--------|---------|
| `dataExtractionEngine` | `"api"`, `"mobile"`, `"none"` | Cloud Process a Document, on-device, or no Lens extract. Not `"custom"` |
| `uploadWithoutProcessingIsOn` | bool | Only with `"none"`. False: local package. True: Lens uploads and returns `bucket` / `package_path` |
| `webhookIsOn` | bool | Leave false unless the host handles an async result |
| `ignoreRemoteSettings` | bool | True keeps this object. False lets dashboard `lens_settings` replace flags during configure |

`"mobile"` is legal for `credit_card`, `code`, and `barcode`. Other types stay `"api"` or `"none"`.

## Documents

| Key | Meaning |
|-----|---------|
| `documentTypes` | String array. The capture list. Not a second plugin |
| `showDocumentTypes` | True when more than one type is set, so the user can switch. One type can hide the picker |
| `defaultSelectedDocumentType` | Which chip starts selected |
| `ocrType` | `"strips"` or `"caps"` when `documentTypes` is `code`. iOS reads both. Android **Unconfirmed**, and Android Full rejects `code` |
| `ocrRegex` | Host pattern for `code`. Ignored on receipt flavors |
| `anyDocumentTemplate` | Any-Documents template id from support. Do not guess |
| `anyDocumentType` | Deprecated local regex OCR. Leave unset |

Android Full allowed strings include `receipt`, `invoice`, `other`, `long_receipt`, `check`, `business_card`, `barcode`, `w2`, `w9`, `any_document`, and the Any-Documents shortcuts (passport, driver license, nutrition facts, prescription label, shipping label, insurance card, bank statement). They do **not** include `credit_card` or `code`. iOS Full embedding past `receipt` / `invoice` / `other` is **Unconfirmed**.

## Capture flow

| Key | Meaning |
|-----|---------|
| `autoSubmitDocumentOnCapture` | Submit as soon as a frame is accepted. Do not combine with batch |
| `batchUploadOnCamera` | Superman mode: keep capturing until `packageMaxScans`, then review |
| `imagePreviewIsOn` | Review screen. With auto-submit, preview still applies to gallery and browse imports |
| `closeCameraOnSubmit` | True ends the session on submit. False returns to the camera |
| `packageMaxScans` | Cap on images in one package. Android native default is 5; receipts recipes set 10 |
| `autoCaptureIsOn` | Capture without a shutter press when detection is confident |
| `autoCaptureOtherIsOn` | Independent of `autoCaptureIsOn`. Native default true, so `other` still auto-captures. Recipes set false |
| `stitchIsOn` | Multi-image stitch. False for checks and cards |
| `multiplePagesCaptureIsOn` | Keep every crop in one image. False keeps the larger crop |
| `multipleDocumentsIsOn` | On submit, ask whether images are separate packages |
| `singleScanPackages` | True skips that question and forces one package per image |
| `returnStitchedPDF` | Include the stitched PDF path in updates |
| `sameFileUploadPreventionPolicy` | `"session"` or `"always"`. `"always"` needs `"api"` |

## Sources

| Key | Meaning |
|-----|---------|
| `galleryIsOn` | Gallery button inside the Lens camera |
| `showBrowserButton` | Dedicated Files button. Works with the More menu off |
| `galleryButtonWithFilesIsOn` | Photos/Files menu on the gallery control. Needs `galleryIsOn` |
| `browseIsOn` | Browse row inside More. Dead when `moreMenuIsOn` is false |
| `moreMenuIsOn` | End-user overrides. Keep false. Android reapplies stored overrides on later configure when true |
| `moreSettingsMenuIsOn` | More > Settings entry. Does not reset those overrides |
| `dictateIsOn` | Obsolete voice control. Native Android default true. Keep false |
| `locationServicesIsOn` | Runtime location. Keep false unless the host asked. Needs the location usage string |

There is no Dart `showGallery` or `showDocumentBrowser`.

## Image quality

| Key | Meaning |
|-----|---------|
| `autoDocDetectionAndCropIsOn` | Green-box detect and crop |
| `autoRotateIsOn` | Rotate the crop. Android native default is false; recipes that need upright documents set true |
| `autoSkewCorrectionIsOn` | Deskew. Android native default false |
| `cleanBorderIsOn` | Clean the crop edge. Android native default false |
| `dewarpingIsOn` | Dewarp. Off for receipts. On for barcodes in that recipe |
| `autoLightDetectionIsOn` | Torch assist. Credit-card and code recipes turn it off |
| `glareDetectionIsOn` | Algorithmic glare gate. Android default true. Keep false unless requested |
| `blurDetectionIsOn` | Blur warning |
| `allowSubmitUndetectedDocsIsOn` | Legacy umbrella for no-document and blur continue |
| `allowSubmitBlurredDocsIsOn` | Continue from blur when undetected-submit is false |
| `showNoDocumentDetectedWarning` | The no-document alert. Usual choice false, and then undetected-submit must stay possible or users get stuck with no message |
| `allowSubmittingScreenshots` | Reject imported screenshots when false |
| `enableScreenshots` | Device screenshots of Lens screens. True shows them. False blanks those screens |
| `autoCropGalleryIsOn` / `autoCropBrowserIsOn` | Best-effort import crop. Need auto detect/crop on. Not a promise for every file |
| `continuousAutoFocus` | iOS close-up focus. Android **Unconfirmed** |

## Checks

`checksBackIsOn`, `checksBackIsRequired`, `checkSequenceMode` (front-then-back UI), `forceLandscapeImage`, aspect-ratio gates (`checksMinAspectRatio`, `checksMaxAspectRatio`), `validateCheckSize`, `validateCheckSides`, `validateCheckCorners`, `allowSubmitCheckSideNotDetected`, `allowSubmitCheckCornersNotDetected`, `captureMarginRatio`, `checksCropMargin`, `forceCropLayoutOnRetake`, `cropLayoutShowDelay`, `cropLayoutAspectRatio`, `cropLayoutCornerRadius`, `cropLayoutOverlayAlpha`.

`validateCheckCorners` stays false unless requested. Do not set `retrieveCheckTiffIsOn` on this plugin.

## Cards, crop layout, barcodes

`cropLayoutWithAutoDetection` draws a frame plus the green box. iOS does not also need `cropLayoutIsOn`. Android hybrid mode needs both. `cropLayoutWidth`, `cropLayoutHeight`, `cropLayoutCornerRadius`, `cropLayoutStroke`, `cropLayoutBorderColor` (hex). Corner radius changes the on-screen guide. The saved crop stays rectangular.

`autoSelectManualCropIsOn` starts checks in manual crop when detection is weak.

## Files and privacy

| Key | Meaning |
|-----|---------|
| `autoDeleteLocalResourcesAfterProcessing` | True (native default): Lens deletes package files after processing. False: host owns deletion, and `clearLensStorage` is not bridged |
| `backupDocsToGallery` | Copy every scan into Photos / gallery. Native default true. Recipes set false |
| `backupDocsToiCloud` | iOS copy into iCloud. Set false. No Android equivalent |
| `autoDeleteAfterProcessing` | Distinct from local-resource deletion. Leave false unless the host asked to drop the processed document record. The Full recipe does not turn it on |

## Not settable from this object

| Key | Why |
|-----|-----|
| `showInfoButton` | iOS `VeryfiInfoView`, Android `Fragment`. A bool does not install a Flutter screen. iOS applies the property only when the value is already a `VeryfiInfoView` |
| `cameraInfoView` | Same class of native view. Top banner. Not constructable from JSON |
| `customLensStrings` | iOS only as a nested dictionary. Android string resources are a different mechanism. Unconfirmed through `initWithJsonObject` |

## Paid flags

| Key | Gate |
|-----|------|
| `fraudDetectionIsOn` | Paid. Backend entitlement. The key alone does not enable it |
| `documentFieldsToDetect` | Paid, and needs Field Detection, Remote Models, or Lite. This plugin links Full only, so the feature stays off |

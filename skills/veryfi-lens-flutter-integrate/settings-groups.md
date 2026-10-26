# Settings groups

Not a Flutter type. Use the ids to pick flags, then put the flags in the settings object. Compose **ExtractionMode** + **CaptureFlow** + **CaptureSources** + **QualityGate** + **MultiPage** + optional extras + **Chrome**. Branding is optional and never required for a first scan.

Plugin constraints on every group: camera is the only host entry point; gallery and files are in-camera flags; Headless, Lite, and Remote Models are not available; `clearLensStorage` is not bridged.

## ExtractionMode

| ID | Keys | Use |
|----|------|-----|
| `CloudProcess` | `dataExtractionEngine: "api"`, `uploadWithoutProcessingIsOn: false` | Veryfi API processing |
| `InApp` | `dataExtractionEngine: "mobile"` | Only `credit_card`, `code`, `barcode`. Those types extract locally. Credit card data is never sent to the backend. Android Full still rejects `credit_card` and `code` |
| `DecoupledLocalPackage` | `"none"`, `uploadWithoutProcessingIsOn: false`, `autoDeleteLocalResourcesAfterProcessing: false` | Any allowed type. No extract. Retain `local_package_path`. The customer calls Process a Document |
| `DecoupledRemotePackage` | `"none"`, `uploadWithoutProcessingIsOn: true` | Lens uploads. Success `data` keeps `bucket` and `package_path` |
| `VisualOnly` | `"none"`, `uploadWithoutProcessingIsOn: false` | Local package or PDF, no extract |

Do not emit `"custom"`.

## CaptureFlow

| ID | Keys |
|----|------|
| `ReviewThenSubmit` | `autoSubmitDocumentOnCapture: false`, `batchUploadOnCamera: false`, `imagePreviewIsOn: true` |
| `AutoSubmit` | `autoSubmitDocumentOnCapture: true`, `batchUploadOnCamera: false` |
| `BatchToMaxThenReview` | `batchUploadOnCamera: true`, `autoSubmitDocumentOnCapture: false`, `packageMaxScans` set |

Do not combine AutoSubmit with BatchToMaxThenReview.

## CaptureSources

| ID | Keys |
|----|------|
| `CameraOnly` | `galleryIsOn: false`, `browseIsOn: false`, `showBrowserButton: false`, `dictateIsOn: false` |
| `CameraPlusGallery` | `galleryIsOn: true`. There is no `showGallery` call |
| `CameraPlusFiles` | `showBrowserButton: true`, or `galleryIsOn: true` with `galleryButtonWithFilesIsOn: true`. Do not rely on `browseIsOn` while `moreMenuIsOn` is false |
| `FilesFirst` | **Unavailable.** Native `showDocumentBrowser` is not bridged |

`autoCropGalleryIsOn` / `autoCropBrowserIsOn` are best-effort for paper photos and scans and also require `autoDocDetectionAndCropIsOn`. They do not crop every import. Internal checks can preserve screenshots and digital copies. An original-file PDF is not page-cropped.

## QualityGate

| ID | Keys |
|----|------|
| `Lenient` | `allowSubmitUndetectedDocsIsOn: true` (legacy umbrella: no-document and blur can continue) |
| `Balanced` | `blurDetectionIsOn: true`, `allowSubmitUndetectedDocsIsOn: false`, `allowSubmitBlurredDocsIsOn: true` |
| `StrictBanking` | Undetected submit off, check side and size validators on, crop layout on retake, `captureMarginRatio: 0.08`. Leave `validateCheckCorners` false unless the host asked |

`allowSubmittingScreenshots: false` rejects imported images the detector classifies as screenshots. `enableScreenshots: false` blanks the camera and submit screens in device screenshots and screen recordings. They are different switches.

`glareDetectionIsOn` stays false unless the host explicitly wants that gate.

## MultiPage

| ID | Keys |
|----|------|
| `SingleFrame` | `stitchIsOn: false`, `multiplePagesCaptureIsOn: false` |
| `StitchToPdf` | `stitchIsOn: true`, `multiplePagesCaptureIsOn: true`, `singleScanPackages: false`, `returnStitchedPDF: true` |
| `SeparatePackages` | `multipleDocumentsIsOn: true`, `stitchIsOn: true`, `singleScanPackages: true` |

`multiplePagesCaptureIsOn` keeps every crop in one image (false keeps the larger one). `multipleDocumentsIsOn` asks, on submit preview when stitch is on, whether several images are separate packages. `singleScanPackages: true` skips that alert and forces one package per image.

## Compliance

| ID | Keys |
|----|------|
| `NoGalleryBackup` | `backupDocsToGallery: false`, `backupDocsToiCloud: false` |
| `KeepLocalResources` | `autoDeleteLocalResourcesAfterProcessing: false`. Host owns deletion. `clearLensStorage()` is not bridged |
| `NoScreenshotSubmit` | `allowSubmittingScreenshots: false` |
| `SameFileSession` | `sameFileUploadPreventionPolicy: "session"` |
| `SameFileAlways` | `"always"` only with `"api"`. Without cloud confirmation the policy cannot stick |

Local fraud detection and local field detection are paid. Fraud needs the backend entitlement. Field detection needs the entitlement and a flavor this plugin does not link.

## BankingExtras

| ID | Keys |
|----|------|
| `CheckBack` | `checkSequenceMode: true`, `checksBackIsOn`, `forceLandscapeImage: true` |
| `CheckValidation` | `validateCheckSides`, `validateCheckSize`, and the allow-submit flags. `validateCheckCorners` stays false unless requested |
| `CheckTiff` | **Do not use.** `retrieveCheckTiffIsOn` needs Remote Models, which this plugin does not link |

## Chrome

| ID | Keys |
|----|------|
| `Minimal` | `moreMenuIsOn: false`, `moreSettingsMenuIsOn: false` |
| `CameraHelpOrInfo` | Do not set `showInfoButton` from Dart. A bool does not become a `VeryfiInfoView` or an Android `Fragment`. `showHelpButton: true` may show the native control, and this plugin does not export `onHelpButtonClicked`, so the host cannot present its own screen from that tap. Help and `showInfoButton` share one iOS camera control; Help wins |

## Branding

Optional hex colors for the submit button, document-detect stroke and fill, and crop-layout border. Not required for a first scan.

## Mapping

| Recipe | Groups |
|--------|--------|
| Receipts / Full | CloudProcess + ReviewThenSubmit + CameraPlusGallery + CameraPlusFiles + StitchToPdf + Minimal |
| Long receipts | CloudProcess + StitchToPdf + CameraPlusGallery |
| Checks | CloudProcess + ReviewThenSubmit + StrictBanking + SingleFrame + CheckBack + CheckValidation + Minimal |
| Credit cards / barcodes / OCR | InApp + CameraOnly + Minimal, subject to the Full binary gate |
| W-2 / W-9 | CloudProcess + CameraPlusGallery + CameraPlusFiles + Minimal |
| Any-Documents | CloudProcess + ReviewThenSubmit + CameraOnly + Minimal, after support confirms the template |

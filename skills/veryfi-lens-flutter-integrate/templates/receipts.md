# Receipts

Cloud extraction for `receipt`, `invoice`, and `other` on the Full binary this plugin already links. There is no Flutter receipts package. Native receipts-specific artifacts (`VeryfiLens-Receipts`, `veryfi-lens-spm-receipts`, `veryfi-lens-receipts-sdk`) are not what `Package.swift` and `android/build.gradle` depend on. Do not add them.

Android Full allows these three types. They are the iOS Full set that is not marked Unconfirmed.

Long receipts are a different document type. Use [long-receipts.md](long-receipts.md) only after the iOS model question in that file is settled. Do not add `long_receipt` here.

## Settings

Merge [recipes.md](../recipes.md) base with the receipts object. `showBrowserButton` replaces More-menu Browse.

```javascript
var settings = {
  ignoreRemoteSettings: true,
  backupDocsToGallery: false,
  backupDocsToiCloud: false,
  moreSettingsMenuIsOn: false,
  moreMenuIsOn: false,
  autoCaptureOtherIsOn: false,
  showNoDocumentDetectedWarning: false,
  dictateIsOn: false,
  locationServicesIsOn: false,
  glareDetectionIsOn: false,
  enableScreenshots: true,

  dataExtractionEngine: 'api',
  documentTypes: ['receipt', 'invoice', 'other'],
  showDocumentTypes: true,
  defaultSelectedDocumentType: 'receipt',
  autoSubmitDocumentOnCapture: false,
  imagePreviewIsOn: true,
  galleryIsOn: true,
  browseIsOn: false,
  showBrowserButton: true,
  autoCaptureIsOn: false,
  autoDocDetectionAndCropIsOn: true,
  autoRotateIsOn: true,
  autoSkewCorrectionIsOn: true,
  cleanBorderIsOn: true,
  stitchIsOn: true,
  multiplePagesCaptureIsOn: true,
  multipleDocumentsIsOn: true,
  returnStitchedPDF: true,
  packageMaxScans: 10,
  closeCameraOnSubmit: true
};
```

Review-then-submit is the default. Auto-submit is `autoSubmitDocumentOnCapture: true` and `batchUploadOnCamera` left false. Batch-until-max is the opposite pair plus `packageMaxScans`. Do not set both auto-submit and batch.

## Wire-up

Same `setDelegate`, `initLens`, and `showCamera` as [full.md](full.md). Success for cloud extract uses `status` `"done"` and `msg` `"results"`. Image paths arrive on `LensEvent.update` (`msg` `img_original_path`, `img_thumbnail_path`, or `img_stitched_pdf_path`; `data` is the path). Read that file in Dart. There is no base64 helper.

Photo library usage is required because `galleryIsOn` is true. Gallery backup stays false, so do not add a photo-library-add string for this recipe.

## iOS and Android

| | iOS | Android |
|--|-----|---------|
| Binary | Full SPM from `3.0.19` | `veryfi-lens-sdk:2.7.0.2` |
| These types | Accepted as the Full UI receipt set | Allowed on Full |
| Failure status | `fail` | `failed` |
| Configure | Success `result` is not called. Host uses `unawaited` | Success `result` is not called. Host uses `unawaited` |

Stitch and PDF return are appropriate for multi-page receipts. `stitchOtherIsOn` stays off unless `other` should stitch differently from receipts. The base recipe already stops `other` from auto-capturing.

## Do not

- Set `"mobile"` for receipts
- Set `backupDocsToGallery` true
- Promise Headless receipt processing. Unsupported

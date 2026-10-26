# Recipes

One settings object. Pass it as the settings map to `Veryfi.initLens`. The native bridge builds `VeryfiLensSettings` from it (`initWith:` on iOS, `initWithJsonObject` on Android). Do not construct `VeryfiLens*Settings` subclasses.

These recipes run on the **Full** UI SDK the plugin links. They are not separate Flutter packages.

Start from **base**, then add the keys in **one** focused recipe. Skip flags the host did not ask for. Focused templates repeat the merged object: [templates/full.md](templates/full.md) and the other files in `templates/`.

Android `initWithJsonObject` acceptance of every key was not verified against the `2.7.0.2` AAR. Keys are the iOS dictionary names (camelCase). Prefer camelCase so one object matches both samples. iOS also reads some snake_case aliases. A key the iOS initializer does not read will not apply on iOS.

**Headless and Lite:** unsupported. No recipe.

**Remote Models:** not in this commit. Do not set `retrieveCheckTiffIsOn`.

**Credit cards and OCR codes:** the settings below are the native shape. Android Full rejects `credit_card` and `code`. iOS Full embedding is Unconfirmed. See those templates before shipping.

## Base

Always, unless the host wants the opposite:

```json
{
  "ignoreRemoteSettings": true,
  "backupDocsToGallery": false,
  "backupDocsToiCloud": false,
  "moreSettingsMenuIsOn": false,
  "moreMenuIsOn": false,
  "autoCaptureOtherIsOn": false,
  "showNoDocumentDetectedWarning": false,
  "dictateIsOn": false,
  "locationServicesIsOn": false,
  "glareDetectionIsOn": false,
  "enableScreenshots": true
}
```

`backupDocsToGallery` false stops the native default, which copies every scan into Photos or the device gallery. `backupDocsToiCloud` is the iOS copy into iCloud. `glareDetectionIsOn` false overrides the Android default true. `dictateIsOn` false overrides the Android default true. `enableScreenshots` true leaves the camera visible in screenshots; it is not the imported-screenshot policy (`allowSubmittingScreenshots`).

If the host must read files after the callback, or keep more than one package:

```json
{ "autoDeleteLocalResourcesAfterProcessing": false }
```

Who deletes those files: [implementation.md](implementation.md). `clearLensStorage()` is not bridged.

## Full (`full`)

Widest UI on the linked Full binary: receipts, invoices, and other. Android Full also allows `long_receipt` in this list. iOS embedding of `long_receipt` in `veryfi-lens-spm` is **Unconfirmed** — leave it out until support confirms, then add it and keep `showDocumentTypes` true. Use a narrower recipe when the host only needs one type.

`browseIsOn` is false because `moreMenuIsOn` is false. Files use `showBrowserButton`.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["receipt", "invoice", "other"],
  "showDocumentTypes": true,
  "defaultSelectedDocumentType": "receipt",
  "autoSubmitDocumentOnCapture": false,
  "batchUploadOnCamera": false,
  "imagePreviewIsOn": true,
  "galleryIsOn": true,
  "browseIsOn": false,
  "showBrowserButton": true,
  "autoCaptureIsOn": false,
  "autoDocDetectionAndCropIsOn": true,
  "autoRotateIsOn": true,
  "autoSkewCorrectionIsOn": true,
  "cleanBorderIsOn": true,
  "dewarpingIsOn": false,
  "stitchIsOn": true,
  "stitchOtherIsOn": false,
  "multipleDocumentsIsOn": true,
  "multiplePagesCaptureIsOn": true,
  "singleScanPackages": false,
  "returnStitchedPDF": true,
  "packageMaxScans": 10,
  "closeCameraOnSubmit": true,
  "sameFileUploadPreventionPolicy": "session",
  "allowSubmittingScreenshots": true,
  "webhookIsOn": false
}
```

`showDocumentTypes` must be true when more than one type is set.

`galleryIsOn` opens the gallery inside the Lens camera. It does not call a host `showGallery`. This plugin has no such method.

## Receipts (`receipts`)

Same capture list as Full without asking support about `long_receipt`. Android Full allows `RECEIPT`, `INVOICE`, and `OTHER`.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["receipt", "invoice", "other"],
  "showDocumentTypes": true,
  "defaultSelectedDocumentType": "receipt",
  "autoSubmitDocumentOnCapture": false,
  "imagePreviewIsOn": true,
  "galleryIsOn": true,
  "browseIsOn": false,
  "showBrowserButton": true,
  "autoCaptureIsOn": false,
  "autoDocDetectionAndCropIsOn": true,
  "autoRotateIsOn": true,
  "autoSkewCorrectionIsOn": true,
  "cleanBorderIsOn": true,
  "stitchIsOn": true,
  "multiplePagesCaptureIsOn": true,
  "multipleDocumentsIsOn": true,
  "returnStitchedPDF": true,
  "packageMaxScans": 10,
  "closeCameraOnSubmit": true
}
```

## Long receipts (`long-receipts`)

`long_receipt` is a vertical multi-frame stitch. It is not the same switch as `stitchIsOn` on ordinary receipts. Keep both. Android Full allows `LONG_RECEIPT`. iOS Full embedding is **Unconfirmed**.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["long_receipt"],
  "showDocumentTypes": false,
  "stitchIsOn": true,
  "multiplePagesCaptureIsOn": true,
  "returnStitchedPDF": true,
  "autoCaptureIsOn": false,
  "autoDocDetectionAndCropIsOn": true,
  "galleryIsOn": true,
  "showBrowserButton": false
}
```

## Checks (`checks`)

Capture and cloud extract. Android Full allows `CHECK`. iOS Full embedding is **Unconfirmed**. Check TIFF is a Remote Models feature and is not a current plugin binary. Leave `retrieveCheckTiffIsOn` unset.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["check"],
  "showDocumentTypes": false,
  "stitchIsOn": false,
  "autoCaptureIsOn": false,
  "galleryIsOn": true,
  "browseIsOn": false,
  "showBrowserButton": true,
  "checksBackIsOn": true,
  "checksBackIsRequired": false,
  "checkSequenceMode": true,
  "forceLandscapeImage": true,
  "autoSelectManualCropIsOn": true,
  "autoRotateIsOn": true,
  "autoSkewCorrectionIsOn": false,
  "captureMarginRatio": 0.08,
  "checksCropMargin": 2,
  "checksMinAspectRatio": 1.9,
  "checksMaxAspectRatio": 2.85,
  "forceCropLayoutOnRetake": true,
  "cropLayoutShowDelay": 15.0,
  "cropLayoutAspectRatio": 2.18,
  "cropLayoutCornerRadius": 5,
  "cropLayoutOverlayAlpha": 0.3,
  "validateCheckSize": true,
  "validateCheckSides": true,
  "validateCheckCorners": false,
  "allowSubmitCheckSideNotDetected": true,
  "allowSubmitCheckCornersNotDetected": true,
  "allowSubmitUndetectedDocsIsOn": false,
  "returnStitchedPDF": true
}
```

Set `checksBackIsRequired` true only when both sides are mandatory. Leave `validateCheckCorners` false unless the host asked for that gate (it is algorithmic and can be aggressive).

## Credit cards (`credit-cards`)

On-device only. `"mobile"` is required. Card data is not sent to the backend. **Android Full will not open the camera for `credit_card`.** iOS Full support is **Unconfirmed**. Contact support. The object is the native recipe if a future plugin links the credit-card binary. Do not point the host at a backend card payload.

```json
{
  "dataExtractionEngine": "mobile",
  "documentTypes": ["credit_card"],
  "showDocumentTypes": false,
  "autoCaptureIsOn": true,
  "galleryIsOn": false,
  "stitchIsOn": false,
  "autoLightDetectionIsOn": false,
  "autoRotateIsOn": true,
  "cropLayoutWithAutoDetection": true,
  "cropLayoutWidth": 80,
  "cropLayoutHeight": 25,
  "cropLayoutCornerRadius": 15,
  "cropLayoutStroke": 16,
  "cropLayoutBorderColor": "#FFFFFFFF"
}
```

Android hybrid crop layout also needs `cropLayoutIsOn: true` together with `cropLayoutWithAutoDetection`. iOS uses `cropLayoutWithAutoDetection` alone. That Android pair still cannot pass the Full flavor gate.

## Business cards (`business-cards`)

`"api"`. Android Full allows `BUSINESS_CARD`. iOS Full embedding is **Unconfirmed**. Do not switch this type to `"mobile"`.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["business_card"],
  "showDocumentTypes": false,
  "autoCaptureIsOn": false,
  "galleryIsOn": false,
  "stitchIsOn": false,
  "autoRotateIsOn": true,
  "autoDocDetectionAndCropIsOn": true,
  "cleanBorderIsOn": true
}
```

## Barcodes (`barcodes`)

`"mobile"` is the on-device engine for `barcode`. Android Full allows `BARCODE`. iOS Full embedding is **Unconfirmed**.

```json
{
  "dataExtractionEngine": "mobile",
  "documentTypes": ["barcode"],
  "showDocumentTypes": false,
  "autoCaptureIsOn": true,
  "galleryIsOn": false,
  "stitchIsOn": false,
  "autoLightDetectionIsOn": false,
  "continuousAutoFocus": true,
  "dewarpingIsOn": true,
  "cleanBorderIsOn": true,
  "autoRotateIsOn": true
}
```

`continuousAutoFocus` is the iOS close-up focus flag for small codes. Android acceptance is **Unconfirmed**.

Success may be a barcode result object without `status: "done"`. See [implementation.md](implementation.md).

## OCR strips (`ocr-strips`)

`code` extracts on device. `ocrType` `"strips"` is the iOS default mode. **Android Full rejects `CODE`.** iOS Full embedding is **Unconfirmed**. Contact support before shipping. Replace `ocrRegex` with the host pattern. Do not ship the example as if it were universal.

```json
{
  "dataExtractionEngine": "mobile",
  "documentTypes": ["code"],
  "showDocumentTypes": false,
  "ocrType": "strips",
  "ocrRegex": "[A-Z0-9]{10}",
  "autoCaptureIsOn": true,
  "galleryIsOn": false,
  "stitchIsOn": false,
  "autoLightDetectionIsOn": false,
  "continuousAutoFocus": true
}
```

## OCR caps (`ocr-caps`)

Same binary limitation as strips. Only `ocrType` changes. iOS serializes caps as `"caps"`. Android acceptance of `ocrType` is **Unconfirmed**, and Android Full rejects the document type.

```json
{
  "dataExtractionEngine": "mobile",
  "documentTypes": ["code"],
  "showDocumentTypes": false,
  "ocrType": "caps",
  "ocrRegex": "[A-Z0-9]{10}",
  "autoCaptureIsOn": true,
  "galleryIsOn": false,
  "stitchIsOn": false,
  "autoLightDetectionIsOn": false,
  "continuousAutoFocus": true
}
```

## W-2 (`w2`)

Android Full allows `W2`. iOS Full embedding is **Unconfirmed**.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["w2"],
  "showDocumentTypes": false,
  "autoCaptureIsOn": false,
  "stitchIsOn": false,
  "galleryIsOn": true,
  "browseIsOn": false,
  "showBrowserButton": true,
  "autoRotateIsOn": true,
  "cleanBorderIsOn": true,
  "returnStitchedPDF": true
}
```

## W-9 (`w9`)

Android Full allows `W9`. iOS Full embedding is **Unconfirmed**.

```json
{
  "dataExtractionEngine": "api",
  "documentTypes": ["w9"],
  "showDocumentTypes": false,
  "autoCaptureIsOn": false,
  "stitchIsOn": false,
  "galleryIsOn": true,
  "browseIsOn": false,
  "showBrowserButton": true,
  "autoRotateIsOn": true,
  "cleanBorderIsOn": true,
  "returnStitchedPDF": true
}
```

## Any-Documents

No default template id. Read [templates/any-documents.md](templates/any-documents.md). Do not invent `anyDocumentTemplate`.

## Do not combine

- `"mobile"` with `receipt`, `invoice`, `other`, `long_receipt`, `check`, `business_card`, `w2`, or `w9`
- `"api"` or `"none"` with `credit_card` when the host expects card data back from Lens
- `showHelpButton` and `showInfoButton` as two camera buttons
- `multiplePagesCaptureIsOn` and `multipleDocumentsIsOn` as one switch
- `backupDocsToGallery` true unless the host wants every scan copied into Photos
- `moreMenuIsOn` true unless end users should override capture behavior
- `dictateIsOn` true
- `browseIsOn` true while `moreMenuIsOn` is false and the host expects a Browse row
- A Headless, Lite, or Remote Models recipe

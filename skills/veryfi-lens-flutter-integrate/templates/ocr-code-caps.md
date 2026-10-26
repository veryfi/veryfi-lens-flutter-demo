# OCR code caps

Same plugin, same document type, and the same Full-binary limitation as [ocr-code-strips.md](ocr-code-strips.md). Bottle-cap OCR is `ocrType: "caps"`. iOS serializes `OCRType.caps` as `"caps"`. It is not a second Flutter package.

## Binary support

Android Full rejects `CODE`. The camera does not open. iOS Full embedding in `veryfi-lens-spm` from `3.0.19` is **Unconfirmed**. Contact support. Android acceptance of `ocrType` is **Unconfirmed** and does not matter until the type is allowed.

Do not add the native OCR SDK next to this plugin.

## Settings

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

  dataExtractionEngine: 'mobile',
  documentTypes: ['code'],
  showDocumentTypes: false,
  ocrType: 'caps',
  ocrRegex: '[A-Z0-9]{10}',
  autoCaptureIsOn: true,
  galleryIsOn: false,
  stitchIsOn: false,
  autoLightDetectionIsOn: false,
  continuousAutoFocus: true
};
```

Replace `ocrRegex`. Camera only, auto capture, no stitch, torch assist off, iOS close-up focus on.

## Callbacks

iOS success arrives as `LensEvent.success` with an `OCRResult` map. This plugin does not add an `event` string. Do not require the cloud `status` / `msg` / `data` envelope. `shareOCRFeedback()` is the bridged way to upload the last code as a failure sample.

Android will not deliver that success for `code` on this Full artifact.

## Do not

- Ship strips and caps as two plugins
- Set both `ocrType` values. One recipe, one mode
- Promise Headless or Lite

# OCR code strips

On-device OCR of a code printed on a strip (label, ticket, peel-off). Document type `code`. `ocrType` `"strips"` is the iOS default mode. Extraction engine `"mobile"`.

Replace `ocrRegex` with the host's pattern. The example `[A-Z0-9]{10}` is not universal.

## Binary support — read this first

| Platform | What happens |
|----------|----------------|
| Android Full | `CODE` is **not** allowed. The camera does not open. Toast, no delegate event. Confirmed on Android SDK `2.7.0.4`. This AAR is `2.7.0.2` |
| iOS Full | Embedding in `veryfi-lens-spm` from `3.0.19` is **Unconfirmed**. Contact support |

The native OCR flavor is a different binary. This plugin does not link it. Do not add `veryfi-lens-ocr-sdk` in the host. A plugin port could. It is not in this commit.

`ocrType` is not in the short plugin README. iOS reads `strips` and `caps`. Android acceptance of the key is **Unconfirmed**, and the type gate rejects `code` before that key matters.

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
  ocrType: 'strips',
  ocrRegex: '[A-Z0-9]{10}',
  autoCaptureIsOn: true,
  galleryIsOn: false,
  stitchIsOn: false,
  autoLightDetectionIsOn: false,
  continuousAutoFocus: true
};
```

## Callbacks

When iOS actually runs OCR, success is an `OCRResult` and may not include `status: "done"`. The live update path can omit `ocr_type` even when the processed result carries `"strips"`. A read that never matches the regex does not call success. `shareOCRFeedback()` sends the last OCR scan as failing feedback. It takes no arguments.

Android Full does not reach these callbacks for `code`.

## Caps

Bottle caps are the same type and the same binary limitation. Only `ocrType` changes. See [ocr-code-caps.md](ocr-code-caps.md).

## Do not

- Put `code` in the receipts `documentTypes` array to "enable OCR"
- Set `"api"` and expect a local code
- Use `ocrRegex` on receipts. It is ignored there

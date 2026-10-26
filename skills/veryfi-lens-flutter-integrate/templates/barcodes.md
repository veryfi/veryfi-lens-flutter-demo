# Barcodes

On-device barcode reading. `dataExtractionEngine` is `"mobile"`. `"api"` is the wrong engine when the host wants the local barcode result.

## Binary support

| Platform | Support |
|----------|---------|
| Android Full | `BARCODE` is allowed |
| iOS Full (`veryfi-lens-spm` from `3.0.19`) | Embedding is **Unconfirmed**. Contact support before shipping |

No barcodes Flutter package. Do not add `veryfi-lens-barcodes-sdk` beside the plugin.

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
  documentTypes: ['barcode'],
  showDocumentTypes: false,
  autoCaptureIsOn: true,
  galleryIsOn: false,
  stitchIsOn: false,
  autoLightDetectionIsOn: false,
  continuousAutoFocus: true,
  dewarpingIsOn: true,
  cleanBorderIsOn: true,
  autoRotateIsOn: true
};
```

`continuousAutoFocus` is the iOS close-up focus flag for small codes. Android acceptance is **Unconfirmed**. If an Android build ignores it, leave the key (iOS needs it) and do not invent a second key.

Camera only. Auto capture on. Stitch off.

## Callbacks

iOS barcode success is a `BarcodeResult` map on `LensEvent.success`. It does not use the cloud envelope (`status` `"done"`, `msg` `"results"`, `data`). This plugin does not add an `event` string. Read the barcode fields from that map. Do not drop the callback because `status` is missing.

Android's barcode field names on AAR `2.7.0.2` were not unpacked. Handle the success object you receive. Do not invent keys.

There is no base64 helper. When an update carries `img_original_path`, `data` is the file path. Many barcode sessions only need the decoded value.

## Do not

- Use `"mobile"` as a license to send barcodes through Process a Document. This recipe is local
- Combine with `credit_card` or `code` on Android Full. `barcode` is allowed; those two are not
- Promise Remote Models

# Checks

Front-and-optional-back check capture with cloud extraction. `checkSequenceMode` is the front-then-back UI. This is not a Headless camera and not Remote Models.

## Binary support

| Platform | Support |
|----------|---------|
| Android Full | `CHECK` is allowed on the Full artifact (confirmed at Android SDK `2.7.0.4`). This plugin's AAR is `2.7.0.2` |
| iOS Full | Check models inside `veryfi-lens-spm` from `3.0.19` are **Unconfirmed**. Contact support before promising detection |

Check TIFF (`retrieveCheckTiffIsOn`, `img_check_front_tiff_path`, `img_check_back_tiff_path`) downloads a large model on native Remote Models. That flavor is **planned** for plugins and is **not** linked here. Do not set the flag.

## Settings

Corners stay off unless the host asked. The corner check is algorithmic and aggressive. Back image is on, and not required, so a front-only check can still submit. Set `checksBackIsRequired: true` only when both sides are mandatory, and keep `packageMaxScans` at least 2 (do not set it to 1).

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
  documentTypes: ['check'],
  showDocumentTypes: false,
  stitchIsOn: false,
  autoCaptureIsOn: false,
  galleryIsOn: true,
  browseIsOn: false,
  showBrowserButton: true,
  checksBackIsOn: true,
  checksBackIsRequired: false,
  checkSequenceMode: true,
  forceLandscapeImage: true,
  autoSelectManualCropIsOn: true,
  autoRotateIsOn: true,
  autoSkewCorrectionIsOn: false,
  captureMarginRatio: 0.08,
  checksCropMargin: 2,
  checksMinAspectRatio: 1.9,
  checksMaxAspectRatio: 2.85,
  forceCropLayoutOnRetake: true,
  cropLayoutShowDelay: 15.0,
  cropLayoutAspectRatio: 2.18,
  cropLayoutCornerRadius: 5,
  cropLayoutOverlayAlpha: 0.3,
  validateCheckSize: true,
  validateCheckSides: true,
  validateCheckCorners: false,
  allowSubmitCheckSideNotDetected: true,
  allowSubmitCheckCornersNotDetected: true,
  allowSubmitUndetectedDocsIsOn: false,
  returnStitchedPDF: true
};
```

`allowSubmitUndetectedDocsIsOn` is false so a missing rectangle is blocked, while the allow-submit check flags still let a user continue when side or corner detection fails. Turning those allow flags false without a way to proceed traps the user. See [conflicts.md](../conflicts.md).

## Wire-up

[full.md](full.md). Engine stays `"api"`. Do not use `"mobile"`. Success is the cloud package (`status` `"done"`). iOS failure status is `fail`; Android is `failed`.

Gallery and the Files button are on so a photographed check can be imported. Backup stays off.

## Do not

- Set `stitchIsOn` true
- Promise TIFF
- Use `anyDocumentBackIsOn` for the check back. Checks use `checksBackIsOn`
- Install `veryfi-lens-cheques-sdk` or `VeryfiLens-Cheques` beside this plugin

# Credit cards

On-device card reading. Card data is never sent to the backend. `"mobile"` is required. There is no cloud card payload to parse on `LensEvent.success`.

## Binary support — read this first

This plugin links the **Full** UI SDK only.

| Platform | What happens |
|----------|----------------|
| Android | Full does **not** allow `CREDIT_CARD`. `showCamera` hits the flavor check, shows a Toast ("Please use only valid document types"), and does not open the camera. No delegate callback. Confirmed on the Android SDK at `2.7.0.4`. This plugin's AAR is `2.7.0.2`. Do not expect this Full artifact to allow the type |
| iOS | Whether `veryfi-lens-spm` from `3.0.19` embeds the credit-card model is **Unconfirmed**. Contact support before shipping |

The native credit-card flavor is a different binary (`veryfi-lens-credit-cards-sdk` / the iOS credit-card package). This plugin does not depend on it. Adding that artifact in the host next to the plugin is not a supported Flutter setup. A future plugin variant could link it. That port does not exist in this commit.

Headless Credit Cards (`process` on frames from the host camera) are a separate SDK. **Unsupported.** Do not imitate them with `showCamera`.

The settings below are the native Lens UI recipe so a confirmed binary has the right flags. Do not tell the host the Android camera will open.

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
  documentTypes: ['credit_card'],
  showDocumentTypes: false,
  autoCaptureIsOn: true,
  galleryIsOn: false,
  stitchIsOn: false,
  autoLightDetectionIsOn: false,
  autoRotateIsOn: true,
  cropLayoutWithAutoDetection: true,
  cropLayoutWidth: 80,
  cropLayoutHeight: 25,
  cropLayoutCornerRadius: 15,
  cropLayoutStroke: 16,
  cropLayoutBorderColor: '#FFFFFFFF'
};
```

Android hybrid frame plus green box also needs `cropLayoutIsOn: true`. That pair still does not pass the Full flavor gate.

Gallery is off. Card images should not be picked from Photos by this recipe. Backup is off so card images are not copied into the gallery.

## Callbacks

When a binary actually runs this type, success is the on-device extraction, not `msg: "results"` from Process a Document. Do not log full card numbers. iOS may omit the package `status` / `data` envelope used for cloud documents. Android Full will not reach this callback for `credit_card`.

## Do not

- Set `dataExtractionEngine` to `"api"` or `"none"` and expect card data
- Set `"custom"`
- Enable `fraudDetectionIsOn` or `documentFieldsToDetect` as a substitute. Those are paid gates and field detection needs a flavor this plugin does not link
- Promise Lite or Headless

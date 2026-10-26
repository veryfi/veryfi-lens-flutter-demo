# Business cards

Cloud extraction for `business_card`. Do not use `"mobile"`. The plugin README lists `business_card` as a camera document type and does not say to use the on-device engine.

## Binary support

| Platform | Support |
|----------|---------|
| Android Full | `BUSINESS_CARD` is allowed |
| iOS Full (`veryfi-lens-spm` from `3.0.19`) | Embedding is **Unconfirmed**. Contact support before shipping |

No business-card Flutter package. Do not add `veryfi-lens-business-cards-sdk` beside the plugin.

## Settings

Camera only. Stitch off. Detect and crop on. Backup off so card photos are not copied into the gallery.

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
  documentTypes: ['business_card'],
  showDocumentTypes: false,
  autoCaptureIsOn: false,
  galleryIsOn: false,
  stitchIsOn: false,
  autoRotateIsOn: true,
  autoDocDetectionAndCropIsOn: true,
  cleanBorderIsOn: true
};
```

## Wire-up

[full.md](full.md). One type, picker hidden. Success is cloud `status` `"done"`, `msg` `"results"`, body in `data`. iOS errors may use `fail`; Android uses `failed`.

Photo library usage is not required while `galleryIsOn` is false. Turn gallery on only if the host asked to import an existing photo, and then the photo library string matters. Keep backup false.

## Do not

- Treat a business card as a credit card. Credit cards are `"mobile"`, local, and blocked on Android Full
- Set `showInfoButton` to show a contact form. That value is a native view, not HTML. See [unbridged.md](../unbridged.md)

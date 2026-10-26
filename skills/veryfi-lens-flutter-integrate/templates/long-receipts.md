# Long receipts

`long_receipt` is a vertical multi-frame stitch of one long paper document. It is not `stitchIsOn` on a normal receipt. This recipe keeps both: the document type selects the long-receipt flow, and stitch plus `returnStitchedPDF` package the frames.

## Binary support

| Platform | Support |
|----------|---------|
| Android Full (`veryfi-lens-sdk`) | `LONG_RECEIPT` is allowed. The Flutter AAR is `2.7.0.2`. The allow-list is confirmed on Android SDK `2.7.0.4`. Verify on device if detection fails, and do not switch artifacts |
| iOS Full (`veryfi-lens-spm` from `3.0.19`) | Embedding of the long-receipt model is **Unconfirmed**. Contact support before shipping. A missing model looks like poor detection, not a Dart error |

There is no long-receipt Flutter package. Native long-receipt flavors are not linked.

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

  dataExtractionEngine: 'api',
  documentTypes: ['long_receipt'],
  showDocumentTypes: false,
  stitchIsOn: true,
  multiplePagesCaptureIsOn: true,
  returnStitchedPDF: true,
  autoCaptureIsOn: false,
  autoDocDetectionAndCropIsOn: true,
  galleryIsOn: true
};
```

One type, so the document picker stays off. Gallery is inside the camera. Files are off (`showBrowserButton` omitted). Add `showBrowserButton: true` if the host must import a long image from Files. Do not turn `moreMenuIsOn` on just for Browse.

## Wire-up and callbacks

[full.md](full.md) `setDelegate` / `initLens` / `showCamera`. Watch `LensEvent.update` for `img_stitched_pdf_path` as well as original and thumbnail paths. Cloud success is `status` `"done"`.

Auto-delete still applies. Copy the PDF path in the update handler, or set `autoDeleteLocalResourcesAfterProcessing: false`.

## Do not

- Treat this as ordinary `stitchIsOn` with `documentTypes: ['receipt']`
- Set `"mobile"`
- Promise check TIFF or Remote Models

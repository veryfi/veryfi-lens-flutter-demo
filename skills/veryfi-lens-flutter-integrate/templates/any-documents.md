# Any-Documents

Any-Documents is a broad capture product. It is not a KYC-only product and not a medical-only product. The host picks a template id (`anyDocumentTemplate`). Nutrition facts, US passport, driver license, and prescription labels are **shortcut flavors** of Any-Documents, not separate plugins and not separate SDKs.

This Flutter plugin does not ship a verified template list. The pinned demo does not prove which template ids are inside the linked Full binary. **Contact support** to confirm an existing template or to arrange one that is not supported yet. Do not invent an id. Do not paste a guessed id into `anyDocumentTemplate`.

## What the binaries allow, before the template id

| Platform | Document types |
|----------|----------------|
| Android Full | `ANY_DOCUMENT` is allowed, and so are shortcut types the Android enum exposes on Full: passport, driver license, nutrition facts, prescription label, shipping label, insurance card. The flavor check is about `documentTypes`, not about whether a named template's model is packed |
| iOS Full | `any_document` plus shortcut flavors are the native Any-Documents design. Whether this `veryfi-lens-spm` build from `3.0.19` contains a given template is **Unconfirmed** |

A type the flavor accepts can still fail detection if the template asset is absent. That is why support has to confirm the id.

## Shortcuts

Use these as Any-Documents, with the template id support provides. Do not create a passport plugin, a nutrition-facts plugin, or a prescription plugin.

| Shortcut | How to talk about it |
|----------|----------------------|
| Nutrition facts | Any-Documents shortcut |
| US passport | Any-Documents shortcut |
| Driver license | Any-Documents shortcut. Back-of-card uses driver-license back flags, not `anyDocumentBackIsOn` |
| Prescription labels | Any-Documents shortcut |

`anyDocumentBackIsOn` runs only when the active type is `any_document`, the flag is true, and `packageMaxScans` is exactly 2. Checks, driver licenses, and insurance cards ignore that flag and use their own back flags.

## Skeleton

Fill `anyDocumentTemplate` only with the id support confirms. Until then, do not ship this object.

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
  documentTypes: ['any_document'],
  showDocumentTypes: false,
  anyDocumentTemplate: '<template-id-from-support>',
  autoCaptureIsOn: false,
  autoDocDetectionAndCropIsOn: true,
  galleryIsOn: false,
  stitchIsOn: false
};
```

Leave `anyDocumentType` unset. It is deprecated local regex OCR.

`cameraProcessingMode` applies to `any_document`. Setting it for receipts may be ignored. Unconfirmed for card types that already use card detectors. Omit it unless support tells the host to set a specific mode.

## Wire-up

Same `init` and `showCamera` as [full.md](full.md). Cloud success is `status` `"done"`. Decoupled capture (`"none"`) is allowed for any type the binary accepts: local zip with auto-delete off, or `uploadWithoutProcessingIsOn: true` for `bucket` and `package_path`.

## Paid add-ons

Local fraud detection and local field detection do not come with the template. Fraud needs the paid backend entitlement. Field detection needs that entitlement and the Field Detection, Remote Models, or Lite flavor. This plugin links Full only, so field detection stays off.

## Do not

- Present a template id as included because it appears in native marketing
- Use Headless or Lite. Unsupported here
- Set `showInfoButton` to render the template UI. The template UI is Lens. `showInfoButton` is an unbridged native view

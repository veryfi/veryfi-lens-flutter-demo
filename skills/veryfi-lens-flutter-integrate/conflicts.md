# Conflicts and support footguns

Run after applying a recipe. Prefer removing extra keys over adding more.

## Hard failures

| Combination | Symptom | Fix |
|-------------|---------|-----|
| `credit_card` or `code` on Android Full | Toast, camera does not open, no delegate event | Say unsupported on this plugin's Android artifact. Contact support. Do not add a second Maven coordinate from the host |
| iOS Full with `check`, `w2`, `w9`, `barcode`, `long_receipt`, `business_card`, cards, or codes when support has not confirmed models | Missing models, poor or no detection | Confirm before shipping. Receipts, invoices, and `other` are the Full UI set that is not marked Unconfirmed |
| `"mobile"` on receipts, checks, W-2, W-9, business cards | No on-device extract | `"api"`, or `"none"` for capture-only |
| `credit_card` with `"api"` or `"none"` when the host expects card data | Card data must stay on device, and Android Full still rejects the type | `"mobile"`, and only if the binary is the credit-card flavor |
| `"always"` same-file policy without `"api"` | Policy cannot confirm uploads | `"session"` or cloud engine |
| `documentFieldsToDetect` on this plugin | Local field detection stays off | Needs a flavor this plugin does not link, plus paid entitlement |
| `fraudDetectionIsOn` without paid entitlement | Stays off | Account/backend gate. The key is not enough |
| `retrieveCheckTiffIsOn` | No TIFF download | Remote Models is not linked |
| `browseIsOn: true` with `moreMenuIsOn: false` | No Browse row | `showBrowserButton` or the gallery Files menu. `showDocumentBrowser` is not exported |
| `autoDeleteLocalResourcesAfterProcessing: true` and the host reads paths later | Empty or overwritten files | Set false, or copy the file at `data` inside the update handler immediately |
| `backupDocsToGallery: true` | Every scan is copied into Photos | Set false |
| `locationServicesIsOn` without a location purpose the host asked for | Unexpected permission prompt | Leave false |
| Quoting XCFramework or AAR size as app size | Wrong install impact | Measure the final build with Lens and without it |

## Submit and session

| Combination | Problem | Fix |
|-------------|---------|-----|
| `autoSubmitDocumentOnCapture` and `batchUploadOnCamera` | Two “when do we leave the camera” policies | Pick one |
| `closeCameraOnSubmit` and `submitWithoutClose` both true | Contradictory submit UX | Pick one. Winner if both are true is **Unconfirmed** |
| `showDocumentTypes: false` with more than one `documentTypes` entry | User cannot switch | Turn the picker on, or set a single type |
| `documentTypes` includes `other` and `autoCaptureOtherIsOn` left at default true | `other` auto-captures even when `autoCaptureIsOn` is false | Base sets `autoCaptureOtherIsOn` false |
| `stitchIsOn` on checks or cards | Wrong UX | `stitchIsOn: false` |
| `packageMaxScans: 1` when a back side is required | Cannot capture the back | Raise the max |
| `multiplePagesCaptureIsOn` used as the package splitter | Side-by-side pages stay one image, or the same-transaction alert never appears | Use `multipleDocumentsIsOn` for the alert |

## Detection

| Combination | Problem | Fix |
|-------------|---------|-----|
| `allowSubmitUndetectedDocsIsOn: false` and check validators without allow-anyway | Users trapped | Keep `allowSubmitCheckSideNotDetected` and `allowSubmitCheckCornersNotDetected` true, or relax the gate |
| `showNoDocumentDetectedWarning: false` and strict undetected gates | Alert hidden, users stuck | Keep undetected-submit true, or turn the warning on while debugging |
| `autoDocDetectionAndCropIsOn: false` and no crop layout | No guide | Enable detect or a crop layout |
| `cropLayoutIsOn: true` while automatic detection stays on | Fixed frame does not activate as expected | Turn automatic detection off for a pure frame, or use `cropLayoutWithAutoDetection` |
| `showHelpButton` and `showInfoButton` both set | One iOS control; Help wins. The info value is not a Flutter widget | Set neither from Dart unless the host only wants the native help glyph, knowing the tap is not bridged |
| `enableScreenshots` used as the import policy | Imported screenshots still submit, or the camera UI is blanked | `allowSubmittingScreenshots` rejects imports. `enableScreenshots` controls device screenshots of Lens |
| `autoCropGalleryIsOn` on screenshots or digital copies | Best effort only | Do not promise every import is cropped |

## Menus, remote, privacy

| Combination | Problem | Fix |
|-------------|---------|-----|
| `ignoreRemoteSettings: false` | Dashboard overrides the recipe | True unless remote control is the product |
| `moreMenuIsOn: true` | Users persist capture and backup overrides. Android writes them back over the host object on the next configure | False |
| `backupDocsToiCloud: true` | Every iOS scan copied to iCloud | False |
| `dictateIsOn: true` | Obsolete dictation | False |
| `retryPackage` on iOS | Returns `retryPackageError` because Dart sends `imageSourceData` and iOS reads `imageSourceTag` | Do not add a Dart argument. Android retries by id and drops metadata |

## Engine pairing

| Combination | Problem | Fix |
|-------------|---------|-----|
| `"none"` and the host expects extracted JSON | No API fields | `"api"` or `"mobile"` for the three on-device types |
| `"none"` + local package + auto-delete true | `local_package_path` is gone | Auto-delete false |
| `uploadWithoutProcessingIsOn: true` without `"none"` | Flag applies only with `"none"` | Set the engine |
| `webhookIsOn` and the host only listens for immediate success | Missed results | Webhook off, or handle the webhook |
| `anyDocumentType` set | Deprecated regex OCR | Use `anyDocumentTemplate` after support confirms the id |

# iOS and Android behavior

One Dart settings map hits two native SDKs. The bridges are not the same, and the Full binaries are not the same product matrix. Generate host code that is safe on **both**, and say which platform still cannot do the thing the host asked for.

Versions in this commit: iOS SPM `veryfi-lens-spm` from `3.0.19`, Android `com.veryfi.lens:veryfi-lens-sdk:2.7.0.2`. Android product rules below are the Lens Android Full artifact contract (confirmed in the Android SDK at `2.7.0.4`). This AAR is the same `2.7.0` series and two patches behind. Treat a behavior that appears only in `2.7.0.4` and not in plugin source as **Unconfirmed** for `2.7.0.2`. See [clarifications.md](clarifications.md).

## Linked binary

| | iOS | Android |
|--|-----|---------|
| Package | `veryfi-lens-spm.git` (Full UI) | `veryfi-lens-sdk` (Full UI, no flavor suffix) |
| How a recipe selects a product | `documentTypes` on that binary | Same, then `FlavorCheckerHelper` |
| `credit_card`, `code` | Whether this Full XCFramework embeds those models is **Unconfirmed**. Contact support before shipping | Full does **not** allow `CREDIT_CARD` or `CODE`. The camera does not open (Toast "Please use only valid document types", no delegate callback) |
| `long_receipt`, `check`, `business_card`, `barcode`, `w2`, `w9`, `any_document` and Any-Documents shortcuts | Model embedding in this Full package is **Unconfirmed** beyond receipts, invoices, and `other`. Contact support | Full allows `LONG_RECEIPT`, `CHECK`, `BUSINESS_CARD`, `BARCODE`, `W2`, `W9`, `ANY_DOCUMENT`, plus passport, driver license, nutrition facts, shipping label, prescription label, insurance card, invoice, receipt, other, bank statement |
| Lite | Unsupported. Not linked | Unsupported. Not linked. Native Lite is a Play Feature module, not an App Clip |
| Headless | Unsupported. Not linked | Unsupported. Separate artifacts |
| Remote Models | Not this SPM URL. Planned | Not this Maven coordinate. Planned. Native Remote Models is the size recommendation and the check-TIFF download path |

A missing native wrapper can be ported later. Shipping a second flavor inside the host app is not a port, and this plugin's Gradle and Package.swift already pin Full. Do not add another Lens dependency beside it.

## Bridge mismatches

| Step | iOS `VeryfiPlugin.swift` | Android `VeryfiPlugin.kt` |
|------|--------------------------|---------------------------|
| `initLens` | `VeryfiLensSettings.init(with:)` and `configure(with:settings:)` with no completion handler. Does not call `result` on success | `initWithJsonObject` then `VeryfiLens.configure` with no completion lambda. Does not call `result.success`. A `JSONException` invokes `veryfiLensError` on the channel and configure still runs |
| Missing maps | `result(FlutterError lensInitError)` | `result.error(lensInitError)` |
| `setDelegate` | `VeryfiLens.shared().delegate = self`. No `result` | `VeryfiLens.setDelegate`. No `result` |
| `showCamera` | `showCamera(in: topVC)` when `UIApplication.getTopViewController()` is non-nil. No `result`. If the top controller is nil, the call does nothing and does not error | `VeryfiLens.showCamera()`. No `result` |
| Camera events | `invokeMethod` `veryfiLensClose` / `Error` / `Success` / `Update` with the native dictionary | Same method names, `json.toMap()` |
| `retryPackage` | Requires `packageID`, `metadata`, and `imageSourceTag`. Dart sends `imageSourceData`, so this `if let` fails and returns `retryPackageError` even when the id was sent | `retryUpload(packageID)` only. Ignores metadata and both tag keys. Empty id returns `retryPackageError`. Success path does not complete `result` |
| `discardPackage` | `utils.discardPackage(with:)` when `packageID` is a string. Otherwise `discardPackageError` | `discardUpload`. Empty id uses detail text "Package ID must be sent to retry the upload" |
| Analytics | `NotificationCenter` `VeryfiLensAnalyticsEvent` into the event sink | `LensAnalyticsReceiver` on `com.veryfi.lens.VeryfiLensSecureAnalyticsEvent` |
| File bytes | No base64 method. Paths arrive on update `data` | Same |
| Help / info view | Settings map cannot construct a `VeryfiInfoView`. No `onHelpButtonClicked` | Settings map cannot construct a `Fragment`. No help callback |

Do not "fix" iOS retry by adding a Dart argument. The public method already accepts `imageSourceTag`. The channel key inside `lens.dart` is the mismatch. A port would send `imageSourceTag` (the name iOS reads) without changing the host call. Android would still ignore metadata.

## Native limits the bridge inherits

### Configure success is not visible

Native iOS wants the host to present only after `completion(true)`. Native Android wants `showCamera()` only inside `configure { ok -> if (ok) … }`. An unusable Android configuration yields `ok == false` and/or a Toast, and Android has **no** `invalid_credentials` delegate error. This plugin never forwards that bool. `invokeMethod` still dispatches configure and the camera. There is no configure-ready signal, so the host cannot wait for configure before `showCamera`. Call both with `unawaited` after `setDelegate`. Do not invent a success callback. If the camera never opens, check credentials and `documentTypes` against the Full artifact.

### Failure status string

iOS package failures use `status` `"fail"`. Android uses `"failed"`. The plugin does not rename `status`. Read both.

### Document types

Strings in the map: `receipt`, `invoice`, `other`, `long_receipt`, `check`, `credit_card`, `business_card`, `barcode`, `code`, `w2`, `w9`, `any_document`. Android maps them to `DocumentType`. More than one type needs `showDocumentTypes: true`.

`"mobile"` extracts on device only for `credit_card`, `code`, and `barcode`. Other types use `"api"` or `"none"`. Android `configure` forces in-app when the first type is `CREDIT_CARD`; that force does not make Full accept the type.

### More menu

`moreMenuIsOn: true` lets end users persist overrides for auto capture, blur, glare, auto torch, gallery backup, close-camera-on-submit, and batch upload. On Android, a later `configure` **replaces the host values** with those stored overrides when the menu is on and the user has opened Lens before. On iOS, hiding the menu discards those stored overrides. Keep `moreMenuIsOn` false unless end users should own the toggles. `moreSettingsMenuIsOn` is a separate More > Settings entry. It does not reset those overrides. Keep it false.

`browseIsOn` only adds Browse inside that More menu. With the menu off, Files need `showBrowserButton: true` or `galleryIsOn` plus `galleryButtonWithFilesIsOn`. This plugin cannot call `showDocumentBrowser`.

### Backups and privacy

Set `backupDocsToGallery` false. The native default is true. Set `backupDocsToiCloud` false on iOS. Android has no iCloud flag. Android acceptance of iOS-only keys is **Unconfirmed**.

`glareDetectionIsOn` defaults true on Android and is a suboptimal algorithmic gate. The base recipe sets it false.

`dictateIsOn` defaults true on Android and is obsolete. The base recipe sets it false.

### Colors and custom UI

Pass colors as hex strings (`#FFFFFFFF`). `customLensStrings` is an iOS dictionary. Android string overrides are resource merges. **Unconfirmed** through `initWithJsonObject`.

`showInfoButton` and `cameraInfoView` stay unbridged. See [unbridged.md](unbridged.md).

### Check TIFF and size

`retrieveCheckTiffIsOn` belongs to native Remote Models, which this plugin does not link. Do not promise TIFF paths.

Measure installed size on the final build, with Lens and without it. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

### Paid detection

`fraudDetectionIsOn` needs the paid backend entitlement. `documentFieldsToDetect` needs the entitlement **and** the Field Detection, Remote Models, or Lite flavor. This plugin's Full link is not those flavors. The setting alone stays off.

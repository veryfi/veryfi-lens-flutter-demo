# Clarifications

Anything not confirmed in the pinned Flutter sources or in the native UI SDK contracts is **Unconfirmed**. Leave it out of host code or say so next to the line that depends on it.

## Plugin source, confirmed

- Version `2.0.59`. iOS SPM `veryfi-lens-spm` from `3.0.19`. Android `com.veryfi.lens:veryfi-lens-sdk:2.7.0.2`. `minSdkVersion` 23 in `android/build.gradle`.
- `lib/lens.dart` exports maps, not `VeryfiLensCredentials` / `VeryfiLensSettings`.
- `initLens`, `showCamera`, `retryAllPackages`, `discardAllPackages`, `shareOCRFeedback`, and `observeAnalyticsEvents` do not call `result` on the success path on either platform. `retryPackage` and `discardPackage` call `result` only on their error branches. Host code uses `unawaited` for every one of them. `setDelegate` is `void`.
- Events are maps on `LensEvent`. Method names are `veryfiLensClose`, `veryfiLensError`, `veryfiLensSuccess`, `veryfiLensUpdate`.
- Dart retry sends `imageSourceData`. iOS reads `imageSourceTag` and returns `retryPackageError`. Android retries by `packageID` only.
- No `showGallery`, `showDocumentBrowser`, `closeCamera`, `uploadImages`, `getFileBase64`, Headless, or Lite symbols on `Veryfi`.

## Unconfirmed

| Item | Why |
|------|-----|
| Models inside the iOS Full XCFramework beyond receipts, invoices, and `other` | Not unpacked. Contact support before `long_receipt`, `check`, cards, `barcode`, `code`, `w2`, `w9`, or an Any-Documents template |
| Android flavor gate on exactly `2.7.0.2` | The Full matrix (no `CREDIT_CARD`, no `CODE`; other listed types allowed) is confirmed on Android SDK `2.7.0.4`. This AAR is two patches older. Do not promise a type the Full artifact rejects |
| `initWithJsonObject` for every recipe key, including `ocrType`, `continuousAutoFocus`, `backupDocsToiCloud`, check validators | Not executed against this AAR |
| Barcode and OCR success field names on Android | iOS forwards `BarcodeResult` / `OCRResult` without the package envelope. Android field list was not read from this AAR |
| Winner if `closeCameraOnSubmit` and `submitWithoutClose` are both true | Native behavior still open |
| `customLensStrings` through the Android JSON initializer | iOS dictionary mechanism. Android strings are resources |
| Contacts and Calendar usage strings in the README | Not used by these recipes. Treat those features as stale |

## iOS and Android differences that change this plugin

| Topic | iOS | Android |
|-------|-----|---------|
| Failure `status` | `fail` | `failed` |
| Configure result | Native completion exists. This plugin calls `configure` without it and does not call `result` on success. Host uses `unawaited` | Native completion exists. This plugin does not pass a lambda and does not call `result.success`. Host uses `unawaited` |
| Invalid credentials | Delegate `msg` `invalid_credentials` when the SDK emits it | No `invalid_credentials` event. Failures are a Toast and a false configure result the plugin does not forward |
| Retry tag | Key `imageSourceTag` required, not sent | Id only |
| More menu | Hiding it drops stored overrides | Menu on replaces host values on later configure |
| Info UI | `VeryfiInfoView` | `Fragment` |
| iCloud backup | `backupDocsToiCloud` | No equivalent |
| `utils`, SwiftUI, share extension, `headlessUpload` | Native iOS only, not bridged | Not on Android |
| Check TIFF paths | Remote Models | Remote Models. Not this AAR |
| Gallery backup default | True | True |
| `glareDetectionIsOn` default | Leave false unless requested | Default true |
| `dictateIsOn` default | Leave false | Default true |
| `packageMaxScans` default | Recipe sets 10 for receipts | Native default 5 |
| `autoRotateIsOn` / skew / clean border | Recipes set them for paper documents | Native defaults false |
| Hybrid crop layout | `cropLayoutWithAutoDetection` alone | Also set `cropLayoutIsOn` |

## Unsupported

- Headless Receipts and Headless Credit Cards
- Lite and App Clip
- A current Remote Models dependency, including check TIFF
- Host-authored `VeryfiInfoView` or Android info `Fragment`
- `dataExtractionEngine: "custom"`
- Partner dictation (`dictateIsOn`)
- Using this skill to patch `VeryfiPlugin.swift` or `VeryfiPlugin.kt`

Native methods in [unbridged.md](unbridged.md) exist on the SDKs and could be ported into the plugin. Until that ships, they are unavailable from Flutter.

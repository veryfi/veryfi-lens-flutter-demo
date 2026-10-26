# API parity

"Yes" means the method is on `Veryfi` in `lib/lens.dart` and a native handler exists. The native SDK method can still exist when this column says No. Those are port candidates, not host calls. See [unbridged.md](unbridged.md).

## Presentation and lifecycle

| Call | Flutter | Native iOS UI SDK | Native Android UI SDK |
|------|---------|-------------------|------------------------|
| Configure | `unawaited(Veryfi.initLens)`. Success does not call `result` | `configure(with:settings:)` with no completion, and no `result` on success | `configure` with no completion lambda, and no `result.success` |
| Camera | `unawaited(Veryfi.showCamera)` after `setDelegate` | `showCamera(in:)` | `showCamera()` |
| Gallery as its own screen | No | `showGallery(in:)` | `showGallery()` |
| Document browser | No | `showDocumentBrowser(in:)` | `showDocumentBrowser()` |
| Close camera | No | Presenter close | `closeCamera()` |
| UI SDK `uploadImages` | No | `uploadImages(paths:)` | `uploadImages(uris/paths, isSameTransaction)` |
| iOS `headlessUpload` | No | Yes, in memory, not Headless | No |
| Headless `process` | No | Headless binary only | Headless binary only |
| Delegate | `setDelegate` + `LensEvent` | `VeryfiLensDelegate` | `VeryfiLensDelegate` |
| Analytics | `observeAnalyticsEvents` + `analyticsStream` | `VeryfiLensAnalyticsEvent` | Secure analytics broadcast |
| Retry one | `retryPackage(id, metadata, tag)` | Reads `imageSourceTag`. Dart sends `imageSourceData`, so iOS errors | `retryUpload(id)` |
| Retry all | Yes | Yes | `retryAll()` |
| Discard one / all | Yes | `utils.discardPackage` / `discardAllPackages` | `discardUpload` / `discardAll` |
| Share OCR feedback | Yes | `shareOCRFeedback` | `shareOCRFeedback` |
| File base64 | No | `utils` base64 helper | Not wrapped. Host reads the path |
| Help button event | No | `onHelpButtonClicked` | `onHelpButtonClicked` |
| `clearLensStorage` | No | `utils.clearLensStorage()` | Not wrapped |

## Retry mismatch

| | iOS bridge | Android bridge |
|--|------------|----------------|
| What Dart sends | `packageID`, `metadata`, `imageSourceData` | Same map |
| What native reads | `packageID`, `metadata`, `imageSourceTag` | `packageID` only |
| Result | `retryPackageError` because `imageSourceTag` is missing | `retryUpload` when the id is non-empty. Metadata is dropped |

## Events

| Native | Flutter |
|--------|---------|
| `veryfiLensClose` | `LensEvent.close` |
| `veryfiLensUpdate` | `LensEvent.update` |
| `veryfiLensSuccess` | `LensEvent.success` |
| `veryfiLensError` | `LensEvent.error` |
| Analytics | `analyticsStream` |
| `onHelpButtonClicked` | No |

There is no `veryfi_lens_*` string on this plugin. Switch on `LensEvent`.

## Settings

A map into `VeryfiLensSettings`. No typed settings class in `lens.dart`. CamelCase keys. Details: [settings-catalog.md](settings-catalog.md).

## Products

| Product | This plugin |
|---------|-------------|
| Full UI, then a recipe | Current path |
| Receipts, long receipts, checks, business cards, barcodes, W-2, W-9 | Settings on Full, if that platform's Full binary allows the type |
| Credit cards, OCR strips, OCR caps | Settings exist. Android Full rejects the type. iOS Full embedding Unconfirmed |
| Lite / App Clip | **Unsupported** |
| Headless receipts, Headless credit cards | **Unsupported** |
| Remote Models, check TIFF | **Not current.** Planned |
| iOS `headlessUpload` | **Unsupported** |

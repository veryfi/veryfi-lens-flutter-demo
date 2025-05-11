import 'package:flutter_dotenv/flutter_dotenv.dart';

class Utils {
  static String getSettingsForDocumentType(String documentType) {
    switch (documentType) {
      case 'Lens for Receipts & Invoices':
        return 'receipt';
      case 'Lens for Long Receipts':
        return 'long_receipt';
      case 'Lens for Checks':
        return 'check';
      case 'Lens for Credit Cards':
        return 'credit_card';
      case 'Lens for Business Cards':
        return 'business_card';
      case 'Lens for OCR':
        return 'code';
      case 'Lens for W-2':
        return 'w2';
      case 'Lens for W-9':
        return 'w9';
      case 'Lens for Bank Statements':
        return 'bank_statements';
      case 'Lens for Barcodes':
        return 'barcodes';
      case 'Headless Receipts':
        return 'receipt';
      case 'Headless Credit Card':
        return 'credit_card';
      default:
        return 'receipt';
    }
  }

  static Map<String, dynamic> getSettings(
      Map<String, bool> preferences, String documentTypeResult) {
    return {
      'blurDetectionIsOn': preferences['Blur detection'],
      'showDocumentTypes': preferences['Show document types'],
      'glareDetectionIsOn': preferences['Glare Detection'],
      'autoLightDetectionIsOn': preferences['Auto Light Detection'],
      'multipleDocumentsIsOn': preferences['Multiple documents'],
      'multiplePagesCaptureIsOn': preferences['Multiple pages'],
      'allowSubmitUndetectedDocsIsOn':
          preferences['Allow submit undetected docs'],
      'autoSubmitDocumentOnCapture':
          preferences['Allow submit document capture'],
      'zoomIsOn': preferences['Zoom'],
      'switchCameraIsOn': preferences['Switch Camera'],
      'enableScreenshots': preferences['Enable Screenshots'],
      'documentTypes': [documentTypeResult],
      'defaultSelectedDocumentType': documentTypeResult,
      'ignoreRemoteSettings': preferences['Ignore remote settings'],
      'ocrType':'caps',
      'ocrRadius':30,
      'dataExtractionEngine':'api',
      'autoTagDeviceId':true,
      'autoTagLensVersion':true,
      'autoTagPlatform':true,
      'tags':[]
    };
  }

  static Map<String, dynamic> getCredentials() {
    return {
      'clientId': dotenv.env['VERYFI_CLIENT_ID'] ?? 'YourClientId',
      'userName': dotenv.env['VERYFI_USERNAME'] ?? 'YourUserName',
      'apiKey': dotenv.env['VERYFI_API_KEY'] ?? 'YourApiKey',
      'url': dotenv.env['VERYFI_URL'] ?? 'YourUrl',
    };
  }

  static Map<String, bool> getPreferences() {
    return {
      'Blur detection': false,
      'Show document types': true,
      'Glare Detection': true,
      'Auto Light Detection': true,
      'Stitch': false,
      'Multiple documents': true,
      'Multiple pages': true,
      'Allow submit undetected docs': true,
      'Allow submit document capture': false,
      'Switch Camera': false,
      'Enable Screenshots': true,
      'Zoom': false,
      'Ignore remote settings': true
    };
  }
}

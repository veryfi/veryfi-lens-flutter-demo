import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veryfi/lens.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  ExtractedData? _extractedData;
  String? _jsonString;
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initPlatformState();
    Veryfi.setDelegate(handleVeryfiEvent);
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> credentials = {
      'clientId': dotenv.env['VERYFI_CLIENT_ID'] ?? 'your_client_id',
      'userName': dotenv.env['VERYFI_USERNAME'] ?? 'your_username',
      'apiKey': dotenv.env['VERYFI_API_KEY'] ?? 'your_api_key',
      'url': dotenv.env['VERYFI_URL'] ?? 'your_url'
    };

    Map<String, dynamic> settings = {
      'blurDetectionIsOn': false,
      'showDocumentTypes': true
    };

    try {
      await Veryfi.initLens(credentials, settings);
      setState(() { _isLoading = false; });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
        showError('Error initializing Veryfi: ${e.message}');
      });
    }
  }

  void showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Veryfi Lens Wrapper'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Extracted Data'),
              Tab(text: 'JSON'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                _buildExtractedDataView(),
                _buildJsonDataView(),
              ],
            ),
            if (_isLoading) _buildLoadingScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onShowCameraPressed,
          child: Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  void onShowCameraPressed() async {
    setState(() { _isLoading = true; });
    await Veryfi.showCamera();
  }

  void handleVeryfiEvent(LensEvent eventType, Map<String, dynamic> response) {
    if (eventType == LensEvent.update) {
      var status = response['status'];
      if (status == 'start') {
        setState(() => _isLoading = true);
      } else if (status == 'removed') {
        setState(() => _isLoading = false);
      }
    } else if (eventType == LensEvent.success) {
      setState(() {
        _jsonString = response['data'].toString();
        _extractedData = ExtractedData.fromJson(Map<String, dynamic>.from(response['data']));
      });
    } else if (eventType == LensEvent.close) {
      var queueCount = response['queue_count'] ?? 0;
      if (queueCount == 0) {
        setState(() => _isLoading = false);
      }
    }
  }


  Widget _buildExtractedDataView() {
    if (_extractedData == null) return Center(child: Text('No extracted data'));
    return ListView(
      children: [
        ListTile(title: Text('ID: ${_extractedData?.id ?? "Not available"}')),
        ListTile(title: Text('Invoice Number: ${_extractedData?.invoiceNumber ?? "Not available"}')),
        ListTile(title: Text('Currency Code: ${_extractedData?.currencyCode ?? "Not available"}')),
        ListTile(title: Text('Tax: ${_extractedData?.tax?.toStringAsFixed(2) ?? "Not available"}')),
        ListTile(title: Text('Category: ${_extractedData?.category ?? "Not available"}')),
        ListTile(title: Text('Image File Name: ${_extractedData?.imgFileName ?? "Not available"}')),
        ListTile(title: Text('Reference: ${_extractedData?.reference ?? "Not available"}')),
        ListTile(title: Text('Created Date: ${_extractedData?.createdDate ?? "Not available"}')),
      ],
    );
  }

  Widget _buildJsonDataView() {
    if (_jsonString == null) return Center(child: Text('No JSON data'));
    return SingleChildScrollView(
      child: Text(_jsonString ?? 'No JSON data'),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/loading_animation.json'),
            Text('Reading document...', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

class ExtractedData {
  String? id;
  String? invoiceNumber;
  String? currencyCode;
  double? tax;
  String? category;
  String? imgFileName;
  String? reference;
  String? createdDate;

  ExtractedData({
    this.id,
    this.invoiceNumber,
    this.currencyCode,
    this.tax,
    this.category,
    this.imgFileName,
    this.reference,
    this.createdDate,
  });

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      id: json['id']?.toString(),
      invoiceNumber: json['invoice_number'],
      currencyCode: json['currency_code'],
      tax: json['tax'] != null ? double.tryParse(json['tax'].toString()) : null,
      category: json['category'],
      imgFileName: json['img_file_name'],
      reference: json['reference_number'],
      createdDate: json['created_date'],
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veryfi/lens.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:json_shrink_widget/json_shrink_widget.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool showVeryfiResults = false;
  ExtractedData? _extractedData;
  bool _isLoading = false;
  late TabController _tabController;
  Map<String, dynamic> _eventData = {};

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> credentials = {
      'clientId': dotenv.env['VERYFI_CLIENT_ID'] ?? 'YourClientId',
      'userName': dotenv.env['VERYFI_USERNAME'] ?? 'YourUserName',
      'apiKey': dotenv.env['VERYFI_API_KEY'] ?? 'YourApiKey',
      'url': dotenv.env['VERYFI_URL'] ?? 'YourUrl',
    };

    Map<String, dynamic> settings = {
      'blurDetectionIsOn': false,
      'showDocumentTypes': true,
      'documentTypes': ['long_receipt']
    };

    try {
      await Veryfi.initLens(credentials, settings);
      startListeningEvents();
    } on PlatformException catch (e) {
      print("Failed to initialize Veryfi: ${e.message}");
    }
  }

  void startListeningEvents() {
    Veryfi.setDelegate(handleVeryfiEvent);
  }

  var widgetsList = <Widget>[];

  void handleVeryfiEvent(LensEvent eventType, Map<String, dynamic> response) {
    setState(() {
      String eventName = eventType.toString().split('.').last;
      _eventData[eventName] ??= [];
      _eventData[eventName].add({
        'status': response['status'],
        'msg': response['msg'],
        'data': response['data'],
      });
      showVeryfiResults = true;
    });

    if (eventType == LensEvent.update) {
      var status = response['status'];
      if (status == 'start') {
        setState(() => _isLoading = true);
      } else if (status == 'removed') {
        setState(() => _isLoading = false);
      }
    } else if (eventType == LensEvent.success) {
      setState(() {
        _extractedData =
            ExtractedData.fromJson(Map<String, dynamic>.from(response['data']));
      });
    } else if (eventType == LensEvent.close) {
      var queueCount = response['queue_count'] ?? 0;
      if (queueCount == 0) {
        setState(() {
          _isLoading = false;
          showVeryfiResults = false;
        });
      }
    }

    widgetsList.add(const SizedBox(
      height: 30,
    ));

    widgetsList.add(const Divider(
      thickness: 1,
    ));
  }

  Widget buildVeryfiResultsList() {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE9ECE4),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildButton(0, 'Extracted Data'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildButton(1, 'JSON'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            color: const Color(0xFFE9ECE4),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExtractedDataView(),
                _buildJsonDataView(),
              ],
            ),
          ),
        ),
        if (_isLoading) _buildLoadingScreen(),
      ],
    );
  }

  Widget _buildButton(int index, String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _tabController.index == index
            ? const Color(0xFF00FA6C)
            : const Color(0xFF002108),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _tabController.index == index
              ? const Color(0xFFE9ECE4)
              : const Color(0xFF00FA6C),
        ),
      ),
    );
  }



  String getSettingsForDocumentType(String documentType) {
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

  void onShowCameraPressed(String documentType) async {
    Map<String, dynamic> credentials = {
      'clientId': dotenv.env['VERYFI_CLIENT_ID'] ?? 'YourClientId',
      'userName': dotenv.env['VERYFI_USERNAME'] ?? 'YourUserName',
      'apiKey': dotenv.env['VERYFI_API_KEY'] ?? 'YourApiKey',
      'url': dotenv.env['VERYFI_URL'] ?? 'YourUrl',
    };
    var documentTypeResult = getSettingsForDocumentType(documentType);

    Map<String, dynamic> settings = {
      'blurDetectionIsOn': false,
      'showDocumentTypes': true,
      'documentTypes': [documentTypeResult]
    };

    setState(() {
      Veryfi.initLens(credentials, settings);
      startListeningEvents();
      _isLoading = false;
    });

    await Veryfi.showCamera();
  }

  final List<Map<String, dynamic>> menuOptions = [
    {
      'title': 'Lens for Receipts & Invoices',
      'icon': Icons.receipt_long,
    },
    {
      'title': 'Lens for Long Receipts',
      'icon': Icons.receipt,
    },
    {
      'title': 'Lens for Checks',
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Lens for Credit Cards',
      'icon': Icons.credit_card,
    },
    {
      'title': 'Lens for Business Cards',
      'icon': Icons.business_center,
    },
    {
      'title': 'Lens for OCR',
      'icon': Icons.text_fields,
    },
    {
      'title': 'Lens for W-2',
      'icon': Icons.library_books,
    },
    {
      'title': 'Lens for W-9',
      'icon': Icons.library_books,
    },
    {
      'title': 'Lens for Bank Statements',
      'icon': Icons.account_balance,
    },
    {
      'title': 'Lens for Barcodes',
      'icon': Icons.qr_code_scanner,
    },
  ];

  final List<Map<String, dynamic>> headlessOptions = [
    {
      'title': 'Headless Receipts',
      'icon': Icons.receipt_long,
    },
    {
      'title': 'Headless Credit Card',
      'icon': Icons.credit_card,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECE4),
      body: showVeryfiResults ? buildVeryfiResultsList() : buildMainMenu(),
    );
  }

  Widget buildMainMenu() {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
            height: 120, child: Image.asset('assets/ic_veryfi_logo_black.PNG')),
        Card(
          elevation: 10,
          margin: const EdgeInsets.all(12.0),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: SizedBox(
            height: 550,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Solutions',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ...menuOptions.map((option) => Padding(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        dense: true,
                        leading: Icon(option['icon'], size: 24.0),
                        title: Text(
                          option['title'],
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        trailing: const Icon(Icons.settings, size: 20.0),
                        onTap: () => onShowCameraPressed(option['title']),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtractedDataView() {
    if (_extractedData == null) {
      return const Center(child: Text('No extracted data'));
    }
    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(12.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListView(
        children: [
          ListTile(title: Text('ID: ${_extractedData?.id ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Invoice Number: ${_extractedData?.invoiceNumber ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Currency Code: ${_extractedData?.currencyCode ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Tax: ${_extractedData?.tax?.toStringAsFixed(2) ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Category: ${_extractedData?.category ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Image File Name: ${_extractedData?.imgFileName ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Reference: ${_extractedData?.reference ?? "Not available"}')),
          ListTile(
              title: Text(
                  'Created Date: ${_extractedData?.createdDate ?? "Not available"}')),
        ],
      ),
    );
  }

  Widget _buildJsonDataView() {
    if (_eventData.isEmpty) {
      return const Center(child: Text('No JSON data'));
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: JsonShrinkWidget(
                  style: const JsonShrinkStyle(
                      textStyle: TextStyle(color: Colors.black),
                      keyStyle: TextStyle(color: Colors.black),
                      numberStyle: TextStyle(color: Colors.black),
                      boolStyle: TextStyle(color: Colors.black),
                      symbolStyle: TextStyle()
                  ),
                  json: _eventData,
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildLoadingScreen() {
    return Container(
      color: const Color(0xFFE9ECE4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 120,
                child: Image.asset('assets/ic_veryfi_logo_black.PNG')),
            const Text('Please wait.. reading document.', style: TextStyle(fontSize: 20)),
            Lottie.asset('assets/loading_animation.json'),
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

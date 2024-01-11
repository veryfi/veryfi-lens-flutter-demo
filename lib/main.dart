import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veryfi/lens.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

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

    try {
      await Veryfi.initLens(credentials, preferences);
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
            title: const Text('Lens console'),
            backgroundColor: const Color(0xFFE9ECE4),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  showVeryfiResults = false;
                });
              },
            ),
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
                      child: _buildButton(1, 'Json'),
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
            ? const Color(0xFF00AA00)
            : const Color(0xFF173835),
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
        Container(
          margin: const EdgeInsets.all(12.0),
          child: Material(
            color: Colors.white,
            elevation: 10,
            borderRadius: BorderRadius.circular(7.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Importante para ajustar al contenido
              children: [
                const SizedBox(height: 20.0,),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Solutions',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF171C3A)),
                    ),
                  ),
                ),
                ...menuOptions.map((option) => Padding(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      option['icon'],
                      size: 24.0,
                      color: const Color(0xFF171C3A),
                    ),
                    title: Text(
                      option['title'],
                      style: const TextStyle(
                          fontSize: 14.0, color: Color(0xFF171C3A)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings, size: 27.0, color: Color(0xFF171C3A)),
                      onPressed: _showSettingsPanel,
                    ),
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

  Map<String, bool> preferences = {
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
    'Zoom': false,
  };

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (_, controller) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xFF171C3A)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Material(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                            color: const Color(0xFFE9ECE4),
                            elevation: 2.0,
                            child: Column(
                              children: [
                                const ListTile(
                                  leading: Icon(Icons.settings, size: 24.0,color: Color(0xFF171C3A)),
                                  title: Text('General Settings',style: TextStyle(color: Color(0xFF171C3A)),),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    controller: controller,
                                    itemCount: preferences.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String key =
                                          preferences.keys.elementAt(index);
                                      return _customSwitchListTile(
                                        key,
                                        preferences[key]!,
                                        (bool value) {
                                          setState(() {
                                            preferences[key] = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _customSwitchListTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title,style: const TextStyle(color: Color(0xFF171C3A)),),
      trailing: Transform.scale(
        scale: 0.7,
        child: Switch(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
          },
          activeColor: const Color(0xFF171C3A),
        ),
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }

  Widget _buildExtractedDataView() {
    if (_extractedData == null) {
      return const Center(child: Text('No extracted data'));
    }

    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Material(
        elevation: 10,
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Extracted fields',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color(0xFF171C3A)
                ),
              ),
            ),
            _buildListTile('ID', _extractedData?.id ?? "Not available"),
            _buildListTile('Invoice Number',
                _extractedData?.invoiceNumber ?? "Not available"),
            _buildListTile('Currency Code',
                _extractedData?.currencyCode ?? "Not available"),
            _buildListTile('Tax',
                _extractedData?.tax?.toStringAsFixed(2) ?? "Not available"),
            _buildListTile(
                'Category', _extractedData?.category ?? "Not available"),
            _buildListTile('Image File Name',
                _extractedData?.imgFileName ?? "Not available"),
            _buildListTile(
                'Reference', _extractedData?.reference ?? "Not available"),
            _buildListTile(
                'Created Date', _extractedData?.createdDate ?? "Not available"),
            _buildListTile('Thumbnail Url',
                _extractedData?.imgThumbNail ?? "Not available",
                isUrl: true),
            _buildListTile(
                'Image Url', _extractedData?.imgUrl ?? "Not available",
                isUrl: true),
            _buildListTile('Pdf Url', _extractedData?.pdfUrl ?? "Not available",
                isUrl: true),
            _buildListTile(
                'Store Number', _extractedData?.storeNumber ?? "Not available"),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF171C3A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: isUrl
                ? SelectableText(
                    value,
                    style: const TextStyle(color: Color(0xFF171C3A)),
                    textAlign: TextAlign.right,
                  )
                : Text(
                    value,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonDataView() {
    if (_eventData.isEmpty) {
      return const Center(child: Text('No JSON data'));
    }

    Map<String, dynamic> jsonMap = json.decode(json.encode(_eventData));

    List<TextSpan> spans = _createSpans(jsonMap);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          children: spans,
          style: const TextStyle(color: Colors.black, fontSize: 14.0),
        ),
      ),
    );
  }

  List<TextSpan> _createSpans(dynamic value, {String indent = ''}) {
    List<TextSpan> spans = [];

    if (value is Map<String, dynamic>) {
      spans.add(
          const TextSpan(text: '{\n', style: TextStyle(color: Colors.black)));
      value.forEach((key, val) {
        spans.add(TextSpan(
            text: '$indent  "$key": ',
            style: const TextStyle(color: Colors.black)));
        spans.addAll(_createSpans(val, indent: '$indent  '));
        spans.add(
            const TextSpan(text: ',\n', style: TextStyle(color: Colors.black)));
      });
      spans.add(TextSpan(
          text: '$indent}', style: const TextStyle(color: Colors.black)));
    } else if (value is List) {
      spans.add(
          const TextSpan(text: '[\n', style: TextStyle(color: Colors.black)));
      for (var val in value) {
        spans.addAll(_createSpans(val, indent: '$indent  '));
        spans.add(
            const TextSpan(text: ',\n', style: TextStyle(color: Colors.black)));
      }
      spans.add(TextSpan(
          text: '$indent]', style: const TextStyle(color: Colors.black)));
    } else {
      spans.add(_formatValueSpan(value));
    }

    return spans;
  }

  TextSpan _formatValueSpan(dynamic value) {
    Color color;
    String text;

    if (value is String) {
      color = const Color(0xFF00AA00);
      text = '"$value"';
    } else if (value is int) {
      color = Colors.red;
      text = value.toString();
    } else if (value is bool) {
      color = Colors.red;
      text = value.toString();
    } else if (value is double) {
      color = Colors.orange;
      text = value.toString();
    } else {
      color = Colors.grey;
      text = value.toString();
    }

    return TextSpan(text: text, style: TextStyle(color: color));
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
            const Text('Please wait.. reading document.',
                style: TextStyle(fontSize: 20,color: Color(0xFF171C3A))),
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
  String? imgThumbNail;
  String? imgUrl;
  String? pdfUrl;
  String? storeNumber;

  ExtractedData(
      {this.id,
      this.invoiceNumber,
      this.currencyCode,
      this.tax,
      this.category,
      this.imgFileName,
      this.reference,
      this.createdDate,
      this.imgThumbNail,
      this.imgUrl,
      this.pdfUrl,
      this.storeNumber});

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
      imgThumbNail: json['img_thumbnail_url'].toString(),
      imgUrl: json['img_url'].toString(),
      pdfUrl: json['pdf_url'].toString(),
      storeNumber: json['store_number'].toString(),
    );
  }
}

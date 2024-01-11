import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veryfi/lens.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:veryfi_flutter_lens_demo/widgets/ui/json_viewer.dart';
import 'widgets/ui/home_menu.dart';
import 'widgets/ui/loading.dart';
import 'widgets/ui/settings.dart';
import 'widgets/ui/extracted_data.dart';
import 'models/extracted_data_model.dart';
import 'utils/utils.dart';

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

  Map<String, bool> preferences = Utils.getPreferences();

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

    Map<String, dynamic> credentials = Utils.getCredentials();

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
                ExtractedDataWidget(_extractedData),
                JsonViewer(_eventData),
              ],
            ),
          ),
        ),
        if (_isLoading) const LoadingScreenWidget(),
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

  void onShowCameraPressed(String documentType) async {

    Map<String, dynamic> credentials = Utils.getCredentials();

    var documentTypeResult = Utils.getSettingsForDocumentType(documentType);

    Map<String, dynamic> settings = Utils.getSettings(preferences, documentTypeResult);

    setState(() {
      Veryfi.initLens(credentials, settings);
      startListeningEvents();
      _isLoading = false;
    });

    await Veryfi.showCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECE4),
      body: showVeryfiResults
          ? buildVeryfiResultsList()
          : MainMenuWidget(
              onShowCameraPressed: onShowCameraPressed,
              showSettingsPanel: _showSettingsPanel),
    );
  }

  void _showSettingsPanel() {
    SettingsPanel.showSettingsPanel(context, preferences);
  }
}

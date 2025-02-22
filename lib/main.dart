import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veryfi/lens.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:veryfi_flutter_lens_demo/models/analytics_event.dart';
import 'package:veryfi_flutter_lens_demo/widgets/ui/analytics.dart';
import 'package:veryfi_flutter_lens_demo/widgets/ui/json_viewer.dart';
import 'widgets/ui/home_menu.dart';
import 'widgets/ui/loading.dart';
import 'widgets/ui/settings.dart';
import 'widgets/ui/extracted_data.dart';
import 'models/extracted_data_model.dart';
import 'utils/utils.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool showVeryfiResults = false;
  ExtractedData? _extractedData;
  bool _isLoading = false;
  late TabController _tabController;
  final Map<String, dynamic> _eventData = {};
  final List<AnalyticsEvent> _analytics = [];
  StreamSubscription<Map<String, dynamic>>? _streamSubscription;

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _streamSubscription = Veryfi.analyticsStream.listen((analyticsEvent) {
      AnalyticsEvent event = AnalyticsEvent(
          name: analyticsEvent["event"],
          params: analyticsEvent["params"]
      );
      _analytics.add(event);
    });
    Veryfi.observeAnalyticsEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _streamSubscription?.cancel();
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
      _eventData["events"] ??= [];
      _eventData["events"].add(response);
      showVeryfiResults = true;
    });
    if (eventType == LensEvent.update) {
      if (response['status'] == "start") {
        setState(() {
          _isLoading = true;
        });
      }
    }
  if (eventType == LensEvent.success) {
      setState(() {
        _extractedData =
            ExtractedData.fromJson(Map<String, dynamic>.from(response['data']));
        _isLoading = false;
      });
    }
    if (eventType == LensEvent.error) {
      setState(() {
        _isLoading = false;
      });
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildButton(2, 'Analytics'),
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
                AnalyticsWidget(_analytics)
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

    Map<String, dynamic> settings =
        Utils.getSettings(preferences, documentTypeResult);

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

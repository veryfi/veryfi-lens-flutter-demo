/// [dart-packages]
import 'dart:async';
import 'dart:io';

/// [flutter-packages]
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [veryfi-packages]
import 'package:veryfi/lens.dart';

/// [third-party-packages]
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var widgetsList = <Widget>[];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Map<String, dynamic> credentials = {
      'clientId':
          dotenv.env['VERYFI_CLIENT_ID'] ?? 'XXXX', //Replace with your clientId
      'userName':
          dotenv.env['VERYFI_USERNAME'] ?? 'XXXX', //Replace with your username
      'apiKey':
          dotenv.env['VERYFI_API_KEY'] ?? 'XXXX', //Replace with your apiKey
      'url': dotenv.env['VERYFI_URL'] ?? 'XXXX' //Replace with your url
    };

    Map<String, dynamic> settings = {
      'blurDetectionIsOn': false,
      'showDocumentTypes': true
    };

    try {
      Veryfi.initLens(credentials, settings);
    } on PlatformException catch (e) {
      setState(() {
        var errorText = 'There was an error trying to initialize Lens:\n\n';
        errorText += '${e.code}\n\n';
        widgetsList.add(Text(errorText));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Veryfi Lens Wrapper'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: startListeningEvents,
                      child: Text("Start Listening Events"),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: widgetsList,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onShowCameraPressed,
          child: Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  void startListeningEvents() {
    Veryfi.setDelegate(handleVeryfiEvent);
  }

  void onShowCameraPressed() async {
    await Veryfi.showCamera();
  }

  void handleVeryfiEvent(LensEvent eventType, Map<String, dynamic> response) {
    setState(() {
      var veryfiResult = '${eventType.toString()}\n\n';
      widgetsList.add(Text(
        veryfiResult,
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      veryfiResult = '${response.toString()}\n\n';
      widgetsList.add(Text(veryfiResult));
    });

    if (eventType.index == 3) {
      if (response["data"] != null &&
          response["data"].toString().contains(".jpg")) {
        var imagePath = response["data"].toString();
        if (imagePath.contains("thumbnail")) {
          widgetsList.add(Text(
            "Thumbnail",
            style: TextStyle(fontWeight: FontWeight.normal),
          ));
          widgetsList.add(
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Image.file(
                  File(imagePath),
                ),
              ),
            ),
          );
        } else {
          widgetsList.add(Text(
            "Original",
            style: TextStyle(fontWeight: FontWeight.normal),
          ));
          widgetsList.add(
            Image.file(
              File(imagePath),
            ),
          );
        }
      }
    }

    widgetsList.add(SizedBox(
      height: 30,
    ));

    widgetsList.add(Divider(
      thickness: 1,
    ));
  }
}

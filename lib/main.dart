import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {

  bool? _isUnityArSupportedOnDevice;
  bool _isArSceneActive = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  Expanded(
                    // unity platformview
                    child: EmbedUnity(
                      onMessageFromUnity: _onMessageFromUnity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text("Activate AR ($_arStatusMessage)"),
                        Switch(
                            value: _isArSceneActive,
                            onChanged: _onArSwitchValueChanged),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onMessageFromUnity(String data) {
    // A message has been received from a Unity script
    if (data == "scene_loaded") {
      _sendRotationSpeedToUnity();
    }
    // handle Unity's detection of AR support
    else if (data == "ar:true") {
      setState(() {
        _isUnityArSupportedOnDevice = true;
      });
    } else if (data == "ar:false") {
      setState(() {
        _isUnityArSupportedOnDevice = false;
      });
    }
  }

  String get _arStatusMessage {
    if (_isUnityArSupportedOnDevice == null) {
      return "checking...";
    } else if (_isUnityArSupportedOnDevice!) {
      return "supported";
    } else {
      return "not supported";
    }
  }

  void _onArSwitchValueChanged(bool value) {
    if (_isUnityArSupportedOnDevice != null && _isUnityArSupportedOnDevice!) {
      // tell unity to switch to a scene that includes AR
      sendToUnity(
        "SceneSwitcher",
        "SwitchToScene",
        _isArSceneActive
            ? "FlutterEmbedExampleScene"
            : "FlutterEmbedExampleSceneAR",
      );
      setState(() {
        _isArSceneActive = value;
      });
    }
  }

  void _sendRotationSpeedToUnity() {
    sendToUnity(
      "FlutterLogo",
      "SetRotationSpeed",
      "30",
    );
  }
}

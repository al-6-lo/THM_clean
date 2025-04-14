import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AlertProvider extends ChangeNotifier {
  final FlutterTts flutterTts = FlutterTts();
  Timer? _alertTimer;
  bool _isDanger = false;

  void startAlert(String bedName) {
    if (_alertTimer != null && _alertTimer!.isActive) return;

    _isDanger = true;
    _alertTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak("Patient $bedName is in danger");
    });

    notifyListeners();
  }

  void stopAlert() {
    _alertTimer?.cancel();
    flutterTts.stop();
    _isDanger = false;
    notifyListeners();
  }

  bool get isDanger => _isDanger;
}

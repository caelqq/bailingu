import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ============================================================
// SOUND
// speak("iro")  -> plays assets/audio/word_iro.mp3 if it exists
// speak("ro")   -> plays assets/audio/syl_ro.mp3 if it exists
// If there is no clip yet, it falls back to the device's robot voice.
// ============================================================
final AudioPlayer _player = AudioPlayer();
final FlutterTts _tts = FlutterTts();
bool _configured = false;
Set<String>? _assets;

/// Is this file inside the app's assets? (e.g. 'assets/audio/word_iro.mp3')
Future<bool> _hasAsset(String path) async {
  try {
    _assets ??= (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets()
        .toSet();
    return _assets!.contains(path);
  } catch (_) {
    return false;
  }
}

Future<void> _configureRobot() async {
  if (_configured) return;
  _configured = true;
  try {
    for (final lang in ['ceb-PH', 'fil-PH', 'en-US']) {
      final ok = await _tts.isLanguageAvailable(lang);
      if (ok == true || ok == 1) {
        await _tts.setLanguage(lang);
        break;
      }
    }
    await _tts.setSpeechRate(0.45);
  } catch (_) {
    // Speech is optional: the app keeps working without it.
  }
}

Future<void> speak(String text) async {
  final clean = text.toLowerCase().trim();
  try {
    await _player.stop();
    await _tts.stop();
  } catch (_) {}

  // 1) your recorded / ElevenLabs clips
  for (final name in ['word_$clean', 'syl_$clean']) {
    if (await _hasAsset('assets/audio/$name.mp3')) {
      try {
        await _player.play(AssetSource('audio/$name.mp3'));
        return;
      } catch (_) {
        break; // fall through to the robot voice
      }
    }
  }

  // 2) robot voice as a backup
  try {
    await _configureRobot();
    await _tts.speak(text);
  } catch (_) {
    // ignore
  }
}

import 'package:flutter_tts/flutter_tts.dart';

// ============================================================
// SPEECH  (the speak() function from words.ts)
// Uses the device's / browser's built-in voice. It tries Cebuano first,
// then Filipino, then English, depending on what the device has.
// ============================================================
final FlutterTts _tts = FlutterTts();
bool _configured = false;

Future<void> _configure() async {
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
  try {
    await _configure();
    await _tts.stop();
    await _tts.speak(text);
  } catch (_) {
    // ignore
  }
}

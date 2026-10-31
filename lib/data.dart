import 'dart:typed_data';

import 'package:flutter/foundation.dart';

// ============================================================
// WORDS  (from words.ts)
// ============================================================
class Word {
  const Word({
    required this.id,
    required this.text,
    required this.parts,
    required this.picture,
    this.audio,
    this.photo,
  });
  final String id;
  final String text;
  final List<String> parts; // the syllables, e.g. ['i', 'ro']
  final String picture; // 'dog', 'cat', 'horse', 'house' or 'word'
  final String? audio; // path/link of the family's recorded voice
  final Uint8List? photo; // the photo the family picked
}

const firstWord = Word(
  id: 'iro',
  text: 'iro',
  parts: ['i', 'ro'],
  picture: 'dog',
);

Word _fromSplit(String split) {
  final parts = split.split('-');
  final text = parts.join();
  return Word(id: text, text: text, parts: parts, picture: 'word');
}

final List<Word> kWords = [
  firstWord,
  const Word(id: 'iring', text: 'iring', parts: ['i', 'ring'], picture: 'cat'),
  const Word(
    id: 'kabayo',
    text: 'kabayo',
    parts: ['ka', 'ba', 'yo'],
    picture: 'horse',
  ),
  const Word(
    id: 'balay',
    text: 'balay',
    parts: ['ba', 'lay'],
    picture: 'house',
  ),
  for (final s in [
    'lo-la',
    'lo-lo',
    'ma-nok',
    'ba-ka',
    'i-sda',
    'sa-ging',
    'bu-lak',
    'tu-big',
    'ga-tas',
    'man-gga',
    'ad-law',
  ])
    _fromSplit(s),
];

/// How many words the family can add (not counting the starter words).
const int maxCustomWords = 5;

/// Splits a typed word into syllables (same rule as the React app).
List<String> splitWord(String text) {
  final cleaned = text.toLowerCase().trim();
  for (final w in kWords) {
    if (w.text == cleaned) return w.parts;
  }
  final re = RegExp(
    r'[^aeiou]*[aeiou](?:ng|[bcdfghjklmnpqrstvwxyz](?=[^aeiou]|$))?',
  );
  final found = re.allMatches(cleaned).map((m) => m.group(0)!).toList();
  return found.isEmpty ? [cleaned] : found;
}

// ============================================================
// APP DATA  (from store.tsx)  -- lives in memory for now.
// Saving to the device comes in a later step.
// ============================================================
class Session {
  Session({required this.at, required this.coop, required this.words});
  final DateTime at;
  final bool coop;
  final List<String> words;
}

class AppState extends ChangeNotifier {
  bool family = true; // true = "Uban sa Ginikanan"
  int stars = 12;
  int familyStars = 0;
  final List<String> built = [];
  final List<Word> custom = [];
  final List<Session> sessions = [];
  final Map<String, int> struggles = {};

  void setFamily(bool v) {
    family = v;
    notifyListeners();
  }

  void addWord(Word word) {
    custom.removeWhere((w) => w.id == word.id);
    custom.add(word);
    notifyListeners();
  }

  void removeWord(String id) {
    custom.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  void finish(List<String> words, bool coop) {
    stars += 3;
    if (coop) familyStars += 3;
    for (final w in words) {
      if (!built.contains(w)) built.add(w);
    }
    sessions.add(Session(at: DateTime.now(), coop: coop, words: words));
    notifyListeners();
  }

  void struggle(String part) {
    struggles[part] = (struggles[part] ?? 0) + 1;
    notifyListeners();
  }
}

/// The one shared copy of the app's data.
final app = AppState();

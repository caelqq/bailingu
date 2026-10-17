import 'dart:async';

import 'package:flutter/material.dart';

import 'audio.dart';
import 'data.dart';
import 'results_screen.dart';
import 'ui.dart';

// ============================================================
// GAME OPTIONS  (the 3 settings the games menu sends in)
// ============================================================
class GameOptions {
  const GameOptions({
    this.coop = false, // "Panag-unay nga Dula" (parent + child)
    this.listen = false, // "Pangitaa ang Tunog" (audio-only prompt)
    this.challenge = false, // "Hagit sa Ginikanan"
  });
  final bool coop;
  final bool listen;
  final bool challenge;
}

// ============================================================
// SYLLABLE TILES
// ============================================================
class Tile {
  const Tile({required this.id, required this.part, required this.color});
  final String id;
  final String part;
  final Color color;
}

/// The word's syllables plus a couple of wrong ones, in a fixed shuffled order.
List<Tile> tilesFor(Word word) {
  final distractors = [
    'ma',
    'su',
  ].where((p) => !word.parts.contains(p)).toList();
  final parts = [...word.parts, ...distractors];
  final order = parts.length == 4
      ? [2, 0, 3, 1]
      : parts.length == 5
      ? [3, 1, 4, 0, 2]
      : List.generate(parts.length, (i) => i);
  const colors = [C.yellow, C.teal, C.pink, C.primary, C.card];
  return [
    for (var i = 0; i < order.length; i++)
      Tile(
        id: '${word.id}-${order[i]}',
        part: parts[order[i]],
        color: colors[i % 5],
      ),
  ];
}

// ============================================================
// GAME SCREEN  ("Buhat og Pulong")
// ============================================================
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.options = const GameOptions()});
  final GameOptions options;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final List<Word> bank;
  int round = 0;
  final Map<int, String> filled = {}; // slot number -> syllable placed there
  final List<String> used = []; // tile ids already placed
  String? hint; // tile id that is glowing
  String? retry; // tile id that was wrong
  String feedback = 'idle'; // 'idle' | 'retry' | 'correct'
  late String prompt; // 'both' | 'audio' | 'picture'
  bool turns = false;
  late bool parentFirst;
  final List<Timer> timers = [];

  GameOptions get o => widget.options;
  Word get word => bank[round];
  bool get complete => filled.length == word.parts.length;

  int get nextIndex {
    for (var i = 0; i < word.parts.length; i++) {
      if (!filled.containsKey(i)) return i;
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();
    prompt = o.listen ? 'audio' : 'both';
    parentFirst = o.challenge;
    final recorded = app.custom.where((w) => w.audio != null).toList();
    bank = (o.challenge && recorded.isNotEmpty)
        ? [...recorded, ...kWords.take(4)].take(4).toList()
        : [...kWords.take(4), ...app.custom];
  }

  @override
  void dispose() {
    for (final t in timers) {
      t.cancel();
    }
    super.dispose();
  }

  // ---------- game logic ----------

  void attempt(Tile tile, int index) {
    final expected = word.parts[index];
    if (complete || filled.containsKey(index)) return;
    speak(tile.part);

    if (tile.part != expected) {
      setState(() {
        retry = tile.id;
        feedback = 'retry';
      });
      app.struggle(expected);
      timers.add(
        Timer(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => retry = null);
        }),
      );
      return;
    }

    setState(() {
      filled[index] = tile.part;
      used.add(tile.id);
      hint = null;
      feedback = filled.length == word.parts.length ? 'correct' : 'idle';
    });
    if (filled.length == word.parts.length) {
      final text = word.text;
      timers.add(Timer(const Duration(milliseconds: 600), () => speak(text)));
    }
  }

  void showHint() {
    final index = nextIndex;
    if (index < 0) return;
    final tiles = tilesFor(word);
    for (final t in tiles) {
      if (t.part == word.parts[index] && !used.contains(t.id)) {
        setState(() => hint = t.id);
        speak(t.part);
        return;
      }
    }
  }

  void next() {
    if (round == bank.length - 1) {
      app.finish(bank.map((w) => w.id).toList(), o.coop);
      goTo(
        context,
        '/results',
        arguments: ResultsArgs(coop: o.coop, word: word.text),
      );
      return;
    }
    setState(() {
      round++;
      filled.clear();
      used.clear();
      feedback = 'idle';
      hint = null;
      retry = null;
    });
  }

  // ---------- screen ----------

  @override
  Widget build(BuildContext context) {
    final w = word;
    final tiles = tilesFor(w);
    final parentTurn = parentFirst || (turns && round % 2 == 1);

    return ScreenScaffold(
      gap: o.coop ? 12 : 16,
      overlay: complete ? const Confetti() : null,
      children: [
        _header(),
        Text(
          o.listen ? 'Pangitaa ang Tunog' : 'Buhat og Pulong',
          textAlign: TextAlign.center,
          style: display(23, height: 1.2),
        ),
        if (o.coop) _familyStrip(parentTurn),
        _picturePanel(w),
        if (!o.coop) _promptModes(w),
        _slots(w),
        _answer(w),
        LayoutBuilder(
          builder: (context, box) {
            final tileWidth = (box.maxWidth - 3 * 11) / 4;
            return Wrap(
              spacing: 11,
              runSpacing: 16,
              children: [for (final t in tiles) _tile(t, tileWidth)],
            );
          },
        ),
        _feedbackRow(),
        if (complete)
          ToyButton(
            color: C.primary,
            onTap: next,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Padayon!', style: display(24, height: 1.15)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 26, color: C.foreground),
              ],
            ),
          ),
        if (o.coop) _helpPanel(w),
      ],
    );
  }

  Widget _header() {
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          ToyButton(
            circle: true,
            size: 56,
            onTap: () => goTo(context, '/games'),
            child: const Icon(Icons.close, size: 26, color: C.foreground),
          ),
          const Spacer(),
          for (var i = 0; i < bank.length; i++) ...[
            if (i > 0) const SizedBox(width: 9),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: C.foreground, width: 2),
                color: i < round
                    ? C.teal
                    : i == round
                    ? C.yellow
                    : C.card,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _familyStrip(bool parentTurn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: C.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.people_outline, size: 20, color: C.foreground),
          Text(
            parentTurn ? 'Turno sa Ginikanan' : 'Turno ni Ana',
            style: display(16),
          ),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: C.foreground),
              const SizedBox(width: 4),
              Text('${app.familyStars}', style: display(16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _speakerButton(Word w, double size) {
    return ToyButton(
      circle: true,
      size: size,
      color: C.teal,
      onTap: () => speak(w.text),
      child: Icon(
        Icons.volume_up_outlined,
        size: size > 60 ? 40 : 26,
        color: C.foreground,
      ),
    );
  }

  Widget _picturePanel(Word w) {
    final audioOnly = prompt == 'audio';
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: C.secondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!audioOnly)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: WordPicture(
                kind: w.picture,
                label: w.text,
                width: 175,
                height: o.coop ? 100 : 125,
              ),
            ),
          if (audioOnly)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: _speakerButton(w, 90),
            )
          else if (prompt != 'picture')
            Positioned(right: 12, bottom: 12, child: _speakerButton(w, 56)),
        ],
      ),
    );
  }

  Widget _promptModes(Word w) {
    Widget mode(String key, IconData icon, String label, {bool say = false}) {
      return Expanded(
        child: ToyButton(
          color: prompt == key ? C.yellow : C.card,
          radius: 18,
          minHeight: 56,
          borderWidth: 2,
          depth: 3,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          onTap: () {
            setState(() => prompt = key);
            if (say) speak(w.text);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: C.foreground),
              const SizedBox(width: 4),
              Text(label, style: body(12, weight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        mode('both', Icons.visibility_outlined, 'Duha'),
        const SizedBox(width: 8),
        mode('picture', Icons.image_outlined, 'Litrato'),
        const SizedBox(width: 8),
        mode('audio', Icons.hearing, 'Tingog', say: true),
      ],
    );
  }

  Widget _slots(Word w) {
    final three = w.parts.length == 3;
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < w.parts.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('+', style: display(three ? 21 : 26)),
                ),
              _slot(i, three),
            ],
          ],
        ),
      ),
    );
  }

  Widget _slot(int index, bool three) {
    final width = three ? 94.0 : 111.0;
    final height = three ? 88.0 : 95.0;
    return DragTarget<Tile>(
      onWillAcceptWithDetails: (_) => !complete && !filled.containsKey(index),
      onAcceptWithDetails: (details) => attempt(details.data, index),
      builder: (context, candidates, rejected) {
        final over = candidates.isNotEmpty;
        final part = filled[index];
        return GestureDetector(
          onTap: () {
            if (!complete) showHint();
          },
          child: CustomPaint(
            foregroundPainter: part == null ? DashedPainter(radius: 26) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: width,
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: part != null ? C.teal : (over ? C.accent : C.card),
                borderRadius: BorderRadius.circular(26),
                border: part != null
                    ? Border.all(color: C.foreground, width: 3)
                    : null,
                boxShadow: part != null
                    ? const [
                        BoxShadow(
                          color: C.foreground,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Text(part ?? '_', style: display(three ? 35 : 42)),
            ),
          ),
        );
      },
    );
  }

  Widget _answer(Word w) {
    return SizedBox(
      height: complete ? 52 : 32,
      child: Center(
        child: Text(
          complete
              ? w.text
              : [for (var i = 0; i < w.parts.length; i++) filled[i] ?? '___']
                    .join(' · '),
          style: complete
              ? display(44, height: 1)
              : display(22, color: C.muted),
        ),
      ),
    );
  }

  Widget _tileFace(Tile t, double width, {VoidCallback? onTap}) {
    return SizedBox(
      width: width,
      child: ToyButton(
        color: retry == t.id ? C.pink : t.color,
        radius: 23,
        minHeight: 74,
        padding: const EdgeInsets.all(6),
        onTap: onTap,
        child: Text(t.part, style: display(29)),
      ),
    );
  }

  Widget _tile(Tile t, double width) {
    final isUsed = used.contains(t.id);
    final hinted = hint == t.id;
    Widget face = _tileFace(
      t,
      width,
      onTap: () {
        final i = nextIndex;
        if (i >= 0) attempt(t, i);
      },
    );
    if (hinted) {
      // yellow ring around the tile that the hint is pointing at
      face = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(color: C.yellow, spreadRadius: 5, blurRadius: 0),
          ],
        ),
        child: face,
      );
    }
    return Visibility(
      visible: !isUsed,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Draggable<Tile>(
        data: t,
        onDragStarted: () => speak(t.part),
        feedback: Material(
          type: MaterialType.transparency,
          child: Transform.rotate(angle: -0.12, child: _tileFace(t, width)),
        ),
        childWhenDragging: SizedBox(width: width, height: 80),
        child: face,
      ),
    );
  }

  Widget _feedbackRow() {
    final message = feedback == 'correct'
        ? 'Maayo kaayo!'
        : feedback == 'retry'
        ? 'Sulayi pag-usab'
        : 'Ihiusa nato!';
    final bannerColor = feedback == 'correct'
        ? C.accent
        : feedback == 'retry'
        ? const Color(0xFFFFCAB8)
        : C.secondary;
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 74),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bannerColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: C.foreground, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: C.foreground,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                const Mascot(width: 55, height: 58),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(message, style: display(20, height: 1.15)),
                ),
                if (feedback == 'correct')
                  const Icon(Icons.check, size: 22, color: C.foreground),
                if (feedback == 'retry')
                  const Icon(Icons.repeat, size: 22, color: C.foreground),
              ],
            ),
          ),
        ),
        if (!complete) ...[
          const SizedBox(width: 9),
          ToyButton(
            circle: true,
            size: 56,
            color: C.yellow,
            onTap: showHint,
            child: const Icon(
              Icons.lightbulb_outline,
              size: 26,
              color: C.foreground,
            ),
          ),
        ],
      ],
    );
  }

  Widget _helpButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: ToyButton(
        color: color,
        radius: 19,
        minHeight: 58,
        padding: const EdgeInsets.all(8),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: C.foreground),
            const SizedBox(height: 3),
            Text(label, style: display(14, height: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _helpPanel(Word w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashedLine(),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.people_outline, size: 24, color: C.foreground),
            const SizedBox(width: 8),
            Text('Tabang sa Ginikanan', style: display(22, height: 1.2)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _helpButton(Icons.lightbulb_outline, 'Tabang', C.yellow, showHint),
            const SizedBox(width: 8),
            _helpButton(
              Icons.mic_none,
              'Imong tingog',
              C.card,
              () => comingSoon(context, 'Recording'),
            ),
            const SizedBox(width: 8),
            _helpButton(
              Icons.menu_book_outlined,
              'Basaha kini',
              C.teal,
              () => speak(w.text),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: turns,
                  activeColor: C.teal,
                  side: const BorderSide(color: C.foreground, width: 2),
                  onChanged: (v) => setState(() {
                    turns = v ?? false;
                    parentFirst = false;
                  }),
                ),
              ),
              const SizedBox(width: 9),
              Text('Magpulipuli ta og turno', style: body(13)),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CONFETTI  (shown when a word is finished)
// ============================================================
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final secs = _c.value * 2.8;
            return Stack(
              children: [
                for (var i = 0; i < 21; i++)
                  _piece(i, secs, box.maxWidth, box.maxHeight),
              ],
            );
          },
        );
      },
    );
  }

  Widget _piece(int i, double secs, double width, double height) {
    final t = ((secs - i * 0.035) / 2.0).clamp(0.0, 1.0).toDouble();
    final color = i % 3 == 0 ? C.teal : (i % 3 == 1 ? C.yellow : C.primary);
    return Positioned(
      left: width * (i * 4.7 / 100),
      top: 120 + t * (height - 260).clamp(100.0, 2000.0),
      child: Opacity(
        opacity: (1 - t * t).clamp(0.0, 1.0).toDouble(),
        child: Transform.rotate(
          angle: 0.44 + t * 5.5,
          child: Container(width: 9, height: 15, color: color),
        ),
      ),
    );
  }
}

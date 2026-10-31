import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'ui.dart';

// ============================================================
// ADD WORD SCREEN  ("Bag-ong Pulong")
// ============================================================
class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _text = TextEditingController();
  final _split = TextEditingController();
  String message = '';

  bool get full => app.custom.length >= maxCustomWords;

  @override
  void dispose() {
    _text.dispose();
    _split.dispose();
    super.dispose();
  }

  /// Every time the word changes, guess the syllables.
  void _onWordChanged(String value) {
    final t = value.trim().toLowerCase();
    setState(() {
      _split.text = t.isEmpty ? '' : splitWord(t).join(' · ');
      message = '';
    });
  }

  /// Returns a message if something is wrong, or null if the word is fine.
  String? _check(String word, List<String> parts) {
    if (full) {
      return 'Puno na ang $maxCustomWords ka bag-ong pulong. Papasa una ang usa.';
    }
    if (word.isEmpty || parts.isEmpty) {
      return 'Isulat una ang pulong ug ang mga silaba.';
    }
    if (parts.join() != word) {
      return 'Ihiusa ang mga silaba aron mahimong imong pulong.';
    }
    if (parts.length < 2 || parts.length > 4) {
      return 'Kinahanglan 2 hangtod 4 ka silaba.';
    }
    if (kWords.any((w) => w.text == word) ||
        app.custom.any((w) => w.text == word)) {
      return 'Naa na ni nga pulong.';
    }
    return null;
  }

  void _save() {
    final word = _text.text.trim().toLowerCase();
    final parts = _split.text
        .split(RegExp(r'[·.\-\s]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p.toLowerCase())
        .toList();

    final error = _check(word, parts);
    if (error != null) {
      setState(() => message = error);
      return;
    }
    app.addWord(
      Word(id: 'custom-$word', text: word, parts: parts, picture: 'word'),
    );
    goTo(context, '/words');
  }

  @override
  Widget build(BuildContext context) {
    final left = maxCustomWords - app.custom.length;
    return ScreenScaffold(
      gap: 16,
      children: [
        const ScreenHeader(title: 'Bag-ong Pulong', backRoute: '/words'),
        Text(
          full
              ? 'Puno na: $maxCustomWords sa $maxCustomWords'
              : 'Nahabilin: $left sa $maxCustomWords',
          style: body(14, color: C.muted),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atong pulong', style: display(18)),
            const SizedBox(height: 8),
            _ToyInput(
              controller: _text,
              hint: 'Pananglitan: iring',
              onChanged: _onWordChanged,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑ]')),
                LengthLimitingTextInputFormatter(20),
              ],
            ),
          ],
        ),
        Text(
          _text.text.trim().isEmpty
              ? 'Mga silaba'
              : '${_text.text.trim().toLowerCase()} → ${_split.text}',
          style: display(19),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usba ang mga silaba', style: display(18)),
            const SizedBox(height: 8),
            _ToyInput(
              controller: _split,
              hint: 'i · ring',
              fontSize: 24,
              onChanged: (_) => setState(() => message = ''),
            ),
            const SizedBox(height: 6),
            Text(
              'Gamita ang space o dash (-) sa taliwala sa silaba. 2 hangtod 4 ra.',
              style: body(12, color: C.muted, weight: FontWeight.w600),
            ),
          ],
        ),
        if (message.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCAB8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.foreground, width: 2),
            ),
            child: Text(message, style: body(14)),
          ),
        Opacity(
          opacity: full ? 0.45 : 1,
          child: ToyButton(
            color: C.teal,
            onTap: _save,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 26, color: C.foreground),
                const SizedBox(width: 8),
                Text('I-save', style: display(26, height: 1.15)),
              ],
            ),
          ),
        ),
        const DeviceNote(),
      ],
    );
  }
}

/// The big rounded text box used on this screen.
class _ToyInput extends StatelessWidget {
  const _ToyInput({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.formatters,
    this.fontSize = 28,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? formatters;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.foreground, width: 3),
        boxShadow: const [
          BoxShadow(color: C.foreground, offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: formatters,
        cursorColor: C.foreground,
        style: display(fontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: display(fontSize, color: const Color(0x80454D68)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

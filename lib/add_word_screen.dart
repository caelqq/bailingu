import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'audio.dart';
import 'data.dart';
import 'ui.dart';

// ============================================================
// ADD WORD SCREEN  ("Bag-ong Pulong")
// Word + syllables, plus an optional recorded voice and photo.
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

  bool _recording = false;
  String? _audioPath; // where the recorded voice is
  String recordMessage = '';
  Uint8List? _photo; // the photo the family picked

  bool get full => app.custom.length >= maxCustomWords;

  @override
  void dispose() {
    if (_recording) cancelRecording();
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

  // ---------- voice ----------

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await stopRecording();
      if (!mounted) return;
      setState(() {
        _recording = false;
        if (path != null) _audioPath = path;
        recordMessage = path == null ? 'Wala ma-save ang recording.' : '';
      });
      return;
    }
    final ok = await startRecording();
    if (!mounted) return;
    setState(() {
      _recording = ok;
      recordMessage = ok
          ? ''
          : 'Dili ma-access ang mikropono. I-allow ang mic sa browser.';
    });
  }

  // ---------- photo ----------

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 3000000) {
        setState(() => message = 'Pilia ang litrato nga ubos sa 3 MB.');
        return;
      }
      setState(() {
        _photo = bytes;
        message = '';
      });
    } catch (_) {
      if (mounted) setState(() => message = 'Dili ma-abli ang litrato.');
    }
  }

  // ---------- saving ----------

  /// Returns a message if something is wrong, or null if the word is fine.
  String? _check(String word, List<String> parts) {
    if (full) {
      return 'Puno na ang $maxCustomWords ka bag-ong pulong. Papasa una ang usa.';
    }
    if (_recording) {
      return 'Hunonga una ang recording.';
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
      Word(
        id: 'custom-$word',
        text: word,
        parts: parts,
        picture: 'word',
        audio: _audioPath,
        photo: _photo,
      ),
    );
    goTo(context, '/words');
  }

  // ---------- screen ----------

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
        _recordArea(),
        _photoArea(),
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

  /// The big pink microphone button, the little sound bars, and "Paminawa".
  Widget _recordArea() {
    const bars = [15.0, 28.0, 20.0, 34.0, 24.0, 31.0, 18.0, 27.0, 16.0, 25.0];
    final active = _recording || _audioPath != null;
    final status = _recording
        ? 'Nag-record... i-tap pag-usab aron mohunong'
        : _audioPath != null
        ? 'Na-record na! I-tap ang mic aron usbon.'
        : 'I-tap ang mic aron i-record ang imong tingog (optional)';

    return Column(
      children: [
        ToyButton(
          circle: true,
          size: 90,
          color: _recording ? C.primary : C.pink,
          onTap: _toggleRecord,
          child: Icon(
            _recording ? Icons.stop_rounded : Icons.mic_none,
            size: 40,
            color: C.foreground,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < bars.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: bars[i],
                  decoration: BoxDecoration(
                    color: active ? C.teal : C.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          textAlign: TextAlign.center,
          style: body(13, color: C.muted, weight: FontWeight.w700),
        ),
        if (recordMessage.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(recordMessage, textAlign: TextAlign.center, style: body(13)),
        ],
        if (_audioPath != null && !_recording) ...[
          const SizedBox(height: 12),
          ToyButton(
            color: C.teal,
            onTap: () => playRecording(_audioPath!),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.volume_up_outlined,
                  size: 24,
                  color: C.foreground,
                ),
                const SizedBox(width: 8),
                Text('Paminawa', style: display(20, height: 1.15)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// The photo preview (with an X to remove it) and the dashed "Litrato" button.
  Widget _photoArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_photo != null) ...[
          SizedBox(
            height: 110,
            child: Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      _photo!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _photo = null),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: C.pink,
                            shape: BoxShape.circle,
                            border: Border.all(color: C.foreground, width: 3),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: C.foreground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        CustomPaint(
          foregroundPainter: DashedPainter(radius: 28),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickPhoto,
            child: Container(
              constraints: const BoxConstraints(minHeight: 73),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 26,
                    color: C.foreground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _photo == null ? 'Litrato (optional)' : 'Usba ang litrato',
                    style: display(20, height: 1.15),
                  ),
                ],
              ),
            ),
          ),
        ),
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

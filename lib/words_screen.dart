import 'package:flutter/material.dart';

import 'audio.dart';
import 'data.dart';
import 'ui.dart';

// ============================================================
// WORD LIST SCREEN  ("Among Pulong")
// ============================================================
class WordsScreen extends StatelessWidget {
  const WordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        // starter words + any word the child has built
        final starter = kWords
            .where(
              (w) =>
                  const ['lola', 'iro', 'balay'].contains(w.id) ||
                  app.built.contains(w.id),
            )
            .toList();
        final custom = app.custom;
        final full = custom.length >= maxCustomWords;

        return ScreenScaffold(
          bottomNav: true,
          gap: 22,
          children: [
            ScreenHeader(
              title: 'Among Pulong',
              end: ToyButton(
                circle: true,
                size: 56,
                onTap: () => goTo(context, '/'),
                child: const Icon(
                  Icons.home_outlined,
                  size: 26,
                  color: C.foreground,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 17) / 2;
                return Wrap(
                  spacing: 17,
                  runSpacing: 22,
                  children: [
                    for (final word in starter)
                      SizedBox(
                        width: cardWidth,
                        child: WordCard(word: word),
                      ),
                    for (final word in custom)
                      SizedBox(
                        width: cardWidth,
                        child: WordCard(
                          word: word,
                          onRemove: () => _remove(context, word),
                        ),
                      ),
                    SizedBox(
                      width: cardWidth,
                      height: 173,
                      child: Opacity(
                        opacity: full ? 0.4 : 1,
                        child: ToyButton(
                          color: C.primary,
                          radius: 30,
                          onTap: () {
                            if (full) {
                              _say(
                                context,
                                'Hangtod $maxCustomWords ra ka bag-ong pulong. Papasa una ang usa.',
                              );
                            } else {
                              goTo(context, '/add-word');
                            }
                          },
                          child: const Icon(
                            Icons.add,
                            size: 52,
                            color: C.foreground,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Center(
              child: Text(
                'Bag-ong pulong: ${custom.length}/$maxCustomWords',
                style: body(13, color: C.muted),
              ),
            ),
          ],
        );
      },
    );
  }

  void _say(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
      );
  }

  void _remove(BuildContext context, Word word) {
    app.removeWord(word.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Natangtang ang "${word.text}"'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'I-undo',
            onPressed: () => app.addWord(word),
          ),
        ),
      );
  }
}

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word, this.onRemove});
  final Word word;

  /// If this is set, the card is a word the family added: it gets an X button.
  final VoidCallback? onRemove;

  bool get isCustom => onRemove != null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ToyCard(
          radius: 30,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 88,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: C.secondary,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Center(
                  child: WordPicture(
                    kind: word.picture,
                    label: word.text,
                    width: 120,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      word.text,
                      style: display(23),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Opacity(
                    opacity: isCustom ? 0.4 : 1,
                    child: ToyButton(
                      circle: true,
                      size: 56,
                      color: C.teal,
                      onTap: () {
                        if (isCustom) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Wala pa\'y tingog kini nga pulong',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                        } else {
                          speak(word.text);
                        }
                      },
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 32,
                        color: C.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isCustom)
          Positioned(
            top: 2,
            left: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
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
    );
  }
}

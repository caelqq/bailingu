import 'package:flutter/material.dart';

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
        // starter words + any word the child has built + words the family added
        final seed = kWords
            .where(
              (w) =>
                  const ['lola', 'iro', 'balay'].contains(w.id) ||
                  app.built.contains(w.id),
            )
            .toList();
        final words = [...seed, ...app.custom];

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
                    for (final word in words)
                      SizedBox(
                        width: cardWidth,
                        child: WordCard(word: word),
                      ),
                    SizedBox(
                      width: cardWidth,
                      height: 173,
                      child: ToyButton(
                        color: C.primary,
                        radius: 30,
                        onTap: () => comingSoon(context, 'Bag-ong Pulong'),
                        child: const Icon(
                          Icons.add,
                          size: 52,
                          color: C.foreground,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
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
              ToyButton(
                circle: true,
                size: 56,
                color: C.teal,
                onTap: () => comingSoon(context, 'Sound'),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 32,
                  color: C.foreground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

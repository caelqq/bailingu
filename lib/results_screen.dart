import 'package:flutter/material.dart';

import 'data.dart';
import 'ui.dart';

class ResultsArgs {
  const ResultsArgs({this.coop = false, this.word = 'iro'});
  final bool coop;
  final String word;
}

// ============================================================
// RESULTS SCREEN  ("Maayo kaayo!")
// ============================================================
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, this.args = const ResultsArgs()});
  final ResultsArgs args;

  @override
  Widget build(BuildContext context) {
    final word = args.word;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return ScreenScaffold(
          gap: 24,
          children: [
            const SizedBox(height: 10),
            // three stars, the middle one bigger and raised
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const OutlinedStar(size: 58),
                const SizedBox(width: 10),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: const OutlinedStar(size: 78),
                ),
                const SizedBox(width: 10),
                const OutlinedStar(size: 58),
              ],
            ),
            const Center(child: Mascot(width: 185, height: 195)),
            Text(
              'Maayo kaayo!',
              textAlign: TextAlign.center,
              style: display(43, height: 1.1),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: C.accent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_open_outlined,
                    size: 22,
                    color: C.foreground,
                  ),
                  const SizedBox(width: 8),
                  Text('Bag-ong pulong na-abli!', style: display(19)),
                ],
              ),
            ),
            if (args.coop) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 22,
                    color: C.foreground,
                  ),
                  const SizedBox(width: 9),
                  Text('Pamilya Stars: ${app.familyStars}', style: display(20)),
                  const SizedBox(width: 9),
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 22,
                    color: C.foreground,
                  ),
                ],
              ),
              _storytime(word),
            ],
            ToyButton(
              color: C.primary,
              onTap: () => goTo(context, '/words'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Padayon!', style: display(29, height: 1.15)),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 26,
                    color: C.foreground,
                  ),
                ],
              ),
            ),
            ToyButton(
              color: C.card,
              onTap: () => goTo(context, '/games'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Dula pag-usab', style: display(24, height: 1.15)),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 26,
                    color: C.foreground,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _storytime(String word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashedLine(),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.people_outline, size: 22, color: C.foreground),
            const SizedBox(width: 6),
            Text('Atong estoryahan', style: display(21, height: 1.2)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Asa nimo nakita ang $word?',
          style: body(15, weight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          word == 'iro'
              ? 'Unsa ang tunog sa iro?'
              : 'Unsa imong nahibaloan bahin sa $word?',
          style: body(15, weight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 22, color: C.foreground),
            const SizedBox(width: 9),
            Text('Bag-ong pamilya badge!', style: display(20)),
          ],
        ),
      ],
    );
  }
}

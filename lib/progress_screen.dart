import 'package:flutter/material.dart';

import 'data.dart';
import 'ui.dart';

// ============================================================
// PROGRESS SCREEN  ("Progreso ni Ana")
// ============================================================
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final now = DateTime.now();
        final week = app.sessions
            .where((s) => now.difference(s.at).inDays < 7)
            .toList();
        final together = week.where((s) => s.coop).length;
        final weekWords = week.expand((s) => s.words).toSet().length;
        final struggles = app.struggles.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topStruggles = struggles.take(4).toList();

        return ScreenScaffold(
          gap: 20,
          children: [
            const ScreenHeader(title: 'Progreso ni Ana', backRoute: '/'),
            const ModeChip(text: 'Family Bonding Mode'),

            // current stage
            ToyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KARON NGA STAGE',
                    style: body(14, color: C.muted, weight: FontWeight.w600),
                  ),
                  Text('2 · Silaba', style: display(21, height: 1.2)),
                  const SizedBox(height: 14),
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: C.secondary,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: C.foreground, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.55,
                          child: Container(color: C.teal),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4 stat cards
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatCard(
                        color: C.yellow,
                        title: 'Mga Bitoon',
                        value: '${app.stars}',
                        withStar: true,
                      ),
                    ),
                    const SizedBox(width: 17),
                    Expanded(
                      child: StatCard(
                        color: C.green,
                        title: 'Pulong karong semana',
                        value: '$weekWords',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatCard(
                        color: C.accent,
                        title: 'Mga Pulong nga Nabuhat',
                        value: '${app.built.length}',
                      ),
                    ),
                    const SizedBox(width: 17),
                    Expanded(
                      child: StatCard(
                        color: const Color(0xFFFFC5B3),
                        title: 'Dula karong semana',
                        value: '${week.length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // hard syllables
            ToyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lisod nga Silaba', style: display(21, height: 1.2)),
                  const SizedBox(height: 12),
                  if (topStruggles.isEmpty)
                    Text(
                      'Wala pay lisod nga silaba.',
                      style: body(14, color: C.muted, weight: FontWeight.w600),
                    )
                  else
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        for (final s in topStruggles)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: C.pink,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: C.foreground, width: 2),
                            ),
                            child: Text(s.key, style: display(22)),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // together card
            ToyCard(
              color: C.green,
              radius: 28,
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 37,
                    color: C.foreground,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dula Together', style: display(21, height: 1.2)),
                        Text(
                          'Panag-unay karong semana',
                          style: body(13, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Text('$together', style: display(34)),
                ],
              ),
            ),

            // family stars + stickers
            ToyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pamilya Stars · ${app.familyStars}',
                    style: display(21, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 9),
                        _Sticker(
                          unlocked: app.familyStars >= (i + 1) * 3,
                          icon: const [
                            Icons.star_rounded,
                            Icons.extension,
                            Icons.emoji_events_outlined,
                          ][i],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const DeviceNote(),
          ],
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.color,
    required this.title,
    required this.value,
    this.withStar = false,
  });
  final Color color;
  final String title;
  final String value;
  final bool withStar;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
      color: color,
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: 98,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: body(16, weight: FontWeight.w700).copyWith(height: 1.25),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                if (withStar) ...[
                  const Icon(Icons.star_rounded, size: 30, color: C.foreground),
                  const SizedBox(width: 6),
                ],
                Text(value, style: display(40, height: 1.1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  const _Sticker({required this.unlocked, required this.icon});
  final bool unlocked;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? C.yellow : C.secondary,
        border: Border.all(color: C.foreground, width: 2),
      ),
      child: Icon(
        unlocked ? icon : Icons.lock_outline,
        size: unlocked ? 28 : 20,
        color: unlocked ? C.foreground : C.muted,
      ),
    );
  }
}

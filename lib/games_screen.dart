import 'package:flutter/material.dart';

import 'data.dart';
import 'game_screen.dart';
import 'ui.dart';

// ============================================================
// GAMES SCREEN  ("Pili og dula")
// ============================================================
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return ScreenScaffold(
          gap: 20,
          children: [
            const ScreenHeader(title: 'Pili og dula', backRoute: '/'),
            Row(
              children: [
                const Mascot(),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: C.foreground, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: C.foreground,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Unsa atong dulaon?',
                      style: display(20, height: 1.2),
                    ),
                  ),
                ),
              ],
            ),
            ModeChip(
              text: app.family ? 'Uban sa Ginikanan' : 'Bata mag-inusara',
            ),
            SelectionCard(
              color: C.primary,
              icon: Icons.extension_outlined,
              title: 'Buhat og Pulong',
              subtitle: 'Ihiusa ang mga silaba',
              onTap: () =>
                  goTo(context, '/game', arguments: const GameOptions()),
            ),
            SelectionCard(
              color: C.teal,
              icon: Icons.volume_up_outlined,
              title: 'Pangitaa ang Tunog',
              subtitle: 'Paminaw ug pilia',
              onTap: () => goTo(
                context,
                '/game',
                arguments: const GameOptions(listen: true),
              ),
            ),
            if (app.family) ...[
              SelectionCard(
                color: C.yellow,
                icon: Icons.people_outline,
                title: 'Panag-unay nga Dula',
                subtitle: 'Ikaw ug ako, mag-uban ta!',
                onTap: () => goTo(
                  context,
                  '/game',
                  arguments: const GameOptions(coop: true),
                ),
              ),
              ToyButton(
                color: C.card,
                onTap: () => goTo(
                  context,
                  '/game',
                  arguments: const GameOptions(coop: true, challenge: true),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_none, size: 26, color: C.foreground),
                    const SizedBox(width: 8),
                    Text(
                      'Hagit sa Ginikanan',
                      style: display(24, height: 1.15),
                    ),
                  ],
                ),
              ),
            ],
            const DeviceNote(),
          ],
        );
      },
    );
  }
}

/// The big colored game button with an icon, a title, a subtitle and an arrow.
class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ToyButton(
      color: color,
      radius: 32,
      minHeight: 128,
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 52, color: C.foreground),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: display(24, height: 1.15)),
                const SizedBox(height: 5),
                Text(subtitle, style: body(14, weight: FontWeight.w700)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 25, color: C.foreground),
        ],
      ),
    );
  }
}

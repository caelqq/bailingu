import 'package:flutter/material.dart';

import 'data.dart';
import 'ui.dart';

// ============================================================
// HOME SCREEN  ("Atong panaw")
// ============================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final modeLabel = app.family ? 'Uban sa Ginikanan' : 'Bata mag-inusara';
        return ScreenScaffold(
          bottomNav: true,
          gap: 18,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StarPill(count: app.stars),
                const Mascot(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atong panaw', style: display(31, height: 1.12)),
                const SizedBox(height: 6),
                ModeChip(text: modeLabel),
              ],
            ),
            _buildMap(context),
            const SizedBox(height: 4),
            ToyButton(
              color: app.family ? C.primary : C.card,
              onTap: () => app.setFamily(!app.family),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 26,
                    color: C.foreground,
                  ),
                  const SizedBox(width: 8),
                  Text(modeLabel, style: display(24, height: 1.15)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// The green learning map with the yellow road and 5 stops.
  Widget _buildMap(BuildContext context) {
    return Container(
      height: 460,
      decoration: BoxDecoration(
        color: C.green,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: C.foreground, width: 3),
        boxShadow: const [
          BoxShadow(color: C.foreground, offset: Offset(0, 6), blurRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(39),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: RoadPainter())),
            const Positioned(
              top: 170,
              left: 22,
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 20,
                color: Color(0xFF8DA68C),
              ),
            ),
            const Positioned(
              bottom: 75,
              right: 26,
              child: Icon(
                Icons.star_border_rounded,
                size: 24,
                color: Color(0xFF8DA68C),
              ),
            ),

            // Sentence (locked)
            Positioned(
              top: 9,
              left: 40,
              child: MapNode(
                label: 'Sentence',
                labelSize: 15,
                color: C.card,
                diameter: 68,
                enabled: false,
                badgeTop: 39,
                badge: const NodeBadge(
                  child: Icon(
                    Icons.lock_outline,
                    size: 13,
                    color: C.foreground,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  size: 34,
                  color: C.foreground,
                ),
              ),
            ),

            // Pulong -> word list
            Positioned(
              top: 75,
              right: 28,
              child: MapNode(
                label: 'Pulong',
                color: C.card,
                onTap: () => goTo(context, '/words'),
                child: const Icon(
                  Icons.home_outlined,
                  size: 38,
                  color: C.foreground,
                ),
              ),
            ),

            // Dula -> games
            Positioned(
              bottom: 200,
              left: 30,
              child: MapNode(
                label: 'Dula',
                color: C.teal,
                onTap: () => goTo(context, '/games'),
                badge: NodeBadge(child: _starCount(app.stars)),
                child: const Icon(
                  Icons.extension_outlined,
                  size: 38,
                  color: C.foreground,
                ),
              ),
            ),

            // Silaba
            Positioned(
              bottom: 128,
              right: 27,
              child: MapNode(
                label: 'Silaba',
                color: C.yellow,
                onTap: () => comingSoon(context, 'Sound'),
                badge: NodeBadge(child: _starCount(12)),
                child: Text('BA', style: display(30)),
              ),
            ),

            // Letra
            Positioned(
              bottom: 24,
              left: 25,
              child: MapNode(
                label: 'Letra',
                color: C.primary,
                onTap: () => comingSoon(context, 'Sound'),
                child: Text('Aa', style: display(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _starCount(int n) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star_border_rounded, size: 12, color: C.foreground),
      const SizedBox(width: 2),
      Text('$n', style: display(13)),
    ],
  );
}

/// One stop on the map: a round toy button, a label under it, and an optional badge.
class MapNode extends StatelessWidget {
  const MapNode({
    super.key,
    required this.label,
    required this.color,
    required this.child,
    this.diameter = 87,
    this.labelSize = 18,
    this.badge,
    this.badgeTop = 53,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final Widget child;
  final double diameter;
  final double labelSize;
  final Widget? badge;
  final double badgeTop;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: enabled ? 1 : 0.5,
              child: ToyButton(
                circle: true,
                size: diameter,
                color: color,
                onTap: enabled ? onTap : null,
                child: child,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.foreground, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: C.foreground,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(label, style: display(labelSize)),
            ),
          ],
        ),
        if (badge != null) Positioned(right: -8, top: badgeTop, child: badge!),
      ],
    );
  }
}

/// The small yellow circle with a star count or a lock.
class NodeBadge extends StatelessWidget {
  const NodeBadge({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 29, minHeight: 29),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: C.yellow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: C.foreground, width: 2),
      ),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}

/// Draws the yellow road with the dashed cream line down the middle.
/// The curve numbers come straight from the SVG path in the React app.
class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height * 0.95;
    Offset p(double x, double y) => Offset(x / 350 * w, 15 + y / 500 * h);

    void curve(
      Path path,
      double x1,
      double y1,
      double x2,
      double y2,
      double x,
      double y,
    ) {
      final a = p(x1, y1), b = p(x2, y2), c = p(x, y);
      path.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);
    }

    final start = p(95, 439);
    final path = Path()..moveTo(start.dx, start.dy);
    curve(path, 280, 444, 332, 359, 242, 335);
    curve(path, 152, 311, 31, 292, 85, 251);
    curve(path, 139, 210, 313, 212, 264, 150);
    curve(path, 215, 88, 50, 146, 89, 65);

    canvas.drawPath(
      path,
      Paint()
        ..color = C.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..strokeJoin = StrokeJoin.round,
    );

    final dashPaint = Paint()
      ..color = C.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 8), dashPaint);
        d += 18;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

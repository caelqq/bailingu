import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// THEME  (colors and fonts copied from src/styles.css of the React app)
// ============================================================
class C {
  static const background = Color(0xFFFFFAE6);
  static const foreground = Color(
    0xFF1C274D,
  ); // dark navy used for borders + text
  static const primary = Color(0xFFFF873A); // orange
  static const secondary = Color(0xFFF2EADA);
  static const muted = Color(0xFF454D68);
  static const card = Color(0xFFFFFFFF);
  static const accent = Color(0xFF97E3CD);
  static const teal = Color(0xFF07AB98);
  static const yellow = Color(0xFFFFD436);
  static const pink = Color(0xFFFF998A);
  static const green = Color(0xFFBDDDA7);
  static const page = Color(0xFFF5F0E3);
}

/// Headline font (Baloo 2)
TextStyle display(double size, {Color color = C.foreground, double? height}) =>
    GoogleFonts.baloo2(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      height: height,
    );

/// Body font (Nunito)
TextStyle body(
  double size, {
  Color color = C.foreground,
  FontWeight weight = FontWeight.w800,
}) => GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color);

// ============================================================
// NAVIGATION HELPERS
// ============================================================

/// Go to another screen (used by the bottom menu, back buttons and games).
void goTo(BuildContext context, String route, {Object? arguments}) {
  if (arguments == null && ModalRoute.of(context)?.settings.name == route) {
    return;
  }
  Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
}

/// Temporary message for buttons whose screen we haven't built yet.
void comingSoon(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$what: coming in a later step'),
      duration: const Duration(seconds: 1),
    ),
  );
}

// ============================================================
// SCREEN LAYOUT
// ============================================================

/// Keeps the app phone-sized and centered when opened in a wide browser.
class PhoneShell extends StatelessWidget {
  const PhoneShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: C.page,
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width > 430 ? 430 : width,
          height: double.infinity,
          child: ColoredBox(
            color: C.background,
            child: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}

/// Standard screen: scrollable column with even spacing and an optional bottom menu.
/// `overlay` is drawn on top of everything (used for the confetti).
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.children,
    this.gap = 22,
    this.bottomNav = false,
    this.overlay,
  });
  final List<Widget> children;
  final double gap;
  final bool bottomNav;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return PhoneShell(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        if (i > 0) SizedBox(height: gap),
                        children[i],
                      ],
                    ],
                  ),
                ),
              ),
              if (bottomNav) const BottomNav(),
            ],
          ),
          if (overlay != null)
            Positioned.fill(child: IgnorePointer(child: overlay!)),
        ],
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.backRoute,
    this.end,
  });
  final String title;
  final String? backRoute;
  final Widget? end;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Row(
        children: [
          if (backRoute != null) ...[
            ToyButton(
              circle: true,
              size: 56,
              onTap: () => goTo(context, backRoute!),
              child: const Icon(
                Icons.arrow_back,
                size: 26,
                color: C.foreground,
              ),
            ),
            const SizedBox(width: 15),
          ],
          Expanded(child: Text(title, style: display(29, height: 1.1))),
          if (end != null) end!,
        ],
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Panaw', '/'),
      (Icons.sports_esports_outlined, 'Dula', '/games'),
      (Icons.menu_book_outlined, 'Pulong', '/words'),
      (Icons.bar_chart_rounded, 'Progreso', '/progress'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => goTo(context, item.$3),
                child: SizedBox(
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$1, size: 24, color: C.foreground),
                      const SizedBox(height: 4),
                      Text(item.$2, style: body(12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DeviceNote extends StatelessWidget {
  const DeviceNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 14, color: C.muted),
          const SizedBox(width: 6),
          Text(
            'Tanan datos naa ra sa device.',
            style: body(12, color: C.muted, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BUTTONS AND SMALL PIECES
// ============================================================

/// The chunky "toy button": thick border, hard shadow, presses down when tapped.
class ToyButton extends StatefulWidget {
  const ToyButton({
    super.key,
    required this.child,
    this.onTap,
    this.color = C.card,
    this.circle = false,
    this.size,
    this.radius = 28,
    this.minHeight,
    this.borderWidth = 3,
    this.depth = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final bool circle;
  final double? size;
  final double radius;
  final double? minHeight;
  final double borderWidth; // thickness of the navy border
  final double depth; // how tall the hard shadow is
  final EdgeInsets padding;

  @override
  State<ToyButton> createState() => _ToyButtonState();
}

class _ToyButtonState extends State<ToyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressedShadow = widget.depth / 3;
    final shadow = _down ? pressedShadow : widget.depth;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(
          0,
          _down ? widget.depth - pressedShadow : 0,
          0,
        ),
        width: widget.size,
        height: widget.size,
        constraints: widget.minHeight == null
            ? null
            : BoxConstraints(minHeight: widget.minHeight!),
        padding: widget.circle ? EdgeInsets.zero : widget.padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.circle
              ? null
              : BorderRadius.circular(widget.radius),
          border: Border.all(color: C.foreground, width: widget.borderWidth),
          boxShadow: [
            BoxShadow(
              color: C.foreground,
              offset: Offset(0, shadow),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// A white card with a thick border and a hard shadow (used on several screens).
class ToyCard extends StatelessWidget {
  const ToyCard({
    super.key,
    required this.child,
    this.color = C.card,
    this.radius = 29,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: C.foreground, width: 3),
        boxShadow: const [
          BoxShadow(color: C.foreground, offset: Offset(0, 6), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }
}

/// A star with a navy outline.
class OutlinedStar extends StatelessWidget {
  const OutlinedStar({super.key, this.size = 23});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.star_rounded, size: size + 4, color: C.foreground),
        Icon(Icons.star_rounded, size: size, color: C.yellow),
      ],
    );
  }
}

class StarPill extends StatelessWidget {
  const StarPill({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.foreground, width: 3),
        boxShadow: const [
          BoxShadow(color: C.foreground, offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OutlinedStar(size: 22),
          const SizedBox(width: 7),
          Text('$count', style: display(24)),
        ],
      ),
    );
  }
}

/// "Uban sa Ginikanan" / "Bata mag-inusara" line with a heart.
class ModeChip extends StatelessWidget {
  const ModeChip({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.favorite_border, size: 15, color: C.muted),
        const SizedBox(width: 7),
        Text(text, style: body(13, color: C.muted)),
      ],
    );
  }
}

/// The tarsier. The PNG is not in the GitHub repo, so until we add
/// assets/mascot.png this shows a simple placeholder.
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.width = 90, this.height = 92});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/mascot.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.pets, size: 48, color: C.muted),
      ),
    );
  }
}

// ============================================================
// WORD PICTURES  (the dog / cat / horse / house drawings from art.tsx)
// ============================================================
class WordPicture extends StatelessWidget {
  const WordPicture({
    super.key,
    required this.kind,
    required this.label,
    this.width = 175,
    this.height = 148,
    this.photo,
  });
  final String kind;
  final String label;
  final double width;
  final double height;
  final Uint8List? photo; // if set, show this photo instead of the drawing

  static const _f = '#1C274D';
  static const _p = '#FF873A';
  static const _w = '#FFFFFF';
  static const _t = '#07AB98';
  static const _y = '#FFD436';
  static const _s = '#F2EADA';
  static const _k = '#FF998A';

  static String _wrap(String inner) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 180 150">$inner</svg>';

  static const _star =
      '<path fill="$_y" d="m90 12 5 11 12 2-9 8 2 12-10-6-10 6 2-12-9-8 12-2Z"/>';

  static String _house() => _wrap(
    '<g stroke="$_f" stroke-width="5" stroke-linejoin="round">'
    '<path fill="$_p" d="M25 62 90 13 155 62Z"/>'
    '<path fill="$_w" d="M34 62h112v74H34Z"/>'
    '<path fill="$_t" d="M74 92h31v44H74Z"/>'
    '<path fill="$_y" d="M46 79h18v21H46Zm70 0h18v21h-18Z"/>'
    '</g>',
  );

  static String _horse() => _wrap(
    '<g stroke="$_f" stroke-width="4" stroke-linejoin="round">'
    '<path fill="$_p" d="M39 73c-12-31-21-15-26-30 0 27 6 43 24 47"/>'
    '<path fill="$_y" d="M37 71q35-10 71 0l14-32 23 4 15 24q1 19-21 18l-13-9-13 28-8 32H93l-1-32H61l-5 32H43l2-39q-16-4-8-26Z"/>'
    '<path fill="$_f" d="m119 42 3-22 12 19 14-21-1 24-15 8-14 20-8-4Z"/>'
    '<circle fill="$_f" stroke="none" cx="144" cy="57" r="4"/>'
    '<path d="m141 77 10-2"/>'
    '</g>',
  );

  static String _pet(bool cat) {
    final tail = cat
        ? 'M118 99q38 10 34-17t-15 1'
        : 'M116 99q37-24 28-39q-9-12-13 6';
    final fur = cat ? _y : _p;
    final ears = cat
        ? '<path fill="$_y" d="m48 59 2-43 29 23m24 0 28-23 3 43"/>'
        : '<path fill="$_p" d="M58 38q-30-8-29 20t23 29l17-43M113 38q29-7 30 20t-22 26l-20-40"/>'
              '<path fill="$_k" stroke="none" d="M45 45q-12 10-7 26l9-2 12-24m72 0q9 10 4 24l-7-2-10-22"/>';
    final whiskers = cat
        ? '<path d="m59 77-18-5m18 12-18 3m81-10 18-5m-18 12 18 3"/>'
        : '';
    return _wrap(
      '<g stroke="$_f" stroke-width="4" stroke-linejoin="round" stroke-linecap="round">'
      '<path fill="$_p" d="$tail"/>'
      '<ellipse fill="$fur" cx="91" cy="99" rx="38" ry="35"/>'
      '<path fill="$_s" d="M77 93q15-7 27 0v38H77Z"/>'
      '<path fill="$fur" d="M49 125q-5 17 20 14l6-10m30-3q-1 17 22 12l-4-12"/>'
      '$ears'
      '<ellipse fill="$fur" cx="90" cy="65" rx="43" ry="34"/>'
      '<ellipse fill="$_w" stroke="none" cx="73" cy="61" rx="12" ry="14"/>'
      '<ellipse fill="$_w" stroke="none" cx="108" cy="61" rx="12" ry="14"/>'
      '<ellipse fill="$_f" stroke="none" cx="76" cy="63" rx="6" ry="9"/>'
      '<ellipse fill="$_f" stroke="none" cx="105" cy="63" rx="6" ry="9"/>'
      '<circle fill="$_w" stroke="none" cx="77" cy="59" r="2.5"/>'
      '<circle fill="$_w" stroke="none" cx="106" cy="59" r="2.5"/>'
      '<ellipse fill="$_s" stroke="none" cx="90" cy="82" rx="23" ry="15"/>'
      '<path fill="$_f" d="m83 77 7 7 7-7Z"/>'
      '<path fill="$_k" d="M79 87q11 18 23 0Z"/>'
      '$whiskers'
      '</g>',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          photo!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }
    if (kind == 'house' || kind == 'horse' || kind == 'dog' || kind == 'cat') {
      final svg = kind == 'house'
          ? _house()
          : kind == 'horse'
          ? _horse()
          : _pet(kind == 'cat');
      return SvgPicture.string(
        svg,
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }
    // Any other word: show the word itself with a little star.
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 180,
          height: 150,
          child: Stack(
            children: [
              SvgPicture.string(_wrap(_star), width: 180, height: 150),
              Align(
                alignment: const Alignment(0, 0.3),
                child: Text(label, style: display(40)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHED LINES / BORDERS
// ============================================================
class DashedPainter extends CustomPainter {
  DashedPainter({
    this.radius = 0,
    this.line = false,
    this.strokeWidth = 3,
    this.dash = 9,
    this.gap = 6,
  });
  final double radius;
  final bool line; // true = a straight line, false = a rounded box border
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (line) {
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    } else {
      final half = strokeWidth / 2;
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            half,
            half,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(radius),
        ),
      );
    }
    final paint = Paint()
      ..color = C.foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A straight dashed line (3px tall) that fills the available width.
class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: CustomPaint(painter: DashedPainter(line: true)),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

const ink = Color(0xFF233E37);
const terra = Color(0xFFC15C3D);
const cream = Color(0xFFFAF7F0);
const muted = Color(0xFF737970);
const gold = Color(0xFFE2B762);
const line = Color(0xFFE8E4DA);
const categoryIcons = [
  Icons.auto_awesome,
  Icons.music_note_rounded,
  Icons.palette_outlined,
  Icons.restaurant_rounded,
  Icons.theater_comedy_outlined,
  Icons.account_balance_outlined,
];

ThemeData tramaTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: cream,
  colorScheme: ColorScheme.fromSeed(
    seedColor: terra,
    primary: terra,
    secondary: ink,
    surface: cream,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 38,
      fontWeight: FontWeight.w700,
      color: ink,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: ink,
      height: 1.15,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: ink, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.45),
    bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.4),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: line),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: cream,
    indicatorColor: const Color(0xFFF0DDD1),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
  ),
);

class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const Eyebrow(this.text, {super.key, this.color = terra});
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
      color: color,
    ),
  );
}

class WovenBand extends StatelessWidget {
  const WovenBand({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 8,
    width: double.infinity,
    child: CustomPaint(painter: _BandPainter()),
  );
}

class _BandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    for (double x = 0; x < size.width; x += 24) {
      p.color = [terra, gold, ink][(x / 24).floor() % 3];
      canvas.drawPath(
        Path()
          ..moveTo(x, 4)
          ..lineTo(x + 7, 0)
          ..lineTo(x + 14, 4)
          ..lineTo(x + 7, 8)
          ..close(),
        p,
      );
      canvas.drawRect(Rect.fromLTWH(x + 17, 2, 4, 4), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Original vector illustrations: offline, scalable and independent of image services.
class EventArt extends StatelessWidget {
  final int kind;
  final double height;
  const EventArt({super.key, required this.kind, this.height = 250});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: CulturalArtPainter(kind)),
  );
}

class CulturalArtPainter extends CustomPainter {
  final int kind;
  CulturalArtPainter(this.kind);
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 400, s.height / 280);
    final p = Paint();
    final backgrounds = [
      const Color(0xFFC16143),
      const Color(0xFF233F3D),
      const Color(0xFFD6B889),
      const Color(0xFF72918A),
      const Color(0xFF6F5263),
      const Color(0xFFCEAD7C),
    ];
    p.color = backgrounds[kind % 6];
    c.drawRect(const Rect.fromLTWH(0, 0, 400, 280), p);
    p.color = cream.withValues(alpha: .08);
    for (int i = 0; i < 70; i++) {
      c.drawCircle(
        Offset((i * 73 % 400).toDouble(), (i * 47 % 280).toDouble()),
        1.1,
        p,
      );
    }
    p.color = gold;
    c.drawCircle(const Offset(308, 67), 41, p);
    p.color = cream.withValues(alpha: .17);
    for (double x = -60; x < 460; x += 85) {
      c.drawArc(
        Rect.fromLTWH(x, 205, 140, 110),
        pi,
        pi,
        false,
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    p.style = PaintingStyle.fill;
    if (kind % 6 == 0) {
      // Marinera: flowing skirt, dancer and white handkerchief.
      p.color = const Color(0xFF7C332A);
      c.drawOval(const Rect.fromLTWH(48, 242, 306, 15), p);
      p.color = cream;
      c.drawPath(
        Path()
          ..moveTo(177, 125)
          ..cubicTo(162, 157, 100, 193, 67, 224)
          ..quadraticBezierTo(197, 290, 321, 224)
          ..cubicTo(265, 186, 226, 151, 219, 126)
          ..close(),
        p,
      );
      p.color = const Color(0xFFD9A66C);
      c.drawPath(
        Path()
          ..moveTo(94, 231)
          ..quadraticBezierTo(198, 272, 298, 232)
          ..lineTo(285, 225)
          ..quadraticBezierTo(195, 257, 108, 224)
          ..close(),
        p,
      );
      p.color = ink;
      c.drawCircle(const Offset(199, 73), 17, p);
      p.color = const Color(0xFFCE9266);
      c.drawCircle(const Offset(202, 82), 13, p);
      c.drawPath(
        Path()
          ..moveTo(190, 103)
          ..lineTo(160, 118)
          ..lineTo(127, 92)
          ..lineTo(121, 98)
          ..lineTo(157, 133)
          ..lineTo(190, 122)
          ..close(),
        p,
      );
      c.drawPath(
        Path()
          ..moveTo(210, 104)
          ..lineTo(243, 92)
          ..lineTo(257, 53)
          ..lineTo(264, 56)
          ..lineTo(255, 104)
          ..lineTo(215, 121)
          ..close(),
        p,
      );
      p.color = cream;
      c.drawPath(
        Path()
          ..moveTo(185, 102)
          ..lineTo(211, 102)
          ..lineTo(220, 139)
          ..lineTo(177, 139)
          ..close(),
        p,
      );
      c.drawPath(
        Path()
          ..moveTo(260, 54)
          ..quadraticBezierTo(294, 18, 313, 44)
          ..quadraticBezierTo(284, 43, 275, 71)
          ..close(),
        p,
      );
      p.color = terra;
      c.drawCircle(const Offset(184, 74), 7, p);
    } else if (kind % 6 == 1) {
      p.color = const Color(0xFF132D2B);
      c.drawOval(const Rect.fromLTWH(70, 236, 270, 20), p);
      p.color = gold;
      c.drawPath(
        Path()
          ..moveTo(153, 46)
          ..lineTo(188, 46)
          ..lineTo(195, 173)
          ..quadraticBezierTo(194, 225, 244, 199)
          ..lineTo(256, 160)
          ..lineTo(292, 174)
          ..lineTo(278, 218)
          ..quadraticBezierTo(183, 291, 160, 208)
          ..close(),
        p,
      );
      p.color = ink;
      c.drawOval(const Rect.fromLTWH(250, 151, 47, 25), p);
      p.color = cream;
      for (double y = 82; y < 180; y += 23) {
        c.drawCircle(Offset(176, y), 5, p);
      }
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      c.drawPath(
        Path()
          ..moveTo(95, 102)
          ..lineTo(95, 62)
          ..lineTo(116, 58)
          ..lineTo(116, 96),
        p,
      );
      p.style = PaintingStyle.fill;
      c.drawOval(const Rect.fromLTWH(82, 96, 14, 9), p);
      c.drawOval(const Rect.fromLTWH(103, 90, 14, 9), p);
    } else if (kind % 6 == 2 || kind % 6 == 3) {
      p.color = ink.withValues(alpha: .15);
      c.drawOval(const Rect.fromLTWH(66, 235, 270, 24), p);
      p.color = terra;
      c.drawPath(
        Path()
          ..moveTo(142, 88)
          ..lineTo(239, 88)
          ..lineTo(229, 133)
          ..cubicTo(312, 184, 279, 245, 195, 246)
          ..cubicTo(106, 245, 79, 180, 151, 133)
          ..close(),
        p,
      );
      p.color = const Color(0xFF7D3C2D);
      c.drawOval(const Rect.fromLTWH(141, 80, 99, 23), p);
      p
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      c.drawPath(
        Path()
          ..moveTo(126, 189)
          ..lineTo(148, 165)
          ..lineTo(173, 189)
          ..lineTo(198, 165)
          ..lineTo(223, 189)
          ..lineTo(248, 165)
          ..lineTo(269, 189),
        p,
      );
      c.drawArc(const Rect.fromLTWH(130, 187, 129, 35), 0, pi, false, p);
      p.style = PaintingStyle.fill;
    } else if (kind % 6 == 4) {
      for (int i = 0; i < 2; i++) {
        c.save();
        c.translate(85 + i * 118, 70 + i * 30);
        c.rotate(i == 0 ? -.15 : .15);
        p.color = i == 0 ? cream : gold;
        c.drawPath(
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(55, 20, 110, 0)
            ..lineTo(103, 91)
            ..quadraticBezierTo(54, 151, 8, 91)
            ..close(),
          p,
        );
        p
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
        c.drawLine(const Offset(22, 43), const Offset(42, 46), p);
        c.drawLine(const Offset(68, 46), const Offset(88, 43), p);
        c.drawArc(
          const Rect.fromLTWH(30, 63, 48, 31),
          i == 0 ? 0 : pi,
          pi,
          false,
          p,
        );
        p.style = PaintingStyle.fill;
        c.restore();
      }
    } else {
      p.color = const Color(0xFFAD8153);
      c.drawPath(
        Path()
          ..moveTo(25, 242)
          ..lineTo(25, 154)
          ..lineTo(95, 154)
          ..lineTo(95, 120)
          ..lineTo(166, 120)
          ..lineTo(166, 87)
          ..lineTo(237, 87)
          ..lineTo(237, 120)
          ..lineTo(308, 120)
          ..lineTo(308, 154)
          ..lineTo(375, 154)
          ..lineTo(375, 242)
          ..close(),
        p,
      );
      p.color = cream.withValues(alpha: .55);
      for (double x = 52; x < 365; x += 45) {
        c.drawPath(
          Path()
            ..moveTo(x, 180)
            ..lineTo(x + 12, 164)
            ..lineTo(x + 24, 180)
            ..lineTo(x + 12, 196)
            ..close(),
          p,
        );
      }
      p.color = const Color(0xFF805D3E);
      c.drawRect(const Rect.fromLTWH(178, 192, 44, 50), p);
    }
    c.restore();
  }

  @override
  bool shouldRepaint(CulturalArtPainter oldDelegate) =>
      kind != oldDelegate.kind;
}

class EmptyState extends StatelessWidget {
  final String title, body;
  final IconData icon;
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.explore_outlined,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
    child: Column(
      children: [
        Icon(icon, size: 46, color: terra),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
      ],
    ),
  );
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// Peint un cercle qui se dessine progressivement (trait animé), comme celui
/// du logo MR Shop, en partant du haut et en tournant dans le sens horaire.
class _CircleRevealPainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0
  final Color color;

  _CircleRevealPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -pi / 2; // départ en haut du cercle
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _CircleRevealPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Animation d'ouverture du logo MR Shop, en 4 temps :
/// 1. Le mot "MR SHOP" apparaît (fondu + léger zoom)
/// 2. Un cercle se dessine progressivement autour
/// 3. Le bouquet de fleurs apparaît en haut à droite du cercle
/// 4. "By Elo" apparaît sous le mot-symbole
///
/// Appelle [onFinished] une fois la séquence terminée.
class LogoRevealAnimation extends StatefulWidget {
  final VoidCallback? onFinished;
  const LogoRevealAnimation({super.key, this.onFinished});

  @override
  State<LogoRevealAnimation> createState() => _LogoRevealAnimationState();
}

class _LogoRevealAnimationState extends State<LogoRevealAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;
  late final Animation<double> _circleProgress;
  late final Animation<double> _flowersOpacity;
  late final Animation<double> _flowersScale;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

    _textOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOut));
    _textScale = Tween(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack)));

    _circleProgress = CurvedAnimation(parent: _controller, curve: const Interval(0.30, 0.68, curve: Curves.easeInOut));

    _flowersOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.62, 0.85, curve: Curves.easeOut));
    _flowersScale = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.62, 0.85, curve: Curves.easeOutBack)));

    _taglineOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeOut));

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () => widget.onFinished?.call());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const circleSize = 260.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: circleSize,
              height: circleSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Cercle qui se dessine
                  CustomPaint(
                    size: const Size(circleSize, circleSize),
                    painter: _CircleRevealPainter(progress: _circleProgress.value, color: AppColors.logoBrown),
                  ),

                  // Texte "MR SHOP"
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.scale(
                      scale: _textScale.value,
                      child: Text(
                        'MR SHOP',
                        style: GoogleFonts.fredoka(
                          fontSize: circleSize * 0.16,
                          letterSpacing: 2,
                          color: AppColors.logoBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Bouquet de fleurs, positionné en haut à droite du cercle
                  Positioned(
                    top: -circleSize * 0.08,
                    right: -circleSize * 0.06,
                    child: Opacity(
                      opacity: _flowersOpacity.value,
                      child: Transform.scale(
                        scale: _flowersScale.value,
                        alignment: Alignment.topRight,
                        child: Image.asset('assets/images/flowers.png', width: circleSize * 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Opacity(
              opacity: _taglineOpacity.value,
              child: Text(
                'By Elo',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                  color: AppColors.logoBrown.withOpacity(0.85),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

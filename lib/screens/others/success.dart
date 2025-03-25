import 'package:flutter/material.dart';
import 'dart:math' as math;

class SuccessScreen extends StatefulWidget {
  final String redirectPath;

  const SuccessScreen({super.key, required this.redirectPath});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();

    // Longer animation duration for visibility
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Circle scale animation
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Checkmark drawing animation with more pronounced curve
    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation and then navigate
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).pushReplacementNamed(widget.redirectPath);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: SuccessAnimationPainter(
                circleProgress: _circleAnimation.value,
                checkmarkProgress: _checkmarkAnimation.value,
              ),
              child: const SizedBox(width: 150, height: 150),
            );
          },
        ),
      ),
    );
  }
}

class SuccessAnimationPainter extends CustomPainter {
  final double circleProgress;
  final double checkmarkProgress;

  SuccessAnimationPainter({
    required this.circleProgress,
    required this.checkmarkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Green Circle Paint
    final circlePaint =
        Paint()
          ..color = Colors.green.shade400
          ..style = PaintingStyle.fill; // Changed to fill

    // Draw filled circle
    canvas.drawCircle(center, radius * circleProgress, circlePaint);

    // Checkmark path with explicit points for clarity
    if (checkmarkProgress > 0) {
      final checkPath = Path();

      // Define checkmark points more explicitly
      final startPoint = Offset(center.dx - radius / 3, center.dy + radius / 6);
      final midPoint = Offset(center.dx - radius / 6, center.dy + radius / 3);
      final endPoint = Offset(center.dx + radius / 2, center.dy - radius / 3);

      checkPath.moveTo(startPoint.dx, startPoint.dy);

      // First line of checkmark
      final firstLine =
          Offset.lerp(
            startPoint,
            midPoint,
            math.min(checkmarkProgress * 2, 1.0),
          )!;
      checkPath.lineTo(firstLine.dx, firstLine.dy);

      // Second line of checkmark
      if (checkmarkProgress > 0.5) {
        final secondLine =
            Offset.lerp(
              midPoint,
              endPoint,
              math.max((checkmarkProgress - 0.5) * 2, 0.0),
            )!;
        checkPath.lineTo(secondLine.dx, secondLine.dy);
      }

      final checkPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 15.0; // Increased stroke width

      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SuccessAnimationPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkmarkProgress != checkmarkProgress;
  }
}

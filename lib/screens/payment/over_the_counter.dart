import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:furcare_app/screens/customer/customer_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'dart:ui';

class OverTheCounter extends StatefulWidget {
  const OverTheCounter({super.key});

  @override
  _OverTheCounterState createState() => _OverTheCounterState();
}

class _OverTheCounterState extends State<OverTheCounter>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    // Button pulse animation
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Subtle background movement
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat(reverse: true);

    // Confetti animation for button press
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Animated Background with parallax effect
            AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return Positioned(
                  left: -50 + 100 * _backgroundAnimationController.value,
                  top: -50 + 100 * _backgroundAnimationController.value,
                  width: size.width + 100,
                  height: size.height + 100,
                  child: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      'assets/veterinary_pattern.jpg',
                      repeat: ImageRepeat.repeat,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withAlpha(50),
                    Colors.white.withAlpha(200),
                    Colors.white,
                  ],
                ),
              ),
            ),

            // Paw print decorations
            ...List.generate(10, (index) {
              final random = index * 0.1;
              return Positioned(
                top: size.height * (0.1 + random * 0.8),
                left: size.width * (0.05 + (index % 3) * 0.3),
                child: Opacity(
                  opacity: 0.1 + random * 0.1,
                  child: Transform.rotate(
                    angle: random * 2,
                    child: Icon(
                      Icons.pets,
                      size: 40 + random * 30,
                      color: AppColors.primary.withAlpha(50),
                    ),
                  ),
                ),
              );
            }),

            // Main Content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Lottie Illustration with enhanced entrance
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: SlideInUp(
                          child: Lottie.asset(
                            'assets/lady_walking_with_dog.json',
                            width: 260,
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Animated Card with Glass Effect
                      FadeInDown(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 1000),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(28.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(200),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(200),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ShakeX(
                                      from: 5,
                                      duration: const Duration(
                                        milliseconds: 2500,
                                      ),
                                      delay: const Duration(milliseconds: 1000),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                        size: 56,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Please proceed',
                                      style: GoogleFonts.nunito(
                                        color: AppColors.primary,
                                        fontSize: 32.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    FadeIn(
                                      delay: const Duration(milliseconds: 800),
                                      child: Text(
                                        'to the counter for your payment',
                                        style: GoogleFonts.nunito(
                                          color: AppColors.primary.withOpacity(
                                            0.8,
                                          ),
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FadeIn(
                                      delay: const Duration(milliseconds: 1200),
                                      child: Text(
                                        'Thank you!',
                                        style: GoogleFonts.lilitaOne(
                                          color: AppColors.primary,
                                          fontSize: 32.0,
                                          height: 1.2,
                                          letterSpacing: 1.0,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 6.0,
                                              color: Colors.black.withAlpha(50),
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Fancy Animated Button with Glow Effect
                      FadeInUp(
                        delay: const Duration(milliseconds: 1500),
                        duration: const Duration(milliseconds: 800),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.08).animate(
                            CurvedAnimation(
                              parent: _buttonAnimationController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(200),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Run confetti animation
                                _confettiController.forward(from: 0.0);

                                // Add a more pronounced haptic feedback
                                HapticFeedback.mediumImpact();

                                // Slight delay for visual feedback
                                await Future.delayed(
                                  const Duration(milliseconds: 600),
                                );

                                // Navigate with a fade transition
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(
                                      milliseconds: 800,
                                    ),
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const CustomerMain(),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.95,
                                            end: 1.0,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },

                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Finish'),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti animation when button is pressed
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                if (_confettiController.value == 0) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: Opacity(
                    opacity:
                        _confettiController.value > 0.8
                            ? 3 * (1.0 - _confettiController.value)
                            : _confettiController.value,
                    child: CustomPaint(
                      painter: ConfettiPainter(
                        progress: _confettiController.value,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Confetti animation painter
class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    final confettiCount = 100;
    final paint = Paint();

    for (int i = 0; i < confettiCount; i++) {
      final index = (random + i) % colors.length;
      paint.color = colors[index];

      final randomX = ((random + i * 7) % 100) / 100 * size.width;
      final randomSize = 5.0 + ((random + i * 13) % 10);
      final gravity = 9.8 * progress * progress;

      final y =
          size.height / 2 -
          100 +
          (i % 3 == 0 ? -1 : 1) * 200 * progress +
          gravity * 100;

      if (i % 3 == 0) {
        // Rectangle confetti
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(randomX, y),
            width: randomSize,
            height: randomSize * 1.5,
          ),
          paint,
        );
      } else if (i % 3 == 1) {
        // Circle confetti
        canvas.drawCircle(Offset(randomX, y), randomSize / 2, paint);
      } else {
        // Triangle confetti
        final path = Path();
        path.moveTo(randomX, y - randomSize / 2);
        path.lineTo(randomX - randomSize / 2, y + randomSize / 2);
        path.lineTo(randomX + randomSize / 2, y + randomSize / 2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ProfileSetupAnimation extends StatefulWidget {
  final String redirectPath;
  final VoidCallback? onSetupComplete;

  const ProfileSetupAnimation({
    super.key,
    required this.redirectPath,
    this.onSetupComplete,
  });

  @override
  State<ProfileSetupAnimation> createState() => _ProfileSetupAnimationState();
}

class _ProfileSetupAnimationState extends State<ProfileSetupAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller with duration matching your Lottie animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Staggered animations for text and progress
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.linear),
      ),
    );

    // Start animation and then navigate
    _controller.forward().then((_) {
      // Optional callback for setup completion
      widget.onSetupComplete?.call();

      // Navigate after animation
      Future.delayed(const Duration(milliseconds: 500), () {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/processing_profile.json',
              width: 500,
              height: 500,
              controller: _controller,
              onLoaded: (composition) {
                // Optional: adjust controller duration to match the Lottie animation
                _controller.duration = composition.duration;
              },
            ),

            const SizedBox(height: 40),

            // Animated Text
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _textAnimation.value)),
                    child: Column(
                      children: [
                        Text(
                          "Let's set up your profile",
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Don't worry, it takes just a few seconds...",
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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

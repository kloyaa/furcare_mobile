import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/utils/const/colors.dart';

/// A standardized widget for displaying the Furcare logo
class FurcareLogo extends StatelessWidget {
  final bool hasError;
  final double fontSize;
  final double taglineSize;

  const FurcareLogo({
    super.key,
    this.hasError = false,
    this.fontSize = 120.0,
    this.taglineSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo text with animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.sunshiney(
                color: hasError ? AppColors.danger : AppColors.primary,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              child: const Text("furcare"),
            ),
          ),
        ),
        // Tagline with animation
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.sunshiney(
              color: hasError ? AppColors.danger : AppColors.secondary,
              fontSize: taglineSize,
              fontWeight: FontWeight.w300,
              height: 0.1,
            ),
            child: const Text('"fur every pet needs"'),
          ),
        ),
      ],
    );
  }
}

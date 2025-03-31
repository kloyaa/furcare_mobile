import 'package:flutter/material.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedTotal extends StatelessWidget {
  final double amount;
  final Duration duration;

  const AnimatedTotal({
    super.key,
    required this.amount,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "TOTAL: PHP",
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: amount),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              phpFormatter.format(value),
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            );
          },
        ),
      ],
    );
  }
}

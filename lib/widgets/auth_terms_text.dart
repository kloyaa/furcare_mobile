import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/utils/const/colors.dart';

/// A standardized widget for displaying terms and conditions text
class AuthTermsText extends StatelessWidget {
  final String text;
  final bool isRegister;

  const AuthTermsText({super.key, this.isRegister = false, this.text = ''});

  @override
  Widget build(BuildContext context) {
    final String defaultText =
        isRegister
            ? "By creating an account, you agree to abide by our terms and conditions. Please review them carefully before proceeding."
            : "By logging in, you agree to abide by our terms and conditions. Please review them carefully before proceeding.";

    return Text(
      text.isNotEmpty ? text : defaultText,
      style: GoogleFonts.urbanist(
        color: AppColors.primary.withOpacity(0.7),
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

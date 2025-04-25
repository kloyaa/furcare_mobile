import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/utils/const/colors.dart';

/// A standardized widget for displaying authentication error messages
class AuthErrorMessage extends StatelessWidget {
  final String message;
  final EdgeInsets padding;

  const AuthErrorMessage({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.only(bottom: 15.0),
  });

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Text(
        message,
        style: GoogleFonts.urbanist(
          color: AppColors.danger,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

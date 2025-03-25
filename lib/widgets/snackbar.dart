import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';

extension SafeSnackBar on State {
  void showSafeSnackBar(
    String message, {
    Color color = AppColors.primary,
    double fontSize = 9.0,
    int duration = 3,
  }) {
    // Check if the widget is still in the tree
    if (!mounted) return;

    // Use the current context safely
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      content: Text(message, style: GoogleFonts.urbanist(fontSize: fontSize)),
      backgroundColor: color,
      duration: Duration(seconds: duration),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}

// Alternative global function with mounted check
void showSnackBar(
  BuildContext context,
  String message, {
  Color color = AppColors.primary,
  double fontSize = 9.0,
  int duration = 3,
}) {
  // Check if the context is still valid
  if (!context.mounted) return;

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final snackBar = SnackBar(
    content: Text(message, style: GoogleFonts.urbanist(fontSize: fontSize)),
    backgroundColor: color,
    duration: Duration(seconds: duration),
  );

  scaffoldMessenger.showSnackBar(snackBar);
}

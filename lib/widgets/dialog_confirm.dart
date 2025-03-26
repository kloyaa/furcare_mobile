import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/const/colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        title,
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.urbanist(color: AppColors.primary.withOpacity(0.7)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: GoogleFonts.urbanist(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(
            'Confirm',
            style: GoogleFonts.urbanist(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

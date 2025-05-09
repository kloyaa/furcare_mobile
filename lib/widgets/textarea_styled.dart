import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/utils/const/colors.dart';

/// A reusable, styled textarea field that matches the AuthFormField styling
class StyledTextArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool hasError;
  final int minLines;
  final int maxLines;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final double borderRadius;
  final String? hintText;
  final int? maxLength;

  const StyledTextArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.hasError = false,
    this.minLines = 3,
    this.maxLines = 5,
    this.suffixIcon,
    this.keyboardType = TextInputType.multiline,
    this.borderRadius = 15.0,
    this.hintText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (hasError ? AppColors.danger : AppColors.primary)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelText: label,
          hintText: hintText,
          labelStyle: GoogleFonts.urbanist(
            color:
                hasError
                    ? AppColors.danger
                    : AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
          ),
          hintStyle: GoogleFonts.urbanist(
            color: AppColors.primary.withOpacity(0.3),
            fontSize: 12.0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              bottom: 0.0,
            ),
            child: Icon(
              icon,
              size: 18.0,
              color: hasError ? AppColors.danger : AppColors.primary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minHeight: 0,
            minWidth: 0,
          ),
          alignLabelWithHint: true,
          border: InputBorder.none,
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(borderRadius),
          //   borderSide: const BorderSide(color: Colors.transparent),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(borderRadius),
          //   borderSide: BorderSide(
          //     color: (hasError ? AppColors.danger : AppColors.primary)
          //         .withOpacity(0.3),
          //     width: 1.0,
          //   ),
          // ),
          contentPadding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
          suffixIcon: suffixIcon,
          // Counter placed below text input
          counterStyle: GoogleFonts.urbanist(
            color: AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
          ),
        ),
        style: TextStyle(
          color: hasError ? AppColors.danger : AppColors.primary,
          fontSize: 12.0,
        ),
      ),
    );
  }
}

// Example usage:
/*
StyledTextArea(
  controller: _notesController,
  focusNode: _notesFocus,
  label: 'Notes',
  icon: Icons.note_alt_outlined,
  minLines: 4,
  maxLines: 6,
  hintText: 'Enter additional notes here...',
  maxLength: 500,
)
*/

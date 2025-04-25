import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/utils/const/colors.dart';

/// A reusable, styled form field for authentication screens
class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool obscureText;
  final bool hasError;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final double borderRadius;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.hasError = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.borderRadius = 15.0,
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
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelText: label,
          labelStyle: GoogleFonts.urbanist(
            color:
                hasError
                    ? AppColors.danger
                    : AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              icon,
              size: 18.0,
              color: hasError ? AppColors.danger : AppColors.primary,
            ),
          ),
          prefixIconColor: AppColors.primary,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: (hasError ? AppColors.danger : AppColors.primary)
                  .withOpacity(0.3),
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(
          color: hasError ? AppColors.danger : AppColors.primary,
          fontSize: 12.0,
        ),
      ),
    );
  }
}

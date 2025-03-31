import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/const/colors.dart';

class PaymentMethodCard extends StatelessWidget {
  final String methodName;
  final IconData icon;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.methodName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(100),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                methodName,
                style: GoogleFonts.urbanist(
                  fontSize: 14.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary.withAlpha(200),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

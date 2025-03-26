import 'package:flutter/material.dart';
import 'package:furcare_app/screens/payment/over_the_counter.dart';
import 'package:furcare_app/screens/payment/payment_qr.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPaymentMethod extends StatefulWidget {
  final String referenceNo;
  final String date;

  const SelectPaymentMethod({
    super.key,
    required this.referenceNo,
    required this.date,
  });

  @override
  State<SelectPaymentMethod> createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: ListView(
          children: [
            const SizedBox(height: 30.0),
            Text(
              "Choose payment method",
              style: GoogleFonts.urbanist(
                fontSize: 14.0,
                color: AppColors.primary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UploadQR(
                          paymentMethod: "GCash",
                          referenceNo: widget.referenceNo,
                          date: widget.date,
                        ),
                  ),
                );
                // f
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  "GCASH",
                  style: GoogleFonts.urbanist(
                    fontSize: 12.0,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UploadQR(
                          paymentMethod: "Bank Transfer",
                          referenceNo: widget.referenceNo,
                          date: widget.date,
                        ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  "BANK TRANSFER",
                  style: GoogleFonts.urbanist(
                    fontSize: 12.0,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OverTheCounter(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  "OVER THE COUNTER",
                  style: GoogleFonts.urbanist(
                    fontSize: 12.0,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

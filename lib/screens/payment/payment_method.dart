import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/screens/payment/over_the_counter.dart';
import 'package:furcare_app/screens/payment/payment_qr.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/card_payment_method.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  final String referenceNo;
  final String date;

  const SelectPaymentMethodScreen({
    super.key,
    required this.referenceNo,
    required this.date,
  });

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  // Payment method configurations
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'GCASH',
      'icon': Icons.payment,
      'onTap': (BuildContext context, String referenceNo, String date) {
        Navigator.push(
          context,
          _createPageRoute(
            UploadQR(
              paymentMethod: "GCash",
              referenceNo: referenceNo,
              date: date,
            ),
          ),
        );
      },
    },
    {
      'name': 'BANK TRANSFER',
      'icon': Icons.account_balance,
      'onTap': (BuildContext context, String referenceNo, String date) {
        Navigator.push(
          context,
          _createPageRoute(
            UploadQR(
              paymentMethod: "Bank Transfer",
              referenceNo: referenceNo,
              date: date,
            ),
          ),
        );
      },
    },
    {
      'name': 'OVER THE COUNTER',
      'icon': Icons.store,
      'onTap': (BuildContext context, String referenceNo, String date) {
        Navigator.push(context, _createPageRoute(const OverTheCounter()));
      },
    },
  ];

  // Custom page route with slide transition
  static Route _createPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Payments",
          style: GoogleFonts.urbanist(
            fontSize: 16.0,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderText(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _paymentMethods.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return PaymentMethodCard(
                          methodName: method['name'],
                          icon: method['icon'],
                          onTap:
                              () => method['onTap'](
                                context,
                                widget.referenceNo,
                                widget.date,
                              ),
                        )
                        .animate()
                        .fadeIn(
                          duration: 300.ms,
                          delay: Duration(milliseconds: 100 * index),
                        )
                        .slideX(begin: 0.5, duration: 300.ms);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHeaderText() {
    return Text(
      "Choose your preferred payment method",
      style: GoogleFonts.urbanist(
        fontSize: 16.0,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

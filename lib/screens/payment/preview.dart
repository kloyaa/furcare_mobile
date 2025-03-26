import 'package:flutter/material.dart';
import 'package:furcare_app/apis/fees_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/fees.dart';
import 'package:furcare_app/screens/payment/payment_method.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaymentPreview extends StatefulWidget {
  final String serviceName;
  final String referenceNo;
  final String date;

  const PaymentPreview({
    super.key,
    required this.serviceName,
    required this.referenceNo,
    required this.date,
  });

  @override
  State<PaymentPreview> createState() => _PaymentPreviewState();
}

class _PaymentPreviewState extends State<PaymentPreview> {
  // State
  String _accessToken = "";
  String _serviceName = "";
  int _serviceFee = 0;
  List _serviceFees = [];

  Future<void> getServiceFee(String service) async {
    FeesApi appApi = FeesApi(_accessToken);

    final data = getServiceByTitle(service);

    setState(() {
      _serviceName = data["title"];
      _serviceFee = data["fee"];
    });
  }

  Map<String, dynamic> getServiceByTitle(String title) {
    for (var service in _serviceFees) {
      if (service['title'] == title) {
        return service;
      }
    }
    return {"fee": 0, "title": "n/a"};
  }

  @override
  void initState() {
    super.initState();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    final appProvider = Provider.of<FeesProvider>(context, listen: false);

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    _serviceFees = appProvider.serviceFees ?? [];

    // Call getServiceFee method with serviceName from widget arguments
    getServiceFee(widget.serviceName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          color: Colors.white,
          padding: const EdgeInsets.all(50.0),
          width: MediaQuery.of(context).size.width * 0.80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "REF",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "FURC${widget.referenceNo.toUpperCase().substring(10, widget.referenceNo.length)}",
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                "DATE",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                formatDate(DateTime.parse(widget.date)),
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40.0),
              Text(
                "SERVICE",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                widget.serviceName.toUpperCase(),
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "DOWPAYMENT",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "P${_serviceFee ~/ 2}.00",
                style: GoogleFonts.rajdhani(
                  fontSize: 16.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "SERVICE FEE",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "P$_serviceFee.00",
                style: GoogleFonts.rajdhani(
                  fontSize: 16.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30.0),
                child: const Divider(),
              ),
              Text(
                "TO PAY",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "P${_serviceFee ~/ 2}.00",
                style: GoogleFonts.rajdhani(
                  fontSize: 42.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SelectPaymentMethod(
                            referenceNo: widget.referenceNo,
                            date: widget.date,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Center(
                    child: Text(
                      'Pay',
                      style: GoogleFonts.urbanist(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Add your UI widgets here
    );
  }
}

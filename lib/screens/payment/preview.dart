import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/fees_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/fees.dart';
import 'package:furcare_app/screens/payment/payment_method.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
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

class _PaymentPreviewState extends State<PaymentPreview>
    with SingleTickerProviderStateMixin {
  // State
  String _accessToken = "";
  String _serviceName = "";
  int _serviceFee = 0;
  List _serviceFees = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

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

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reference Number Section
                      _buildInfoSection(
                        title: "REF",
                        value:
                            "FURC${widget.referenceNo.toUpperCase().substring(10)}",
                      ),

                      // Date Section
                      _buildInfoSection(
                        title: "DATE",
                        value: formatDate(DateTime.parse(widget.date)),
                      ),

                      const SizedBox(height: 20.0),

                      // Service Details
                      _buildInfoSection(
                        title: "SERVICE",
                        value: widget.serviceName.toUpperCase(),
                      ),

                      _buildFinancialSection(
                        title: "SERVICE FEE",
                        value: "P$_serviceFee.00",
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        child: const Divider(),
                      ),

                      // Total to Pay
                      Text(
                        "TO PAY",
                        style: GoogleFonts.urbanist(
                          fontSize: 12.0,
                          color: AppColors.primary.withOpacity(0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        "P$_serviceFee.00",
                        style: GoogleFonts.rajdhani(
                          fontSize: 48.0,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // Pay Button
                      ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SelectPaymentMethodScreen(
                                        referenceNo: widget.referenceNo,
                                        date: widget.date,
                                      ),
                                ),
                              );
                            },

                            child: Center(child: Text('Proceed to Payment')),
                          )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.1, end: 0, duration: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build info sections
  Widget _buildInfoSection({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 10.0,
            color: AppColors.primary.withOpacity(0.7),
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 14.0,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  // Helper method to build financial sections
  Widget _buildFinancialSection({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 12.0,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 16.0,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';

class PreviewTransit extends StatefulWidget {
  const PreviewTransit({super.key});

  @override
  State<PreviewTransit> createState() => _PreviewTransitState();
}

class _PreviewTransitState extends State<PreviewTransit>
    with SingleTickerProviderStateMixin {
  // Controller for animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // API access token
  String _accessToken = "";

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Get transit details from the API
  Future<Map<String, dynamic>?> getBookingDetails() async {
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      final application = arguments['application'];

      if (application == null) {
        throw Exception("Application ID is missing");
      }

      BookingApi bookingApi = BookingApi(_accessToken);
      Response<dynamic> response = await bookingApi.getTransitDetails(
        application,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio specific errors
      final errorMsg = ErrorResponse.fromJson(e.response?.data ?? {}).message;
      setState(
        () => _errorMessage = errorMsg ?? "Failed to get booking details",
      );
      return null;
    } catch (e) {
      // Handle other errors
      setState(() => _errorMessage = e.toString());
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update booking status (accept/decline)
  Future<void> updateBookingStatus(String status) async {
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      final booking = arguments['booking'];

      if (booking == null) {
        throw Exception("Booking ID is missing");
      }

      StaffApi staffApi = StaffApi(_accessToken);

      UpdateBookingStatusPayload payload = UpdateBookingStatusPayload(
        status: status,
        booking: booking,
      );

      await staffApi.updateBookingStatus(payload);

      if (context.mounted) {
        // Use slide transition for success screen
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    SuccessScreen(redirectPath: "/s/main"),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    } on DioException catch (e) {
      final errorMsg = ErrorResponse.fromJson(e.response?.data ?? {}).message;
      if (context.mounted) {
        showSnackBar(
          context,
          errorMsg ?? "An error occurred",
          color: AppColors.danger,
          fontSize: 10.0,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          e.toString(),
          color: AppColors.danger,
          fontSize: 10.0,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show confirmation dialog before updating status
  void showConfirmationDialog({
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Confirmation",
            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: GoogleFonts.urbanist()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.urbanist(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Confirm",
                style: GoogleFonts.urbanist(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Get access token from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );

      setState(() {
        _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safely get arguments, providing an empty map as fallback
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final profile = arguments['profile'] as Map<String, dynamic>? ?? {};
    final pet = arguments['pet'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Booking Preview",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Ionicons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.secondary,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      children: [
                        // Owner Information Card
                        _buildInfoCard(
                          title: "Owner Information",
                          content: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoColumn(
                                label: "Name",
                                value: "${profile["fullName"] ?? ""}",
                                flex: 2,
                              ),
                              _buildInfoColumn(
                                label: "Gender",
                                value: profile["gender"] ?? "Not specified",
                                flex: 1,
                              ),
                              _buildInfoColumn(
                                label: "Contact No.",
                                value:
                                    profile.containsKey("contact")
                                        ? profile["contact"]["number"]
                                        : "Not available",
                                flex: 1,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Pet Information Card
                        _buildInfoCard(
                          title: "Pet Information",
                          content: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoColumn(
                                label: "Name",
                                value: pet["name"] ?? "Not specified",
                                flex: 1,
                              ),
                              _buildInfoColumn(
                                label: "Specie",
                                value: pet["specie"] ?? "Not specified",
                                flex: 1,
                              ),
                              _buildInfoColumn(
                                label: "Gender",
                                value: pet["gender"] ?? "Not specified",
                                flex: 1,
                              ),
                              _buildInfoColumn(
                                label: "Identification",
                                value: pet["identification"] ?? "Not specified",
                                flex: 1,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Booking Details Card with API data
                        FutureBuilder<Map<String, dynamic>?>(
                          future: getBookingDetails(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerLoadingCard();
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return _buildErrorCard(
                                error:
                                    snapshot.hasError
                                        ? snapshot.error.toString()
                                        : "No booking data available",
                                onRetry: () => setState(() {}),
                              );
                            }

                            final data = snapshot.data!;
                            return _buildInfoCard(
                              title: "Pick up and Drop off",
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Schedule information
                                  Text(
                                    data.containsKey('schedule')
                                        ? formatDate(
                                          DateTime.parse(data['schedule']),
                                        )
                                        : "Schedule not available",
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),

                                  const SizedBox(height: 32.0),

                                  // Action buttons
                                  _buildActionButton(
                                    label: "Accept",
                                    isPrimary: true,
                                    onPressed: () {
                                      showConfirmationDialog(
                                        message:
                                            "Are you sure you want to accept this booking?",
                                        onConfirm:
                                            () => updateBookingStatus(
                                              'confirmed',
                                            ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 12.0),

                                  _buildActionButton(
                                    label: "Decline",
                                    isPrimary: false,
                                    onPressed: () {
                                      showConfirmationDialog(
                                        message:
                                            "Are you sure you want to decline this booking?",
                                        onConfirm:
                                            () =>
                                                updateBookingStatus('declined'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // Helper widget to build consistent info cards
  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16.0),
          content,
        ],
      ),
    );
  }

  // Helper widget for displaying information columns
  Widget _buildInfoColumn({
    required String label,
    required String value,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 10.0,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: GoogleFonts.urbanist(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for action buttons
  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child:
          isPrimary
              ? ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.greenAccent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.urbanist(
                    color: AppColors.secondary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.danger.withOpacity(0.6),
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.urbanist(
                    color: AppColors.danger,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
    );
  }

  // Helper widget for error cards
  Widget _buildErrorCard({
    required String error,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Ionicons.alert_circle_outline,
            color: AppColors.danger,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "Error Loading Data",
            style: GoogleFonts.urbanist(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.urbanist(fontSize: 14.0, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Ionicons.refresh_outline),
            label: Text("Try Again", style: GoogleFonts.urbanist()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer loading effect for cards
class ShimmerLoadingCard extends StatelessWidget {
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

// Error display for the entire screen
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDisplay({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Ionicons.cloud_offline_outline,
          size: 80,
          color: AppColors.danger.withOpacity(0.7),
        ),
        const SizedBox(height: 24),
        Text(
          "Something went wrong",
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 16, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Ionicons.refresh_outline),
          label: Text("Retry", style: GoogleFonts.urbanist()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';

class PreviewGrooming extends StatefulWidget {
  const PreviewGrooming({super.key});

  @override
  State<PreviewGrooming> createState() => _PreviewGroomingState();
}

class _PreviewGroomingState extends State<PreviewGrooming>
    with SingleTickerProviderStateMixin {
  // State variables
  String _accessToken = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  /// Fetches detailed information about the grooming booking
  Future<dynamic> getBookingDetails() async {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final application = arguments['application'];

    // Show loading state
    setState(() => _isLoading = true);

    try {
      BookingApi bookingApi = BookingApi(_accessToken);
      Response<dynamic> response = await bookingApi.getGroomingDetails(
        application,
      );
      return response.data;
    } catch (e) {
      // Handle any errors that occur during the API call
      return Future.error('Failed to load booking details: ${e.toString()}');
    } finally {
      // Hide loading state if widget is still mounted
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Updates the booking status (confirmed/declined)
  Future<void> updateBookingStatus(String status) async {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final booking = arguments['booking'];

    // Show loading state
    setState(() => _isLoading = true);

    try {
      StaffApi staffApi = StaffApi(_accessToken);
      UpdateBookingStatusPayload payload = UpdateBookingStatusPayload(
        status: status,
        booking: booking,
      );

      await staffApi.updateBookingStatus(payload);

      if (mounted) {
        // Use animation to transition to success screen
        _animationController.reverse().then((_) {
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
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        });
      }
    } on DioException catch (e) {
      // Handle API errors
      final errorMessage =
          e.response?.data != null
              ? ErrorResponse.fromJson(e.response?.data).message
              : "An unknown error occurred";

      if (mounted) {
        showSnackBar(
          context,
          errorMessage,
          color: AppColors.danger,
          fontSize: 10.0,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        showSnackBar(
          context,
          "An unexpected error occurred",
          color: AppColors.danger,
          fontSize: 10.0,
        );
      }
    } finally {
      // Hide loading state if widget is still mounted
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start the animation when the screen loads
    _animationController.forward();

    // Get the access token from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );

      // Safely retrieve the access token
      _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    });
  }

  @override
  void dispose() {
    // Clean up animation controller
    _animationController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog before executing an action
  void _showConfirmationDialog({
    required String message,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Confirmation",
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
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
                  borderRadius: BorderRadius.circular(10.0),
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
  Widget build(BuildContext context) {
    // Extract arguments from route
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    final profile = arguments['profile'] ?? {};
    final pet = arguments['pet'] ?? {};

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Preview",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: AppColors.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: AppColors.secondary,
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      // Owner Information Card
                      _buildInfoCard(
                        title: "Owner Information",
                        child: Row(
                          children: [
                            _buildInfoColumn(
                              label: "Name",
                              value: "${profile["fullName"] ?? ""}",
                            ),
                            const SizedBox(width: 16.0),
                            _buildInfoColumn(
                              label: "Gender",
                              value: profile["gender"] ?? "Not specified",
                            ),
                            const Spacer(),
                            _buildInfoColumn(
                              label: "Contact No.",
                              value:
                                  profile["contact"]?["number"] ??
                                  "Not provided",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Pet Information Card
                      _buildInfoCard(
                        title: "Pet Information",
                        child: Row(
                          children: [
                            _buildInfoColumn(
                              label: "Name",
                              value: pet["name"] ?? "Not specified",
                            ),
                            const SizedBox(width: 16.0),
                            _buildInfoColumn(
                              label: "Species",
                              value: pet["specie"] ?? "Not specified",
                            ),
                            const SizedBox(width: 16.0),
                            _buildInfoColumn(
                              label: "Gender",
                              value: pet["gender"] ?? "Not specified",
                            ),
                            const Spacer(),
                            _buildInfoColumn(
                              label: "Identification",
                              value: pet["identification"] ?? "Not provided",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Booking Details Card with FutureBuilder
                      FutureBuilder(
                        future: getBookingDetails(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return _buildErrorCard(snapshot.error.toString());
                          } else if (!snapshot.hasData) {
                            return _buildErrorCard("No data available");
                          }

                          // Display grooming details
                          final scheduleTitle =
                              snapshot.data['schedule']?['title'] ??
                              "No title available";

                          return _buildInfoCard(
                            title: "",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Grooming title with animation
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Grooming",
                                    style: GoogleFonts.urbanist(
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),

                                // Schedule title with animation
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 700),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    scheduleTitle,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40.0),

                                // Action buttons
                                _buildActionButtons(),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  /// Creates a reusable info card with consistent styling
  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16.0),
          ],
          child,
        ],
      ),
    );
  }

  /// Creates a column with label and value for information display
  Widget _buildInfoColumn({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Creates an error card for displaying error messages
  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
          const SizedBox(height: 16.0),
          Text(
            'Error',
            style: GoogleFonts.urbanist(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(color: Colors.black87, fontSize: 14.0),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Refresh to try again
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.urbanist(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates the action buttons for accepting or declining the booking
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Accept button with animation
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () => _showConfirmationDialog(
                      message: "Are you sure you want to accept this booking?",
                      onConfirm: () => updateBookingStatus('confirmed'),
                    ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.greenAccent,
              disabledBackgroundColor: Colors.greenAccent.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              elevation: 2,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Accept',
                          style: GoogleFonts.urbanist(
                            color: AppColors.secondary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12.0),

        // Decline button with animation
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: OutlinedButton(
            onPressed:
                _isLoading
                    ? null
                    : () => _showConfirmationDialog(
                      message: "Are you sure you want to decline this booking?",
                      onConfirm: () => updateBookingStatus('declined'),
                    ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.danger.withOpacity(0.5),
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  "Decline",
                  style: GoogleFonts.urbanist(
                    color: AppColors.danger,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

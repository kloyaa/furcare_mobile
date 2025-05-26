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
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Add a class variable to store the future
  late Future<Map<String, dynamic>?> _bookingDetailsFuture;

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

    // Start animation after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    // Initialize booking details future
    _bookingDetailsFuture = getBookingDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments only when dependencies change
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    // Only recreate the future if needed data has changed
    if (arguments.containsKey('application')) {
      _bookingDetailsFuture = getBookingDetails();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get transit details from the API
  Future<Map<String, dynamic>?> getBookingDetails() async {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final String accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    if (accessToken.isEmpty) {
      return null;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      final application = arguments['application'];

      if (application == null) {
        throw Exception("Application ID is missing");
      }

      BookingApi bookingApi = BookingApi(accessToken);
      Response<dynamic> response = await bookingApi.getTransitDetails(
        application,
      );

      if (response.data == null) {
        throw Exception('No booking data received');
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio specific errors
      if (context.mounted) {
        final errorMsg = ErrorResponse.fromJson(e.response?.data ?? {}).message;
        showSnackBar(
          context,
          errorMsg ?? "Failed to get booking details",
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
      return null;
    } catch (e) {
      // Handle other errors
      if (context.mounted) {
        showSnackBar(
          context,
          'Failed to load booking details: ${e.toString()}',
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Determine the next status based on current status
  String moveToNextState() {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    final currentStatus = arguments['currentStatus'];

    if (currentStatus == "confirmed") {
      return 'done';
    }

    if (currentStatus == "declined") {
      return 'declined';
    }

    if (currentStatus == "pending") {
      return 'confirmed';
    }

    return 'pending';
  }

  /// Display different action buttons based on current status
  Widget actionsBasedOnCurrentStatus(Map booking) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    final currentStatus = arguments['currentStatus'] ?? booking['status'];

    if (currentStatus == "confirmed") {
      return _buildAcceptedActionButtons(booking);
    }

    if (currentStatus == "declined") {
      return const SizedBox();
    }

    if (currentStatus == "pending") {
      return _buildActionButtons(booking);
    }

    return const SizedBox();
  }

  /// Update booking status (confirm or decline)
  Future<void> updateBookingStatus(String status, String id) async {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final String accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    setState(() => _isLoading = true);

    try {
      StaffApi staffApi = StaffApi(accessToken);
      UpdateBookingStatusPayload payload = UpdateBookingStatusPayload(
        status: status == 'declined' ? 'declined' : moveToNextState(),
        booking: id,
      );

      await staffApi.updateBookingStatus(payload);

      if (context.mounted) {
        // Success animation
        _animationController.reverse().then((_) {
          Navigator.pushReplacement(
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
      if (context.mounted) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(
          e.response?.data ?? {'message': 'Unknown error occurred'},
        );
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context,
          'An unexpected error occurred',
          color: AppColors.danger,
          fontSize: 12.0,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Confirmation dialog before updating booking status
  void confirmAction({
    required String message,
    required VoidCallback onConfirm,
  }) {
    execOnConfirm(message: message, method: onConfirm, context);
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
          _isLoading && _animationController.isDismissed
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoColumn(
                                label: "Name",
                                value: "${profile["fullName"] ?? ""}",
                              ),
                              _buildInfoColumn(
                                label: "Contact No.",
                                value:
                                    profile.containsKey("contact")
                                        ? profile["contact"]["number"]
                                        : "Not available",
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
                                value: pet["breed"] ?? "Not specified",
                                flex: 1,
                              ),
                              _buildInfoColumn(
                                label: "Gender",
                                value: pet["gender"] ?? "Not specified",
                                flex: 1,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Booking Details Card with API data
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _bookingDetailsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerLoadingCard();
                            } else if (snapshot.hasError) {
                              return _buildErrorCard(
                                error: snapshot.error.toString(),
                                onRetry:
                                    () => setState(() {
                                      _bookingDetailsFuture =
                                          getBookingDetails();
                                    }),
                              );
                            } else if (!snapshot.hasData) {
                              return _buildErrorCard(
                                error: "No booking data available",
                                onRetry:
                                    () => setState(() {
                                      _bookingDetailsFuture =
                                          getBookingDetails();
                                    }),
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

                                  if (data['additionalNotes'] != null) ...[
                                    const SizedBox(height: 16.0),
                                    Text(
                                      "Additional Notes:",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    Text(
                                      data['additionalNotes'],
                                      style: GoogleFonts.urbanist(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 32.0),

                                  // Action buttons based on status
                                  actionsBasedOnCurrentStatus(data),
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

  /// Action buttons for accepting/declining booking
  Widget _buildActionButtons(Map booking) {
    String bookingId = booking['_id'];
    return Column(
      children: [
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () => confirmAction(
                    message: "Are you sure you want to accept this booking?",
                    onConfirm:
                        () => updateBookingStatus('confirmed', bookingId),
                  ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.greenAccent,
            disabledBackgroundColor: Colors.greenAccent.withOpacity(0.5),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Accept Booking',
                            style: GoogleFonts.urbanist(
                              color: AppColors.secondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        OutlinedButton(
          onPressed:
              _isLoading
                  ? null
                  : () => confirmAction(
                    message: "Are you sure you want to decline this booking?",
                    onConfirm: () => updateBookingStatus('declined', bookingId),
                  ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: AppColors.danger.withOpacity(0.7),
              width: 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Decline Booking",
                    style: GoogleFonts.urbanist(
                      color: AppColors.danger,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Action buttons for completed bookings
  Widget _buildAcceptedActionButtons(Map booking) {
    String bookingId = booking['_id'];
    return Column(
      children: [
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () => confirmAction(
                    message: "Are you sure you want to complete this booking?",
                    onConfirm: () => updateBookingStatus('done', bookingId),
                  ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.greenAccent,
            disabledBackgroundColor: Colors.greenAccent.withOpacity(0.5),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Done',
                            style: GoogleFonts.urbanist(
                              color: AppColors.secondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: content,
          ),
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
          Text(
            value,
            style: GoogleFonts.urbanist(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

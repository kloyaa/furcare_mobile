import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/extensions.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/utils/enums/enum.dart';
import 'package:furcare_app/widgets/screen_booking_details.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomerTabBookings extends StatefulWidget {
  const CustomerTabBookings({super.key});

  @override
  State<CustomerTabBookings> createState() => _CustomerTabBookingsState();
}

class _CustomerTabBookingsState extends State<CustomerTabBookings>
    with SingleTickerProviderStateMixin {
  // State variables
  String _accessToken = "";
  String _status = "pending";
  List<dynamic> _bookings = [];
  bool _isLoading = false;
  String _errorMessage = "";

  // Animation controllers
  late AnimationController _animationController;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );
      _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
      handleGetBookings("pending");
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fetch bookings method with improved error handling
  Future<void> handleGetBookings(String status) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      BookingApi bookingApi = BookingApi(_accessToken);
      Response<dynamic> response = await bookingApi.getBookingsByAccessToken(
        status,
      );

      setState(() {
        _status = status;
        _bookings = response.data;
        _isLoading = false;
      });

      // Trigger list animation
      _animationController.forward(from: 0.0);
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.response?.data['message'] ?? 'An error occurred';
      });
    }
  }

  // Extend Stay method
  Future<void> handleExtendStay(String bookingId, int days) async {
    setState(() {
      _isLoading = true;
    });

    try {
      BookingApi bookingApi = BookingApi(_accessToken);
      await bookingApi.extendBoarding(
        BoardingExtensionPayload(booking: bookingId, days: days),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stay extended by $days day(s)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh bookings
      await handleGetBookings(_status);
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data['message'] ?? 'Failed to extend stay'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Show extend stay dialog
  void _showExtendStayDialog(String bookingId) {
    int days = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.hotel, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Extend Boarding Stay',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How many additional days would you like to extend the stay?',
                style: GoogleFonts.urbanist(),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (days > 1) {
                                setState(() {
                                  days--;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: days > 1 ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$days ${days == 1 ? 'day' : 'days'}',
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (days < 30) {
                                setState(() {
                                  days++;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color:
                                  days < 30 ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Maximum: 30 days',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.urbanist(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                handleExtendStay(bookingId, days);
              },
              child: Text(
                'Confirm Extension',
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Status dropdown widget with animation
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 10),
      child: SafeArea(
        child: Animate(
          effects: [
            FadeEffect(duration: 300.ms),
            SlideEffect(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
              duration: 300.ms,
            ),
          ],
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'My Bookings',
                    style: GoogleFonts.urbanist(
                      color: AppColors.primary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusDropdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Status dropdown widget with animation
  Widget _buildStatusDropdown() {
    return Container(
      width: 150, // Fixed width to prevent layout issues
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _status,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        style: GoogleFonts.urbanist(fontSize: 14.0, color: AppColors.primary),
        onChanged: (String? newValue) {
          if (newValue != null) {
            handleGetBookings(newValue);
          }
        },
        items:
            BookingStatus.values.map((status) {
              return DropdownMenuItem<String>(
                value: status.toString().split('.').last,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    status.toString().split('.').last.capitalize(),
                    style: GoogleFonts.urbanist(
                      fontSize: 14.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // Error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Animate(
        effects: [FadeEffect(duration: 300.ms), ScaleEffect(duration: 300.ms)],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.danger, size: 80),
            const SizedBox(height: 16),
            Text(
              'Error Loading Bookings',
              style: GoogleFonts.urbanist(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 8.0,
              ),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => handleGetBookings(_status),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyStateWidget() {
    return Center(
      child: Animate(
        effects: [FadeEffect(duration: 300.ms), ScaleEffect(duration: 300.ms)],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[400], size: 80),
            const SizedBox(height: 16),
            Text(
              'No Bookings Found',
              style: GoogleFonts.urbanist(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 8.0,
              ),
              child: Text(
                'You have no bookings in the ${_status.toLowerCase()} status',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => handleGetBookings('pending'),
              child: Text('View Pending Bookings'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions for UI logic
  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icon(Icons.pending_outlined, size: 14);
      case 'confirmed':
        return Icon(Icons.check_circle_outline, size: 14);
      case 'completed':
        return Icon(Icons.task_alt, size: 14);
      case 'cancelled':
        return Icon(Icons.cancel_outlined, size: 14);
      default:
        return Icon(Icons.info_outline, size: 14);
    }
  }

  void _viewDetails(Map<String, dynamic> booking) {
    // Navigate to booking details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: booking),
      ),
    );
  }

  // Animated booking card widget
  Widget _buildAnimatedBookingCard(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final booking = _bookings[index];
    final bool isBoardingType =
        booking['applicationType'].toString().toLowerCase() == 'boarding';

    return SizeTransition(
      sizeFactor: animation,
      child: Animate(
        effects: [
          FadeEffect(duration: 300.ms),
          SlideEffect(
            begin: const Offset(0.5, 0),
            end: Offset.zero,
            duration: 300.ms,
          ),
        ],
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Application Type and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Application Type Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBoardingType
                                ? Icons.hotel
                                : Icons.assignment_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking['applicationType'].toString().toUpperCase(),
                            style: GoogleFonts.urbanist(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 4),
                          Text(
                            _status.capitalize(),
                            style: GoogleFonts.urbanist(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Pet Information
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        booking['pet']["name"].toString(),
                        style: GoogleFonts.urbanist(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Branch Information and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Branch Information
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['branch']["name"].toString(),
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking['branch']["address"].toString(),
                                  style: GoogleFonts.urbanist(
                                    fontSize: 13.0,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "PHP${phpFormatter.format(booking['payable'])}",
                            style: GoogleFonts.urbanist(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Action Buttons
                isBoardingType &&
                        (_status == 'confirmed' || _status == 'pending')
                    ? Row(
                      children: [
                        // View Details Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _viewDetails(booking),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                            ),
                            child: Text(
                              "View Details",
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Extend Stay Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                () => _showExtendStayDialog(booking['_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hotel, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "Extend Stay",
                                  style: GoogleFonts.urbanist(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _viewDetails(booking),
                        child: Text("View Details"),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Use the custom AppBar method
      body: RefreshIndicator(
        onRefresh: () => handleGetBookings(_status),
        child:
            _isLoading
                ? Center(
                  child:
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ).animate().scale(),
                )
                : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _bookings.isEmpty
                ? _buildEmptyStateWidget()
                : AnimatedList(
                  key: _listKey,
                  initialItemCount: _bookings.length,
                  itemBuilder: (context, index, animation) {
                    return _buildAnimatedBookingCard(context, index, animation);
                  },
                ),
      ),
    );
  }
}

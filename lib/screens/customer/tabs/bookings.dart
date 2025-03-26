import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/utils/enums/enum.dart';
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
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => handleGetBookings(_status),
              child: Text(
                'Retry',
                style: GoogleFonts.urbanist(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => handleGetBookings('pending'),
              child: Text(
                'View Pending Bookings',
                style: GoogleFonts.urbanist(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
        child: Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                // Gradient background
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              booking['applicationType']
                                  .toString()
                                  .toUpperCase(),
                              style: GoogleFonts.urbanist(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _status.capitalize(),
                              style: GoogleFonts.urbanist(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(_status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking['pet']["name"].toString().toUpperCase(),
                              style: GoogleFonts.urbanist(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "P${booking['payable']}.00",
                            style: GoogleFonts.rajdhani(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
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
      backgroundColor: AppColors.secondary.withOpacity(0.95),
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

  // ... (rest of the previous methods remain the same)
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

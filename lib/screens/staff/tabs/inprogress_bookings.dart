import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';

class StaffTabInprogressBookings extends StatefulWidget {
  const StaffTabInprogressBookings({super.key});

  @override
  State<StaffTabInprogressBookings> createState() =>
      _StaffTabInprogressBookingsState();
}

class _StaffTabInprogressBookingsState extends State<StaffTabInprogressBookings>
    with SingleTickerProviderStateMixin {
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State management
  String _accessToken = "";
  String _currentStatus = "confirmed";
  List<dynamic> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize animation controllers and animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  /// Initialize data and fetch bookings
  void _initializeData() {
    try {
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );

      _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

      if (_accessToken.isEmpty) {
        setState(() {
          _errorMessage = "Authentication required. Please log in again.";
        });
        return;
      }

      _fetchBookings(_currentStatus);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize. Please try again.";
      });
    }
  }

  /// Fetch bookings from API with proper error handling
  Future<void> _fetchBookings(String status) async {
    if (_accessToken.isEmpty) {
      setState(() {
        _errorMessage = "No access token available";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staffApi = StaffApi(_accessToken);
      final Response<dynamic> response = await staffApi
          .getBookingsByAccessToken(status);

      // Validate response data
      if (response.data == null) {
        throw Exception("No data received from server");
      }

      setState(() {
        _currentStatus = status;
        _bookings = List<dynamic>.from(response.data);
        _isLoading = false;
      });

      // Start animations after successful data load
      _animationController.forward();
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  /// Handle Dio-specific errors with user-friendly messages
  void _handleDioError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = "Connection timeout. Please check your internet.";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "Server is taking too long to respond.";
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = "Authentication failed. Please log in again.";
        } else if (statusCode == 403) {
          errorMessage = "Access denied. Insufficient permissions.";
        } else if (statusCode == 404) {
          errorMessage = "Resource not found.";
        } else {
          errorMessage = "Server error (${statusCode ?? 'Unknown'})";
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "Request was canceled.";
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "Network error. Please check your connection.";
    }

    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
    });
  }

  /// Navigate to appropriate booking detail screen
  void _navigateToBookingDetail(Map<String, dynamic> booking) {
    try {
      final arguments = {
        "application": booking['application'],
        "booking": booking['_id'],
        "pet": booking["pet"],
        "profile": booking["profile"],
      };

      final applicationType =
          booking['applicationType']?.toString().toLowerCase();

      String route;
      switch (applicationType) {
        case "boarding":
          route = "/s/preview-inprogress/boarding";
          break;
        case "transit":
          route = "/s/preview-inprogress/transit";
          break;
        case "grooming":
          route = "/s/preview-inprogress/grooming";
          break;
        default:
          // Handle unknown application types
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unknown booking type: $applicationType"),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
      }

      Navigator.pushNamed(context, route, arguments: arguments);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to open booking details"),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  /// Build individual booking card with animations
  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    // Safely extract booking data with null checks
    final applicationType = booking['applicationType']?.toString() ?? 'Unknown';
    final profile = booking['profile'] as Map<String, dynamic>?;
    final firstName = profile?['firstName']?.toString() ?? '';
    final lastName = profile?['lastName']?.toString() ?? '';
    final fullName = profile?['fullName'].trim();
    final payable = booking['payable'];

    // Calculate display amount (half of payable)
    final displayAmount = payable != null ? (payable ~/ 2) : 0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: () => _navigateToBookingDetail(booking),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Left side content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Application type badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  applicationType.toUpperCase(),
                                  style: GoogleFonts.urbanist(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),

                              // Customer name
                              Text(
                                fullName.isEmpty
                                    ? 'Unknown Customer'
                                    : fullName,
                                style: GoogleFonts.urbanist(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                phpFormatter.format(displayAmount),
                                style: GoogleFonts.rajdhani(
                                  fontSize: 24.0,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Price with currency formatting
                            ],
                          ),
                        ),

                        // Right side arrow with ripple effect
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: IconButton(
                            onPressed: () => _navigateToBookingDetail(booking),
                            icon: const Icon(
                              Ionicons.chevron_forward_outline,
                              color: AppColors.primary,
                              size: 20.0,
                            ),
                            tooltip: 'View booking details',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.calendar_outline,
              size: 64.0,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              "No bookings found",
              style: GoogleFonts.urbanist(
                color: Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Confirmed bookings will appear here",
              style: GoogleFonts.urbanist(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.alert_circle_outline,
              size: 64.0,
              color: AppColors.danger.withOpacity(0.7),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Oops! Something went wrong",
              style: GoogleFonts.urbanist(
                color: AppColors.danger,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage ?? "An unexpected error occurred",
                style: GoogleFonts.urbanist(color: Colors.grey, fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () => _fetchBookings(_currentStatus),
              icon: const Icon(Ionicons.refresh_outline),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16.0),
          Text(
            "Loading bookings...",
            style: TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: RefreshIndicator(
        onRefresh: () => _fetchBookings(_currentStatus),
        color: AppColors.primary,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child:
              _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                  ? _buildErrorState()
                  : _bookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index] as Map<String, dynamic>;
                      return _buildBookingCard(booking, index);
                    },
                  ),
        ),
      ),
    );
  }
}

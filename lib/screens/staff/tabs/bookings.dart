import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/widgets/fade_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:provider/provider.dart';

class StaffTabBookings extends StatefulWidget {
  const StaffTabBookings({super.key});

  @override
  State<StaffTabBookings> createState() => _StaffTabBookingsState();
}

class _StaffTabBookingsState extends State<StaffTabBookings>
    with AutomaticKeepAliveClientMixin {
  // Current filter for bookings status
  late String _status;

  // Store bookings data
  List<dynamic> _bookings = [];

  // Loading and error states
  bool _isLoading = false;
  bool _hasError = false;
  final String _errorMessage = "";

  // Filter options for booking status
  final List<Map<String, dynamic>> _statusFilters = [
    {'value': 'pending', 'label': 'Pending', 'icon': Ionicons.time_outline},
    {
      'value': 'confirmed',
      'label': 'Accepted',
      'icon': Ionicons.checkmark_circle_outline,
    },
    {
      'value': 'declined',
      'label': 'Rejected',
      'icon': Ionicons.close_circle_outline,
    },
    {
      'value': 'done',
      'label': 'Completed',
      'icon': Ionicons.checkmark_circle_outline,
    },
  ];

  /// Keep this tab alive when switching between tabs
  @override
  bool get wantKeepAlive => true;

  /// Update bookings by status
  void updateBookings(String status, List<dynamic> bookings) {
    if (!mounted) return;

    setState(() {
      _status = status;
      _bookings = bookings;
      _isLoading = false;
      _hasError = false;
    });
  }

  /// Handle navigation to detail screen based on application type
  void navigateToBookingDetail(dynamic booking) {
    if (!mounted) return;

    final String applicationType = booking['applicationType'] ?? '';
    final Object arguments = {
      "application": booking['application'],
      "booking": booking['_id'],
      "pet": booking["pet"],
      "profile": booking["profile"],
      "currentStatus": _status,
    };

    switch (applicationType) {
      case "boarding":
        Navigator.pushNamed(
          context,
          "/s/preview/boarding",
          arguments: arguments,
        );
        break;
      case "transit":
        Navigator.pushNamed(
          context,
          "/s/preview/transit",
          arguments: arguments,
        );
        break;
      case "grooming":
        Navigator.pushNamed(
          context,
          "/s/preview/grooming",
          arguments: arguments,
        );
        break;
      default:
        // Show snackbar for unsupported booking types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot preview this booking type: $applicationType'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  Future<void> _fetchBookings({String status = 'pending'}) async {
    String accessToken =
        Provider.of<AuthTokenProvider>(
          context,
          listen: false,
        ).authToken?.accessToken ??
        '';

    final StaffApi staffApi = StaffApi(accessToken);
    final response = await staffApi.getBookingsByAccessToken(status);

    setState(() {
      _bookings = response.data;
    });
  }

  @override
  void initState() {
    super.initState();

    // Show loading state briefly if no bookings provided
    if (_bookings.isEmpty) {
      _isLoading = true;
      // Simulate loading for better UX
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    _status = 'pending';
    _fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: ValueKey(
        '${_status}_${_bookings.length}',
      ), // Force rebuild when data changes
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildBookingsList()),
        ],
      ),
      // Add a refresh button to enhance UX
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulate refresh for better UX
          setState(() {
            _isLoading = true;
          });

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  /// Build custom app bar

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build filter chips for booking status
  Widget _buildStatusFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _statusFilters.map((filter) {
                final bool isSelected = _status == filter['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Row(
                      children: [
                        Icon(
                          filter['icon'],
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filter['label'],
                          style: GoogleFonts.urbanist(
                            color:
                                isSelected ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary,
                    onSelected: (_) {
                      setState(() {
                        _status = filter['value'];
                        _isLoading = true;
                      });

                      // Simulate loading for status change
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      });

                      _fetchBookings(status: filter['value']);
                    },
                    elevation: 0,
                    pressElevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Colors.transparent
                                : AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  /// Build the main bookings list or appropriate placeholder
  Widget _buildBookingsList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_bookings.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          return AnimatedSlideAndFadeTransition(
            key: ValueKey(_bookings[index]['_id'] ?? index.toString()),
            delay: Duration(milliseconds: 25 * (index % 10)),
            child: _buildBookingCard(_bookings[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading bookings...",
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait while we fetch your data",
            style: GoogleFonts.urbanist(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Build error state widget with visual enhancements
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.alert_circle_outline,
                size: 48,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : "We couldn't load your bookings at this time",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate refresh for better UX
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });

                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                });
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                "Try Again",
                style: GoogleFonts.urbanist(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build visually appealing empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.calendar_outline,
              size: 72,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "No ${_status.toLowerCase()} bookings found",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "There are no bookings in this category at the moment. Try checking other booking statuses.",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              // Find the first non-current filter and select it
              final nextFilter = _statusFilters.firstWhere(
                (filter) => filter['value'] != _status,
                orElse: () => _statusFilters.first,
              );

              setState(() {
                // Simulate refresh for better UX
                _status = nextFilter['value'];
                _isLoading = true;
              });

              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            },
            icon: const Icon(Ionicons.swap_horizontal_outline),
            label: const Text("Try another status"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single booking card with improved visuals
  Widget _buildBookingCard(dynamic booking) {
    // Extract booking data with null safety
    final String applicationType =
        booking['applicationType']?.toString() ?? 'Unknown';

    final String fullName =
        booking['profile']?['fullName']?.toString() ?? 'Unknown User';
    final int payable = (booking['payable'] ?? 0) ~/ 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => navigateToBookingDetail(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Left colored indicator based on application type
                  Container(
                    width: 6,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getApplicationTypeColor(applicationType),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Booking details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getApplicationTypeColor(
                            applicationType,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          applicationType.toUpperCase(),
                          style: GoogleFonts.urbanist(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: _getApplicationTypeColor(applicationType),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        fullName.isEmpty
                            ? "Unknown Client"
                            : fullName.toUpperCase(),
                        style: GoogleFonts.urbanist(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Ionicons.wallet_outline,
                            size: 12,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "PHP ${payable.toStringAsFixed(2)}",
                            style: GoogleFonts.rajdhani(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // View button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => navigateToBookingDetail(booking),
                  icon: const Icon(
                    Ionicons.chevron_forward_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  tooltip: 'View details',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color based on application type for visual differentiation
  Color _getApplicationTypeColor(String applicationType) {
    switch (applicationType.toLowerCase()) {
      case 'boarding':
        return Colors.blue;
      case 'transit':
        return Colors.purple;
      case 'grooming':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }
}

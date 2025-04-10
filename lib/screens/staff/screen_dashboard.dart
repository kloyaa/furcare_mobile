import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/apis/fees_api.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/fees.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/staff/tabs/bookings.dart';
import 'package:furcare_app/screens/staff/tabs/inprogress_bookings.dart';
import 'package:furcare_app/screens/staff/tabs/settings.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain>
    with SingleTickerProviderStateMixin {
  // Current selected tab index
  int _currentIndex = 0;
  // Store access token for API calls
  String _accessToken = "";
  // Animation controller for tab transitions
  late AnimationController _animationController;
  // Flag to track if data is being loaded
  bool _isLoading = true;
  // Flag to track if there was an error fetching data
  bool _hasError = false;
  // Error message to display if there's an error
  String _errorMessage = "";

  late List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for tab transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize all data needed for the dashboard
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Get access token from provider
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );
      _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

      // Check if token is available
      if (_accessToken.isEmpty) {
        throw Exception("No access token available");
      }

      // Fetch all required data in parallel
      // await Future.wait([_fetchProfile(), _fetchPets(), _fetchServiceFees()]);

      // await _fetchPets();
      // await _fetchServiceFees();
    } catch (e) {
      print(e);
      setState(() {
        _hasError = true;
        _errorMessage = "Failed to load data: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Method to retry loading data if there was an error
  void _retryLoading() {
    _initializeData();
  }

  /// Handle tab change with animation
  void _handleTabChange(int index) {
    _animationController.reset();
    _animationController.forward();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      // Show loading spinner or error message if needed
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StaffTabBookings(),
          StaffTabInprogressBookings(),
          StaffTabSettings(),
        ],
      ),
      // Keep bottom navigation bar consistent
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Build loading state with spinner and text
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.pink),
          const SizedBox(height: 16),
          Text(
            "Loading your dashboard...",
            style: GoogleFonts.urbanist(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.pink[300]),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong",
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh),
              label: Text("Try Again", style: GoogleFonts.urbanist()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
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

  // /// Build the main content with tab views
  // Widget _buildContent() {
  //   return FadeTransition(
  //     opacity: _animationController,
  //     child: ,
  //   );
  // }

  /// Build the custom bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SalomonBottomBar(
          margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 12.0),
          currentIndex: _currentIndex,
          onTap: _handleTabChange,
          items: [
            _buildNavBarItem(
              icon: Icons.book_outlined,
              title: "Bookings",
              color: Colors.pink,
            ),
            _buildNavBarItem(
              icon: Ionicons.sync_outline,
              title: "In Progress",
              color: Colors.pink,
            ),
            _buildNavBarItem(
              icon: Ionicons.settings_outline,
              title: "Settings",
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build navigation bar items with consistent styling
  SalomonBottomBarItem _buildNavBarItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return SalomonBottomBarItem(
      icon: Icon(icon, size: 20.0),
      title: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      selectedColor: color,
      unselectedColor: Colors.grey[400],
    );
  }
}

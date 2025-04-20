import 'package:flutter/material.dart';
import 'package:furcare_app/screens/staff/tabs/bookings.dart';
import 'package:furcare_app/screens/staff/tabs/inprogress_bookings.dart';
import 'package:furcare_app/screens/staff/tabs/settings.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for tab transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

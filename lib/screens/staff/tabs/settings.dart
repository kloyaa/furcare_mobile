import 'package:flutter/material.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:furcare_app/utils/const/colors.dart';

class StaffTabSettings extends StatefulWidget {
  const StaffTabSettings({super.key});

  @override
  State<StaffTabSettings> createState() => _StaffTabSettingsState();
}

class _StaffTabSettingsState extends State<StaffTabSettings>
    with SingleTickerProviderStateMixin {
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize animation controllers and animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations
    _animationController.forward();
  }

  /// Handle profile navigation with error handling
  void _navigateToProfile() {
    try {
      Navigator.pushNamed(context, '/s/edit/profile/1');
    } catch (e) {
      _showErrorSnackBar('Failed to open profile settings');
    }
  }

  /// Handle activity log navigation with error handling
  void _navigateToActivityLog() {
    try {
      Navigator.pushNamed(context, '/c/activity');
    } catch (e) {
      _showErrorSnackBar('Failed to open activity log');
    }
  }

  /// Handle logout with confirmation dialog
  Future<void> _handleLogout() async {
    try {
      final shouldLogout = await _showLogoutConfirmationDialog();
      if (shouldLogout == true) {
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
          );
        }

        // Simulate logout process (replace with actual logout logic)
        await Future.delayed(const Duration(seconds: 1));

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
          // Navigate to auth screen
          redirectOnConfirm(context, path: "/auth/staff");
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Logout failed. Please try again.');
    }
  }

  /// Show logout confirmation dialog
  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(
                Ionicons.warning_outline,
                color: AppColors.danger,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Text(
                'Confirm Logout',
                style: GoogleFonts.urbanist(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: GoogleFonts.urbanist(
              fontSize: 14.0,
              color: AppColors.primary.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.urbanist(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.urbanist(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.all(16.0),
        ),
      );
    }
  }

  /// Build animated settings card
  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDangerous = false,
    int animationDelay = 0,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              animationDelay * 0.1,
              0.8 + (animationDelay * 0.1),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return FadeTransition(
          opacity: delayedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(delayedAnimation),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Icon container with background
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: (iconColor ?? AppColors.primary).withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? AppColors.primary,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.urbanist(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDangerous
                                          ? AppColors.danger
                                          : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                subtitle,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.0,
                                  color: AppColors.primary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        Icon(
                          Ionicons.chevron_forward_outline,
                          color: AppColors.primary.withOpacity(0.4),
                          size: 20.0,
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

  /// Build header section
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.urbanist(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Manage your account and preferences',
                    style: GoogleFonts.urbanist(
                      fontSize: 14.0,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build settings sections
  Widget _buildSettingsSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Section
        _buildSectionHeader('Account', animationDelay: 1),
        _buildSettingsCard(
          icon: Ionicons.person_outline,
          title: 'Profile',
          subtitle: 'Change your basic info and more',
          onTap: _navigateToProfile,
          animationDelay: 2,
        ),
        _buildSettingsCard(
          icon: Ionicons.list_outline,
          title: 'Activity Log',
          subtitle: 'See your furcare activities',
          onTap: _navigateToActivityLog,
          animationDelay: 3,
        ),

        const SizedBox(height: 32.0),

        // Danger Zone Section
        _buildSectionHeader('Account Actions', animationDelay: 4),
        _buildSettingsCard(
          icon: Ionicons.log_out_outline,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: _handleLogout,
          iconColor: AppColors.danger,
          isDangerous: true,
          animationDelay: 5,
        ),
      ],
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title, {int animationDelay = 0}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              animationDelay * 0.1,
              0.8 + (animationDelay * 0.1),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return FadeTransition(
          opacity: delayedAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0, left: 4.0),
            child: Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSettingsSections(),

                // Bottom spacing
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

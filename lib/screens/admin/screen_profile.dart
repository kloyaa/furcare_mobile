import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/admin_profile.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
// AdminProfile screen - Displays administrator information with responsive layout
// Features enhanced UI, smooth animations, and better state management

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile>
    with SingleTickerProviderStateMixin {
  // State variables
  String _accessToken = '';
  AdminProfileModel? _adminProfileModel;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Navigation items for the top menu
  final List<Map<String, dynamic>> _navItems = [
    {
      'title': 'Profile',
      'isActive': true,
      'route': null, // Current page
    },
    {
      'title': 'Reports',
      'isActive': false,
      'isDropdown': true,
      'items': [
        {'title': 'Check ins', 'route': '/a/report/checkins'},
        {'title': 'Service usages', 'route': '/a/report/service-usage'},
        {'title': 'Transactions', 'route': '/a/report/transactions'},
      ],
    },
    {'title': 'Staffs', 'isActive': false, 'route': '/a/management/staff'},
    {
      'title': 'Users and Pets',
      'isActive': false,
      'route': '/a/management/customers',
    },
  ];

  /// Fetches the admin profile data from the API
  Future<void> _fetchProfileData() async {
    if (_accessToken.isEmpty) {
      setState(() {
        _errorMessage = "Authentication token not found";
        _isLoading = false;
      });
      return;
    }

    try {
      ClientApi clientApi = ClientApi(_accessToken);
      final profileData = await clientApi.getMeProfile();
      final profile = AdminProfileModel.fromJson(profileData.data);

      // Add a slight delay for animation purposes
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _adminProfileModel = profile;
        _isLoading = false;
      });

      // Start entrance animation after data is loaded
      _animationController.forward();
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?["message"] ?? "Failed to load profile data";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred";
        _isLoading = false;
      });
    }
  }

  /// Handles user sign out with confirmation
  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Sign Out",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to sign out?",
            style: GoogleFonts.urbanist(color: AppColors.primary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: GoogleFonts.urbanist(
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear auth token and navigate to login
                // Provider.of<AuthTokenProvider>(
                //   context,
                //   listen: false,
                // ).clearAuthToken();
                Navigator.pop(dialogContext);
                Navigator.pushReplacementNamed(context, '/auth/admin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text("Sign Out", style: GoogleFonts.urbanist()),
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

    // Configure animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Get auth token and fetch profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );

      _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
      _fetchProfileData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  /// Builds the app bar with navigation menu
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      leading: const SizedBox(),
      leadingWidth: 0,
      actions: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Navigation items
                ...List.generate(_navItems.length, (index) {
                  final navItem = _navItems[index];

                  // Dropdown menu
                  if (navItem['isDropdown'] == true) {
                    return _buildDropdownNavItem(navItem);
                  }

                  // Regular menu item
                  return _buildNavItem(navItem);
                }),

                const Spacer(),

                // Sign out button
                _buildSignOutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a regular navigation item
  Widget _buildNavItem(Map<String, dynamic> navItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: () {
          if (navItem['route'] != null) {
            Navigator.pushReplacementNamed(context, navItem['route']);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 12.0,
              fontWeight:
                  navItem['isActive'] ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(navItem['title']),
          ),
        ),
      ),
    );
  }

  /// Builds a dropdown navigation item
  Widget _buildDropdownNavItem(Map<String, dynamic> navItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.grey, width: 0.1),
        ),
        tooltip: "Click to view ${navItem['title']}",
        color: Colors.white,
        elevation: 3,
        position: PopupMenuPosition.under,
        child: Row(
          children: [
            Text(
              navItem['title'],
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
        itemBuilder: (BuildContext context) {
          return List.generate(
            navItem['items'].length,
            (index) => PopupMenuItem<String>(
              value: navItem['items'][index]['route'],
              child: Text(
                navItem['items'][index]['title'],
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 12.0,
                ),
              ),
            ),
          );
        },
        onSelected: (String route) {
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }

  /// Builds the sign out button
  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => _handleSignOut(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Sign out",
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(width: 4.0),
              const Icon(
                Ionicons.log_out_outline,
                size: 12.0,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the loading state UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading profile...",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error state UI
  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              "Error Loading Profile",
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                color: AppColors.primary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchProfileData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Try Again", style: GoogleFonts.urbanist()),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main profile content
  Widget _buildProfileContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel with avatar and role
            Expanded(child: _buildProfileSidebar()),
            const SizedBox(width: 20.0),
            // Right panel with personal info
            Expanded(flex: 2, child: _buildProfileDetails()),
          ],
        ),
      ),
    );
  }

  /// Builds the profile sidebar with avatar and role
  Widget _buildProfileSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Profile avatar with hover effect
          _buildProfileAvatar(),
          const SizedBox(height: 20.0),
          // Role badge
          _buildRoleBadge(),
          const SizedBox(height: 8),
          // Role title
          Text(
            "Administrator",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          _buildProfileQuickActions(),
        ],
      ),
    );
  }

  /// Builds the profile avatar with animation
  Widget _buildProfileAvatar() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 1.05),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(value),
              transformAlignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Image.asset(
                    "assets/avatar_male.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the role badge with animation
  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Role",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 5),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14,
                child: const Icon(
                  Ionicons.shield_checkmark_outline,
                  size: 18.0,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds quick action buttons for the profile
  Widget _buildProfileQuickActions() {
    // List of quick actions
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.edit, 'label': 'Edit Profile'},
      {'icon': Icons.settings, 'label': 'Settings'},
      {'icon': Icons.security, 'label': 'Security'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                  icon: Icon(action['icon'], size: 16),
                  label: Text(
                    action['label'],
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// Builds the profile details section
  Widget _buildProfileDetails() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Greeting section
          _buildGreetingSection(),
          const SizedBox(height: 30.0),

          // Personal information section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Right column (Email, Mobile)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      label: "Email",
                      icon: Icons.email_outlined,
                      value:
                          _adminProfileModel?.contact['email'] ??
                          "Not provided",
                      isLarge: true,
                    ),
                    const SizedBox(height: 20.0),
                    _buildInfoItem(
                      label: "Mobile No.",
                      icon: Icons.phone_outlined,
                      value:
                          _adminProfileModel?.contact['number'] ??
                          "Not provided",
                      isLarge: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30.0),
            child: Divider(
              color: AppColors.primary.withOpacity(0.2),
              height: 1,
            ),
          ),

          // Address section
          _buildInfoItem(
            label: "Address",
            icon: Icons.location_on_outlined,
            value: _adminProfileModel?.address ?? "Not provided",
            isLarge: true,
          ),

          const SizedBox(height: 30.0),

          // Activity section
          _buildActivitySection(),
        ],
      ),
    );
  }

  /// Builds the greeting section with animated title
  Widget _buildGreetingSection() {
    final String name = _adminProfileModel?.fullName ?? "Admin";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Hi! ",
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 40.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.9, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: GoogleFonts.urbanist(
                        color: AppColors.primary,
                        fontSize: 40.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Welcome back to your dashboard",
          style: GoogleFonts.urbanist(
            color: AppColors.primary.withOpacity(0.7),
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  /// Builds an info item with icon
  Widget _buildInfoItem({
    required String label,
    required IconData icon,
    required String value,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 5),
            Icon(icon, size: 18.0, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: isLarge ? 20.0 : 16.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Builds the recent activity section
  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Activity",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Activity tracking will be available in the next update",
                  style: GoogleFonts.urbanist(
                    color: AppColors.primary,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

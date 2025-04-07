import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/models/active_status.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AdminStaffManagement extends StatefulWidget {
  const AdminStaffManagement({super.key});

  @override
  State<AdminStaffManagement> createState() => _AdminStaffManagementState();
}

class _AdminStaffManagementState extends State<AdminStaffManagement>
    with SingleTickerProviderStateMixin {
  // State variables
  String _accessToken = "";
  late Future<List<dynamic>> _staffsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<dynamic> _filteredStaffs = [];
  bool _isLoading = false;

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

    // Get access token from provider
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    // Initialize data and start animation
    _fetchStaffs();
    _animationController.forward();

    // Add listener for search functionality
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Search functionality
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Filter staff list based on search query
  List<dynamic> _getFilteredStaffs(List<dynamic>? staffs) {
    if (staffs == null) return [];
    if (_searchQuery.isEmpty) return staffs;

    return staffs.where((staff) {
      final name = staff['profile']['fullName']?.toString().toLowerCase() ?? '';
      final email = staff['email']?.toString().toLowerCase() ?? '';
      final username = staff['username']?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          username.contains(_searchQuery);
    }).toList();
  }

  // Fetch staff data from API
  Future<void> _fetchStaffs() async {
    setState(() => _isLoading = true);
    try {
      _staffsFuture = handleGetStaffs();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // API call to get staff list
  Future<List<dynamic>> handleGetStaffs() async {
    AdminApi adminApi = AdminApi(_accessToken);
    Response<dynamic> response = await adminApi.getStaffs();
    return response.data.toList();
  }

  // Update staff active status
  Future<void> handleUpdateActiveStatus(UpdateActiveStatus payload) async {
    AdminApi adminApi = AdminApi(_accessToken);

    try {
      await adminApi.updateProfileActiveStatus(payload);
      if (context.mounted) {
        _showFeedback("Status updated successfully!", isSuccess: true);
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        _showFeedback(errorResponse.message);
      }
    }
  }

  // Delete user
  Future<void> handleDeleteUser(String id) async {
    // Show confirmation dialog before deletion
    final shouldDelete = await _showDeleteConfirmation();
    if (shouldDelete != true) return;

    setState(() => _isLoading = true);
    AdminApi adminApi = AdminApi(_accessToken);

    try {
      await adminApi.deleteUser(id);
      if (context.mounted) {
        _showFeedback("Deleted successfully!", isSuccess: true);
      }
      // Refresh staff list
      _fetchStaffs();
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        _showFeedback(errorResponse.message);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show feedback to user
  void _showFeedback(String message, {bool isSuccess = false}) {
    showSnackBar(
      context,
      message,
      color: isSuccess ? Colors.green : AppColors.danger,
      fontSize: 14.0,
      duration: isSuccess ? 1 : 3,
    );
  }

  // Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Deletion',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this staff member? This action cannot be undone.',
              style: GoogleFonts.urbanist(color: AppColors.primary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.urbanist(color: AppColors.primary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.urbanist(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1100;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(isWideScreen),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.all(20.0),
            width: isWideScreen ? screenWidth * 0.7 : screenWidth * 0.95,
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                Expanded(child: _buildStaffList()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushReplacementNamed(
              context,
              "/a/management/staff/enrollment",
            ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  // Build app bar with navigation items
  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: const SizedBox(),
      leadingWidth: 0,
      elevation: 2,
      title:
          isWideScreen
              ? _buildDesktopNavItems()
              : Text(
                'Staff Management',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      actions:
          isWideScreen
              ? null
              : [
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu, color: AppColors.primary),
                  onSelected: _handleMenuSelection,
                  itemBuilder:
                      (context) => [
                        _buildMenuItem('Profile', 'profile'),
                        _buildMenuItem('Reports', 'reports'),
                        _buildMenuItem('Users and Pets', 'users'),
                        _buildMenuItem('Enroll Staff', 'enroll'),
                        _buildMenuItem('Sign out', 'signout'),
                      ],
                ),
              ],
    );
  }

  // Build desktop navigation items
  Widget _buildDesktopNavItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavItem('Profile', () => _navigateTo('/a/profile')),
        const SizedBox(width: 25.0),
        _buildReportsDropdown(),
        const SizedBox(width: 25.0),
        _buildNavItem('Staffs', () {}, isCurrent: true),
        const SizedBox(width: 25.0),
        _buildNavItem(
          'Users and Pets',
          () => _navigateTo('/a/management/customers'),
        ),
        const Spacer(),
        _buildNavItem('Sign out', () => _navigateTo('/')),
      ],
    );
  }

  // Build individual navigation item
  Widget _buildNavItem(
    String title,
    VoidCallback onTap, {
    bool isCurrent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          title,
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  // Build reports dropdown
  Widget _buildReportsDropdown() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: const BorderSide(color: Colors.grey, width: 0.1),
      ),
      tooltip: "Click to view",
      color: Colors.white,
      elevation: 3,
      position: PopupMenuPosition.under,
      child: Text(
        "Reports",
        style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
      ),
      itemBuilder:
          (BuildContext context) => [
            _buildMenuItem('Check ins', 'check_ins'),
            _buildMenuItem('Service usages', 'service_usages'),
            _buildMenuItem('Transactions', 'transactions'),
          ],
      onSelected: (value) {
        String route = '/';
        switch (value) {
          case 'check_ins':
            route = "/a/report/checkins";
            break;
          case 'service_usages':
            route = "/a/report/service-usage";
            break;
          case 'transactions':
            route = "/a/report/transactions";
            break;
        }
        _navigateTo(route);
      },
    );
  }

  // Build menu item for dropdown or popup menu
  PopupMenuItem<String> _buildMenuItem(String title, String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        title,
        style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
      ),
    );
  }

  // Handle menu selection for mobile view
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        _navigateTo('/a/profile');
        break;
      case 'reports':
        // Show reports submenu
        break;
      case 'users':
        _navigateTo('/a/management/customers');
        break;
      case 'enroll':
        _navigateTo('/a/management/staff/enrollment');
        break;
      case 'signout':
        _navigateTo('/');
        break;
    }
  }

  // Navigate to a route with replacement
  void _navigateTo(String route, {Map<String, dynamic>? arguments}) {
    Navigator.pushReplacementNamed(context, route, arguments: arguments);
  }

  // Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search staff by name, email or username...",
          hintStyle: GoogleFonts.urbanist(
            color: AppColors.primary.withOpacity(0.5),
            fontSize: 14.0,
          ),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.primary),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  // Build staff list
  Widget _buildStaffList() {
    return FutureBuilder<List<dynamic>>(
      future: _staffsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyWidget();
        } else {
          // Filter staff list based on search query
          _filteredStaffs = _getFilteredStaffs(snapshot.data);

          if (_filteredStaffs.isEmpty) {
            return Center(
              child: Text(
                'No matching staff found',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 16.0,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: _filteredStaffs.length,
            itemBuilder: (context, index) {
              // Add staggered animation for list items
              return AnimatedOpacity(
                duration: Duration(milliseconds: 300 + (index * 100)),
                opacity: 1.0,
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  transform: Matrix4.translationValues(0, 0, 0)
                    ..translate(0.0, index * 5.0, 0.0),
                  child: _buildStaffCard(_filteredStaffs[index]),
                ),
              );
            },
          );
        }
      },
    );
  }

  // Build error widget
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.danger, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading staff data',
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.urbanist(
              color: AppColors.primary.withOpacity(0.7),
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchStaffs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('Try Again', style: GoogleFonts.urbanist()),
          ),
        ],
      ),
    );
  }

  // Build empty state widget
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          Text(
            'No staff members found',
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add staff members by clicking the "+" button',
            style: GoogleFonts.urbanist(
              color: AppColors.primary.withOpacity(0.7),
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateTo('/a/management/staff/enrollment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('Add Staff', style: GoogleFonts.urbanist()),
          ),
        ],
      ),
    );
  }

  // Build individual staff card
  Widget _buildStaffCard(dynamic staff) {
    // Extract staff data
    final bool isActive = staff['profile']['isActive'];
    final String fullName = staff['profile']['fullName'];
    final String email = staff['email'];
    final String username = staff['username'];
    final String contactEmail = staff['profile']['contact']['email'];
    final String contactNumber = staff['profile']['contact']['number'];
    final String address = staff['profile']['address'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isActive ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          'assets/avatar_male.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ToggleSwitch(
                      initialLabelIndex: isActive ? 0 : 1,
                      totalSwitches: 2,
                      activeBgColors: const [
                        [Colors.green],
                        [Colors.pink],
                      ],
                      inactiveBgColor: Colors.grey.shade200,
                      customTextStyles: [GoogleFonts.urbanist(fontSize: 12.0)],
                      minHeight: 30.0,
                      labels: const ['Active', 'Inactive'],
                      onToggle: (index) {
                        handleUpdateActiveStatus(
                          UpdateActiveStatus(
                            isActive: index == 0,
                            user: staff['_id'],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Staff details section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildSectionHeader('Profile'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            fullName,
                            style: GoogleFonts.urbanist(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          _buildActionButtons(staff),
                        ],
                      ),
                      const Divider(height: 24),

                      // Build information rows
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          // Account info
                          _buildInfoSection('Account', [
                            _buildInfoItem('Username', username),
                            _buildInfoItem('Email', email),
                          ]),

                          // Contact info
                          _buildInfoSection('Contact', [
                            _buildInfoItem('Email', contactEmail),
                            _buildInfoItem('Mobile No.', contactNumber),
                          ]),

                          // Address info
                          _buildInfoSection('Address', [
                            _buildInfoItem('Address', address),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Build information section
  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  // Build information item
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 10,
            color: AppColors.primary.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // Build action buttons
  Widget _buildActionButtons(dynamic staff) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed:
              () => _navigateTo(
                "/a/management/staff/edit",
                // Pass user data as arguments
                arguments: staff,
              ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(Icons.edit, size: 16),
          label: Text('Edit', style: GoogleFonts.urbanist(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => handleDeleteUser(staff['_id']),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(Ionicons.trash_bin_outline, size: 16),
          label: Text('Delete', style: GoogleFonts.urbanist(fontSize: 12)),
        ),
      ],
    );
  }
}

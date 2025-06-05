import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/models/active_status.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AdminCustomerManagement extends StatefulWidget {
  const AdminCustomerManagement({super.key});

  @override
  State<AdminCustomerManagement> createState() =>
      _AdminCustomerManagementState();
}

class _AdminCustomerManagementState extends State<AdminCustomerManagement>
    with SingleTickerProviderStateMixin {
  // State variables
  String _accessToken = "";
  bool _isLoading = false;
  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    // Initialize search controller
    _searchController.addListener(_onSearchChanged);

    // Initialize data
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Handle search text changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _filterCustomers();
    });
  }

  /// Filter customers based on search query
  /// Filter customers based on search query
  void _filterCustomers() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers =
          _customers.where((customer) {
            final fullName =
                customer['profile']?['fullName']?.toString().toLowerCase() ??
                '';
            final username =
                customer['username']?.toString().toLowerCase() ?? '';
            final email = customer['email']?.toString().toLowerCase() ?? '';

            return fullName.contains(_searchQuery) ||
                username.contains(_searchQuery) ||
                email.contains(_searchQuery);
          }).toList();
    }
  }

  /// Initialize data and load customers
  Future<void> _initializeData() async {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    // Load customer data
    await _loadCustomers();

    // Start animation after data is loaded
    _animationController.forward();
  }

  /// Load customer data from API
  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final customers = await _fetchCustomers();
      setState(() {
        _customers = customers;
        // Initialize filtered list with all customers
        _filteredCustomers = List.from(customers);
        _isLoading = false;
      });

      // Start animation after data is loaded
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        showSnackBar(
          context,
          "Failed to load customers: ${e.toString()}",
          color: AppColors.danger,
          fontSize: 14.0,
        );
      }
    }
  }

  /// Fetch customers from API
  Future<List<dynamic>> _fetchCustomers() async {
    AdminApi adminApi = AdminApi(_accessToken);
    Response<dynamic> response = await adminApi.getCustomers();
    return response.data.toList();
  }

  /// Handle updating user active status
  Future<void> _handleUpdateActiveStatus(UpdateActiveStatus payload) async {
    setState(() => _isLoading = true);

    AdminApi adminApi = AdminApi(_accessToken);

    try {
      UpdateActiveStatus update = UpdateActiveStatus(
        isActive: payload.isActive,
        user: payload.user,
      );
      await adminApi.updateProfileActiveStatus(update);

      // Refresh customer list after update
      await _loadCustomers();

      if (context.mounted) {
        showSnackBar(
          context,
          "Status updated successfully!",
          color: Colors.green,
          fontSize: 14.0,
          duration: 1,
        );
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 14.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

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

  /// Build app bar with navigation links
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.20,
              ),
              child: Row(
                children: [
                  _buildNavLink("Profile", "/a/profile"),
                  const SizedBox(width: 25.0),
                  _buildReportsMenu(),
                  const SizedBox(width: 25.0),
                  _buildNavLink("Staffs", "/a/management/staff"),
                  const SizedBox(width: 25.0),
                  _buildNavLink("Users and Pets", "/a/management/customers"),
                  const Spacer(),
                  _buildSignOutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main body content
  Widget _buildBody() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width * 0.80,
        child: Column(
          children: [
            // Add search bar at the top
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredCustomers.isEmpty
                      ? _buildEmptyState()
                      : _buildCustomerList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget - shows different message based on search results
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No customers available'
                : 'No results found for "$_searchQuery"',
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: Text(
                'Clear search',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build customer list with animations
  Widget _buildCustomerList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          // Add staggered animation for list items
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(bottom: 10.0, top: index == 0 ? 10.0 : 0.0),
            child: _buildCustomerCard(_filteredCustomers[index], index),
          );
        },
      ),
    );
  }

  /// Build individual customer card
  Widget _buildCustomerCard(dynamic customer, int index) {
    final bool isActive = customer['profile']?['isActive'] ?? false;
    final List pets = customer['pets'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            _buildUserProfile(customer, isActive),
            const SizedBox(width: 40.0),

            // User details section
            Expanded(flex: 3, child: _buildUserDetails(customer)),

            // Pets section
            Expanded(flex: 2, child: _buildPetsList(pets)),
          ],
        ),
      ),
    );
  }

  /// Build user profile section with avatar and status toggle
  Widget _buildUserProfile(dynamic customer, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with hover effect
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.green : Colors.grey,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade200,
              child: Image.asset(
                'assets/avatar_male.png',
                height: 70,
                width: 70,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Status toggle switch
        ToggleSwitch(
          initialLabelIndex: isActive ? 0 : 1,
          totalSwitches: 2,
          activeBgColors: const [
            [Colors.green],
            [Colors.pink],
          ],
          inactiveBgColor: Colors.grey.shade200,
          customTextStyles: [
            GoogleFonts.urbanist(fontSize: 12.0, fontWeight: FontWeight.w600),
          ],
          minHeight: 30.0,
          labels: const ['Active', 'Inactive'],
          onToggle: (index) {
            _handleUpdateActiveStatus(
              UpdateActiveStatus(isActive: index == 0, user: customer['_id']),
            );
          },
        ),
      ],
    );
  }

  /// Build user details section (profile, account, contact, address)
  Widget _buildUserDetails(dynamic customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section
        _buildSectionTitle("Profile"),
        const SizedBox(height: 10.0),
        _buildInfoRow(
          label: "Full name",
          value: customer['profile']?['fullName'] ?? 'N/A',
          valueSize: 18.0,
        ),
        const SizedBox(height: 20.0),

        // Account section
        _buildSectionTitle("Account"),
        const SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                label: "Username",
                value: customer['username'] ?? 'N/A',
              ),
            ),
            Expanded(
              child: _buildInfoRow(
                label: "Email",
                value: customer['email'] ?? 'N/A',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),

        // Contact section
        _buildSectionTitle("Contact"),
        const SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                label: "Email",
                value: customer['profile']?['contact']?['email'] ?? 'N/A',
              ),
            ),
            Expanded(
              child: _buildInfoRow(
                label: "Mobile No.",
                value: customer['profile']?['contact']?['number'] ?? 'N/A',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),

        // Address section
        _buildSectionTitle("Address"),
        const SizedBox(height: 10.0),
        _buildInfoRow(
          label: "Present",
          value: customer['profile']?['address'] ?? 'N/A',
        ),
      ],
    );
  }

  /// Build pets list section
  Widget _buildPetsList(List pets) {
    // Section title for pets
    Widget title = _buildSectionTitle("Pets");

    if (pets.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 20),
          Text(
            "No pets registered",
            style: GoogleFonts.urbanist(
              fontSize: 14.0,
              color: AppColors.primary.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 12),
        ListView.builder(
          itemCount: pets.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final pet = pets[index];
            return _buildPetCard(pet, index);
          },
        ),
      ],
    );
  }

  /// Build individual pet card
  Widget _buildPetCard(dynamic pet, int index) {
    // Map pet type to appropriate icon
    IconData petIcon;
    switch (pet['type']?.toString().toLowerCase() ?? 'dog') {
      case 'cat':
        petIcon = Icons.pets;
        break;
      case 'bird':
        petIcon = Icons.flutter_dash;
        break;
      default:
        petIcon = Icons.pets;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      color: Colors.purple.withOpacity(0.04),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Pet icon
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(petIcon, color: AppColors.primary),
            ),
            const SizedBox(width: 16.0),

            // Pet details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: GoogleFonts.urbanist(
                              fontSize: 10.0,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            pet['name'] ?? 'N/A',
                            style: GoogleFonts.sunshiney(
                              fontSize: 18.0,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            style: GoogleFonts.urbanist(
                              fontSize: 10.0,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                pet['gender']?.toString().toLowerCase() ==
                                        'female'
                                    ? Icons.female
                                    : Icons.male,
                                size: 14,
                                color:
                                    pet['gender']?.toString().toLowerCase() ==
                                            'female'
                                        ? Colors.pink
                                        : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pet['gender'] ?? 'N/A',
                                style: GoogleFonts.sunshiney(
                                  fontSize: 18.0,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Additional pet details if available
                  if (pet['breed'] != null || pet['age'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          if (pet['breed'] != null)
                            Expanded(
                              child: _buildInfoRow(
                                label: "Specie",
                                value: pet['breed'],
                                valueSize: 12.0,
                              ),
                            ),
                          if (pet['age'] != null)
                            Expanded(
                              child: _buildInfoRow(
                                label: "Age",
                                value: "${pet['age']} years",
                                valueSize: 12.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build section title with consistent styling
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.urbanist(
        fontSize: 12.0,
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Build info row with label and value
  Widget _buildInfoRow({
    required String label,
    required String value,
    double valueSize = 14.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 10.0,
            color: AppColors.primary.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: valueSize,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build navigation link with hover effect
  Widget _buildNavLink(String title, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          title,
          style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
        ),
      ),
    );
  }

  /// Build reports dropdown menu
  Widget _buildReportsMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.grey, width: 0.1),
      ),
      tooltip: "Click to view",
      color: Colors.white,
      elevation: 3,
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reports",
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
          ],
        ),
      ),
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            _buildReportMenuItem('check_ins', 'Check ins'),
            _buildReportMenuItem('service_usages', 'Service usages'),
            _buildReportMenuItem('transactions', 'Transactions'),
          ],
      onSelected: (String value) {
        switch (value) {
          case 'check_ins':
            Navigator.pushReplacementNamed(context, "/a/report/checkins");
            break;
          case 'service_usages':
            Navigator.pushReplacementNamed(context, "/a/report/service-usage");
            break;
          case 'transactions':
            Navigator.pushReplacementNamed(context, "/a/report/transactions");
            break;
        }
      },
    );
  }

  /// Build report menu item
  PopupMenuItem<String> _buildReportMenuItem(String value, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(_getReportIcon(value), size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Get appropriate icon for report type
  IconData _getReportIcon(String reportType) {
    switch (reportType) {
      case 'check_ins':
        return Icons.login;
      case 'service_usages':
        return Icons.pets;
      case 'transactions':
        return Icons.receipt_long;
      default:
        return Icons.article;
    }
  }

  /// Build enroll staff button
  Widget _buildEnrollStaffButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Navigate to staff enrollment screen
          Navigator.pushReplacementNamed(context, '/a/management/staff/enroll');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add, size: 14.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(
                "Enroll Staff",
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build sign out button
  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/auth/admin'),
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
}

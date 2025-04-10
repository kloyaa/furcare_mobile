import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class AdminStaffEdit extends StatefulWidget {
  const AdminStaffEdit({super.key});

  @override
  State<AdminStaffEdit> createState() => _AdminStaffEditState();
}

class _AdminStaffEditState extends State<AdminStaffEdit>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _mobileNoController = MaskedTextController(mask: '0000-000-000');
  final TextEditingController _birthdateController = MaskedTextController(
    mask: '0000/00/00',
  );
  final TextEditingController _emailController = TextEditingController();

  // Focus nodes for form fields
  late final FocusNode _fullNameFocus;
  late final FocusNode _addressFocus;
  late final FocusNode _mobileNoFocus;
  late final FocusNode _emailFocus;

  // Animation controller for form transitions
  late AnimationController _animationController;

  // Animations for form sections
  late Animation<Offset> _slideBasicInfoAnimation;
  late Animation<Offset> _slideAddressAnimation;
  late Animation<Offset> _slideButtonsAnimation;
  late Animation<double> _fadeAnimation;

  // State variables
  String _selectedGender = "male";
  String _accessToken = "";
  String _errorMessage = "";
  bool _hasError = false;
  bool _isLoading = false;

  // Staff profile data
  Map<String, dynamic>? _staffData;

  /// Validates and updates the staff profile
  Future<void> handleUpdateProfile(String id) async {
    // Set loading state
    setState(() => _isLoading = true);

    // Form validation
    if (!_validateForm()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Prepare profile data
      Profile profile = _buildProfileFromForm();

      // Call API to update profile
      AdminApi adminApi = AdminApi(_accessToken);
      await adminApi.updateProfile(profile.toJson(), id);

      // Update state to reflect success
      setState(() {
        _hasError = false;
        _errorMessage = "";
        _isLoading = false;
      });

      // Show success message
      if (context.mounted) {
        _showSuccessMessage("Profile updated successfully!");
      }
    } on DioException catch (e) {
      // Handle API errors
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);

      setState(() {
        _hasError = true;
        _errorMessage = errorResponse.message;
        _isLoading = false;
      });
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        _hasError = true;
        _errorMessage = "An unexpected error occurred. Please try again.";
        _isLoading = false;
      });
    }
  }

  /// Build profile object from form data
  Profile _buildProfileFromForm() {
    String fullName = _fullNameController.text.trim();
    String address = _addressController.text.trim();
    String email = _emailController.text.trim();
    String mobileNo = _mobileNoController.text.trim();

    return Profile(
      facebook: '',
      messenger: '',
      basicInfo: BasicInfo(fullName: fullName, birthdate: '1999-01-01'),
      address: address,
      isActive: true,
      contact: Contact(
        email: email,
        number: "0${mobileNo.replaceAll('-', '')}",
      ),
    );
  }

  /// Validate all form fields
  bool _validateForm() {
    // List of required fields and their focus nodes
    List<Map<String, dynamic>> fields = [
      {
        'value': _fullNameController.text.trim(),
        'focus': _fullNameFocus,
        'name': 'Full name',
      },

      {
        'value': _addressController.text.trim(),
        'focus': _addressFocus,
        'name': 'Address',
      },
      {
        'value': _emailController.text.trim(),
        'focus': _emailFocus,
        'name': 'Email',
      },
      {
        'value': _mobileNoController.text.trim(),
        'focus': _mobileNoFocus,
        'name': 'Mobile number',
      },
    ];

    // Check each field
    for (var field in fields) {
      if (field['value'].toString().isEmpty) {
        // Focus on the first empty field
        field['focus'].requestFocus();

        // Show error message
        setState(() {
          _hasError = true;
          _errorMessage = "${field['name']} is required";
        });

        return false;
      }
    }

    // Email validation
    if (!_validateEmail(_emailController.text.trim())) {
      _emailFocus.requestFocus();
      setState(() {
        _hasError = true;
        _errorMessage = "Please enter a valid email address";
      });
      return false;
    }

    return true;
  }

  /// Validate email format
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Show success message using snackbar
  void _showSuccessMessage(String message) {
    showSnackBar(
      context,
      message,
      color: Colors.green,
      fontSize: 14.0,
      duration: 2,
    );
  }

  /// Reset all form fields
  void resetForm() {
    setState(() {
      _fullNameController.clear();
      _addressController.clear();
      _mobileNoController.clear();
      _emailController.clear();
      _hasError = false;
      _errorMessage = "";

      // Reset to initial data if available
      if (_staffData != null) {
        _populateFormWithData(_staffData!);
      }
    });
  }

  /// Fill form fields with existing data
  void _populateFormWithData(Map<String, dynamic> data) {
    try {
      final profile = data["profile"];

      if (profile["contact"]["number"] != null) {
        _mobileNoController.text = profile["contact"]["number"].substring(
          1,
          11,
        );
      }

      _emailController.text = profile["contact"]["email"] ?? '';
      _addressController.text = profile["address"] ?? '';
    } catch (e) {
      // Log the error but don't crash
      debugPrint('Error populating form data: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    _fullNameFocus = FocusNode();
    _addressFocus = FocusNode();
    _mobileNoFocus = FocusNode();
    _emailFocus = FocusNode();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Define animations
    _slideBasicInfoAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAddressAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideButtonsAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    // Get access token from provider
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get staff data from route arguments
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _staffData = args;
      _populateFormWithData(args);
    }

    // Start animations after data is loaded
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _fullNameController.dispose();
    _addressController.dispose();
    _mobileNoController.dispose();
    _emailController.dispose();

    _fullNameFocus.dispose();
    _addressFocus.dispose();
    _mobileNoFocus.dispose();
    _emailFocus.dispose();

    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Build the app bar with navigation links
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const SizedBox(),
      leadingWidth: 0,
      actions: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.20,
            ),
            child: _buildNavLinks(),
          ),
        ),
      ],
    );
  }

  /// Builds the sign out button
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

  /// Build navigation links in the app bar
  Widget _buildNavLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavLink(
          "Profile",
          () => Navigator.pushReplacementNamed(context, "/a/profile"),
        ),
        const SizedBox(width: 25.0),
        _buildReportsMenu(),
        const SizedBox(width: 25.0),
        _buildNavLink(
          "Staffs",
          () => Navigator.pushReplacementNamed(context, "/a/management/staff"),
        ),
        const SizedBox(width: 25.0),
        _buildNavLink(
          "Users and Pets",
          () => Navigator.pushReplacementNamed(
            context,
            "/a/management/customers",
          ),
        ),
        const Spacer(),
        _buildNavLink("Enroll Staff", () {}, isBold: true, fontSize: 10.0),
        const SizedBox(width: 25.0),
        _buildSignOutButton(),
      ],
    );
  }

  /// Build a single navigation link
  Widget _buildNavLink(
    String title,
    VoidCallback onTap, {
    bool isBold = false,
    double fontSize = 12.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          title,
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  /// Build reports dropdown menu
  Widget _buildReportsMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: const BorderSide(color: Colors.grey, width: 0.1),
      ),
      tooltip: "Click to view",
      color: Colors.white,
      elevation: 2,
      position: PopupMenuPosition.under,
      child: Text(
        "Reports",
        style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
      ),
      itemBuilder:
          (BuildContext context) => [
            _buildMenuItem('check_ins', 'Check ins'),
            _buildMenuItem('service_usages', 'Service usages'),
            _buildMenuItem('transactions', 'Transactions'),
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

  /// Build a menu item for the reports dropdown
  PopupMenuItem<String> _buildMenuItem(String value, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        text,
        style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
      ),
    );
  }

  /// Build the main body of the screen
  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.50,
          padding: const EdgeInsets.symmetric(
            horizontal: 100.0,
            vertical: 30.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _buildFormContent(),
        ),
      ),
    );
  }

  /// Build the form content with animations
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25.0),
        // Basic Info Section
        SlideTransition(
          position: _slideBasicInfoAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBasicInfoSection(),
          ),
        ),

        const SizedBox(height: 25.0),

        // Address Section
        SlideTransition(
          position: _slideAddressAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildAddressSection(),
          ),
        ),

        const SizedBox(height: 50.0),

        // Error message
        if (_errorMessage.isNotEmpty)
          Center(
            child: AnimatedOpacity(
              opacity: _hasError ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                _errorMessage,
                style: GoogleFonts.urbanist(
                  color: AppColors.danger,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        const Spacer(),

        // Action buttons
        SlideTransition(
          position: _slideButtonsAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildActionButtons(),
          ),
        ),
      ],
    );
  }

  /// Build basic info section of the form
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic info",
          style: GoogleFonts.urbanist(
            color: AppColors.primary.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 25.0),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: "Email",
                prefixIcon: Ionicons.mail_open_outline,
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: _buildTextField(
                controller: _mobileNoController,
                focusNode: _mobileNoFocus,
                label: "Mobile No.",
                prefixIcon: Ionicons.call_outline,
                keyboardType: TextInputType.number,
                prefixText: '+63',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        _buildTextField(
          controller: _fullNameController,
          focusNode: _fullNameFocus,
          label: "Full name",
          prefixIcon: Ionicons.person_outline,
        ),
      ],
    );
  }

  /// Build address section of the form
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address",
          style: GoogleFonts.urbanist(
            color: AppColors.primary.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 25.0),
        _buildTextField(
          controller: _addressController,
          focusNode: _addressFocus,
          label: "Address",
          prefixIcon: Ionicons.map_outline,
        ),
      ],
    );
  }

  /// Build text field with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(15.0),
        border:
            _hasError
                ? Border.all(color: AppColors.danger.withOpacity(0.3))
                : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          fillColor: _hasError ? AppColors.danger : AppColors.primary,
          labelText: label,
          prefixText: prefixText,
          labelStyle: GoogleFonts.urbanist(
            color:
                _hasError
                    ? AppColors.danger.withOpacity(0.7)
                    : AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 18.0,
            color: _hasError ? AppColors.danger : AppColors.primary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          floatingLabelAlignment: FloatingLabelAlignment.start,
        ),
        style: TextStyle(
          color: _hasError ? AppColors.danger : AppColors.primary,
          fontSize: 12.0,
        ),
      ),
    );
  }

  /// Build action buttons (Reset and Save)
  Widget _buildActionButtons() {
    return Column(
      children: [
        OutlinedButton(
          onPressed: _isLoading ? null : resetForm,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            disabledForegroundColor: AppColors.primary.withOpacity(0.5),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                'Reset',
                style: GoogleFonts.urbanist(
                  color:
                      _isLoading
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.primary,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    if (_staffData != null) {
                      handleUpdateProfile(_staffData!["profile"]["_id"]);
                    } else {
                      setState(() {
                        _hasError = true;
                        _errorMessage = "Staff data not found";
                      });
                    }
                  },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      )
                      : Text(
                        'Save Changes',
                        style: GoogleFonts.urbanist(
                          color: AppColors.secondary,
                          fontSize: 12.0,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

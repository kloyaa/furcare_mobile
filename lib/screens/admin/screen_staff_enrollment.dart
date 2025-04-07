import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/models/ekyc.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class AdminStaffEnrollment extends StatefulWidget {
  const AdminStaffEnrollment({super.key});

  @override
  State<AdminStaffEnrollment> createState() => _AdminStaffEnrollmentState();
}

class _AdminStaffEnrollmentState extends State<AdminStaffEnrollment>
    with SingleTickerProviderStateMixin {
  // Controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _mobileNoController = MaskedTextController(mask: '0000-000-000');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Focus nodes for form fields
  late final Map<String, FocusNode> _focusNodes;

  // Animation controller for form sections
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form section animations
  late List<Animation<Offset>> _slideAnimations;

  // State variables
  String _selectedGender = "male";
  String _accessToken = "";
  String _registrationErrorMessage = "";
  bool _isCreateError = false;
  bool _isPasswordVisible = false;
  bool _isPasswordMatched = true;
  bool _isLoading = false;

  // Validation state
  final Map<String, bool> _validationState = {};

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    _focusNodes = {
      'username': FocusNode(),
      'email': FocusNode(),
      'password': FocusNode(),
      'confirm': FocusNode(),
      'fullName': FocusNode(),
      'address': FocusNode(),
      'mobileNo': FocusNode(),
    };

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Create staggered animations for form sections
    _slideAnimations = [
      _createSlideAnimation(0.0), // Account section
      _createSlideAnimation(0.2), // Basic info section
      _createSlideAnimation(0.4), // Address section
      _createSlideAnimation(0.6), // Buttons section
    ];

    // Get access token from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessTokenProvider = Provider.of<AuthTokenProvider>(
        context,
        listen: false,
      );
      setState(() {
        _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
      });

      // Start animations after build
      _animationController.forward();
    });
  }

  // Helper to create slide animations with delay
  Animation<Offset> _createSlideAnimation(double delay) {
    return Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, delay + 0.4, curve: Curves.easeOutQuad),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (final controller in [
      _fullNameController,
      _addressController,
      _mobileNoController,
      _usernameController,
      _passwordController,
      _confirmController,
      _emailController,
    ]) {
      controller.dispose();
    }

    // Dispose all focus nodes
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    // Dispose animation controller
    _animationController.dispose();

    super.dispose();
  }

  // Validates a field and returns true if valid
  bool _validateField(String fieldName, String value) {
    if (value.trim().isEmpty) {
      _focusNodes[fieldName]?.requestFocus();
      setState(() {
        _validationState[fieldName] = false;
      });
      return false;
    }
    setState(() {
      _validationState[fieldName] = true;
    });
    return true;
  }

  // Email validation
  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final isValid = emailRegex.hasMatch(email);
    setState(() {
      _validationState['email'] = isValid;
    });
    return isValid;
  }

  // Password validation
  bool _validatePassword() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      setState(() {
        _isPasswordMatched = false;
        _registrationErrorMessage =
            "Password must be at least 8 characters long";
      });
      return false;
    }

    if (password != confirm) {
      setState(() {
        _isPasswordMatched = false;
        _registrationErrorMessage = "Passwords do not match";
      });
      return false;
    }

    setState(() {
      _isPasswordMatched = true;
      _registrationErrorMessage = "";
    });
    return true;
  }

  // Handle form submission
  Future<void> _handleCreateEkyc() async {
    // Clear previous error
    setState(() {
      _registrationErrorMessage = "";
      _isCreateError = false;
      _isLoading = true;
    });

    // Validate all required fields
    final fieldsToValidate = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'confirm': _confirmController.text,
      'fullName': _fullNameController.text,
      'address': _addressController.text,
      'mobileNo': _mobileNoController.text,
    };

    bool isValid = true;

    // Validate each field
    for (final entry in fieldsToValidate.entries) {
      if (!_validateField(entry.key, entry.value)) {
        isValid = false;
        // Don't break early to validate all fields
      }
    }

    // Perform additional validations
    if (isValid) {
      isValid = _validateEmail(_emailController.text) && isValid;
      isValid = _validatePassword() && isValid;
    }

    // If validation fails, stop processing
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Format phone number properly
      final formattedMobileNo =
          "0${_mobileNoController.text.replaceAll('-', '')}";

      // Create eKYC data model
      AdminApi adminApi = AdminApi(_accessToken);
      Ekyc ekyc = Ekyc(
        account: Account(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
        profile: Profile(
          facebook: '',
          messenger: '',
          basicInfo: BasicInfo(
            fullName: _fullNameController.text.trim(),
            gender: '',
            birthdate: "1999-01-01",
          ),
          address: _addressController.text.trim(),
          contact: Contact(
            email: _emailController.text.trim(),
            number: formattedMobileNo,
          ),
          isActive: true,
        ),
      );

      // Submit the enrollment
      await adminApi.enrollment(ekyc);

      setState(() {
        _isCreateError = false;
        _isPasswordMatched = true;
        _registrationErrorMessage = "";
      });

      if (context.mounted) {
        // Show success message with animation
        _showSuccessMessage();
      }
    } on DioException catch (e) {
      // Handle API errors
      _handleApiError(e);
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        _isCreateError = true;
        _registrationErrorMessage =
            "An unexpected error occurred: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle API errors with proper error messages
  void _handleApiError(DioException e) {
    String errorMessage = "Failed to create staff account";

    try {
      if (e.response?.data != null) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
        errorMessage = errorResponse.message;
      }
    } catch (_) {
      // If parsing fails, use a generic message
      errorMessage = e.message ?? "Network error occurred";
    }

    setState(() {
      _isCreateError = true;
      _registrationErrorMessage = errorMessage;
    });
  }

  // Display success message
  void _showSuccessMessage() {
    showSnackBar(
      context,
      "Staff registration successful!",
      color: Colors.green,
      fontSize: 14.0,
      duration: 3,
    );

    // Reset form after short delay to give user time to see success message
    Future.delayed(const Duration(milliseconds: 500), () {
      _resetEkycForm();
    });
  }

  // Reset form fields
  void _resetEkycForm() {
    // Reset all text controllers
    for (final controller in [
      _fullNameController,
      _addressController,
      _mobileNoController,
      _usernameController,
      _passwordController,
      _confirmController,
      _emailController,
    ]) {
      controller.clear();
    }

    // Reset validation states
    setState(() {
      _validationState.clear();
      _isPasswordMatched = true;
      _registrationErrorMessage = "";
      _isCreateError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // App bar with navigation links
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: const SizedBox(),
      leadingWidth: 0,
      elevation: 1,
      toolbarHeight: 60,
      actions: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavLink("Profile", "/a/profile"),
                const SizedBox(width: 25.0),
                _buildReportsMenu(),
                const SizedBox(width: 25.0),
                _buildNavLink("Staffs", "/a/management/staff"),
                const SizedBox(width: 25.0),
                _buildNavLink("Users and Pets", "/a/management/customers"),
                const Spacer(),
                Text(
                  "Enroll Staff",
                  style: GoogleFonts.urbanist(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                  ),
                ),
                const SizedBox(width: 25.0),
                _buildNavLink("Sign out", "/auth/admin"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Navigation link builder
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

  // Reports dropdown menu
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

  // Report menu item builder
  PopupMenuItem<String> _buildReportMenuItem(String value, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        text,
        style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
      ),
    );
  }

  // Main body of the screen
  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.50,
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 30.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25.0),

                // Account section
                SlideTransition(
                  position: _slideAnimations[0],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Account"),
                      const SizedBox(height: 25.0),
                      _buildAccountFormRow(),
                      const SizedBox(height: 10.0),
                      _buildPasswordFormRow(),
                    ],
                  ),
                ),

                const SizedBox(height: 25.0),

                // Basic Info section
                SlideTransition(
                  position: _slideAnimations[1],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Basic info"),
                      const SizedBox(height: 25.0),
                      _buildBasicInfoFormRow(),
                    ],
                  ),
                ),

                const SizedBox(height: 25.0),

                // Address section
                SlideTransition(
                  position: _slideAnimations[2],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Address"),
                      const SizedBox(height: 25.0),
                      _buildAddressFormRow(),
                    ],
                  ),
                ),

                const SizedBox(height: 35.0),

                // Error message
                if (_registrationErrorMessage.isNotEmpty)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _registrationErrorMessage,
                          style: GoogleFonts.urbanist(
                            color: AppColors.danger,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                const Spacer(),

                // Buttons section
                SlideTransition(
                  position: _slideAnimations[3],
                  child: Row(
                    children: [
                      Expanded(child: _buildResetButton()),
                      const SizedBox(width: 15),
                      Expanded(child: _buildSubmitButton()),
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

  // Section title builder
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.urbanist(
        color: AppColors.primary.withOpacity(0.5),
        fontWeight: FontWeight.w600,
        fontSize: 12.0,
      ),
    );
  }

  // Account form fields row
  Widget _buildAccountFormRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _usernameController,
            focusNode: _focusNodes['username']!,
            label: "Username",
            icon: Ionicons.id_card_outline,
            isError: _isCreateError || _validationState['username'] == false,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: _buildTextField(
            controller: _emailController,
            focusNode: _focusNodes['email']!,
            label: "Email",
            icon: Ionicons.mail_open_outline,
            isError: _isCreateError || _validationState['email'] == false,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: _buildTextField(
            controller: _mobileNoController,
            focusNode: _focusNodes['mobileNo']!,
            label: "Mobile No.",
            icon: Ionicons.call_outline,
            isError: _isCreateError || _validationState['mobileNo'] == false,
            keyboardType: TextInputType.number,
            prefixText: '+63',
          ),
        ),
      ],
    );
  }

  // Password form fields row
  Widget _buildPasswordFormRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _passwordController,
            focusNode: _focusNodes['password']!,
            label: "Password",
            icon: Ionicons.lock_closed_outline,
            isError: _isCreateError || !_isPasswordMatched,
            obscureText: !_isPasswordVisible,
            suffix: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              child: Icon(
                _isPasswordVisible
                    ? Ionicons.eye_outline
                    : Ionicons.eye_off_outline,
                size: 18.0,
                color:
                    _isCreateError || !_isPasswordMatched
                        ? AppColors.danger
                        : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: _buildTextField(
            controller: _confirmController,
            focusNode: _focusNodes['confirm']!,
            label: "Confirm",
            icon: Ionicons.lock_closed_outline,
            isError: _isCreateError || !_isPasswordMatched,
            obscureText: true,
          ),
        ),
      ],
    );
  }

  // Basic info form fields row
  Widget _buildBasicInfoFormRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _fullNameController,
            focusNode: _focusNodes['fullName']!,
            label: "Full name",
            icon: Ionicons.person_outline,
            isError: _isCreateError || _validationState['fullName'] == false,
          ),
        ),
      ],
    );
  }

  // Birthdate and gender form fields row
  Widget _buildBirthdateGenderRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color:
                    _isCreateError
                        ? AppColors.danger.withOpacity(0.5)
                        : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: GenderSelectionWidget(
              onGenderSelected: (gender) {
                setState(() {
                  _selectedGender = gender!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // Address form fields row
  Widget _buildAddressFormRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _addressController,
            focusNode: _focusNodes['address']!,
            label: "Address",
            icon: Ionicons.map_outline,
            isError: _isCreateError || _validationState['address'] == false,
          ),
        ),
      ],
    );
  }

  // Reset button
  Widget _buildResetButton() {
    return OutlinedButton(
      onPressed: _isLoading ? null : _resetEkycForm,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color:
              _isLoading
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
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
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleCreateEkyc,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor:
            _isLoading ? AppColors.primary.withOpacity(0.7) : AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: Center(
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    'Create Staff Account',
                    style: GoogleFonts.urbanist(
                      color: AppColors.secondary,
                      fontSize: 12.0,
                    ),
                  ),
        ),
      ),
    );
  }

  // Reusable text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isError = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? prefixText,
    Widget? suffix,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color:
              isError
                  ? AppColors.danger.withOpacity(0.5)
                  : focusNode.hasFocus
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.transparent,
          width: 1.0,
        ),
        boxShadow:
            focusNode.hasFocus
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onTap: () {
          setState(() {
            // Trigger rebuild to update the focus state
          });
        },
        onChanged: (value) {
          // Clear validation error when user types
          if (_validationState.containsKey(focusNode.hashCode.toString()) &&
              _validationState[focusNode.hashCode.toString()] == false) {
            setState(() {
              _validationState.remove(focusNode.hashCode.toString());
            });
          }
        },
        decoration: InputDecoration(
          fillColor: isError ? AppColors.danger : AppColors.primary,
          labelText: label,
          prefixText: prefixText,
          labelStyle: GoogleFonts.urbanist(
            color:
                isError
                    ? AppColors.danger.withOpacity(0.7)
                    : AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
          ),
          prefixIcon: Icon(
            icon,
            size: 18.0,
            color: isError ? AppColors.danger : AppColors.primary,
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
        ),
        style: TextStyle(
          color: isError ? AppColors.danger : AppColors.primary,
          fontSize: 12.0,
        ),
      ),
    );
  }
}

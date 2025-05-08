import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/auth_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/screens/others/setup.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

/// A polished customer registration screen with animated UI elements
/// Features:
/// - Two-stage registration process (username/email, then password)
/// - Robust form validation
/// - Smooth animations
/// - Error handling with visual feedback
/// - Responsive layout
class CustomerRegister extends StatefulWidget {
  const CustomerRegister({super.key});

  @override
  State<CustomerRegister> createState() => _CustomerRegisterState();
}

class _CustomerRegisterState extends State<CustomerRegister>
    with TickerProviderStateMixin {
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // Focus nodes for form fields
  late final FocusNode _emailFocus;
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmFocus;

  // Animation controllers
  late AnimationController _shakeAnimationController;
  late Animation<double> _shakeAnimation;

  late AnimationController _logoAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _bounceAnimation;

  // Page transition controller
  late AnimationController _pageTransitionController;
  late Animation<double> _pageTransitionAnimation;

  // Form state
  bool _isPasswordVisible = false;
  bool _isLoginError = false;
  String _errorMessage = "";
  bool _isFirstScreen = true;
  bool _isLoading = false;

  // App theme colors
  final Color _primaryColor = const Color(0xFF4CAF50); // Green for health/care
  final Color _accentColor = const Color(0xFF42A5F5); // Blue for trust/calm

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    _setupAnimations();

    // For development purposes only - remove in production
    _prefillTestData();
  }

  /// Initialize all focus nodes
  void _initializeFocusNodes() {
    _emailFocus = FocusNode();
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmFocus = FocusNode();
  }

  /// Setup all animations used in this screen
  void _setupAnimations() {
    // Error shake animation
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_shakeAnimationController);

    // Logo animation
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Scale animation for subtle "breathing" effect on logo
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Color animation to transition between brand colors
    _colorAnimation = ColorTween(
      begin: _primaryColor,
      end: _accentColor,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Subtle bounce animation for logo
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -3, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Page transition animation
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pageTransitionAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    );
  }

  /// Pre-fill test data - REMOVE IN PRODUCTION
  void _prefillTestData() {
    _usernameController.text = "kolya";
    _emailController.text = "kolya@gmail.com";
    _passwordController.text = "Password@1234";
    _confirmController.text = "Password@1234";
  }

  @override
  void dispose() {
    // Dispose controllers
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    // Dispose focus nodes
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    // Dispose animation controllers
    _shakeAnimationController.dispose();
    _logoAnimationController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  /// Validates the first screen inputs and proceeds to password screen if valid
  void _validateFirstScreen() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    // Validate username
    if (username.isEmpty) {
      _showError("Username is required");
      _usernameFocus.requestFocus();
      return;
    }

    // Basic email validation
    if (email.isEmpty) {
      _showError("Email is required");
      _emailFocus.requestFocus();
      return;
    }

    if (!_isValidEmail(email)) {
      _showError("Please enter a valid email address");
      _emailFocus.requestFocus();
      return;
    }

    // Clear any previous errors
    _clearError();

    // Animate to the second screen
    _pageTransitionController.forward().then((_) {
      setState(() {
        _isFirstScreen = false;
        _passwordFocus.requestFocus();
      });
      _pageTransitionController.reverse();
    });
  }

  /// Simple email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Return to the first screen
  void _goBack() {
    _pageTransitionController.forward().then((_) {
      setState(() {
        _isFirstScreen = true;
      });
      _pageTransitionController.reverse();
    });
  }

  /// Handles the registration process
  Future<void> _handleRegistration() async {
    // Validate passwords
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty) {
      _showError("Password is required");
      _passwordFocus.requestFocus();
      return;
    }

    // Password strength validation
    if (!_isStrongPassword(password)) {
      _showError(
        "Password must be at least 8 characters with uppercase, lowercase, number and special character",
      );
      _passwordFocus.requestFocus();
      return;
    }

    if (confirm.isEmpty) {
      _showError("Please confirm your password");
      _confirmFocus.requestFocus();
      return;
    }

    if (confirm != password) {
      _showError("Passwords do not match");
      _confirmFocus.requestFocus();
      return;
    }

    // Clear any previous errors
    _clearError();

    // Show loading state
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final username = _usernameController.text.trim();

      final authenticationApi = AuthenticationApi("mobile");

      final response = await authenticationApi.register(
        email: email,
        username: username,
        password: password,
      );

      // Process the response
      if (response.data != null) {
        final registerResponse = RegistrationResponse.fromJson(response.data);

        // Check user role
        final userRole = response.data["role"]?.toString().toLowerCase() ?? "";
        if (userRole != "customer") {
          _showError(
            "Please use the Furcare web app for non-customer accounts",
          );
          return;
        }

        // Set authentication token
        if (mounted) {
          final accessTokenProvider = Provider.of<AuthTokenProvider>(
            context,
            listen: false,
          );
          accessTokenProvider.setAuthToken(registerResponse.accessToken);

          // Navigate to profile setup
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProfileSetupAnimation(
                    redirectPath: "/c/create/profile/1",
                  ),
            ),
          );
        }
      } else {
        _showError("Registration failed. Please try again.");
      }
    } on DioException catch (e) {
      // Handle API errors
      String errorMessage = "Registration failed";

      if (e.response?.data != null && e.response!.data["message"] != null) {
        errorMessage = e.response!.data["message"];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout. Please check your internet.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "No internet connection";
      }

      _showError(errorMessage);
    } catch (e) {
      _showError("An unexpected error occurred");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Shows error message with shake animation
  void _showError(String message) {
    setState(() {
      _isLoginError = true;
      _errorMessage = message;
    });
    _shakeAnimationController.forward(from: 0);
  }

  /// Clears error message
  void _clearError() {
    setState(() {
      _isLoginError = false;
      _errorMessage = "";
    });
  }

  /// Validates password strength
  bool _isStrongPassword(String password) {
    // At least 8 characters, with uppercase, lowercase, number, and special character
    return password.length >= 8 &&
        RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
        ).hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Close keyboard when tapping outside
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Changed to true for better keyboard handling
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: _buildContent(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main content with animated page transition
  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _pageTransitionAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 1 - _pageTransitionAnimation.value,
          child: _isFirstScreen ? _buildFirstScreen() : _buildSecondScreen(),
        );
      },
    );
  }

  /// Builds the first registration screen (username/email)
  Widget _buildFirstScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Column(children: [_buildAnimatedLogo()]),
              ),
              const SizedBox(height: 20.0),

              // Title
              Text(
                "Create your account",
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),

              // Form fields with staggered animation
              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: _buildInputField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  label: "Username",
                  icon: Ionicons.person_outline,
                  keyboardType: TextInputType.text,
                ),
              ),

              const SizedBox(height: 16.0),

              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: _buildInputField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: "Email",
                  icon: Ionicons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              // Error message if any
              if (_isLoginError)
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.urbanist(
                        color: AppColors.danger,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 40.0),

              // Action buttons
              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 400),
                child: _buildPrimaryButton(
                  label: 'Continue',
                  onPressed: _validateFirstScreen,
                ),
              ),

              const SizedBox(height: 16.0),

              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 500),
                child: _buildAlreadyHaveAnAccountButton(
                  label: "Already have an account?",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the second registration screen (password)
  Widget _buildSecondScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SizedBox(
          width: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar animation
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Lottie.asset(
                  'assets/men_head_moving.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              // Title and subtitle
              Text(
                "Set Your Password",
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),

              Text(
                "Creating account for ${_usernameController.text}",
                style: GoogleFonts.urbanist(
                  color: AppColors.primary.withAlpha(200),
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 24.0),

              // Password fields with staggered animation
              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: _buildPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  label: "Password",
                  showVisibilityToggle: true,
                ),
              ),

              const SizedBox(height: 16.0),

              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: _buildPasswordField(
                  controller: _confirmController,
                  focusNode: _confirmFocus,
                  label: "Confirm Password",
                  showVisibilityToggle: false,
                ),
              ),

              // Error message if any
              if (_isLoginError)
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.urbanist(
                        color: AppColors.danger,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 16.0),

              // Terms text
              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 400),
                child: Text(
                  "By creating an account, you agree to abide by our terms and conditions.",
                  style: GoogleFonts.urbanist(
                    color: AppColors.primary.withAlpha(200),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40.0),

              // Action buttons
              FadeInUp(
                from: 20,
                delay: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          _isLoading
                              ? _buildLoadingButton()
                              : _buildPrimaryButton(
                                label: 'Register',
                                onPressed: _handleRegistration,
                              ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              FadeInUp(
                child: _buildSecondaryButton(label: "Back", onPressed: _goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the animated logo with breathing and color effects
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Text(
              "FUR CARE",
              style: GoogleFonts.titanOne(
                color: _colorAnimation.value,
                fontSize: 42.0,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Colors.black12,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a standard text input field
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          fillColor: AppColors.primary,
          labelText: label,
          labelStyle: GoogleFonts.urbanist(
            color:
                _isLoginError
                    ? AppColors.danger.withAlpha(200)
                    : AppColors.primary.withAlpha(200),
            fontSize: 10.0,
          ),
          prefixIcon: Icon(
            icon,
            size: 18.0,
            color: _isLoginError ? AppColors.danger : AppColors.primary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          focusedBorder: InputBorder.none,
        ),
        style: TextStyle(
          color: _isLoginError ? AppColors.danger : AppColors.primary,
          fontSize: 12.0,
        ),
        onChanged: (_) => _clearError(),
      ),
    );
  }

  /// Builds a password input field with optional visibility toggle
  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool showVisibilityToggle = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: showVisibilityToggle ? !_isPasswordVisible : true,
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelText: label,
          labelStyle: GoogleFonts.urbanist(
            color:
                _isLoginError
                    ? AppColors.danger.withAlpha(200)
                    : AppColors.primary.withAlpha(200),
            fontSize: 12.0,
          ),
          prefixIcon: Icon(
            Ionicons.lock_closed_outline,
            size: 18.0,
            color: _isLoginError ? AppColors.danger : AppColors.primary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          suffixIcon:
              showVisibilityToggle
                  ? GestureDetector(
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
                          _isLoginError ? AppColors.danger : AppColors.primary,
                    ),
                  )
                  : null,
        ),
        style: TextStyle(
          color: _isLoginError ? AppColors.danger : AppColors.primary,
          fontSize: 14.0,
        ),
        onChanged: (_) => _clearError(),
      ),
    );
  }

  /// Builds a primary action button
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a secondary action button
  /// Builds a tappable arrow button with text
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated arrow
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 5.0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(value, 0),
                  child: child,
                );
              },
              child: Icon(
                Ionicons.arrow_back,
                color: AppColors.primary,
                size: 18.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyHaveAnAccountButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated arrow
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 5.0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(value, 0),
                  child: child,
                );
              },
              child: Text(
                label,
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a loading button to show during API calls
  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: null, // Disabled during loading
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withOpacity(0.7),
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

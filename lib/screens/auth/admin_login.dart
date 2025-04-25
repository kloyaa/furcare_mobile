import 'package:flutter/material.dart';
import 'package:furcare_app/services/auth_service.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/auth_button.dart';
import 'package:furcare_app/widgets/auth_error_message.dart';
import 'package:furcare_app/widgets/auth_form_field.dart';
import 'package:furcare_app/widgets/auth_terms_text.dart';
import 'package:furcare_app/animations/shake_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class ScreenAdminLogin extends StatefulWidget {
  const ScreenAdminLogin({super.key});

  @override
  State<ScreenAdminLogin> createState() => _ScreenAdminLoginState();
}

class _ScreenAdminLoginState extends State<ScreenAdminLogin>
    with TickerProviderStateMixin {
  // Controllers & Focus Nodes
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late ShakeAnimationController _shakeController;

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoginError = false;
  String _loginErrorMessage = "";
  bool _isLoading = false;

  /// Handles the login authentication flow
  Future<void> _handleLogin() async {
    // Validate form before proceeding
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    // Use AuthService for login
    final authService = AuthService(
      context: context,
      platform: "web",
      allowedRole: AuthRole.admin,
    );

    final result = await authService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result.result == AuthResult.success) {
      // Clear any previous errors
      setState(() {
        _isLoginError = false;
        _loginErrorMessage = "";
      });

      // Add login success animation
      _animationController.forward().then((_) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/a/profile');
        }
      });
    } else {
      _showLoginError(result.message);
    }
  }

  /// Validates the form fields
  bool _validateForm() {
    if (_usernameController.text.trim().isEmpty) {
      _usernameFocus.requestFocus();
      setState(() => _isLoading = false);
      return false;
    }

    if (_passwordController.text.trim().isEmpty) {
      _passwordFocus.requestFocus();
      setState(() => _isLoading = false);
      return false;
    }

    return true;
  }

  /// Shows login error with shake animation
  void _showLoginError(String message) {
    setState(() {
      _isLoginError = true;
      _loginErrorMessage = message;
      _isLoading = false;
    });

    // Play shake animation for error feedback
    _shakeController.shake();
  }

  @override
  void initState() {
    super.initState();
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize shake controller
    _shakeController = ShakeAnimationController(vsync: this);

    // Configure animations
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    // Set default values for development only - REMOVE IN PRODUCTION
    _usernameController.text = "ErenJaeger_";
    _passwordController.text = "Password@123";

    // Start initial animation
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    _shakeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout handling
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 900;
    final isVerySmallScreen = screenWidth < 600;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.secondary,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child:
                    isVerySmallScreen
                        ? _buildMobileLayout(screenHeight)
                        : isSmallScreen
                        ? _buildTabletLayout()
                        : _buildDesktopLayout(),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Desktop layout with 3:1 ratio for logo and form
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side logo section (3/4 of screen)
        Expanded(flex: 3, child: _buildLogoSection()),
        // Right side login form (1/4 of screen)
        Expanded(child: _buildLoginForm()),
      ],
    );
  }

  /// Tablet layout with 1:1 ratio for logo and form
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left side logo section (1/2 of screen)
        Expanded(child: _buildLogoSection()),
        // Right side login form (1/2 of screen)
        Expanded(child: _buildLoginForm()),
      ],
    );
  }

  /// Mobile layout with vertical stacking
  Widget _buildMobileLayout(double screenHeight) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // Top logo section (1/3 of screen height)
          SizedBox(height: screenHeight * 0.35, child: _buildLogoSection()),
          // Bottom login form (2/3 of screen height)
          Container(
            constraints: BoxConstraints(minHeight: screenHeight * 0.65),
            child: _buildLoginForm(isMobile: true),
          ),
        ],
      ),
    );
  }

  /// Logo section with animated color change on error
  Widget _buildLogoSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: AppColors.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo text with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: GoogleFonts.sunshiney(
                    color:
                        _isLoginError ? AppColors.danger : AppColors.secondary,
                    fontSize: 120.0,
                    fontWeight: FontWeight.bold,
                  ),
                  child: const Text("furcare"),
                ),
              ),
            ),
            // Tagline with animation
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.sunshiney(
                  color: _isLoginError ? AppColors.danger : AppColors.secondary,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                  height: 0.1,
                ),
                child: const Text('"fur every pet needs"'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Login form with responsive sizing
  Widget _buildLoginForm({bool isMobile = false}) {
    // Responsive padding based on device type
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 30.0 : 50.0,
        vertical: isMobile ? 30.0 : 50.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            "Login to your account",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: isMobile ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 15.0 : 20.0),

          // Form fields with shake animation
          ShakeAnimationBuilder(
            animation: _shakeController.animation,
            child: Column(
              children: [
                // Username field
                AuthFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  label: "Username or Email",
                  icon: Ionicons.person_outline,
                  hasError: _isLoginError,
                  obscureText: false,
                ),
                const SizedBox(height: 15.0),

                // Password field
                AuthFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  label: "Password",
                  icon: Ionicons.lock_closed_outline,
                  hasError: _isLoginError,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: GestureDetector(
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
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15.0),

          // Error message with animation
          AuthErrorMessage(message: _loginErrorMessage),

          // Terms text
          const AuthTermsText(),

          const SizedBox(height: 30.0),

          // Sign in button
          AuthButton(
            label: "Sign in",
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),

          // Forgot password link
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Forgot password functionality
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.urbanist(
                    color: AppColors.primary,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A responsive admin login screen with enhanced UI, animations, and better code organization
// Supports desktop, tablet, and mobile layouts

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/auth_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart' show Provider;

class ScreenAdminLogin extends StatefulWidget {
  const ScreenAdminLogin({super.key});

  @override
  State<ScreenAdminLogin> createState() => _ScreenAdminLoginState();
}

class _ScreenAdminLoginState extends State<ScreenAdminLogin>
    with SingleTickerProviderStateMixin {
  // Controllers & Focus Nodes
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;

  // Animation controller for enhanced UI feedback
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

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

    final authenticationApi = AuthenticationApi("web");
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      Response response = await authenticationApi.login(
        username: username,
        password: password,
      );

      // Check for correct role
      String role = response.data["role"].toString().toLowerCase();
      if (role == "staff" || role == "customer") {
        _showLoginError("Please use the Furcare Mobile app, Thank you.");
        return;
      }

      // Clear any previous errors
      setState(() {
        _isLoginError = false;
        _loginErrorMessage = "";
      });

      // Handle successful login
      if (context.mounted) {
        final accessTokenProvider = Provider.of<AuthTokenProvider>(
          context,
          listen: false,
        );

        accessTokenProvider.setAuthToken(response.data['data']);

        // Add login success animation
        _animationController.forward().then((_) {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/a/profile');
          }
        });
      }
    } on DioException catch (e) {
      _showLoginError(
        e.response?.data["message"] ?? "Login failed. Please try again.",
      );
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
    _animationController.reset();
    _animationController.forward();
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

          // Form fields with animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset:
                    _isLoginError
                        ? Offset(sin(_animationController.value * 10) * 5, 0)
                        : Offset.zero,
                child: Column(
                  children: [
                    // Username field
                    _buildFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      label: "Username or Email",
                      icon: Ionicons.person_outline,
                      obscureText: false,
                    ),
                    const SizedBox(height: 15.0),

                    // Password field
                    _buildFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: "Password",
                      icon: Ionicons.lock_closed_outline,
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
                              _isLoginError
                                  ? AppColors.danger
                                  : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 15.0),

          // Error message with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child:
                _loginErrorMessage.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _loginErrorMessage,
                        style: GoogleFonts.urbanist(
                          color: AppColors.danger,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          // Terms text
          Text(
            "By logging in, you agree to abide by our terms and conditions. Please review them carefully before proceeding.",
            style: GoogleFonts.urbanist(
              color: AppColors.primary.withOpacity(0.7),
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30.0),

          // Sign in button with animation
          _buildSignInButton(),

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

  /// Enhanced form field with animated feedback
  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: (_isLoginError ? AppColors.danger : AppColors.primary)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        onChanged: (_) {
          // Clear error on input change
          if (_isLoginError) {
            setState(() {
              _isLoginError = false;
              _loginErrorMessage = "";
            });
          }
        },
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelText: label,
          labelStyle: GoogleFonts.urbanist(
            color:
                _isLoginError
                    ? AppColors.danger
                    : AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              icon,
              size: 18.0,
              color: _isLoginError ? AppColors.danger : AppColors.primary,
            ),
          ),
          prefixIconColor: AppColors.primary,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: (_isLoginError ? AppColors.danger : AppColors.primary)
                  .withOpacity(0.3),
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(
          color: _isLoginError ? AppColors.danger : AppColors.primary,
          fontSize: 12.0,
        ),
      ),
    );
  }

  /// Enhanced sign-in button with loading animation
  Widget _buildSignInButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(_isLoading ? 0.2 : 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: _isLoading ? 1 : 3,
          shadowColor: AppColors.primary.withOpacity(0.4),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child:
                _isLoading
                    ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.secondary,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    : Text(
                      'Sign in',
                      style: GoogleFonts.urbanist(
                        color: AppColors.secondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

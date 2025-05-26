import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:furcare_app/animations/shake_animation.dart';
import 'package:furcare_app/services/auth_service.dart';
import 'package:furcare_app/services/location_permission.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/auth_button.dart';
import 'package:furcare_app/widgets/auth_error_message.dart';
import 'package:furcare_app/widgets/auth_form_field.dart';
import 'package:furcare_app/widgets/auth_terms_text.dart';
import 'package:furcare_app/widgets/furcare_logo.dart';

class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus Nodes
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;

  // Animation Controller
  late final ShakeAnimationController _shakeController;

  // State Variables
  bool _isPasswordVisible = false;
  bool _isLoginError = false;
  bool _isLoading = false;
  String _loginErrorMessage = "";

  @override
  void initState() {
    super.initState();

    // Initialize Focus Nodes
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();

    // Initialize Shake Animation Controller
    _shakeController = ShakeAnimationController(vsync: this);

    // Pre-fill username for development convenience
    _usernameController.text = "Staff01"; // Example username
    _passwordController.text = "Password@1234"; // Example password

    // Request Location Permission
    _requestPermission();
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _shakeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Request Location Permission
  Future<void> _requestPermission() async {
    await LocationPermissionHandler.requestLocationPermission(context);
  }

  // Toggle Password Visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      _usernameFocus.requestFocus();
      setState(() => _isLoading = false);
      return;
    }

    if (password.isEmpty) {
      _passwordFocus.requestFocus();
      setState(() => _isLoading = false);
      return;
    }

    // Use AuthService for login
    final authService = AuthService(
      context: context,
      platform: "mobile",
      allowedRole: AuthRole.staff,
    );

    final result = await authService.login(
      username: username,
      password: password,
    );

    setState(() {
      _isLoading = false;
      _isLoginError = result.result != AuthResult.success;
      _loginErrorMessage = result.message;
    });

    if (result.result == AuthResult.success) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/s/main');
      }
    } else if (result.result == AuthResult.needsProfile) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/c/create/profile/1');
      }
    } else {
      _shakeController.shake(); // Trigger shake animation
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: ShakeAnimationBuilder(
            animation: _shakeController.animation,
            child: SizedBox(
              width: 300.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeIn(
                    duration: const Duration(milliseconds: 2000),
                    onFinish: (direction) {
                      // Automatically focus on the username field after the logo animation
                      FocusScope.of(context).requestFocus(_usernameFocus);
                    },
                    child: Image.asset(
                      "assets/furcare_logo.png",
                      width: 320.0,
                      height: 320.0,
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Username field
                  AuthFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocus,
                    label: "Username or Email",
                    icon: Ionicons.person_outline,
                    hasError: _isLoginError,
                  ),

                  const SizedBox(height: 10.0),

                  // Password field
                  AuthFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: "Password",
                    icon: Ionicons.lock_closed_outline,
                    obscureText: !_isPasswordVisible,
                    hasError: _isLoginError,
                    suffixIcon: GestureDetector(
                      onTap: _togglePasswordVisibility,
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

                  const SizedBox(height: 10.0),

                  // Error message
                  AuthErrorMessage(message: _loginErrorMessage),

                  // Terms text
                  const AuthTermsText(isRegister: false),

                  const SizedBox(height: 80.0),

                  // Login button
                  AuthButton(
                    label: "Sign in",
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

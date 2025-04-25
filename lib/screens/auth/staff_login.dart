import 'package:flutter/material.dart';
import 'package:furcare_app/animations/shake_animation.dart';
import 'package:furcare_app/services/location_permission.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:furcare_app/widgets/auth_button.dart';
import 'package:furcare_app/widgets/auth_error_message.dart';
import 'package:furcare_app/widgets/auth_form_field.dart';
import 'package:furcare_app/widgets/auth_terms_text.dart';
import 'package:furcare_app/widgets/furcare_logo.dart';
import 'package:furcare_app/services/auth_service.dart';

class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;

  late final ShakeAnimationController _shakeController;

  // State
  bool _isPasswordVisible = false;
  bool _isLoginError = false;
  bool _isLoading = false;
  String _loginErrorMessage = "";

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

  Future<void> _requestPermission() async {
    await LocationPermissionHandler.requestLocationPermission(context);
    // No need to handle the permission result here as it's handled in the LocationPermissionHandler
  }

  @override
  void initState() {
    super.initState();

    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();

    // For development convenience
    _usernameController.text = "Staff01";
    _passwordController.text = "Password@123";

    // Initialize shake animation controller
    _shakeController = ShakeAnimationController(vsync: this);

    _requestPermission();
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _shakeController.dispose();
    super.dispose();
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
                  _isLoginError
                      ? FurcareLogo(
                        hasError: true,
                        fontSize: 80,
                        taglineSize: 18,
                      )
                      : FurcareLogo(fontSize: 80, taglineSize: 18),

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

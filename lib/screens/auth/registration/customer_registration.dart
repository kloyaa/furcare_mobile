import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/auth_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/screens/others/setup.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CustomerRegister extends StatefulWidget {
  const CustomerRegister({super.key});

  @override
  State<CustomerRegister> createState() => _CustomerRegisterState();
}

class _CustomerRegisterState extends State<CustomerRegister>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  late final FocusNode _emailFocus;
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmFocus;

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  // State
  bool _isPasswordVisible = false;
  bool _isLoginError = false;
  String _loginErrorMessage = "";

  Future<void> _handleRegistration() async {
    final authenticationApi = AuthenticationApi("mobile");
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (username.isEmpty) {
      _usernameFocus.requestFocus();
      return;
    }
    if (password.isEmpty) {
      _passwordFocus.requestFocus();
      return;
    }
    if (confirm.isEmpty) {
      _confirmFocus.requestFocus();
      return;
    }
    if (email.isEmpty) {
      _emailFocus.requestFocus();
      return;
    }

    if (confirm != password) {
      setState(() {
        _isLoginError = true;
        _loginErrorMessage = "Password and confirm password does not match.";
      });

      return;
    }

    try {
      Response response = await authenticationApi.register(
        email: email,
        username: username,
        password: password,
      );

      final registerResponse = RegistrationResponse.fromJson(response.data);

      if (response.data["role"].toString().toLowerCase() != "customer") {
        setState(() {
          _isLoginError = true;
          _loginErrorMessage = "Please use the Furcare web app, Thank you.";
        });

        return;
      }

      setState(() {
        _isLoginError = false;
        _loginErrorMessage = "";
      });

      if (context.mounted) {
        final accessTokenProvider = Provider.of<AuthTokenProvider>(
          context,
          listen: false,
        );

        accessTokenProvider.setAuthToken(registerResponse.accessToken);

        if (context.mounted) {
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
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);

      if (errorResponse.code == '0104') {}

      setState(() {
        _isLoginError = true;
        _loginErrorMessage = e.response!.data["message"];
      });

      _animationController.forward(from: 0); // Trigger shake animation
    }
  }

  @override
  void initState() {
    super.initState();

    _emailFocus = FocusNode();
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmFocus = FocusNode();

    _usernameController.text = "kolya";
    _emailController.text = "kolya@gmail.com";
    _passwordController.text = "Password@1234";
    _confirmController.text = "Password@1234";

    // Shake Animation Controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.secondary,
        body: Center(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: SizedBox(
                  width: 300.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        child: Lottie.asset(
                          'assets/men_head_moving.json',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        "Create your account",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            fillColor: AppColors.primary,
                            labelText: "Username",
                            labelStyle: GoogleFonts.urbanist(
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary.withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                            prefixIcon: Icon(
                              Ionicons.person_outline,
                              size: 18.0,
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary,
                            ),
                            prefixIconColor: AppColors.primary,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start,
                          ),
                          style: TextStyle(
                            color:
                                _isLoginError
                                    ? AppColors.danger
                                    : AppColors.primary,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            fillColor: AppColors.primary,
                            labelText: "Email",
                            labelStyle: GoogleFonts.urbanist(
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary.withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                            prefixIcon: Icon(
                              Ionicons.mail_outline,
                              size: 18.0,
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary,
                            ),
                            prefixIconColor: AppColors.primary,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start,
                          ),
                          style: TextStyle(
                            color:
                                _isLoginError
                                    ? AppColors.danger
                                    : AppColors.primary,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Password",
                            labelStyle: GoogleFonts.urbanist(
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary.withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                            prefixIcon: Icon(
                              Ionicons.lock_closed_outline,
                              size: 18.0,
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary,
                            ),
                            prefixIconColor: AppColors.primary,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
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
                          style: TextStyle(
                            color:
                                _isLoginError
                                    ? AppColors.danger
                                    : AppColors.primary,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          controller: _confirmController,
                          focusNode: _confirmFocus,
                          obscureText: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Confirm",
                            labelStyle: GoogleFonts.urbanist(
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary.withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                            prefixIcon: Icon(
                              Ionicons.lock_closed_outline,
                              size: 18.0,
                              color:
                                  _isLoginError
                                      ? AppColors.danger
                                      : AppColors.primary,
                            ),
                            prefixIconColor: AppColors.primary,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: TextStyle(
                            color:
                                _isLoginError
                                    ? AppColors.danger
                                    : AppColors.primary,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      _loginErrorMessage.isNotEmpty
                          ? Column(
                            children: [
                              Text(
                                _loginErrorMessage,
                                style: GoogleFonts.urbanist(
                                  color: AppColors.danger,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                            ],
                          )
                          : const SizedBox(),
                      Text(
                        "By creating an account, you agree to abide by our terms and conditions. Please review them carefully before proceeding.",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary.withOpacity(0.7),
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 80.0),
                      ElevatedButton(
                        onPressed: () async {
                          await _handleRegistration();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Center(
                            child: Text(
                              'Register',
                              style: GoogleFonts.urbanist(
                                color: AppColors.secondary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      OutlinedButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, "/");
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 0.5,
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
                              "Already have an account?",
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

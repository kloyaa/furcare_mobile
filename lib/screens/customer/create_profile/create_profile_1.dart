import 'package:flutter/material.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/container_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart'; // Add this package for animations

class CreateProfileStep1 extends StatefulWidget {
  const CreateProfileStep1({super.key});

  @override
  State<CreateProfileStep1> createState() => _CreateProfileStep1State();
}

class _CreateProfileStep1State extends State<CreateProfileStep1>
    with SingleTickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController();
  late final FocusNode _fullNameFocus;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State
  final String _selectedGender = "male";
  final String _selectedBirthdate = "1999-01-01";
  bool _isTyping = false;
  bool _isNameValid = false;

  Future handleSaveBasicInfo() async {
    final fullName = _fullNameController.text.trim();

    if (fullName.isEmpty) {
      _fullNameFocus.requestFocus();
      return;
    }

    // Add a short animation before navigation
    setState(() {
      _isNameValid = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Provider.of<RegistrationProvider>(context, listen: false).setBasicInfo(
      BasicInfo(
        birthdate: _selectedBirthdate,
        fullName: fullName,
        gender: _selectedGender,
      ),
    );

    Navigator.pushNamed(context, '/c/create/profile/2');
  }

  @override
  void initState() {
    super.initState();

    _fullNameFocus = FocusNode();
    _fullNameFocus.addListener(_onFocusChange);

    _fullNameController.addListener(_onTextChange);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  void _onFocusChange() {
    setState(() {
      _isTyping = _fullNameFocus.hasFocus;
    });
  }

  void _onTextChange() {
    setState(() {
      _isNameValid = _fullNameController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onTextChange);
    _fullNameFocus.removeListener(_onFocusChange);
    _fullNameFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.primary.withOpacity(0.05),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),

                // App Logo
                FadeIn(
                  duration: const Duration(milliseconds: 800),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Ionicons.paw,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Furcare",
                        style: GoogleFonts.urbanist(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40.0),

                // Welcome Text with Animation
                FadeInDown(
                  from: 30,
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    "Hello,",
                    style: GoogleFonts.urbanist(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                FadeInDown(
                  from: 30,
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Welcome to ",
                          style: GoogleFonts.urbanist(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "Furcare!",
                          style: GoogleFonts.lilitaOne(
                            fontSize: 32.0,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                FadeInDown(
                  from: 30,
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 700),
                  child: Text(
                    "What's your name?",
                    style: GoogleFonts.urbanist(
                      fontSize: 22.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 30.0),

                // Name Input Field with Animation
                FadeInUp(
                  from: 30,
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 900),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    child: TextFormField(
                      controller: _fullNameController,
                      focusNode: _fullNameFocus,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Ionicons.person_outline,
                          size: 18.0,
                          color: _isTyping ? AppColors.primary : Colors.black45,
                        ),
                        labelText: "Name",
                        fillColor: AppColors.primary,
                        labelStyle: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIconColor: AppColors.primary,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        floatingLabelAlignment: FloatingLabelAlignment.start,
                      ),
                      style: GoogleFonts.urbanist(
                        color: Colors.black87,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Pet illustration
                Expanded(
                  child: Center(
                    child: FadeIn(
                      child: Lottie.asset(
                        'assets/dog.json',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Continue Button with Animation
                FadeInUp(
                  from: 30,
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 1100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _isNameValid
                              ? () async {
                                if (context.mounted) {
                                  handleSaveBasicInfo();
                                }
                              }
                              : null,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue'),
                          const SizedBox(width: 8.0),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  _isNameValid
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Ionicons.arrow_forward_outline,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

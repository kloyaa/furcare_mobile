import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:animate_do/animate_do.dart'; // Add this package for animations

class CreateProfileStep2 extends StatefulWidget {
  const CreateProfileStep2({super.key});

  @override
  State<CreateProfileStep2> createState() => _CreateProfileStep2State();
}

class _CreateProfileStep2State extends State<CreateProfileStep2>
    with SingleTickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _messengerController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _mobileNoController = MaskedTextController(mask: '0000-000-000');

  late final FocusNode _addressFocus;
  late final FocusNode _facebookFocus;
  late final FocusNode _messengerFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _mobileNoFocus;

  // Animation controller
  late AnimationController _animationController;

  // State
  bool _isLoading = false;
  bool _isCreateError = false;
  Map<String, bool> _focusStates = {};
  Map<String, bool> _validStates = {};

  Future<void> handleCreateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final address = _addressController.text.trim();
    final email = _emailController.text.trim();
    final number = _mobileNoController.text;
    final facebook = _facebookController.text;
    final messenger = _messengerController.text;

    // Validation checks
    if (address.isEmpty) {
      _addressFocus.requestFocus();
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (email.isEmpty) {
      _emailFocus.requestFocus();
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (number.isEmpty) {
      _mobileNoFocus.requestFocus();
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (facebook.isEmpty) {
      _facebookFocus.requestFocus();
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (messenger.isEmpty) {
      _messengerFocus.requestFocus();
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    final registrationProvider = Provider.of<RegistrationProvider>(
      context,
      listen: false,
    );

    final fullName = registrationProvider.basicInfo!.fullName;
    final birthdate = registrationProvider.basicInfo!.birthdate;

    Profile profile = Profile(
      facebook: facebook,
      messenger: messenger,
      basicInfo: BasicInfo(fullName: fullName, birthdate: birthdate),
      address: address,
      isActive: true,
      contact: Contact(email: email, number: "0${number.replaceAll('-', '')}"),
    );

    ClientApi clientApi = ClientApi(
      accessTokenProvider.authToken?.accessToken ?? "",
    );

    try {
      Response response = await clientApi.createMeProfile(profile.toJson());

      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });

        // Add a small delay before navigation for smoother transition
        await Future.delayed(const Duration(milliseconds: 300));

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(redirectPath: "/"),
            ),
          );
        }
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _isCreateError = true;
      });

      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSafeSnackBar(errorResponse.message.toString());
      }
    }
  }

  void _setupFocusListeners() {
    _addressFocus.addListener(() => _onFocusChange(_addressFocus, 'address'));
    _facebookFocus.addListener(
      () => _onFocusChange(_facebookFocus, 'facebook'),
    );
    _messengerFocus.addListener(
      () => _onFocusChange(_messengerFocus, 'messenger'),
    );
    _emailFocus.addListener(() => _onFocusChange(_emailFocus, 'email'));
    _mobileNoFocus.addListener(() => _onFocusChange(_mobileNoFocus, 'mobile'));
  }

  void _onFocusChange(FocusNode node, String field) {
    setState(() {
      _focusStates[field] = node.hasFocus;
      if (node.hasFocus) {}
    });
  }

  void _setupTextListeners() {
    _addressController.addListener(
      () => _validateField('address', _addressController.text.isNotEmpty),
    );
    _facebookController.addListener(
      () => _validateField('facebook', _facebookController.text.isNotEmpty),
    );
    _messengerController.addListener(
      () => _validateField('messenger', _messengerController.text.isNotEmpty),
    );
    _emailController.addListener(
      () => _validateField('email', _emailController.text.contains('@')),
    );
    _mobileNoController.addListener(
      () => _validateField('mobile', _mobileNoController.text.length > 9),
    );
  }

  void _validateField(String field, bool isValid) {
    setState(() {
      _validStates[field] = isValid;
    });
  }

  bool get _isFormValid {
    return _validStates['address'] == true &&
        _validStates['facebook'] == true &&
        _validStates['messenger'] == true &&
        _validStates['email'] == true &&
        _validStates['mobile'] == true;
  }

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    _addressFocus = FocusNode();
    _facebookFocus = FocusNode();
    _messengerFocus = FocusNode();
    _emailFocus = FocusNode();
    _mobileNoFocus = FocusNode();

    // Initialize focus and validation states
    _focusStates = {
      'address': false,
      'facebook': false,
      'messenger': false,
      'email': false,
      'mobile': false,
    };

    _validStates = {
      'address': false,
      'facebook': false,
      'messenger': false,
      'email': false,
      'mobile': false,
    };

    // Setup focus and text listeners
    _setupFocusListeners();
    _setupTextListeners();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    _addressController.dispose();
    _facebookController.dispose();
    _messengerController.dispose();
    _emailController.dispose();
    _mobileNoController.dispose();

    _addressFocus.dispose();
    _facebookFocus.dispose();
    _messengerFocus.dispose();
    _emailFocus.dispose();
    _mobileNoFocus.dispose();

    _animationController.dispose();

    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required int index,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    final isActive =
        _focusStates[[
          'address',
          'facebook',
          'messenger',
          'email',
          'mobile',
        ][index]] ??
        false;

    final isValid =
        _validStates[[
          'address',
          'facebook',
          'messenger',
          'email',
          'mobile',
        ][index]] ??
        false;

    final hasError = _isCreateError && !isValid;

    return FadeInUp(
      from: 20,
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: 200 + (index * 100)),
      child: AnimatedContainer(
        margin: EdgeInsets.only(bottom: 15),
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color:
                          hasError
                              ? AppColors.danger.withAlpha(100)
                              : AppColors.primary.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
          border: Border.all(
            color:
                hasError
                    ? AppColors.danger
                    : isActive
                    ? AppColors.primary
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            fillColor: AppColors.primary,
            labelText: label,
            prefixText: prefixText,
            labelStyle: GoogleFonts.urbanist(
              color:
                  hasError
                      ? AppColors.danger
                      : isActive
                      ? AppColors.primary
                      : Colors.black45,
              fontSize: 14.0,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              size: 20.0,
              color:
                  hasError
                      ? AppColors.danger
                      : isActive
                      ? AppColors.primary
                      : Colors.black45,
            ),

            prefixIconColor: AppColors.primary,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            floatingLabelAlignment: FloatingLabelAlignment.start,
          ),
          style: GoogleFonts.urbanist(
            color: hasError ? AppColors.danger : AppColors.primary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.primary.withAlpha(50),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20.0),

                        // Back button and progress
                        FadeIn(
                          duration: const Duration(milliseconds: 600),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Step indicators
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  Container(
                                    width: 30,
                                    height: 2,
                                    color: AppColors.primary,
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "2",
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30.0),

                        // Title
                        FadeInDown(
                          from: 30,
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Complete Your Profile",
                            style: GoogleFonts.urbanist(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        FadeInDown(
                          from: 20,
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            "Please provide your contact details and address",
                            style: GoogleFonts.urbanist(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30.0),

                        // Input fields
                        _buildInputField(
                          controller: _addressController,
                          focusNode: _addressFocus,
                          label: "Present address",
                          icon: Ionicons.map_outline,
                          index: 0,
                        ),

                        const SizedBox(height: 10.0),

                        FadeInDown(
                          from: 10,
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Social Accounts",
                                style: GoogleFonts.urbanist(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Connect your accounts for better communication",
                                style: GoogleFonts.urbanist(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        _buildInputField(
                          controller: _facebookController,
                          focusNode: _facebookFocus,
                          label: "Facebook",
                          icon: Icons.facebook_outlined,
                          index: 1,
                        ),

                        _buildInputField(
                          controller: _messengerController,
                          focusNode: _messengerFocus,
                          label: "Messenger",
                          icon: Icons.messenger_outline_outlined,
                          index: 2,
                        ),

                        const SizedBox(height: 10.0),

                        FadeInDown(
                          from: 10,
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 900),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Contact Information",
                                style: GoogleFonts.urbanist(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "We'll use these to reach out to you",
                                style: GoogleFonts.urbanist(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        _buildInputField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: "Email",
                          icon: Ionicons.mail_outline,
                          index: 3,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        _buildInputField(
                          controller: _mobileNoController,
                          focusNode: _mobileNoFocus,
                          label: "Mobile Number",
                          icon: Ionicons.call_outline,
                          index: 4,
                          keyboardType: TextInputType.phone,
                          prefixText: '+63 ',
                        ),

                        const SizedBox(height: 30.0),

                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Submit and back buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    FadeInUp(
                      from: 20,
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 1400),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                          boxShadow:
                              _isFormValid
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: ElevatedButton(
                          onPressed:
                              _isFormValid && !_isLoading
                                  ? handleCreateProfile
                                  : null,
                          child:
                              _isLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Submit',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color:
                                              _isFormValid
                                                  ? Colors.white.withOpacity(
                                                    0.2,
                                                  )
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Ionicons.checkmark_outline,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    FadeInUp(
                      from: 20,
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 1500),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed:
                              !_isLoading ? () => Navigator.pop(context) : null,

                          child: Text(
                            "Back",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

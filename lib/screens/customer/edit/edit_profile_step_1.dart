import 'package:flutter/material.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class EditProfileStep1 extends StatefulWidget {
  const EditProfileStep1({super.key});

  @override
  State<EditProfileStep1> createState() => _EditProfileStep1State();
}

class _EditProfileStep1State extends State<EditProfileStep1>
    with SingleTickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _messengerController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late final FocusNode _fullNameFocus;
  late final FocusNode _facebookFocus;
  late final FocusNode _messengerFocus;
  late final FocusNode _addressFocus;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State
  String _selectedGender = "male";
  final String _selectedBirthdate = "1999-01-01";
  String _accessToken = "";
  String _birthDate = "";
  int _activeField = -1;

  Future handleSaveBasicInfo() async {
    final fullName = _fullNameController.text.trim();
    final facebook = _facebookController.text.trim();
    final messenger = _messengerController.text.trim();
    final address = _addressController.text.trim();

    if (fullName.isEmpty) {
      _fullNameFocus.requestFocus();
      return;
    }

    // Animate out before navigating
    _animationController.reverse().then((_) {
      Provider.of<RegistrationProvider>(context, listen: false).setBasicInfo(
        BasicInfo(
          birthdate:
              _selectedBirthdate != "1999-01-01"
                  ? _selectedBirthdate
                  : _birthDate,
          fullName: fullName,
          gender: _selectedGender,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 900)).then((_) {
      if (!mounted) return;
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    _fullNameFocus = FocusNode();
    _facebookFocus = FocusNode();
    _messengerFocus = FocusNode();
    _addressFocus = FocusNode();

    // Set up listeners for focus changes
    _fullNameFocus.addListener(
      () => _onFocusChange(0, _fullNameFocus.hasFocus),
    );
    _facebookFocus.addListener(
      () => _onFocusChange(1, _facebookFocus.hasFocus),
    );
    _messengerFocus.addListener(
      () => _onFocusChange(2, _messengerFocus.hasFocus),
    );
    _addressFocus.addListener(() => _onFocusChange(3, _addressFocus.hasFocus));

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    _fullNameController.text = clientProvider.profile?.basicInfo.fullName ?? '';
    _facebookController.text = clientProvider.profile?.facebook ?? '';
    _messengerController.text = clientProvider.profile?.messenger ?? '';
    _addressController.text = clientProvider.profile?.address ?? '';
    _selectedGender = clientProvider.profile?.basicInfo.gender ?? '';
    _birthDate = clientProvider.profile?.basicInfo.birthdate ?? '';

    // Start animation
    _animationController.forward();
  }

  void _onFocusChange(int fieldIndex, bool hasFocus) {
    if (hasFocus) {
      setState(() {
        _activeField = fieldIndex;
      });
    } else if (_activeField == fieldIndex) {
      setState(() {
        _activeField = -1;
      });
    }
  }

  @override
  void dispose() {
    _fullNameFocus.dispose();
    _facebookFocus.dispose();
    _messengerFocus.dispose();
    _addressFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Your Profile",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Ionicons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(position: _slideAnimation, child: child),
            );
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  ..._buildAnimatedFields(),

                  const SizedBox(height: 10.0),
                  // Gender Selection with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.6,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: _buildGenderSelection(),
                  ),

                  const SizedBox(height: 30.0),
                  // Continue button with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.7,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: _buildContinueButton(),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Ionicons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 15),
          Text(
            "Tell us about yourself",
            style: GoogleFonts.urbanist(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Fill in your details to complete your profile",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.primary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedFields() {
    final fields = [
      {
        'controller': _fullNameController,
        'focusNode': _fullNameFocus,
        'label': 'Full name',
        'icon': Ionicons.person_outline,
        'index': 0,
      },
      {
        'controller': _facebookController,
        'focusNode': _facebookFocus,
        'label': 'Facebook profile',
        'icon': Ionicons.logo_facebook,
        'index': 1,
      },
      {
        'controller': _messengerController,
        'focusNode': _messengerFocus,
        'label': 'Messenger',
        'icon': Ionicons.chatbubbles_outline,
        'index': 2,
      },
      {
        'controller': _addressController,
        'focusNode': _addressFocus,
        'label': 'Address',
        'icon': Ionicons.location_outline,
        'index': 3,
      },
    ];

    return fields.asMap().entries.map((entry) {
      final index = entry.key;
      final field = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      0.2 + (index * 0.1),
                      0.7 + (index * 0.05),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: child,
              ),
            );
          },
          child: _buildTextField(
            controller: field['controller'] as TextEditingController,
            focusNode: field['focusNode'] as FocusNode,
            labelText: field['label'] as String,
            icon: field['icon'] as IconData,
            isActive: _activeField == (field['index'] as int),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required IconData icon,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.urbanist(
            color:
                isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.5),
            fontSize: 10.0,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              icon,
              size: 20.0,
              color:
                  isActive
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.5),
            ),
          ),
          fillColor: AppColors.primary,
          prefixIconColor: AppColors.primary,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          floatingLabelAlignment: FloatingLabelAlignment.start,
        ),
        style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 12.0),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 15.0),
          GenderSelectionWidget(
            onGenderSelected: (gender) {
              setState(() {
                _selectedGender = gender!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () async {
        if (context.mounted) {
          handleSaveBasicInfo();
        }
      },

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Continue'),
          const SizedBox(width: 8),
          Icon(Ionicons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}

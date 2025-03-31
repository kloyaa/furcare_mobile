import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/pet_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class AddNewPet extends StatefulWidget {
  const AddNewPet({super.key});

  @override
  State<AddNewPet> createState() => _AddNewPetState();
}

class _AddNewPetState extends State<AddNewPet>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _specieController = TextEditingController();
  final _ageController = TextEditingController();
  final _identificationController = TextEditingController();
  final _feedingInsController = TextEditingController();
  final _medicInsController = TextEditingController();

  late final FocusNode _nameFocus;
  late final FocusNode _specieFocus;
  late final FocusNode _ageFocus;
  late final FocusNode _identificationFocus;
  late final FocusNode _feedingInsFocus;
  late final FocusNode _medicInsFocus;

  // State
  final bool _isCreateError = false;
  final bool _bitingHistory = false;
  String _selectedGender = "male";
  String _accessToken = "";

  // Animation controllers
  late AnimationController _formAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  // Hover states for buttons
  bool _isSaveHovered = false;
  bool _isBackHovered = false;

  // Input field hover states
  Map<String, bool> _fieldHoverStates = {
    'name': false,
    'age': false,
    'breed': false,
  };

  Future<void> handleAddNewPet() async {
    ClientApi clientApi = ClientApi(_accessToken);

    final name = _nameController.text.trim();
    final specie = _specieController.text.trim();
    final age = _ageController.text.trim();
    final identification = _identificationController.text.trim();
    final feeding = _feedingInsController.text.trim();
    final medication = _medicInsController.text.trim();

    if (name.isEmpty) {
      _nameFocus.requestFocus();
    }
    if (specie.isEmpty) {
      _specieFocus.requestFocus();
    }
    if (age.isEmpty) {
      _ageFocus.requestFocus();
    }
    if (identification.isEmpty) {
      _identificationFocus.requestFocus();
    }
    if (feeding.isEmpty) {
      _feedingInsFocus.requestFocus();
    }
    if (medication.isEmpty) {
      _medicInsFocus.requestFocus();
    }

    try {
      await clientApi.createPet(
        CreatePetPayload(
          name: name,
          age: int.parse(age),
          gender: _selectedGender,
          breed: identification,
        ),
      );
      if (context.mounted) {
        _formAnimationController.reverse().then((_) {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        });
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSafeSnackBar(errorResponse.message, color: AppColors.danger);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize form animation controller
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create fade in animation
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );

    // Create slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOutQuint,
      ),
    );

    _nameFocus = FocusNode();
    _specieFocus = FocusNode();
    _ageFocus = FocusNode();
    _identificationFocus = FocusNode();
    _feedingInsFocus = FocusNode();
    _medicInsFocus = FocusNode();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    // Start animations after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _formAnimationController.dispose();

    _nameFocus.dispose();
    _specieFocus.dispose();
    _ageFocus.dispose();
    _identificationFocus.dispose();
    _feedingInsFocus.dispose();
    _medicInsFocus.dispose();

    super.dispose();
  }

  // Animated form field widget
  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String fieldKey = '',
    TextInputType keyboardType = TextInputType.text,
    int animationDelayMs = 0,
  }) {
    return AnimatedBuilder(
      animation: _formAnimationController,
      builder: (context, child) {
        // Delay each field's animation
        final double animationValue =
            _formAnimationController.value > (animationDelayMs / 800)
                ? (_formAnimationController.value - (animationDelayMs / 800)) *
                    (800 / (800 - animationDelayMs))
                : 0.0;

        if (animationValue <= 0) return const SizedBox.shrink();

        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Interval(animationDelayMs / 800, 1.0, curve: Curves.easeIn),
          ),
        );

        final slideAnim = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Interval(
              animationDelayMs / 800,
              1.0,
              curve: Curves.easeOutQuint,
            ),
          ),
        );

        return FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: MouseRegion(
              onEnter: (_) {
                if (fieldKey.isNotEmpty) {
                  setState(() {
                    _fieldHoverStates[fieldKey] = true;
                  });
                }
              },
              onExit: (_) {
                if (fieldKey.isNotEmpty) {
                  setState(() {
                    _fieldHoverStates[fieldKey] = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                  boxShadow:
                      _fieldHoverStates[fieldKey] == true
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [],
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
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: _fieldHoverStates[fieldKey] == true ? 1.1 : 1.0,
                      child: Icon(
                        icon,
                        size: 18.0,
                        color:
                            _isCreateError
                                ? AppColors.danger
                                : AppColors.primary.withOpacity(0.8),
                      ),
                    ),
                    prefixIconColor: AppColors.primary,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                  ),
                  style: TextStyle(
                    color:
                        _isCreateError ? AppColors.danger : AppColors.primary,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50.0),
              FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    "But your fur is our priority",
                    style: GoogleFonts.urbanist(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    "finish your fur profile",
                    style: GoogleFonts.urbanist(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Form fields with staggered animation
              _buildAnimatedFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                label: "Name",
                icon: Ionicons.paw_outline,
                fieldKey: 'name',
                animationDelayMs: 100,
              ),
              const SizedBox(height: 10.0),

              // Age and Breed in row - with staggered animations
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedFormField(
                      controller: _ageController,
                      focusNode: _ageFocus,
                      label: "Age",
                      icon: Ionicons.calendar_number_outline,
                      fieldKey: 'age',
                      keyboardType: TextInputType.number,
                      animationDelayMs: 200,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _buildAnimatedFormField(
                      controller: _identificationController,
                      focusNode: _identificationFocus,
                      label: "Breed",
                      icon: Icons.pets,
                      fieldKey: 'breed',
                      keyboardType: TextInputType.text,
                      animationDelayMs: 300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10.0),

              // Gender section with animation
              AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _formAnimationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                    ),
                  );

                  final slideAnim = Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _formAnimationController,
                      curve: const Interval(
                        0.5,
                        1.0,
                        curve: Curves.easeOutQuint,
                      ),
                    ),
                  );

                  return FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender',
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 8.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            GenderSelectionWidget(
                              onGenderSelected: (gender) {
                                setState(() {
                                  _selectedGender = gender!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Animated Save button
              AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _formAnimationController,
                      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                    ),
                  );

                  return FadeTransition(
                    opacity: fadeAnim,
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isSaveHovered = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isSaveHovered = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform:
                            Matrix4.identity()
                              ..scale(_isSaveHovered ? 1.02 : 1.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            handleAddNewPet();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: _isSaveHovered ? 4 : 2,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(child: Text('Save')),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10.0),

              // Animated Back button
              AnimatedBuilder(
                animation: _formAnimationController,
                builder: (context, child) {
                  final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _formAnimationController,
                      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                    ),
                  );

                  return FadeTransition(
                    opacity: fadeAnim,
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isBackHovered = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isBackHovered = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform:
                            Matrix4.identity()
                              ..scale(_isBackHovered ? 1.02 : 1.0),
                        child: OutlinedButton(
                          onPressed: () async {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            elevation: _isBackHovered ? 2 : 0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(child: Text("Back")),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

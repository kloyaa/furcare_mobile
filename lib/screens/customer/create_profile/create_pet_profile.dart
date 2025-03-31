import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/pet_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/widgets/snackbar.dart';

class CreatePet extends StatefulWidget {
  const CreatePet({super.key});

  @override
  State<CreatePet> createState() => _CreatePetState();
}

class _CreatePetState extends State<CreatePet> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();

  late final FocusNode _nameFocus;
  late final FocusNode _ageFocus;
  late final FocusNode _breedFocus;

  // State
  final bool _isCreateError = false;
  String _selectedGender = "male";
  String _accessToken = "";

  Future<void> handleCreatePet() async {
    ClientApi clientApi = ClientApi(_accessToken);

    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final breed = _breedController.text.trim();

    if (name.isEmpty) {
      _nameFocus.requestFocus();
    }

    if (age.isEmpty) {
      _ageFocus.requestFocus();
    }
    if (breed.isEmpty) {
      _breedFocus.requestFocus();
    }

    try {
      await clientApi.createPet(
        CreatePetPayload(
          name: name,
          age: int.parse(age),
          gender: _selectedGender,
          breed: breed,
        ),
      );
      if (context.mounted) {
        showSafeSnackBar("Updated successfully!", color: Colors.green);

        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/c/main');
          }
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
    _nameFocus = FocusNode();
    _ageFocus = FocusNode();
    _breedFocus = FocusNode();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    _breedFocus.dispose();
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
              Text(
                "But your fur is our priority",
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "finish your fur profile",
                style: GoogleFonts.urbanist(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        decoration: InputDecoration(
                          fillColor: AppColors.primary,
                          labelText: "Name",
                          labelStyle: GoogleFonts.urbanist(
                            color:
                                _isCreateError
                                    ? AppColors.danger
                                    : AppColors.primary.withOpacity(0.5),
                            fontSize: 10.0,
                          ),
                          prefixIcon: Icon(
                            Ionicons.paw_outline,
                            size: 18.0,
                            color:
                                _isCreateError
                                    ? AppColors.danger
                                    : AppColors.primary,
                          ),
                          prefixIconColor: AppColors.primary,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                        ),
                        style: TextStyle(
                          color:
                              _isCreateError
                                  ? AppColors.danger
                                  : AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      child: TextFormField(
                        controller: _ageController,
                        focusNode: _ageFocus,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          fillColor: AppColors.primary,
                          labelText: "Age",
                          labelStyle: GoogleFonts.urbanist(
                            color:
                                _isCreateError
                                    ? AppColors.danger
                                    : AppColors.primary.withOpacity(0.5),
                            fontSize: 10.0,
                          ),
                          prefixIcon: Icon(
                            Ionicons.calendar_number_outline,
                            size: 18.0,
                            color:
                                _isCreateError
                                    ? AppColors.danger
                                    : AppColors.primary.withOpacity(0.8),
                          ),
                          prefixIconColor: AppColors.primary,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                        ),
                        style: TextStyle(
                          color:
                              _isCreateError
                                  ? AppColors.danger
                                  : AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      child: TextFormField(
                        controller: _breedController,
                        focusNode: _breedFocus,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          fillColor: AppColors.primary,
                          labelText: "Breed",
                          labelStyle: GoogleFonts.urbanist(
                            color:
                                _isCreateError
                                    ? AppColors.danger
                                    : AppColors.primary.withOpacity(0.5),
                            fontSize: 10.0,
                          ),
                          prefixIcon: Icon(
                            Icons.pets,
                            size: 18.0,
                            color:
                                _isCreateError
                                    ? AppColors.danger
                                    : AppColors.primary.withOpacity(0.8),
                          ),
                          prefixIconColor: AppColors.primary,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                        ),
                        style: TextStyle(
                          color:
                              _isCreateError
                                  ? AppColors.danger
                                  : AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sex',
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

              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  handleCreatePet();
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Save'),
                        const SizedBox(width: 2.0),
                        const Icon(Ionicons.checkbox_outline, size: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

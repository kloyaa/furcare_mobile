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

class _AddNewPetState extends State<AddNewPet> {
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
        showSafeSnackBar("Updated successfully!", color: Colors.green);

        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pop(context);
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
  }

  @override
  void dispose() {
    super.dispose();

    _nameFocus.dispose();
    _specieFocus.dispose();
    _ageFocus.dispose();
    _identificationFocus.dispose();
    _feedingInsFocus.dispose();
    _medicInsFocus.dispose();
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
              Container(
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
                          _isCreateError ? AppColors.danger : AppColors.primary,
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
                        controller: _identificationController,
                        focusNode: _identificationFocus,
                        keyboardType: TextInputType.number,
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
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  handleAddNewPet();
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Center(child: Text('Save')),
                ),
              ),
              const SizedBox(height: 10.0),
              OutlinedButton(
                onPressed: () async {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: Text(
                      "Back",
                      style: GoogleFonts.urbanist(
                        color: AppColors.primary,
                        fontSize: 12.0,
                      ),
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

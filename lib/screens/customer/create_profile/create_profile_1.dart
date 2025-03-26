import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class CreateProfileStep1 extends StatefulWidget {
  const CreateProfileStep1({super.key});

  @override
  State<CreateProfileStep1> createState() => _CreateProfileStep1State();
}

class _CreateProfileStep1State extends State<CreateProfileStep1> {
  final TextEditingController _fullNameController = TextEditingController();
  late final FocusNode _fullNameFocus;

  // State
  final String _selectedGender = "male";
  final String _selectedBirthdate = "1999-01-01";

  Future handleSaveBasicInfo() async {
    final fullName = _fullNameController.text.trim();

    if (fullName.isEmpty) {
      _fullNameFocus.requestFocus();
      return;
    }

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
  }

  @override
  void dispose() {
    super.dispose();

    _fullNameFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.secondary,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50.0),
              Text(
                "Hello, Welcome to Furcare! What's your name?",
                style: GoogleFonts.lilitaOne(
                  fontSize: 42.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextFormField(
                  controller: _fullNameController,
                  focusNode: _fullNameFocus,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Write here",
                    labelStyle: GoogleFonts.urbanist(
                      color: AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Ionicons.person_outline,
                      size: 18.0,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    prefixIconColor: AppColors.primary,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                  ),
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.5),
                    fontSize: 12.0,
                  ),
                ),
              ),
              const Spacer(flex: 5),
              ElevatedButton(
                onPressed: () async {
                  if (context.mounted) {
                    handleSaveBasicInfo();
                  }
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.urbanist(
                            color: AppColors.secondary,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        const Icon(Ionicons.arrow_forward_outline, size: 12),
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

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';

class StaffEditProfileStep1 extends StatefulWidget {
  const StaffEditProfileStep1({super.key});

  @override
  State<StaffEditProfileStep1> createState() => _StaffEditProfileStep1State();
}

class _StaffEditProfileStep1State extends State<StaffEditProfileStep1> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  late final FocusNode _firstNameFocus;
  late final FocusNode _lastNameFocus;

  // State
  String _selectedGender = "male";
  String _selectedBirthdate = "1999-01-01";
  String _accessToken = "";
  String _birthDate = "";

  Future handleSaveBasicInfo() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      _firstNameFocus.requestFocus();
      return;
    }
    if (lastName.isEmpty) {
      _lastNameFocus.requestFocus();
      return;
    }

    Provider.of<RegistrationProvider>(context, listen: false).setBasicInfo(
      BasicInfo(
        birthdate:
            _selectedBirthdate != "1999-01-01"
                ? _selectedBirthdate
                : _birthDate,
        gender: _selectedGender,
        fullName: '',
      ),
    );
    Navigator.pushNamed(context, '/s/edit/profile/2');
  }

  @override
  void initState() {
    super.initState();

    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';

    _firstNameController.text =
        clientProvider.profile?.basicInfo.fullName ?? '';
  }

  @override
  void dispose() {
    super.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Profile",
            style: GoogleFonts.urbanist(
              color: AppColors.primary,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.secondary,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextFormField(
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        decoration: InputDecoration(
                          fillColor: AppColors.primary,
                          labelText: "First name",
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
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextFormField(
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        decoration: InputDecoration(
                          fillColor: AppColors.primary,
                          labelText: "Last name",
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
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
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
              const SizedBox(height: 10.0),
              Text(
                'Birthday',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 8.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarDatePicker2(
                      config: CalendarDatePicker2Config(
                        calendarType: CalendarDatePicker2Type.single,
                        currentDate: DateTime.parse(_birthDate),
                      ),
                      displayedMonthDate: DateTime.parse(_birthDate),
                      value: const [],
                      onValueChanged: (dates) {
                        final String date = dates[0].toIso8601String();
                        _selectedBirthdate = date.substring(0, 10);
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
                    child: Text(
                      'Continue',
                      style: GoogleFonts.urbanist(
                        color: AppColors.secondary,
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

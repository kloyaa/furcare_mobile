import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

class StaffEditProfileStep2 extends StatefulWidget {
  const StaffEditProfileStep2({super.key});

  @override
  State<StaffEditProfileStep2> createState() => _StaffEditProfileStep2State();
}

class _StaffEditProfileStep2State extends State<StaffEditProfileStep2> {
  final TextEditingController _presentController = TextEditingController();
  final TextEditingController _permanentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _mobileNoController = MaskedTextController(mask: '0000-000-000');

  late final FocusNode _presentFocus;
  late final FocusNode _permanentFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _mobileNoFocus;

  // State
  final bool _isCreateError = false;

  Future handleCreateProfile() async {
    final present = _presentController.text.trim();
    final permanent = _permanentController.text.trim();
    final email = _emailController.text.trim();
    final number = _mobileNoController.text;

    if (present.isEmpty) {
      _presentFocus.requestFocus();
      return;
    }
    if (permanent.isEmpty) {
      _permanentFocus.requestFocus();
      return;
    }
    if (email.isEmpty) {
      _emailFocus.requestFocus();
      return;
    }
    if (number.isEmpty) {
      _mobileNoFocus.requestFocus();
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
      basicInfo: BasicInfo(fullName: fullName, birthdate: birthdate),
      address: present,
      isActive: true,
      contact: Contact(email: email, number: "0${number.replaceAll('-', '')}"),
      facebook: '',
      messenger: '',
    );

    ClientApi clientApi = ClientApi(
      accessTokenProvider.authToken?.accessToken ?? "",
    );

    try {
      await clientApi.updateeMeProfile(profile.toJson());

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(redirectPath: "/s/main"),
          ),
        );
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
    _presentFocus = FocusNode();
    _permanentFocus = FocusNode();
    _emailFocus = FocusNode();
    _mobileNoFocus = FocusNode();

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    _presentController.text = clientProvider.profile?.address ?? '';
    _emailController.text = clientProvider.profile?.contact.email ?? '';
    _mobileNoController.text =
        clientProvider.profile?.contact.number.substring(1, 11) ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _presentFocus.dispose();
    _permanentFocus.dispose();
    _emailFocus.dispose();
    _mobileNoFocus.dispose();
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextFormField(
                  controller: _presentController,
                  focusNode: _presentFocus,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Present address",
                    labelStyle: GoogleFonts.urbanist(
                      color:
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Ionicons.map_outline,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextFormField(
                  controller: _permanentController,
                  focusNode: _permanentFocus,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Permanent address",
                    labelStyle: GoogleFonts.urbanist(
                      color:
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Ionicons.map_outline,
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
              // Contact starts here
              const SizedBox(height: 40.0),
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
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Ionicons.mail_outline,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextFormField(
                  controller: _mobileNoController,
                  focusNode: _mobileNoFocus,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Mobile No.",
                    prefixText: '+63',
                    labelStyle: GoogleFonts.urbanist(
                      color:
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Ionicons.call_outline,
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
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  handleCreateProfile();
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
                      'Save',
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

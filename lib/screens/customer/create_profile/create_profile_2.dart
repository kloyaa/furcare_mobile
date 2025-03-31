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

class CreateProfileStep2 extends StatefulWidget {
  const CreateProfileStep2({super.key});

  @override
  State<CreateProfileStep2> createState() => _CreateProfileStep2State();
}

class _CreateProfileStep2State extends State<CreateProfileStep2> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _messengerController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final _mobileNoController = MaskedTextController(mask: '0000-000-000');

  late final FocusNode _facebookFocus;
  late final FocusNode _messengerFocus;

  late final FocusNode _addresstFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _mobileNoFocus;

  // State
  final bool _isCreateError = false;

  Future handleCreateProfile() async {
    final address = _addressController.text.trim();
    final email = _emailController.text.trim();
    final number = _mobileNoController.text;
    final facebook = _facebookController.text;
    final messenger = _messengerController.text;

    if (address.isEmpty) {
      _addresstFocus.requestFocus();
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

    if (facebook.isEmpty) {
      _facebookFocus.requestFocus();
      return;
    }
    if (messenger.isEmpty) {
      _messengerFocus.requestFocus();
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
    final gender = registrationProvider.basicInfo!.gender;

    Profile profile = Profile(
      facebook: facebook,
      messenger: messenger,
      basicInfo: BasicInfo(
        fullName: fullName,
        birthdate: birthdate,
        gender: gender,
      ),
      address: address,
      isActive: true,
      contact: Contact(email: email, number: "0${number.replaceAll('-', '')}"),
    );

    print(profile.toJson());

    ClientApi clientApi = ClientApi(
      accessTokenProvider.authToken?.accessToken ?? "",
    );

    try {
      Response response = await clientApi.createMeProfile(profile.toJson());

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(redirectPath: "/"),
          ),
        );
      }

      print(response.data);
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSafeSnackBar(errorResponse.message.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _addresstFocus = FocusNode();
    _facebookFocus = FocusNode();
    _messengerFocus = FocusNode();
    _emailFocus = FocusNode();
    _mobileNoFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _addresstFocus.dispose();
    _facebookFocus.dispose();
    _messengerFocus.dispose();
    _emailFocus.dispose();
    _mobileNoFocus.dispose();
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
                child: TextFormField(
                  controller: _addressController,
                  focusNode: _addresstFocus,
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
              // Contact starts here
              const SizedBox(height: 40.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
                child: TextFormField(
                  controller: _facebookController,
                  focusNode: _facebookFocus,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Facebook",
                    labelStyle: GoogleFonts.urbanist(
                      color:
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Icons.facebook_outlined,
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
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
                child: TextFormField(
                  controller: _messengerController,
                  focusNode: _messengerFocus,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Messenger",
                    labelStyle: GoogleFonts.urbanist(
                      color:
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Icons.messenger_outline_outlined,
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
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
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
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
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

                child: SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Submit')),
                ),
              ),
              const SizedBox(height: 10.0),
              OutlinedButton(
                onPressed: () async {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                child: SizedBox(
                  width: double.infinity,
                  child: Center(child: Text("Back")),
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

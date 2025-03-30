import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/owner_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/widgets/snackbar.dart';

class EditOwner extends StatefulWidget {
  const EditOwner({super.key});

  @override
  State<EditOwner> createState() => _CreateOwnerState();
}

class _CreateOwnerState extends State<EditOwner> {
  final TextEditingController _workController = TextEditingController();
  final _emergenyNoController = MaskedTextController(mask: '0000-000-000');
  late final FocusNode _workFocus;
  late final FocusNode _emergenyNoFocus;

  // State
  final bool _isCreateError = false;
  String _accessToken = "";

  Future<void> handleCreateOwner() async {
    ClientApi clientApi = ClientApi(_accessToken);

    final emergencyNo = _emergenyNoController.text.trim();
    final work = _workController.text.trim();

    if (emergencyNo.isEmpty) {
      return _emergenyNoFocus.requestFocus();
    }

    if (work.isEmpty) {
      return _workFocus.requestFocus();
    }

    try {
      await clientApi.updateOwner(
        OwnerProfilePayload(
          emergencyContactNo: "0${emergencyNo.replaceAll('-', '')}",
          work: work,
        ),
      );
      if (context.mounted) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(redirectPath: "/c/main"),
            ),
          );
        }
      }
    } on DioException catch (e) {
      print(e.response!.data);
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSafeSnackBar(errorResponse.message.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _workFocus = FocusNode();
    _emergenyNoFocus = FocusNode();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    _workController.text = clientProvider.ownerProfile?.work ?? '';
    _emergenyNoController.text =
        clientProvider.ownerProfile?.emergencyContactNo.substring(1, 11) ?? '';
  }

  @override
  void dispose() {
    super.dispose();

    _workFocus.dispose();
    _emergenyNoFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Owner Info",
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
                  controller: _workController,
                  focusNode: _workFocus,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Work",
                    labelStyle: GoogleFonts.urbanist(
                      color:
                          _isCreateError
                              ? AppColors.danger
                              : AppColors.primary.withOpacity(0.5),
                      fontSize: 10.0,
                    ),
                    prefixIcon: Icon(
                      Ionicons.briefcase_outline,
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
                  controller: _emergenyNoController,
                  focusNode: _emergenyNoFocus,
                  decoration: InputDecoration(
                    fillColor: AppColors.primary,
                    labelText: "Emergency No.",
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
                  handleCreateOwner();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
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

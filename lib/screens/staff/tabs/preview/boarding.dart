import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/screens/others/success.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PreviewBoarding extends StatefulWidget {
  const PreviewBoarding({super.key});

  @override
  State<PreviewBoarding> createState() => _PreviewBoardingState();
}

class _PreviewBoardingState extends State<PreviewBoarding> {
  // State
  String _accessToken = "";

  Future<dynamic> getBookingDetails() async {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final application = arguments['application'];
    final booking = arguments['booking'];

    BookingApi bookingApi = BookingApi(_accessToken);
    Response<dynamic> response = await bookingApi.getBookingDetails(
      application,
    );

    return response.data;
  }

  Future<dynamic> updateBookingStatus(String status) async {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final booking = arguments['booking'];
    StaffApi staffApi = StaffApi(_accessToken);

    try {
      UpdateBookingStatusPayload payload = UpdateBookingStatusPayload(
        status: status,
        booking: booking,
      );
      await staffApi.updateBookingStatus(payload);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(redirectPath: "/s/main"),
          ),
        );
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 10.0,
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Preview",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.secondary,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Owner Information",
                    style: GoogleFonts.urbanist(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            "${arguments['profile']["firstName"]} ${arguments['profile']["lastName"]}",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            arguments['profile']["gender"] ?? "",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contact No.",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            arguments['profile']["contact"]["number"] ?? "",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pet Information",
                    style: GoogleFonts.urbanist(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            arguments['pet']["name"] ?? "",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Specie",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            arguments['pet']["specie"] ?? "",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            arguments['pet']["gender"] ?? "",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Identification",
                            style: GoogleFonts.urbanist(
                              fontSize: 8.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            arguments['pet']["identification"] ?? "",
                            style: GoogleFonts.urbanist(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            FutureBuilder(
              future: getBookingDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.urbanist(color: AppColors.primary),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      'No data available',
                      style: GoogleFonts.urbanist(color: AppColors.primary),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(20.0),
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Boarding",
                        style: GoogleFonts.urbanist(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${snapshot.data['cage']['title']} sized cage",
                        style: GoogleFonts.urbanist(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${snapshot.data['daysOfStay']} day(s)",
                        style: GoogleFonts.urbanist(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      ElevatedButton(
                        onPressed: () async {
                          execOnConfirm(
                            message: "Accept booking?",
                            method: () => updateBookingStatus('confirmed'),
                            context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Accept',
                              style: GoogleFonts.urbanist(
                                color: AppColors.secondary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          execOnConfirm(
                            message: "Decline booking?",
                            method: () => updateBookingStatus('declined'),
                            context,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.danger.withOpacity(0.3),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Decline",
                              style: GoogleFonts.urbanist(
                                color: AppColors.danger,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

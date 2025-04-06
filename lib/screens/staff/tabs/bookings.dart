import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/staff_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class StaffTabBookings extends StatefulWidget {
  const StaffTabBookings({super.key});

  @override
  State<StaffTabBookings> createState() => _StaffTabBookingsState();
}

class _StaffTabBookingsState extends State<StaffTabBookings> {
  // State
  String _accessToken = "";
  String _status = "pending";

  List<dynamic> _bookings = [];

  Future<void> handleGetBookings(String status) async {
    StaffApi staffApi = StaffApi(_accessToken);
    try {
      Response<dynamic> response = await staffApi.getBookingsByAccessToken(
        status,
      );
      setState(() {
        _status = status;
        _bookings = response.data;
      });
    } on DioException catch (e) {
      print(e.response);
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

    handleGetBookings("pending");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child:
            _bookings.isEmpty
                ? Center(
                  child: Text(
                    "Bookings is empty",
                    style: GoogleFonts.urbanist(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 5.0),
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _bookings[index]['applicationType']
                                    .toString()
                                    .toUpperCase(),
                                style: GoogleFonts.urbanist(
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                "${_bookings[index]['profile']['firstName']} ${_bookings[index]['profile']['lastName']}"
                                    .toString()
                                    .toUpperCase(),
                                style: GoogleFonts.urbanist(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                "P${(_bookings[index]['payable'] ~/ 2)}.00",
                                style: GoogleFonts.rajdhani(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Object arguments = {
                                "application": _bookings[index]['application'],
                                "booking": _bookings[index]['_id'],
                                "pet": _bookings[index]["pet"],
                                "profile": _bookings[index]["profile"],
                              };
                              if (_bookings[index]['applicationType'] ==
                                  "boarding") {
                                Navigator.pushNamed(
                                  context,
                                  "/s/preview/boarding",
                                  arguments: arguments,
                                );
                              }
                              if (_bookings[index]['applicationType'] ==
                                  "transit") {
                                Navigator.pushNamed(
                                  context,
                                  "/s/preview/transit",
                                  arguments: arguments,
                                );
                              }
                              if (_bookings[index]['applicationType'] ==
                                  "grooming") {
                                Navigator.pushNamed(
                                  context,
                                  "/s/preview/grooming",
                                  arguments: arguments,
                                );
                              }
                            },
                            icon: const Icon(
                              Ionicons.chevron_forward_outline,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

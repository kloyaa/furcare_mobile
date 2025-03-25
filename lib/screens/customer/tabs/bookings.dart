import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/utils/enums/enum.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomerTabBookings extends StatefulWidget {
  const CustomerTabBookings({super.key});

  @override
  State<CustomerTabBookings> createState() => _CustomerTabBookingsState();
}

class _CustomerTabBookingsState extends State<CustomerTabBookings> {
  // State
  String _accessToken = "";
  String _status = "pending";

  List<dynamic> _bookings = [];

  Future<void> handleGetBookings(String status) async {
    BookingApi bookingApi = BookingApi(_accessToken);
    try {
      Response<dynamic> response = await bookingApi.getBookingsByAccessToken(
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
      appBar: AppBar(
        actions: [
          DropdownButton<String>(
            value: _status,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              handleGetBookings(newValue!);
            },
            items:
                BookingStatus.values.map((status) {
                  return DropdownMenuItem<String>(
                    value: status.toString().split('.').last,
                    child: Text(
                      status.toString().split('.').last,
                      style: GoogleFonts.urbanist(fontSize: 12.0),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: ListView.builder(
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 5.0),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bookings[index]['applicationType']
                        .toString()
                        .toUpperCase(),
                    style: GoogleFonts.urbanist(
                      fontSize: 6.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    _bookings[index]['pet']["name"].toString().toUpperCase(),
                    style: GoogleFonts.urbanist(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "P${_bookings[index]['payable']}.00",
                    style: GoogleFonts.rajdhani(
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
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

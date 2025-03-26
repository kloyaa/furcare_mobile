import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/booking_api.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/models/booking_payload.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/payment/preview.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/widgets/snackbar.dart';

class BookGrooming extends StatefulWidget {
  const BookGrooming({super.key});

  @override
  State<BookGrooming> createState() => _BookGroomingState();
}

class _BookGroomingState extends State<BookGrooming> {
  // State
  String _accessToken = "";
  String _selectedScheduleId = "";
  String _selectedPet = "";
  String _selectedPetId = "";
  List _pets = [];

  Future<void> handleSubmit() async {
    BookingApi booking = BookingApi(_accessToken);

    if (_selectedScheduleId.isEmpty) {
      return showSafeSnackBar(
        "Please select a schedule",
        color: AppColors.danger,
      );
    }

    if (_selectedPetId.isEmpty) {
      return showSafeSnackBar("Please select a pet", color: AppColors.danger);
    }

    try {
      Response<dynamic> response = await booking.groomingBooking(
        GroomingPayload(pet: _selectedPetId, schedule: _selectedScheduleId),
      );

      if (context.mounted) {
        showSafeSnackBar("Booked successfully!", color: Colors.green);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PaymentPreview(
                  serviceName: "grooming",
                  date: response.data['date'],
                  referenceNo: response.data['referenceNo'],
                ),
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

  Future<List<dynamic>> handleGetSchedules() async {
    ClientApi clientApi = ClientApi(_accessToken);

    Response<dynamic> response = await clientApi.getSchedules();

    return response.data;
  }

  List<DropdownMenuItem<dynamic>> getPets() {
    List<DropdownMenuItem<dynamic>> items = [];
    for (var i = 0; i < _pets.length; i++) {
      DropdownMenuItem item = DropdownMenuItem(
        value: _pets[i]['_id'], // Assuming _id is the unique identifier
        child: Text(
          _pets[i]['name'],
          style: GoogleFonts.urbanist(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

      items.add(item);
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    _pets = clientProvider.pets ?? [];

    handleGetSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Grooming",
          style: GoogleFonts.urbanist(
            color: AppColors.primary,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Schedule  ',
              style: GoogleFonts.urbanist(
                color: AppColors.primary.withOpacity(0.5),
                fontWeight: FontWeight.w400,
                fontSize: 8.0,
              ),
            ),
            const SizedBox(height: 10.0),
            FutureBuilder(
              future: handleGetSchedules(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color:
                            _selectedScheduleId == snapshot.data?[index]['_id']
                                ? Colors.purple
                                : Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedScheduleId = snapshot.data?[index]['_id'];
                          });
                        },
                        title: Text(
                          snapshot.data?[index]['title'],
                          style: GoogleFonts.urbanist(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color:
                                _selectedScheduleId ==
                                        snapshot.data?[index]['_id']
                                    ? Colors.white
                                    : AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20.0),
            Text(
              'Select Pet',
              style: GoogleFonts.urbanist(
                color: AppColors.primary.withOpacity(0.5),
                fontWeight: FontWeight.w400,
                fontSize: 8.0,
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(5.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: DropdownButton<dynamic>(
                  value: _selectedPet.isNotEmpty ? _selectedPet : null,
                  underline: const SizedBox(),
                  onChanged: (dynamic newValue) {
                    setState(() {
                      _selectedPet = newValue!;
                      _selectedPetId = newValue;
                    });
                  },
                  items: getPets(),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                execOnConfirm(
                  message: "Proceed with pet grooming appointment",
                  method: () => handleSubmit(),
                  context,
                );
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
                    'Submit',
                    style: GoogleFonts.urbanist(
                      color: AppColors.secondary,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

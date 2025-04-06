import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/apis/fees_api.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/fees.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/staff/tabs/bookings.dart';
import 'package:furcare_app/screens/staff/tabs/inprogress_bookings.dart';
import 'package:furcare_app/screens/staff/tabs/settings.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class StaffMain extends StatefulWidget {
  const StaffMain({super.key});

  @override
  State<StaffMain> createState() => _StaffMainState();
}

class _StaffMainState extends State<StaffMain> {
  // State
  int _currentIndex = 0;
  String _accessToken = "";

  Future<void> handleGetProfile() async {
    ClientApi clientApi = ClientApi(_accessToken);
    try {
      Response<dynamic> response = await clientApi.getMeProfile();
      Profile profile = Profile.fromJson(response.data);

      if (context.mounted) {
        final clientProvider = Provider.of<ClientProvider>(
          context,
          listen: false,
        );

        clientProvider.setProfile(profile);
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (errorResponse.code == "99000") {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/c/create/profile');
        }
      }
    }
  }

  Future<void> handleGetPets() async {
    ClientApi clientApi = ClientApi(_accessToken);
    try {
      Response<dynamic> response = await clientApi.getMePets();
      List<dynamic> pets = response.data;

      if (pets.isEmpty) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/c/create/profile/pet');
        }
      }

      if (context.mounted) {
        final clientProvider = Provider.of<ClientProvider>(
          context,
          listen: false,
        );
        clientProvider.setPets(pets);
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
    }
  }

  Future<void> handleGetServiceFees() async {
    FeesApi appApi = FeesApi(_accessToken);
    try {
      Response<dynamic> response = await appApi.getServiceFees();
      List<dynamic> serviceFees = response.data;

      if (context.mounted) {
        final appProvider = Provider.of<FeesProvider>(context, listen: false);
        appProvider.setServiceFees(serviceFees);
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
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

    handleGetPets();
    handleGetProfile();
    handleGetServiceFees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 10.0),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.book_outlined, size: 15.0),
            title: Text(
              "Bookings",
              style: GoogleFonts.urbanist(fontSize: 10.0),
            ),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Ionicons.sync_outline, size: 15.0),
            title: Text(
              "In Progress",
              style: GoogleFonts.urbanist(fontSize: 10.0),
            ),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Ionicons.settings_outline, size: 15.0),
            title: Text(
              "Settings",
              style: GoogleFonts.urbanist(fontSize: 10.0),
            ),
            selectedColor: Colors.pink,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          StaffTabBookings(),
          StaffTabInprogressBookings(),
          StaffTabSettings(),
        ],
      ),
    );
  }
}

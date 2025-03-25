import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/client_api.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class CustomerTabPets extends StatefulWidget {
  const CustomerTabPets({super.key});

  @override
  State<CustomerTabPets> createState() => _CustomerTabPetsState();
}

class _CustomerTabPetsState extends State<CustomerTabPets> {
  // State
  String _accessToken = "";
  final List<dynamic> _pets = [];

  Future<List<dynamic>> handleGetPets() async {
    ClientApi clientApi = ClientApi(_accessToken);
    try {
      Response<dynamic> response = await clientApi.getMePets();
      return response.data;
    } on DioException {
      return [];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/c/add/pet");
        },
        icon: const Icon(Ionicons.add_outline),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: FutureBuilder(
          future: handleGetPets(),
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
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final pet = snapshot.data?[index];
                  return Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15.0),
                      leading: Icon(
                        Ionicons.paw,
                        color:
                            pet['gender'] == "male"
                                ? Colors.blueGrey
                                : Colors.pink,
                      ),
                      title: Text(
                        "${pet['name']}",
                        style: GoogleFonts.urbanist(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    pet['gender'] == "male"
                                        ? Ionicons.male
                                        : Ionicons.female,
                                    size: 10.0,
                                  ),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    pet['gender'],
                                    style: GoogleFonts.urbanist(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10.0),
                              Row(
                                children: [
                                  const Icon(
                                    Ionicons.calendar_number_outline,
                                    size: 10.0,
                                  ),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    pet['age'].toString(),
                                    style: GoogleFonts.urbanist(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

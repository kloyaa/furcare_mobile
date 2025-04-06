import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/models/ekyc.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/models/user_info.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/select_gender.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ServiceUsage extends StatefulWidget {
  const ServiceUsage({super.key});

  @override
  State<ServiceUsage> createState() => _ServiceUsageState();
}

class _ServiceUsageState extends State<ServiceUsage> {
  // State
  final String _accessToken = "";

  Future<List<dynamic>> handleGetServiceUsage() async {
    AdminApi adminApi = AdminApi(_accessToken);
    Response<dynamic> response = await adminApi.getServiceUsages();

    return response.data.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const SizedBox(),
        leadingWidth: 0,
        actions: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap:
                        () => Navigator.pushReplacementNamed(
                          context,
                          "/a/profile",
                        ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Profile",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 0.1,
                      ), // Border color
                    ),
                    tooltip: "Click to view",
                    color: Colors.white,
                    elevation: 0,
                    position: PopupMenuPosition.under,
                    child: Text(
                      "Reports",
                      style: GoogleFonts.urbanist(
                        color: AppColors.primary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'check_ins',
                            child: Text(
                              'Check ins',
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'service_usages',
                            child: Text(
                              'Service usages',
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'transactions',
                            child: Text(
                              'Transactions',
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                    onSelected: (String value) {
                      switch (value) {
                        case 'check_ins':
                          Navigator.pushReplacementNamed(
                            context,
                            "/a/report/checkins",
                          );
                          break;
                        case 'service_usages':
                          break;
                        case 'transactions':
                          Navigator.pushReplacementNamed(
                            context,
                            "/a/report/transactions",
                          );
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                  const SizedBox(width: 25.0),
                  GestureDetector(
                    onTap:
                        () => Navigator.pushReplacementNamed(
                          context,
                          "/a/management/staff",
                        ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Staffs",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  GestureDetector(
                    onTap:
                        () => Navigator.pushReplacementNamed(
                          context,
                          "/a/management/customers",
                        ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Users and Pets",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Sign out",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: handleGetServiceUsage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
              margin: const EdgeInsets.all(20.0),
              child: BarChart(snapshot.data!),
            );
          }
        },
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  final List<dynamic> responseData;

  const BarChart(this.responseData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: SfCartesianChart(
            backgroundColor: Colors.white,
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: const NumericAxis(),
            series: <BarSeries<dynamic, String>>[
              BarSeries<dynamic, String>(
                dataSource: responseData,
                animationDelay: 5,
                animationDuration: 3000,
                enableTooltip: true,
                xValueMapper: (datum, _) => datum.keys.first,
                yValueMapper: (datum, _) => datum.values.first,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

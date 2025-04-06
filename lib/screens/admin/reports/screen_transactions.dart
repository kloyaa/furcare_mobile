import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  // State
  final String _accessToken = "";

  Future<List<dynamic>> getTransactions() async {
    AdminApi adminApi = AdminApi(_accessToken);
    Response<dynamic> response = await adminApi.getTransactions();

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
                          Navigator.pushReplacementNamed(
                            context,
                            "/a/report/service-usage",
                          );
                          break;
                        case 'transactions':
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
        future: getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
              margin: const EdgeInsets.all(20.0),
              child: Table(snapshot.data!),
            );
          }
        },
      ),
    );
  }
}

class Table extends StatelessWidget {
  final List<dynamic> responseData;

  const Table(this.responseData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                border: const TableBorder(
                  horizontalInside: BorderSide(width: 0.1, color: Colors.grey),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'Staff',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Customer',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Address',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Contact',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Pet',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Specie',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Service',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Fee',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Date',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                rows:
                    responseData.map<DataRow>((data) {
                      String customer =
                          '${data['customer']['firstName']} ${data['customer']['lastName']}';
                      String address = data['customer']['address']['present'];
                      String contact = data['customer']['contact']['number'];
                      String pet = data['pet']['name'];
                      String specie = data['pet']['specie'];
                      String staff =
                          '${data['staff']['firstName']} ${data['staff']['lastName']}';
                      String service = data['service']['title'];
                      int fee = data['service']['fee'];
                      String date = DateFormat(
                        'MMM d, h:mm a',
                      ).format(DateTime.parse(data['date']));

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              staff,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              customer,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              address,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              contact,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              pet,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              specie,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                getIconByService(service),
                                const SizedBox(width: 5),
                                Text(
                                  service.toUpperCase(),
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '₱$fee.00',
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              date,
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

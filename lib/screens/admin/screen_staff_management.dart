import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:furcare_app/apis/admin_api.dart';
import 'package:furcare_app/models/active_status.dart';
import 'package:furcare_app/models/login_response.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AdminStaffManagement extends StatefulWidget {
  const AdminStaffManagement({super.key});

  @override
  State<AdminStaffManagement> createState() => _AdminStaffManagementState();
}

class _AdminStaffManagementState extends State<AdminStaffManagement> {
  // State
  String _accessToken = "";
  late Future<List<dynamic>> _staffsFuture;

  Future<List<dynamic>> handleGetStaffs() async {
    AdminApi adminApi = AdminApi(_accessToken);
    Response<dynamic> response = await adminApi.getStaffs();

    final staffs = response.data.toList();
    return staffs;
  }

  Future<void> handleUpdateActiveStatus(UpdateActiveStatus payload) async {
    AdminApi adminApi = AdminApi(_accessToken);

    try {
      UpdateActiveStatus update = UpdateActiveStatus(
        isActive: payload.isActive,
        user: payload.user,
      );
      await adminApi.updateProfileActiveStatus(update);
      if (context.mounted) {
        showSnackBar(
          context,
          "Status updated successfully!",
          color: Colors.green,
          fontSize: 14.0,
          duration: 1,
        );
      }
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 14.0,
        );
      }
    }
  }

  Future<void> handeDeleteUser(String id) async {
    AdminApi adminApi = AdminApi(_accessToken);
    try {
      await adminApi.deleteUser(id);
      if (context.mounted) {
        showSnackBar(
          context,
          "Deleted successfully!",
          color: Colors.green,
          fontSize: 14.0,
          duration: 1,
        );
      }

      setState(() {
        _staffsFuture = handleGetStaffs(); // Call handleGetStaffs() again
      });
    } on DioException catch (e) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(e.response?.data);
      if (context.mounted) {
        showSnackBar(
          context,
          errorResponse.message,
          color: AppColors.danger,
          fontSize: 14.0,
        );
      }
    }
  }

  @override
  void initState() {
    final accessTokenProvider = Provider.of<AuthTokenProvider>(
      context,
      listen: false,
    );

    // Retrieve the access token from the provider and assign it to _accessToken
    _accessToken = accessTokenProvider.authToken?.accessToken ?? '';
    _staffsFuture = handleGetStaffs();

    super.initState();
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
                          fontSize: 10.0,
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
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Staffs",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
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
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap:
                        () => Navigator.pushReplacementNamed(
                          context,
                          "/a/management/staff/enrollment",
                        ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Enroll Staff",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Sign out",
                        style: GoogleFonts.urbanist(
                          color: AppColors.primary,
                          fontSize: 10.0,
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
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          width: MediaQuery.of(context).size.width * 0.50,
          child: FutureBuilder<List<dynamic>>(
            future: _staffsFuture,
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
                final List<dynamic>? staffList = snapshot.data;
                return ListView.builder(
                  itemCount: staffList!.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];

                    final bool isActive = staff['profile']['isActive'];
                    final Map user = staffList[index];

                    return Container(
                      padding: const EdgeInsets.all(50.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/avatar_male.png', scale: 2),
                              const SizedBox(height: 20.0),
                              ToggleSwitch(
                                initialLabelIndex: isActive ? 0 : 1,
                                totalSwitches: 2,
                                activeBgColors: const [
                                  [Colors.green],
                                  [Colors.pink],
                                  [Colors.red],
                                ],
                                inactiveBgColor: Colors.grey.shade200,
                                customTextStyles: [
                                  GoogleFonts.urbanist(fontSize: 12.0),
                                ],
                                minHeight: 30.0,
                                labels: const ['Active', 'Inactive'],
                                onToggle: (index) {
                                  handleUpdateActiveStatus(
                                    UpdateActiveStatus(
                                      isActive: index == 0 ? true : false,
                                      user: staff['_id'],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 50.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Profile",
                                style: GoogleFonts.urbanist(
                                  fontSize: 10.0,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Firstname",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['firstName'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 18.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Lastname",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['lastName'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 18.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Birthday",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatBirthDate(
                                          DateTime.parse(
                                            staff['profile']['birthdate'],
                                          ),
                                        ),
                                        style: GoogleFonts.urbanist(
                                          fontSize: 18.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Gender",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['gender'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 18.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                "Account",
                                style: GoogleFonts.urbanist(
                                  fontSize: 10.0,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Username",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['username'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['email'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                "Contact",
                                style: GoogleFonts.urbanist(
                                  fontSize: 10.0,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['contact']['email'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mobile No.",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['contact']['number'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                "Address",
                                style: GoogleFonts.urbanist(
                                  fontSize: 10.0,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Present",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['address']['present'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 40.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Permanent",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 10.0,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        staff['profile']['address']['permanent'],
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14.0,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 50.0),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        "/a/management/staff/edit",
                                        arguments: user,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Edit',
                                              style: GoogleFonts.urbanist(
                                                color: AppColors.secondary,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            const SizedBox(width: 2.0),
                                            const Icon(
                                              Icons.note_alt_outlined,
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  OutlinedButton(
                                    onPressed: () async {
                                      handeDeleteUser(staff['_id']);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Delete',
                                              style: GoogleFonts.urbanist(
                                                color: Colors.red,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            const SizedBox(width: 2.0),
                                            const Icon(
                                              Ionicons.trash_bin_outline,
                                              size: 12,
                                              color: Colors.red, // Icon color
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // title:,
                      // subtitle: Text(staff['email']),
                      // trailing: Text('Created: ${staff['createdAt'].toString()}'),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

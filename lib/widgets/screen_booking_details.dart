import 'package:flutter/material.dart';
import 'package:furcare_app/extensions.dart';
import 'package:furcare_app/models/servcefee_info.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/card_extra_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final pet = booking['pet'];
    final branch = booking['branch'];
    final status = booking['status'];
    final days = booking['extension'] ?? 0;
    final List<ServiceFee> extraServices = ServiceFee.fromJsonList(
      booking['extraServices'],
    );

    final createdDate = DateTime.parse(booking['createdAt']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(createdDate);
    final formattedTime = DateFormat('h:mm a').format(createdDate);

    // Calculate the end date based on days
    String stayDurationText;
    if (days == 0) {
      // If days is 0, only show the booking date
      stayDurationText = DateFormat('MMM DD, yyyy').format(createdDate);
    } else {
      // Calculate end date by adding days to the created date
      final endDate = createdDate.add(Duration(days: days));
      final formattedEndDate = DateFormat('MMMM d').format(endDate);
      stayDurationText =
          '${DateFormat('MMMM d').format(createdDate)} to $formattedEndDate';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leadingWidth: 0,
        leading: SizedBox(),
        title: Center(
          child: Text(
            "Booking details",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Bar
            Container(
              width: double.infinity,
              color: _getStatusColor(status).withAlpha(50),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${status.toUpperCase()}',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Booking ID and Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Information',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Booking Cards
                  _buildInfoCard(
                    title: 'Booking ID',
                    value:
                        booking['_id']
                            .toString()
                            .substring(booking['_id'].toString().length - 8)
                            .toUpperCase(),
                    icon: Icons.confirmation_number_outlined,
                  ),

                  _buildInfoCard(
                    title: 'Booking Date extended for $days day(s)',
                    value: '$formattedDate at $formattedTime',
                    icon: Icons.calendar_today_outlined,
                  ),

                  _buildInfoCard(
                    title: 'Service Type',
                    value: booking['applicationType'].toString().capitalize(),
                    icon: Icons.medical_services_outlined,
                    chipColor: AppColors.primary.withAlpha(50),
                    textColor: AppColors.primary,
                  ),

                  ServicesCard(services: extraServices),

                  const SizedBox(height: 24),

                  // Pet Information
                  Text(
                    'Pet Information',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pet Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(50),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.pets,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet['name'],
                                      style: GoogleFonts.urbanist(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      pet['breed'],
                                      style: GoogleFonts.urbanist(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPetAttribute(
                                  'Age',
                                  '${pet['age']} year${pet['age'] > 1 ? 's' : ''}',
                                  Icons.cake_outlined,
                                ),
                              ),
                              Expanded(
                                child: _buildPetAttribute(
                                  'Gender',
                                  pet['gender'].toString().capitalize(),
                                  pet['gender'].toLowerCase() == 'male'
                                      ? Icons.male_outlined
                                      : Icons.female_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Branch Information
                  Text(
                    'Branch Information',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Branch Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.store_outlined,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      branch['name'],
                                      style: GoogleFonts.urbanist(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            branch['address'],
                                            style: GoogleFonts.urbanist(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () {
                              // Call branch
                              launchUrl(Uri.parse("tel:${branch['mobileNo']}"));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    branch['mobileNo'],
                                    style: GoogleFonts.urbanist(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () {
                              MapsLauncher.launchCoordinates(
                                8.475595321127928,
                                124.66306220357012,
                                'Furcare',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "View in maps",
                                    style: GoogleFonts.urbanist(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Payment Information
                  Text(
                    'Payment Information',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: AppColors.danger,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "PHP${phpFormatter.format(booking['payable'])}",
                                style: GoogleFonts.urbanist(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Total amount to be paid\nPlease disregard if already settled.',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? chipColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: chipColor ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: textColor ?? Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetAttribute(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Helper functions
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_outlined;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

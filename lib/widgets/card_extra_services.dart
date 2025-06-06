import 'package:flutter/material.dart';
import 'package:furcare_app/models/servcefee_info.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/widgets/container_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesCard extends StatelessWidget {
  final List<ServiceFee> services;
  final String emptyMessage;
  final Color cardColor;
  final Color textColor;
  final Color accentColor;

  const ServicesCard({
    super.key,
    required this.services,
    this.emptyMessage = 'No extra services added',
    this.cardColor = const Color(0xFFF9F9F9),
    this.textColor = Colors.black87,
    this.accentColor = const Color(0xFF6B8E23),
  });

  @override
  Widget build(BuildContext context) {
    return ContainerWrapper(
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.note, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Pet Services',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[100]),
            services.isEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 16.0,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 0.5,
                        indent: 16,
                        endIndent: 16,
                        color: Colors.grey[100],
                      ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      title: Text(
                        service.title,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                        child: Text(
                          "PHP ${phpFormatter.format(service.fee)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            services.isNotEmpty
                ? Column(
                  children: [
                    Divider(height: 1, color: Colors.grey[100]),
                    Container(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'PHP ${phpFormatter.format(services.fold(0.0, (sum, service) => sum + service.fee))}',
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

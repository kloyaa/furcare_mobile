import 'package:flutter/material.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:furcare_app/utils/const/colors.dart';

class StaffTabSettings extends StatefulWidget {
  const StaffTabSettings({super.key});

  @override
  State<StaffTabSettings> createState() => _StaffTabSettingsState();
}

class _StaffTabSettingsState extends State<StaffTabSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/s/edit/profile/1');
              },
              leading: const Icon(
                Ionicons.person_outline,
                color: AppColors.primary,
                size: 18.0,
              ),
              title: Text(
                'Profile',
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              subtitle: Text(
                'Change your basic info and more',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 10.0,
                ),
              ),
              tileColor: Colors.white,
              // Add any other content you want here
            ),
            const SizedBox(height: 10.0),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/c/activity');
              },
              leading: const Icon(
                Ionicons.list_outline,
                color: AppColors.primary,
                size: 18.0,
              ),
              title: Text(
                'Activity log',
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              subtitle: Text(
                'See your furcare activities',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 10.0,
                ),
              ),
              tileColor: Colors.white,
              // Add any other content you want here
            ),
            const SizedBox(height: 150.0),
            ListTile(
              leading: const Icon(
                Ionicons.log_out_outline,
                color: AppColors.primary,
                size: 18.0,
              ),
              title: Text(
                'Leave',
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              subtitle: Text(
                'Sign out your account',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 10.0,
                ),
              ),
              tileColor: Colors.white,
              onTap: () {
                redirectOnConfirm(context, path: "/auth/staff");
              },
              // Add any other content you want here
            ),
          ],
        ),
      ),
    );
  }
}

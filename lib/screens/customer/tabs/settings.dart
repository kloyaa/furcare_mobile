import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:furcare_app/utils/common.util.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:furcare_app/utils/const/static_infos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CustomerTabSettings extends StatefulWidget {
  const CustomerTabSettings({super.key});

  @override
  State<CustomerTabSettings> createState() => _CustomerTabSettingsState();
}

class _CustomerTabSettingsState extends State<CustomerTabSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/c/edit/profile/1');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: AppColors.primary.withAlpha(0),
                  width: 1,
                ),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: AppColors.primary.withAlpha(0),
                  width: 1,
                ),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: AppColors.primary.withAlpha(0),
                  width: 1,
                ),
              ),
              leading: const Icon(
                Ionicons.call_outline,
                color: AppColors.primary,
                size: 18.0,
              ),
              title: Text(
                'Call us',
                style: GoogleFonts.urbanist(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              subtitle: Text(
                'Any concerns?',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 10.0,
                ),
              ),
              tileColor: Colors.white,
              onTap: () async {
                // call
                launchUrl(Uri.parse('tel:$furcareContactNo'));
                // await FlutterPhoneDirectCaller.callNumber(furcareContactNo);
              },
              // Add any other content you want here
            ),
            const SizedBox(height: 10.0),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: AppColors.primary.withAlpha(0),
                  width: 1,
                ),
              ),
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
                redirectOnConfirm(context);
              },
              // Add any other content you want here
            ),
          ],
        ),
      ),
    );
  }
}

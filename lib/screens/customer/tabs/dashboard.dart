import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_launcher/maps_launcher.dart';

class CustomerTabDashboard extends StatefulWidget {
  const CustomerTabDashboard({super.key});

  @override
  State<CustomerTabDashboard> createState() => _CustomerTabDashboardState();
}

class _CustomerTabDashboardState extends State<CustomerTabDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/book/boarding');
              },
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: Image.asset(
                    'assets/img_3.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    'Boarding',
                    style: GoogleFonts.urbanist(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Ensure your furry friend's comfort and care while you're away. Choose from trusted facilities and caregivers for peace of mind.",
                    style: GoogleFonts.urbanist(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Add any other content you want here
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/book/grooming');
              },
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: Image.asset(
                    'assets/img_2.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    'Grooming',
                    style: GoogleFonts.urbanist(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Treat your pet to a spa day! Book professional grooming services to keep your furry friend looking and feeling their best.",
                    style: GoogleFonts.urbanist(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Add any other content you want here
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/book/transit');
              },
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: Image.asset(
                    'assets/img_4.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    'Home Service',
                    style: GoogleFonts.urbanist(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Convenient pet care at your doorstep. Book hassle-free grooming, check-ups, and more—right in the comfort of your home.",
                    style: GoogleFonts.urbanist(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Add any other content you want here
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                MapsLauncher.launchCoordinates(
                  8.475595321127928,
                  124.66306220357012,
                  'Furcare',
                );
              },
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  leading: Image.asset(
                    'assets/img_1.jpg',
                    width: 100,
                    height: 100,
                  ),
                  title: Text(
                    'Location',
                    style: GoogleFonts.urbanist(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Discover a haven for pet lovers! Visit our conveniently located pet shop for all your furry friend's needs.",
                    style: GoogleFonts.urbanist(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Add any other content you want here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

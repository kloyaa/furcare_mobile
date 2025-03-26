import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_launcher/maps_launcher.dart';

class CustomerTabDashboard extends StatefulWidget {
  const CustomerTabDashboard({super.key});

  @override
  State<CustomerTabDashboard> createState() => _CustomerTabDashboardState();
}

class _CustomerTabDashboardState extends State<CustomerTabDashboard> {
  // Dashboard service items
  final List<Map<String, dynamic>> _serviceItems = [
    {
      'title': 'Boarding',
      'subtitle':
          "Ensure your furry friend's comfort and care while you're away. Choose from trusted facilities and caregivers for peace of mind.",
      'image': 'assets/img_3.jpg',
      'route': '/book/boarding',
      'icon': Icons.hotel,
    },
    {
      'title': 'Grooming',
      'subtitle':
          "Treat your pet to a spa day! Book professional grooming services to keep your furry friend looking and feeling their best.",
      'image': 'assets/img_2.jpg',
      'route': '/book/grooming',
      'icon': Icons.pets,
    },
    {
      'title': 'Home Service',
      'subtitle':
          "Convenient pet care at your doorstep. Book hassle-free grooming, check-ups, and more—right in the comfort of your home.",
      'image': 'assets/img_4.jpg',
      'route': '/book/transit',
      'icon': Icons.home_repair_service,
    },
    {
      'title': 'Location',
      'subtitle':
          "Discover a haven for pet lovers! Visit our conveniently located pet shop for all your furry friend's needs.",
      'image': 'assets/img_1.jpg',
      'action':
          () => MapsLauncher.launchCoordinates(
            8.475595321127928,
            124.66306220357012,
            'Furcare',
          ),
      'icon': Icons.location_on,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _serviceItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildServiceCard(
                            context,
                            _serviceItems[index],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        // Check if there's a specific route or action
        if (service['route'] != null) {
          Navigator.pushNamed(context, service['route']);
        } else if (service['action'] != null) {
          service['action']();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              ),
              child: Image.asset(
                service['image'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          service['icon'],
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          service['title'],
                          style: GoogleFonts.roboto(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service['subtitle'],
                      style: GoogleFonts.roboto(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

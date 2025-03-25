import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHandler {
  static Future<bool> requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      return true; // Permission already granted
    }

    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        var result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Location Permission Required',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'To use this feature, enable location access from your device settings.',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontSize: 12.0,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    await openAppSettings(); // Open device settings
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        );

        if (result == true) {
          return false; // Wait for user to change settings manually
        }
      }
    }

    return false; // Permission not granted
  }
}

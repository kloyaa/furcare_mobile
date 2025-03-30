import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderSelectionWidget extends StatefulWidget {
  final Function(String?) onGenderSelected;

  const GenderSelectionWidget({super.key, required this.onGenderSelected});

  @override
  // ignore: library_private_types_in_public_api
  _GenderSelectionWidgetState createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  String? _selectedGender = "male";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent, // Disable splash and ripple effects
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: RadioListTile<String>(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              'Male',
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 10.0,
              ),
            ),
            value: 'male',
            groupValue: _selectedGender,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
              widget.onGenderSelected(value);
            },
          ),
        ),
        Material(
          color: Colors.transparent, // Disable splash and ripple effects
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),

          child: RadioListTile<String>(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              'Female',
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 10.0,
              ),
            ),
            value: 'female',
            activeColor: AppColors.primary,
            groupValue: _selectedGender,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
              widget.onGenderSelected(value);
            },
          ),
        ),
        Material(
          color: Colors.transparent, // Disable splash and ripple effects
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: RadioListTile<String>(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              'Others',
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontSize: 10.0,
              ),
            ),
            value: 'other',
            activeColor: AppColors.primary,
            groupValue: _selectedGender,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
              widget.onGenderSelected(value);
            },
          ),
        ),
      ],
    );
  }
}

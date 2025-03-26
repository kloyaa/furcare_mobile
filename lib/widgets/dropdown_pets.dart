import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/const/colors.dart';

class PetDropdown extends StatefulWidget {
  final List<dynamic> pets;
  final Function(String) onPetSelected;

  const PetDropdown({
    super.key,
    required this.pets,
    required this.onPetSelected,
  });

  @override
  State<PetDropdown> createState() => _PetDropdownState();
}

class _PetDropdownState extends State<PetDropdown> {
  String? _selectedPet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            'Select Your Pet',
            style: GoogleFonts.urbanist(
              color: AppColors.primary.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          value: _selectedPet,
          isExpanded: true,
          style: GoogleFonts.urbanist(color: AppColors.primary, fontSize: 14),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPet = newValue;
            });
            widget.onPetSelected(newValue!);
          },
          items:
              widget.pets.map<DropdownMenuItem<String>>((pet) {
                return DropdownMenuItem<String>(
                  value: pet['_id'],
                  child: Text(pet['name']),
                );
              }).toList(),
        ),
      ),
    );
  }
}

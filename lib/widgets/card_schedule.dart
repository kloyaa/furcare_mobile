import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/const/colors.dart';

class ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final bool isSelected;
  final VoidCallback onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(100),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          schedule['title'],
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
        trailing: Icon(
          Icons.calendar_today,
          color: isSelected ? Colors.white : AppColors.primary.withAlpha(200),
        ),
      ),
    );
  }
}

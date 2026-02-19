import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeaderInfo extends StatelessWidget {
  const AppHeaderInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/construction_loho.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.construction,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Construction Tracker",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for green bg
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Version 1.0.0",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70, // Lighter white for version
            ),
          ),
        ],
      ),
    );
  }
}

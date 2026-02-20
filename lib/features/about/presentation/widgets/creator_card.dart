import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_color.dart';
import 'social_button.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4568DC)], // Example gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.grey[200],
              backgroundImage: const AssetImage(
                "assets/images/creator_placeholder.png",
              ), // Placeholder
              foregroundImage: const AssetImage(
                "assets/images/about_pic.jpeg",
              ), // Try to load sreejesh.jpg if exists, otherwise fallback
              onForegroundImageError: (exception, stackTrace) {
                // Fallback handled by child
              },
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Sreejesh",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Software Engineer",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            "Flutter | Node.js",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Passionate about building scalable mobile and web applications. Combining clean code with intuitive design to solve real-world problems.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialButton(
                icon: FontAwesomeIcons.github,
                url: "https://github.com/Sreejesh75",
              ), // Replace with actual GitHub
              SizedBox(width: 20),
              SocialButton(
                icon: FontAwesomeIcons.linkedin,
                url: "www.linkedin.com/in/sreejesh-os-71a490259",
              ), // Replace with actual LinkedIn
              SizedBox(width: 20),
              SocialButton(
                icon: FontAwesomeIcons.envelope,
                url: "mailto:sreejeshos75@gmail.com",
              ), // Replace with actual email
            ],
          ),
        ],
      ),
    );
  }
}

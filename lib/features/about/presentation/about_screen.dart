import 'package:construction_app/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/app_header_info.dart';
import 'widgets/creator_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/section_header.dart';
import 'widgets/tech_chip.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientTop,
      appBar: AppBar(
        title: Text(
          "About App",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Decorations (Subtle)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Main Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Header Center
                const Center(child: AppHeaderInfo()),
                const SizedBox(height: 40),

                // About App (Glassmorphism inspired)
                const SectionHeader(title: "About App"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "Construction Tracker is a comprehensive solution designed to streamline construction site management. Manage workers, track materials, organize project documents, and monitor progress — all in one place.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Key Features (White Cards)
                const SectionHeader(title: "Key Features"),
                const SizedBox(height: 16),
                const FeatureCard(
                  icon: FontAwesomeIcons.users,
                  title: "Labour Tracking",
                  description:
                      "Manage daily wages, contractor payments, and attendance effortlessly.",
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                const FeatureCard(
                  icon: FontAwesomeIcons.boxesStacked,
                  title: "Material Management",
                  description:
                      "Track inventory, purchase history, and stock levels in real-time.",
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                const FeatureCard(
                  icon: FontAwesomeIcons.filePdf,
                  title: "Project Documents",
                  description:
                      "Store and organize blueprints, invoices, and contracts securely.",
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                const FeatureCard(
                  icon: FontAwesomeIcons.chartLine,
                  title: "Progress Monitoring",
                  description:
                      "Visualize construction progress with intuitive charts and timelines.",
                  color: Colors.green,
                ),
                const SizedBox(height: 32),

                // Tech Stack
                const SectionHeader(title: "Tech Stack"),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    TechChip(label: "Flutter", color: Colors.blue),
                    TechChip(label: "Dart", color: Colors.blue[700]!),
                    TechChip(label: "Node.js", color: Colors.green[600]!),
                    TechChip(label: "MongoDB", color: Colors.green[800]!),
                    const TechChip(label: "Express.js", color: Colors.black),
                    const TechChip(label: "Bloc Pattern", color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 32),

                // About Creator
                const SectionHeader(title: "About Creator"),
                const SizedBox(height: 16),
                // Creator card is already nice (dark gradient), let's keep it or give it a border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const CreatorCard(),
                ),
                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Text(
                    "© 2026 Construction Tracker. All rights reserved.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

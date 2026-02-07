import 'package:construction_app/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomAnimatedBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Container(
        height: 70,
        width: size.width,
        decoration: BoxDecoration(
          color: Color(0xFF4DB6AC), // Darker glass base
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.15), // Blue glow
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home Item (Index 0)
            _buildIconItem(0, Icons.home_rounded),

            // Add Project Item (Index 1) - Now Standard
            _buildIconItem(1, Icons.add_rounded),

            // Profile Item (Index 2)
            _buildIconItem(2, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem(int index, IconData icon) {
    final isSelected = currentIndex == index;

    // Apply Glow to ANY selected item
    if (isSelected) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 50,
        height: 50,
        color: Colors.transparent, // Hit test
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white54, size: 26),
      ),
    );
  }
}

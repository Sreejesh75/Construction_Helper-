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
      padding: const EdgeInsets.fromLTRB(45, 0, 45, 25),
      child: Container(
        height: 60,
        width: size.width,
        decoration: BoxDecoration(
          color: AppColors.primary, // Green Pill
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home Item (Index 0)
            _buildIconItem(0, Icons.home_outlined),

            // Add Project Item (Index 1) - Now Standard
            _buildIconItem(1, Icons.add_rounded),

            // Profile Item (Index 2)
            _buildIconItem(2, Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem(int index, IconData icon) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Colors.white.withOpacity(0.2) // Subtle active state
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: Colors.white, // Always white icons
          size: 28,
        ),
      ),
    );
  }
}

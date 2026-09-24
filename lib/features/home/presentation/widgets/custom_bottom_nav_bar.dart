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
    final double navBarWidth = size.width - 48; // 24px padding on each side
    const double navBarHeight = 64.0;
    const double bumpHeight = 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).padding.bottom > 0 ? 16 : 24,
      ),
      child: SizedBox(
        width: navBarWidth,
        height: navBarHeight + bumpHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // White notched background painter
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: navBarHeight,
              child: CustomPaint(
                painter: NotchedNavBarPainter(
                  color: Colors.white,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Tab items row (Home, Center space for Add, Profile)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: navBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home Tab
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: "Home",
                    ),
                  ),

                  // Center Spacer for elevated Add button
                  const SizedBox(width: 64),

                  // Profile Tab
                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: "Profile",
                    ),
                  ),
                ],
              ),
            ),

            // Elevated Center Green Action Button inside top notch
            Positioned(
              top: 0,
              child: _buildCenterButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? AppColors.primary : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(2),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
            child: Text(label),
          ),
          const SizedBox(height: 2),
          // Active dot indicator (matches reference design)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: isSelected ? 4 : 0,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    final bool isSelected = currentIndex == 1;

    return GestureDetector(
      onTap: () => onTap(1),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class NotchedNavBarPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  NotchedNavBarPainter({
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double r = 26.0; // Corner radius for floating pill
    final double cX = w / 2; // Center X
    final double bumpWidth = 36.0; // Half-width of notch curve
    final double bumpHeight = 20.0; // Height of top notch bump

    path.moveTo(r, 0);
    // Line to start of notch curve
    path.lineTo(cX - bumpWidth - 10, 0);
    // Smooth upward curve to top of notch
    path.cubicTo(
      cX - bumpWidth + 2, 0,
      cX - bumpWidth + 4, -bumpHeight,
      cX, -bumpHeight,
    );
    path.cubicTo(
      cX + bumpWidth - 4, -bumpHeight,
      cX + bumpWidth - 2, 0,
      cX + bumpWidth + 10, 0,
    );
    // Line to right top corner
    path.lineTo(w - r, 0);
    // Top-right corner
    path.quadraticBezierTo(w, 0, w, r);
    // Line to bottom-right corner
    path.lineTo(w, h - r);
    // Bottom-right corner
    path.quadraticBezierTo(w, h, w - r, h);
    // Line to bottom-left corner
    path.lineTo(r, h);
    // Bottom-left corner
    path.quadraticBezierTo(0, h, 0, h - r);
    // Line to top-left corner
    path.lineTo(0, r);
    // Top-left corner
    path.quadraticBezierTo(0, 0, r, 0);

    path.close();

    // Draw smooth drop shadow
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);
    // Draw white background
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NotchedNavBarPainter oldDelegate) => false;
}

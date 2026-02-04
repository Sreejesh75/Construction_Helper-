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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: size.width,
        height: 70, // Reduced height
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size.width, 70), // Reduced height
              painter: BNBCustomPainter(currentIndex: currentIndex),
            ),
            Center(
              heightFactor: 0.6,
              child: SizedBox(
                height: 70, // Match outer height
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded),
                    _buildNavItem(1, Icons.add_rounded),
                    _buildNavItem(2, Icons.person_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isSelected ? 40 : 25, // Slightly smaller
          height: isSelected ? 40 : 25,
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFFE88A64), // Orange color from image
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE88A64).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                )
              : null,
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : Colors.white54, // Adapted for dark bg
            size: isSelected ? 24 : 22,
          ),
        ),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final int currentIndex;

  BNBCustomPainter({required this.currentIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color =
          const Color(0xFF1E293B) // Slate 800 - Dark theme
      ..style = PaintingStyle.fill;

    Path path = Path();

    // With padding in the parent widget, 'size.width' is already the inner width (capsule width)

    double loc = 0.5;
    if (currentIndex == 0) loc = 0.17;
    if (currentIndex == 1) loc = 0.5;
    if (currentIndex == 2) loc = 0.83;

    double x = size.width * loc;

    // Capsule parameters - reduced radius for smaller height
    double cornerRadius = 20.0;

    // Start from top-left rounded corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    double curveWidth = size.width * 0.20;
    if (curveWidth > 80) curveWidth = 80;

    // Line to the start of the cutout
    path.lineTo(x - curveWidth / 2 - 10, 0);

    // Smooth cutout curve
    path.cubicTo(
      x - curveWidth / 4,
      0,
      x - curveWidth / 4,
      30, // Reduced Depth from 35 to 30
      x,
      30,
    );

    path.cubicTo(
      x + curveWidth / 4,
      30,
      x + curveWidth / 4,
      0,
      x + curveWidth / 2 + 10,
      0,
    );

    // Line to top-right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right side down
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom side
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.3),
      10,
      true,
    ); // Slightly stronger shadow for dark on dark
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

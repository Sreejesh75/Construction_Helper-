import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/home/presentation/add_project_screen.dart';
import 'package:construction_app/features/home/presentation/home_screen.dart';
import 'package:construction_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:construction_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final bool isNewUser;

  const MainScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.isNewUser = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        userId: widget.userId,
        userName: widget.userName,
        isNewUser: widget.isNewUser,
        fromMainScreen: true, // Hint to hide FAB/Gradient if needed
      ),
      AddProjectScreen(
        userId: widget.userId,
        onSuccess: () {
          setState(() {
            _currentIndex = 0; // Go back to home on success
          });
        },
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Important for the curve
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.heading],
            stops: const [0.2, 0.9],
          ),
        ),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: CustomAnimatedBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

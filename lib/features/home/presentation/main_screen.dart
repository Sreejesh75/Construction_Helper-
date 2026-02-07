import 'package:construction_app/features/home/presentation/add_project_screen.dart';
import 'package:construction_app/features/home/presentation/home_screen.dart';
import 'package:construction_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:construction_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;
  final bool isNewUser;

  const MainScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
    this.isNewUser = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Set status bar color based on current index
    // Home (0) has dark green header -> Light Status Bar Content (White icons)
    // AddProject (1) has white background -> Dark Status Bar Content (Black icons)
    // Profile (2) has white background -> Dark Status Bar Content (Black icons)
    final bool isHome = _currentIndex == 0;

    final SystemUiOverlayStyle overlayStyle = isHome
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.light, // White icons for Android
            statusBarBrightness: Brightness.dark, // White icons for iOS
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Black icons for Android
            statusBarBrightness: Brightness.light, // Black icons for iOS
          );

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
      ProfileScreen(userName: widget.userName, email: widget.email),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        extendBody: true, // Important for the curve
        body: Container(
          color: const Color(0xFFF7F8FA), // Light Grey Background
          child: SafeArea(
            top: false, // Allow header to extend behind status bar
            bottom: false, // Let content flow behind bottom nav if needed
            child: pages[_currentIndex],
          ),
        ),
        bottomNavigationBar: CustomAnimatedBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

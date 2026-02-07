import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/chatbot/presentation/chat_screen.dart';
import 'package:construction_app/features/home/bloc/home_bloc.dart';
import 'package:construction_app/features/home/bloc/home_event.dart';
import 'package:construction_app/features/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:construction_app/features/auth/presentation/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String email;

  const ProfileScreen({
    super.key,
    this.userName = "User",
    this.email = "user@example.com",
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        // Use state name if valid, otherwise fallback to passed userName
        final currentUserName =
            (state.userName != null && state.userName!.isNotEmpty)
            ? state.userName!
            : userName;

        return Scaffold(
          backgroundColor: Colors.transparent, // Background handled by stack
          body: Stack(
            children: [
              // Green Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.gradientTop],
                  ),
                ),
              ),

              // White Bubble Decoration
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 20),
                  // Profile Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          currentUserName.isNotEmpty
                              ? currentUserName[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUserName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // White Menu Container
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Menu Items
                            _buildProfileOption(
                              context,
                              icon: Icons.settings_rounded,
                              title: "Settings",
                              onTap: () {},
                            ),
                            _buildProfileOption(
                              context,
                              icon: Icons.notifications_rounded,
                              title: "Notifications",
                              onTap: () {},
                            ),
                            _buildProfileOption(
                              context,
                              icon: Icons.smart_toy_rounded,
                              title: "Help & Support",
                              subtitle: "Chat with our virtual assistant",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildProfileOption(
                              context,
                              icon: Icons.logout_rounded,
                              title: "Logout",
                              isDestructive: true,
                              onTap: () {
                                _showLogoutDialog(context);
                              },
                            ),
                            const SizedBox(height: 80), // Bottom padding
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Light grey background for contrast on white
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!), // Subtle border
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? Colors.red : AppColors.heading,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomeBloc>().add(LogoutEvent());
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

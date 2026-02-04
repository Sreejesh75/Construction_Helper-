import 'package:construction_app/features/home/bloc/home_bloc.dart';
import 'package:construction_app/features/home/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final bool isNewUser;
  final String userId;
  final bool isDarkBackground;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.isNewUser,
    required this.userId,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  // Text(
                  //   "Welcome back,",
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: isDarkBackground
                  //         ? Colors.white70
                  //         : Colors.grey[600],
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () => _showUpdateNameDialog(context),
                    child: Row(
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkBackground
                                ? Colors.white
                                : AppColors.heading,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: isDarkBackground
                              ? Colors.white70
                              : Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // TODO: Implement Logout Logic
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to login or perform logout
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkBackground
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isDarkBackground
                    ? null
                    : Border.all(color: Colors.grey[200]!),
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 24,
                color: isDarkBackground ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateNameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: userName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Full Name",
            hintText: "Enter your name",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<HomeBloc>().add(
                  UpdateUserName(userId: userId, name: controller.text.trim()),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good Morning,";
    } else if (hour < 17) {
      greeting = "Good Afternoon,";
    } else {
      greeting = "Good Evening,";
    }

    return Text(
      greeting,
      style: TextStyle(
        fontSize: 16,
        color: isDarkBackground ? Colors.white70 : Colors.grey[600],
      ),
    );
  }
}

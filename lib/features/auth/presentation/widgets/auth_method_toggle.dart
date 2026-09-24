import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/auth/bloc/login_bloc.dart';
import 'package:construction_app/features/auth/bloc/login_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthMethodToggle extends StatelessWidget {
  final AuthMethod currentMethod;

  const AuthMethodToggle({
    super.key,
    required this.currentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              context: context,
              title: "Email Login",
              icon: Icons.email_outlined,
              method: AuthMethod.email,
              isSelected: currentMethod == AuthMethod.email,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              context: context,
              title: "Mobile OTP",
              icon: Icons.phone_android_rounded,
              method: AuthMethod.phone,
              isSelected: currentMethod == AuthMethod.phone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required AuthMethod method,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<LoginBloc>().add(AuthMethodChanged(method));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/auth/bloc/login_bloc.dart';
import 'package:construction_app/features/auth/bloc/login_event.dart';
import 'package:construction_app/features/auth/bloc/login_state.dart';
import 'package:construction_app/features/auth/data/auth_api_service.dart';
import 'package:construction_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(AuthApiService()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userId: state.userId!,
                userName: state.userName ?? 'User',
                isNewUser: state.isNewUser,
              ),
            ),
          );
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final size = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: AppColors.gradientTop,
          body: Stack(
            children: [
              // Top Background & Animation
              Column(
                children: [
                  SizedBox(
                    height: size.height * 0.45,
                    width: double.infinity,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Lottie.asset(
                          'assets/images/login_animation.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Sheet content
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 0.6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CONSTRUCTION TRACKER",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Hello!",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.heading,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Manage workers, materials, and purchases \n—all in one place.",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.subtitle,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Email Input
                          TextFormField(
                            onChanged: (value) => context.read<LoginBloc>().add(
                              LoginEmailChanged(value),
                            ),
                            decoration: InputDecoration(
                              hintText: 'your-email@gmail.com',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              // Optional: Add prefix icon if desired, though screenshot doesn't show one clearly but has a cursor
                              // prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      context.read<LoginBloc>().add(
                                        LoginSubmitted(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: AppColors.primary
                                    .withOpacity(0.6),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Sign in",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement support/workspace finding navigation
                              },
                              child: Text(
                                "Need help finding your workspace?",
                                style: TextStyle(
                                  color: AppColors.primary.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

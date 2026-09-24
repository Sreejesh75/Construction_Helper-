import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/about/presentation/about_screen.dart';
import 'package:construction_app/features/auth/bloc/login_bloc.dart';
import 'package:construction_app/features/auth/bloc/login_event.dart';
import 'package:construction_app/features/auth/bloc/login_state.dart';
import 'package:construction_app/features/auth/data/auth_api_service.dart';
import 'package:construction_app/features/auth/presentation/widgets/auth_method_toggle.dart';
import 'package:construction_app/features/auth/presentation/widgets/email_login_form.dart';
import 'package:construction_app/features/auth/presentation/widgets/mobile_otp_form.dart';
import 'package:construction_app/features/home/presentation/main_screen.dart';
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
              builder: (context) => MainScreen(
                userId: state.userId!,
                userName: state.userName ?? 'User',
                email: state.email,
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

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
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
              // Background Circle Decoration
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

              // Top Lottie Animation
              Column(
                children: [
                  SizedBox(
                    height: size.height * 0.38,
                    width: double.infinity,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Lottie.asset(
                          'assets/images/login_animation.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Sheet Card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 0.65,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                          const SizedBox(height: 8),
                          const Text(
                            "Hello!",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.heading,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Manage workers, materials, and purchases \n—all in one place.",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.subtitle,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Auth Method Toggle (Email vs Mobile OTP)
                          AuthMethodToggle(currentMethod: state.authMethod),
                          const SizedBox(height: 24),

                          // Dynamic Form based on selected AuthMethod
                          if (state.authMethod == AuthMethod.email)
                            EmailLoginForm(state: state)
                          else
                            MobileOtpForm(state: state),

                          const SizedBox(height: 24),

                          // Footer Info Link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Want to know more about the app ?",
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

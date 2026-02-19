import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/auth/bloc/login_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:construction_app/features/auth/bloc/login_event.dart';
import 'package:construction_app/features/auth/bloc/login_state.dart';
import 'package:construction_app/features/auth/data/auth_api_service.dart';
import 'package:construction_app/features/home/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:construction_app/features/about/presentation/about_screen.dart';

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
      },
      builder: (context, state) {
        final size = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: AppColors.gradientTop,
          body: Stack(
            children: [
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

              // Top Background & Animation
              Column(
                children: [
                  SizedBox(
                    height: size.height * 0.45,
                    width: double.infinity,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
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
                  margin: const EdgeInsets.all(
                    16,
                  ), // Add margin for floating effect
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Rounded corners on all sides
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

                          const SizedBox(height: 16),

                          // Google Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      context.read<LoginBloc>().add(
                                        GoogleLoginRequested(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // We can use an asset or a network image for the Google logo
                                  // Assuming we might not have a local asset, we'll try to use a local one if available,
                                  // or just text if not. But user asked for matching UI.
                                  // I will assume a standard Google G icon is available or I should use an Icon.
                                  // Since I don't see a google icon asset in the file list, I'll use text or FontAwesome if available.
                                  // checking pubspec, font_awesome_flutter is there.
                                  // However, pure Google logo is usually preferred.
                                  // I'll try to use an Image.asset if I had one, but I'll use a generic icon or text for now
                                  // and ask user to provide the asset if needed, or use FontAwesome.
                                  // pubspec has 'font_awesome_flutter: ^10.12.0'.
                                  // Let's use FontAwesomeIcons.google.
                                  FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 24,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Sign in with Google",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer
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

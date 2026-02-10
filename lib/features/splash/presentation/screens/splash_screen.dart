import 'dart:async';
import 'package:construction_app/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:construction_app/core/theme/app_color.dart';
// Assuming this ex

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showTagline = false;

  @override
  void initState() {
    super.initState();
    // Navigate after 4 seconds
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.gradientTop, AppColors.gradientBottom],
              ),
            ),
          ),

          // Background Bubbles (Modern & Large)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Lottie.asset(
                    'assets/images/splash_lottie.json',  repeat: false,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                ),

                // Animated Text
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'Construction Tracker',
                            speed: const Duration(milliseconds: 120),
                          ),
                        ],
                        onFinished: () {
                          setState(() {
                            _showTagline = true;
                          });
                        },
                        totalRepeatCount: 1,
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Tagline
                if (_showTagline)
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        "Let's Build Your Dream, Together",
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                        speed: const Duration(milliseconds: 30),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

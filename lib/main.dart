import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/core/theme/app_text_styles.dart';
import 'package:construction_app/features/auth/bloc/login_bloc.dart';
import 'package:construction_app/features/auth/data/auth_api_service.dart';
import 'package:construction_app/features/auth/presentation/login_screen.dart';
import 'package:construction_app/features/home/bloc/home_bloc.dart';
import 'package:construction_app/features/home/data/home_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const ConstructionApp());
}

class ConstructionApp extends StatelessWidget {
  const ConstructionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (_) => LoginBloc(AuthApiService())),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(HomeApiService(), AuthApiService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Construction App',

        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,

          primaryColor: AppColors.primary,

          textTheme: TextTheme(
            headlineLarge: AppTextStyles.heading,
            bodyMedium: AppTextStyles.subtitle,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: AppTextStyles.subtitle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        home: const LoginScreen(),
      ),
    );
  }
}

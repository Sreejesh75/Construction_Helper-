import 'package:construction_app/core/theme/app_color.dart' show AppColors;
import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.gradientTop,
      AppColors.gradientBottom,
    ],
  );
}

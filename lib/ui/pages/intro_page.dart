import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../ui/widgets/custom_button.dart';
import 'login_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App Logo/Icon
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: AppColors.primaryText,
                  ),
                ),

                const SizedBox(height: AppDimensions.marginXL * 2),

                // App Name
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.marginM),

                // Tagline
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.marginS),

                // Intro Text
                Text(
                  AppStrings.introSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Get Started Button
                CustomButton(
                  text: AppStrings.getStarted,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  width: double.infinity,
                  height: AppDimensions.buttonHeightL,
                ),

                const SizedBox(height: AppDimensions.marginL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

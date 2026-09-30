import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/logo_loading_indicator.dart';

/// App Splash Screen displaying custom Govi Mithuru stationary rectangle with traveling white gap animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Transition to Home Screen after 2.5 seconds
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ValueListenableBuilder<String>(
        valueListenable: LanguageController.instance,
        builder: (context, lang, child) {
          final isSinhala = LanguageController.instance.isSinhala;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Stationary Rectangle with Traveling White Gap along perimeter
                const LogoLoadingIndicator(
                  logoSize: 80.0,
                  boxWidth: 180.0,
                  boxHeight: 110.0,
                  strokeWidth: 4.5,
                  gapColor: Colors.white,
                ),

                const SizedBox(height: 36),

                // 2. Loading Subtitle / Welcome Text
                Text(
                  isSinhala ? 'Govi Mithuru ආරම්භ වෙමින් පවතී...' : 'Loading Govi Mithuru...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lavenderDarkText,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

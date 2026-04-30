import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import 'onboarding_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Load user data during splash
    await context.read<UserProvider>().load();
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final hasName = context.read<UserProvider>().hasName;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            hasName ? const MainShell() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 130,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Text('🌸', style: TextStyle(fontSize: 80))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 1200.ms,
                          curve: Curves.easeInOut,
                        ),
                    Positioned(
                      top: 8,
                      right: 12,
                      child: const Text('✨', style: TextStyle(fontSize: 28))
                          .animate(
                              delay: 300.ms,
                              onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn()
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 900.ms,
                          ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: const Text('💖', style: TextStyle(fontSize: 24))
                          .animate(
                              delay: 600.ms,
                              onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn()
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 1100.ms,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Glowup ✨',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.textDark,
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'your cute bestie app 🎀',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 60),
              _buildLoadingDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.babyPink,
            borderRadius: BorderRadius.circular(4),
          ),
        )
            .animate(
                delay: Duration(milliseconds: 800 + i * 200),
                onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.3, 1.3),
              duration: 500.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.3, 1.3),
              end: const Offset(0.5, 0.5),
              duration: 500.ms,
            );
      }),
    );
  }
}

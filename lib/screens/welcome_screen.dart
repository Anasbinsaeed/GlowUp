import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate to home after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = context.read<UserProvider>().name;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated emoji burst
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: context.gradientPink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.accentPink.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),

                    // Main emoji
                    const Text('🌸', style: TextStyle(fontSize: 64))
                        .animate(delay: 200.ms)
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 300.ms),

                    // Floating sparkles
                    Positioned(
                      top: 0,
                      right: 10,
                      child: const Text('✨', style: TextStyle(fontSize: 28))
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                            duration: 500.ms,
                          ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 10,
                      child: const Text('💖', style: TextStyle(fontSize: 24))
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                            duration: 500.ms,
                          ),
                    ),
                    Positioned(
                      top: 10,
                      left: 5,
                      child: const Text('🎀', style: TextStyle(fontSize: 20))
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                            duration: 500.ms,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Welcome text
                Text(
                  'Welcome,',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                    fontFamily: AppFonts.nclGasdrifo,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 6),

                Text(
                  name.isNotEmpty ? name : 'Bestie',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    fontFamily: AppFonts.nclGasdrifo,
                    letterSpacing: 1,
                  ),
                )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                Text(
                  "It's time to glow up ✨",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.accentPink,
                    fontFamily: AppFonts.nclGasdrifo,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 60),

                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.accentPink,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(
                          delay: Duration(milliseconds: 800 + i * 150),
                          onPlay: (c) => c.repeat(reverse: true),
                        )
                        .scaleXY(
                          begin: 0.5,
                          end: 1.2,
                          duration: 500.ms,
                          curve: Curves.easeInOut,
                        )
                        .fadeIn(duration: 300.ms);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

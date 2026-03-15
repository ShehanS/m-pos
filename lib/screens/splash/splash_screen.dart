// lib/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/local_storage/local_storage_service.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/blocs.dart';
import '../../routes/route_names.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _localStorageService = LocalStorageService.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
    _navigate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(NotificationInitializeEvent());
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final hasSeenOnboarding = _localStorageService.getIntroEnabled() ?? false;

    final authState = context.read<AuthBloc>().state;

    if (authState.isAuthenticated) {
      context.go(RouteNames.home);
    } else if (!hasSeenOnboarding) {
      context.go(RouteNames.onboarding);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF9B59B6),
              Color(0xFFE74C3C),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                    duration: const Duration(milliseconds: 800),
                  )
                  .fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 24),

              // App name
              const Text(
                'BLoC App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 8),

              const Text(
                'Flutter • Firebase • BLoC',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 600),
                  ),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                  strokeWidth: 2,
                ),
              ).animate().fadeIn(
                    delay: const Duration(milliseconds: 1000),
                    duration: const Duration(milliseconds: 400),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

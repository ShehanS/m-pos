// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../routes/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.notifications_active_rounded,
      'color': const Color(0xFF6C63FF),
      'gradient': [const Color(0xFF6C63FF), const Color(0xFF9B59B6)],
    },
    {
      'icon': Icons.language_rounded,
      'color': const Color(0xFF43CFAE),
      'gradient': [const Color(0xFF43CFAE), const Color(0xFF2980B9)],
    },
    {
      'icon': Icons.security_rounded,
      'color': const Color(0xFFFF6584),
      'gradient': [const Color(0xFFFF6584), const Color(0xFFE74C3C)],
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [l10n.onboardingTitle1, l10n.onboardingTitle2, l10n.onboardingTitle3];
    final subtitles = [l10n.onboardingSubtitle1, l10n.onboardingSubtitle2, l10n.onboardingSubtitle3];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingPage(
                icon: page['icon'] as IconData,
                title: titles[index],
                subtitle: subtitles[index],
                gradient: page['gradient'] as List<Color>,
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      if (!isLast)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            l10n.skip,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (isLast) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _pages[_currentPage]['color'] as Color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          isLast ? l10n.getStarted : l10n.next,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            // Icon animation
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: Colors.white),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.95,
                  end: 1.05,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideY(
                        begin: 0.2,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 16),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 500),
                      )
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/blocs.dart';
import '../../l10n/app_localizations.dart';
import '../../routes/route_names.dart';
import '../../theme/app_theme.dart';
import '../../widgets/notification_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        actions: [
          // Notification icon with badge
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              return NotificationBadge(
                showBadge: state.hasNewNotification,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              );
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            onPressed: () => context.push(RouteNames.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              _WelcomeCard(
                name: user?.displayName ?? user?.username ?? 'User',
                email: user?.email ?? '',
                photoUrl: user?.photoUrl,
                initials: user?.initials ?? 'U',
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              Text(
                'Quick Actions',
                style: theme.textTheme.headlineSmall,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: _ActionCard(
                    icon: Icons.qr_code,
                    title: "Scanning",
                    color: AppTheme.primaryColor,
                    onTap: () => context.push(RouteNames.scan),
                    delay: 300,
                  )),

              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _ActionCard(
                    icon: Icons.person_outline,
                    title: l10n.profile,
                    color: AppTheme.primaryColor,
                    onTap: () => context.push(RouteNames.profile),
                    delay: 300,
                  ),
                  _ActionCard(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    color: AppTheme.secondary,
                    onTap: () => context.push(RouteNames.settings),
                    delay: 400,
                  ),
                  _ActionCard(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    color: AppTheme.accent,
                    onTap: () {},
                    delay: 500,
                  ),
                  _ActionCard(
                    icon: Icons.language_outlined,
                    title: l10n.language,
                    color: const Color(0xFFFF9F43),
                    onTap: () => context.push(RouteNames.settings),
                    delay: 600,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // FCM Token card
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state.isGranted && state.fcmToken != null) {
                    return _FcmTokenCard(token: state.fcmToken!)
                        .animate()
                        .fadeIn(delay: 700.ms);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final String initials;

  const _WelcomeCard({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hi(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(
          begin: const Offset(0.8, 0.8),
          delay: Duration(milliseconds: delay),
          curve: Curves.easeOutBack,
        );
  }
}

class _FcmTokenCard extends StatelessWidget {
  final String token;

  const _FcmTokenCard({required this.token});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active,
                  color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.fcmToken,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.tokenCopied),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.copyToken),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            token,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

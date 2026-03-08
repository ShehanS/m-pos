// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/blocs.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AuthBloc>().state;
    final user = state.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          TextButton(
            onPressed: () => _showEditDialog(context, l10n),
            child: Text(l10n.editProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            user?.initials ?? 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ],
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),

              const SizedBox(height: 16),

              Text(
                user?.displayName ?? user?.username ?? 'User',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 4),

              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 8),

              // Email verification badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.emailVerified == true
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: user?.emailVerified == true
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user?.emailVerified == true
                          ? Icons.verified_rounded
                          : Icons.warning_rounded,
                      size: 16,
                      color: user?.emailVerified == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user?.emailVerified == true
                          ? l10n.emailVerified
                          : l10n.emailNotVerified,
                      style: TextStyle(
                        fontSize: 12,
                        color: user?.emailVerified == true
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Profile info cards
              _ProfileInfoCard(
                items: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    label: l10n.username,
                    value: user?.username ?? '-',
                  ),
                  _ProfileItem(
                    icon: Icons.email_outlined,
                    label: l10n.email,
                    value: user?.email ?? '-',
                  ),
                  if (user?.createdAt != null)
                    _ProfileItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Member Since',
                      value: DateFormat.yMMMd().format(user!.createdAt!),
                    ),
                ],
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0, delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController(
      text: context.read<AuthBloc>().state.user?.displayName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editProfile),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(label: Text(l10n.displayName)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    AuthUpdateProfileEvent(displayName: nameController.text),
                  );
              Navigator.pop(ctx);
            },
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final List<_ProfileItem> items;

  const _ProfileInfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: items.map((item) {
            return ListTile(
              leading: Icon(item.icon, color: AppTheme.primaryColor),
              title: Text(
                item.label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              subtitle: Text(
                item.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

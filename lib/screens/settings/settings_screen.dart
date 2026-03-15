// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/blocs.dart';
import '../../bloc/locale/app_locales.dart';
import '../../bloc/locale/locale_event.dart';
import '../../bloc/locale/locale_state.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);


    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Theme section
          _SectionHeader(title: l10n.theme)
              .animate()
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 12),

          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return _SettingsTile(
                icon: state.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: state.isDark ? l10n.darkMode : l10n.lightMode,
                trailing: Switch.adaptive(
                  value: state.isDark,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (_) =>
                      context.read<ThemeBloc>().add(ThemeToggleEvent()),
                ),
              );
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05, end: 0, delay: 300.ms),

          const SizedBox(height: 24),

          // Language section
          _SectionHeader(title: l10n.language)
              .animate()
              .fadeIn(delay: 400.ms),

          const SizedBox(height: 12),

          BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return Column(
                children: AppLocales.supported.map((locale) {
                  final isSelected = state.locale.languageCode == locale.languageCode;
                  return _LanguageTile(
                    locale: locale,
                    isSelected: isSelected,
                    onTap: () => context
                        .read<LocaleBloc>()
                        .add(LocaleChangeEvent(locale)),
                  );
                }).toList(),
              );
            },
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .slideX(begin: -0.05, end: 0, delay: 500.ms),

          const SizedBox(height: 24),

          // Account section
          _SectionHeader(title: 'Account')
              .animate()
              .fadeIn(delay: 600.ms),

          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.signOut,
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _showSignOutDialog(context, l10n),
          ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.05, end: 0, delay: 700.ms),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOut),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.primaryColor,
            letterSpacing: 1.0,
            fontSize: 12,
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(
          AppLocales.getFlag(locale),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          AppLocales.getLanguageName(locale),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          locale.languageCode == 'en'
              ? 'English'
              : locale.languageCode == 'si'
                  ? 'Sinhala'
                  : 'Tamil',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded,
                color: AppTheme.primaryColor)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

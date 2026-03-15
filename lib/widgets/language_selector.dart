// lib/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../bloc/locale/app_locales.dart';
import '../bloc/locale/locale_event.dart';
import '../bloc/locale/locale_state.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return PopupMenuButton<Locale>(
          initialValue: state.locale,
          onSelected: (locale) =>
              context.read<LocaleBloc>().add(LocaleChangeEvent(locale)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => AppLocales.supported.map((locale) {
            final isSelected = state.locale.languageCode == locale.languageCode;
            return PopupMenuItem<Locale>(
              value: locale,
              child: Row(
                children: [
                  Text(
                    AppLocales.getFlag(locale),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocales.getLanguageName(locale),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  if (isSelected) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: AppTheme.primaryColor, size: 18),
                  ],
                ],
              ),
            );
          }).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocales.getFlag(state.locale),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocales.getLanguageName(state.locale),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

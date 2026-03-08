// lib/widgets/google_sign_in_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../l10n/app_localizations.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () => context
                    .read<AuthBloc>()
                    .add(AuthLoginWithGoogleEvent()),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google logo (SVG alternative using container)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const Text(
                          'G',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.signInWithGoogle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

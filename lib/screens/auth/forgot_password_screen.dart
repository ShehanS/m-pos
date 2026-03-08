// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/blocs.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthForgotPasswordEvent(email: _emailController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.isPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.resetEmailSent(state.resetEmail ?? '')),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
          context.pop();
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? l10n.error),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.forgotPasswordTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 50, color: AppTheme.primaryColor),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.9, end: 1.0, duration: 2000.ms, curve: Curves.easeInOut),
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.forgotPasswordSubtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _emailController,
                    label: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.validationEmailRequired;
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                        return l10n.validationEmailInvalid;
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                    builder: (context, state) => AnimatedGradientButton(
                      onPressed: state.isLoading ? null : _onSubmit,
                      label: l10n.sendResetLink,
                      isLoading: state.isLoading,
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

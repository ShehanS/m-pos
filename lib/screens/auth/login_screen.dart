// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/blocs.dart';
import '../../l10n/app_localizations.dart';
import '../../routes/route_names.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_gradient_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthLoginWithEmailEvent(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.isAuthenticated) {
          context.go(RouteNames.home);
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: LanguageSelector(),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondary],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.5, 0.5),
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(),
                          const SizedBox(height: 20),
                          Text(l10n.welcome, style: theme.textTheme.headlineMedium)
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.2, end: 0, delay: 200.ms),
                          const SizedBox(height: 6),
                          Text(l10n.welcomeSubtitle, style: theme.textTheme.bodyMedium)
                              .animate()
                              .fadeIn(delay: 300.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

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
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0, delay: 400.ms),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.validationPasswordRequired;
                        if (v.length < 6) return l10n.validationPasswordLength;
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0, delay: 500.ms),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(RouteNames.forgotPassword),
                        child: Text(l10n.forgotPassword),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 8),

                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                      builder: (context, state) => AnimatedGradientButton(
                        onPressed: state.isLoading ? null : _onLogin,
                        label: l10n.signIn,
                        isLoading: state.isLoading,
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0, delay: 700.ms),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 20),

                    const GoogleSignInButton()
                        .animate()
                        .fadeIn(delay: 900.ms)
                        .slideY(begin: 0.2, end: 0, delay: 900.ms),

                    const SizedBox(height: 32),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.noAccount, style: theme.textTheme.bodyMedium),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.register),
                            child: Text(
                              l10n.createAccount,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1000.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

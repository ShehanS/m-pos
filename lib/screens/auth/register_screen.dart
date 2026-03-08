// lib/screens/auth/register_screen.dart
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthRegisterWithEmailEvent(
            email: _emailController.text,
            password: _passwordController.text,
            username: _usernameController.text,
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
        if (state.isRegistrationSuccess || state.isAuthenticated) {
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
        appBar: AppBar(
          title: Text(l10n.createAccount),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(l10n.createAccountSubtitle, style: theme.textTheme.bodyLarge)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: _usernameController,
                    label: l10n.username,
                    prefixIcon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.validationUsernameRequired;
                      if (v.length < 3) return l10n.validationUsernameLength;
                      return null;
                    },
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0, delay: 300.ms),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: l10n.confirmPassword,
                    obscureText: _obscureConfirm,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.validationPasswordRequired;
                      if (v != _passwordController.text) return l10n.validationPasswordMatch;
                      return null;
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0, delay: 600.ms),

                  const SizedBox(height: 24),

                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                    builder: (context, state) => AnimatedGradientButton(
                      onPressed: state.isLoading ? null : _onRegister,
                      label: l10n.signUp,
                      isLoading: state.isLoading,
                      gradientColors: const [AppTheme.secondary, AppTheme.primaryColor],
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

                  const GoogleSignInButton().animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 32),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccount, style: theme.textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
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
    );
  }
}

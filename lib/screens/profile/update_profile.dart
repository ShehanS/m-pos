import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/blocs.dart';
import 'package:flutter_bloc_app/bloc/user/user_bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_event.dart';
import 'package:flutter_bloc_app/bloc/user/user_state.dart';
import 'package:flutter_bloc_app/entities/user_entity.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    final userEntity = context.read<UserBloc>().state.user;
    _firstNameController = TextEditingController(text: userEntity?.firstName ?? '');
    _lastNameController = TextEditingController(text: userEntity?.lastName ?? '');
    _addressController = TextEditingController(text: userEntity?.address ?? '');
    _contactController = TextEditingController(text: userEntity?.contact ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authUser = context.read<AuthBloc>().state.user;
    if (authUser == null) return;

    final updatedUser = UserEntity(
      uid: authUser.uid,
      email: authUser.email ?? '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      displayName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      address: _addressController.text.trim(),
      contact: _contactController.text.trim(),
      isUpdateProfile: true,
    );

    context.read<UserBloc>().add(UpdateUser(uid: authUser.uid, user: updatedUser));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.home),
          ),
          body: BlocBuilder<MasterDataBloc, MasterDataState>(
            builder: (context, state) {
              return BlocBuilder<UserBloc, UserState>(
                builder: (context, profileState) {
                  if (profileState.status == UserStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.updateProfile,
                            style: theme.textTheme.headlineSmall,
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 50),
                          CustomTextField(
                            controller: _firstNameController,
                            label: l10n.firstName,
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.validationUsernameRequired;
                              if (v.length < 3) return l10n.validationUsernameLength;
                              return null;
                            },
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0, delay: 300.ms),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _lastNameController,
                            label: l10n.lastName,
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.validationUsernameRequired;
                              if (v.length < 3) return l10n.validationUsernameLength;
                              return null;
                            },
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0, delay: 400.ms),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _addressController,
                            label: l10n.address,
                            prefixIcon: Icons.location_on_outlined,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.validationUsernameRequired;
                              if (v.length < 3) return l10n.validationUsernameLength;
                              return null;
                            },
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0, delay: 500.ms),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _contactController,
                            label: l10n.contact,
                            prefixIcon: Icons.phone_outlined,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.validationUsernameRequired;
                              if (v.length < 3) return l10n.validationUsernameLength;
                              return null;
                            },
                          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0, delay: 600.ms),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: profileState.status == UserStatus.loading ? null : _submit,
                              child: Text(l10n.next),
                            ),
                          ).animate().fadeIn(delay: 700.ms),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
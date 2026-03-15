import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/blocs.dart';
import 'package:flutter_bloc_app/bloc/profile/profile_bloc.dart';

import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dynamic_form.dart';

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final _formController = DynamicFormController();
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.home),
          ),
          body: BlocBuilder<MasterDataBloc, MasterDataState>(
            builder: (context, state) {
              final profileForm = state.setting?.profile;
              if (profileForm != null && profileForm.isNotEmpty) {
                return BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, profileState) {
                  if (profileState.status == ProfileStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.updateProfile,
                          style: theme.textTheme.headlineSmall,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 50),
                        DynamicForm(
                          showSubmitButton: true,
                          isDark: themeState.isDark,
                          formData: profileForm,
                          buttonLabel: l10n.next,
                          controller: _formController,
                          onChanged: (data) {},
                          onClick: (data) {
                            data["isUpdateProfile"] = true;
                            context.read<ProfileBloc>().add(
                                ModifyProfile(uid: user!.uid, profile: data));
                          },
                          button: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => _formController.submit(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ).animate().fadeIn(delay: 300.ms).slideY(
                                begin: 0.3,
                                duration: 400.ms,
                                curve: Curves.easeOut),
                          ),
                        )
                      ],
                    ),
                  );
                });
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

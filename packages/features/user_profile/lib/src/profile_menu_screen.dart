import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_profile/user_profile.dart';
import 'package:user_profile/src/profile_menu_bloc.dart';
import 'package:user_repository/user_repository.dart';

part './dark_mode_preference_picker.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({
    required this.userRepository,
    this.onSignInTap,
    this.onSignUpTap,
    this.onUpdateProfileTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onSignInTap;
  final VoidCallback? onUpdateProfileTap;
  final VoidCallback? onSignUpTap;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileMenuBloc>(
      create: (_) => ProfileMenuBloc(
        userRepository: userRepository,
      ),
      child: ProfileMenuView(
        onSignInTap: onSignInTap,
        onUpdateProfileTap: onUpdateProfileTap,
        onSignUpTap: onSignUpTap,
      ),
    );
  }
}

@visibleForTesting
class ProfileMenuView extends StatelessWidget {
  const ProfileMenuView({
    this.onSignInTap,
    this.onSignUpTap,
    this.onUpdateProfileTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onSignInTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onUpdateProfileTap;

  @override
  Widget build(BuildContext context) {
    final child = buildContent(context);
    ThemeData themeData = Theme.of(context);
    return themeData.brightness == Brightness.light
        ? StyledStatusBar.dark(
            child: child,
          )
        : StyledStatusBar.light(
            child: child,
          );
  }

  Widget buildContent(BuildContext context){
    final l10n = ProfileMenuLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileMenuBloc, ProfileMenuState>(
          builder: (context, state) {
            if (state is ProfileMenuLoaded) {
              final username = state.username;
              return Column(
                children: [
                  if (!state.isUserAuthenticated) ...[
                    _SignInButton(
                      onSignInTap: onSignInTap,
                    ),
                    const SizedBox(
                      height: Spacing.xLarge,
                    ),
                    Text(
                      l10n.signUpOpeningText,
                    ),
                    TextButton(
                      onPressed: onSignUpTap,
                      child: Text(
                        l10n.signUpButtonLabel,
                      ),
                    ),
                    const SizedBox(
                      height: Spacing.large,
                    ),
                  ],
                  if (username != null) ...[
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Spacing.small,
                          ),
                          child: Text(
                            l10n.signedInUserGreeting(username),
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(l10n.updateProfileTileLabel),
                      onTap: onUpdateProfileTap,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: Spacing.mediumLarge,
                    ),
                  ],
                  DarkModePreferencePicker(
                    currentValue: state.darkModePreference,
                  ),
                  if (state.isUserAuthenticated) ...[
                    const Spacer(),
                    _SignOutButton(
                      isSignOutInProgress: state.isSignOutInProgress,
                    ),
                  ]
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    Key? key,
    this.onSignInTap,
  }) : super(key: key);

  final VoidCallback? onSignInTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = ProfileMenuLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: theme.screenMargin,
        right: theme.screenMargin,
        top: Spacing.xxLarge,
      ),
      child: ElevatedButton.icon(
        onPressed: onSignInTap,
        label: Text(l10n.signInButtonLabel),
        icon: const Icon(
          Icons.login,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({
    required this.isSignOutInProgress,
    Key? key,
  }) : super(key: key);

  final bool isSignOutInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = ProfileMenuLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: theme.screenMargin,
        right: theme.screenMargin,
        bottom: Spacing.xLarge,
      ),
      child: isSignOutInProgress
          ? ElevatedButton(
              child: Text(l10n.signOutButtonLabel),
              onPressed: () {},
            )
          : ElevatedButton.icon(
              onPressed: () {
                final bloc = context.read<ProfileMenuBloc>();
                bloc.add(
                  const ProfileMenuSignedOut(),
                );
              },
              label: Text(l10n.signOutButtonLabel),
              icon: const Icon(
                Icons.logout,
              ),
            ),
    );
  }
}

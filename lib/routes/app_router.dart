import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_event.dart';
import 'package:flutter_bloc_app/bloc/user/user_state.dart';
import 'package:flutter_bloc_app/screens/ai_assistant.dart';
import 'package:flutter_bloc_app/screens/profile/update_profile.dart';
import 'package:flutter_bloc_app/screens/scan/scan_dispatch_screen.dart';
import 'package:flutter_bloc_app/screens/stock/stock_in_screen.dart';
import 'package:go_router/go_router.dart';

import '../bloc/blocs.dart';
import '../bloc/inventory/inventory_bloc.dart';
import '../bloc/scanner/scanner_bloc.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/printer/bluetooth_printer_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import 'route_names.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _sub;

  GoRouterRefreshStream(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _ProfileLoadingScreen extends StatelessWidget {
  const _ProfileLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthBloc authBloc, UserBloc userBloc) {
    final listenable = GoRouterRefreshStream(
      StreamGroup.merge([authBloc.stream, userBloc.stream]),
    );

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteNames.splash,
      refreshListenable: listenable,
      redirect: (context, state) {
        final authState = authBloc.state;
        final profileState = userBloc.state;

        final isSplash = state.matchedLocation == RouteNames.splash;
        final isLoading = state.matchedLocation == RouteNames.loading;

        final isOnAuthPage = state.matchedLocation == RouteNames.login ||
            state.matchedLocation == RouteNames.register ||
            state.matchedLocation == RouteNames.forgotPassword ||
            state.matchedLocation == RouteNames.onboarding;

        if (isSplash) return null;

        if (authState.isLoading) return null;

        if (authState.isUnauthenticated) {
          if (!isOnAuthPage) return RouteNames.login;
          return null;
        }

        if (authState.isAuthenticated) {
          final uid = authState.user!.uid;

          if (profileState.status == UserStatus.initial) {
            userBloc.add(GetUser(uid: uid));
            if (!isLoading) return RouteNames.loading;
            return null;
          }

          if (profileState.status == UserStatus.loading) {
            if (!isLoading) return RouteNames.loading;
            return null;
          }

          if (profileState.status == UserStatus.error) {
            if (state.matchedLocation != RouteNames.updateProfile) {
              return RouteNames.updateProfile;
            }
            return null;
          }

          if (profileState.status == UserStatus.loaded) {
            final isUpdateProfile = profileState.user?.isUpdateProfile ?? false;

            if (!isUpdateProfile) {
              if (state.matchedLocation != RouteNames.updateProfile) {
                return RouteNames.updateProfile;
              }
              return null;
            }

            if (isUpdateProfile) {
              if (isOnAuthPage || isLoading) {
                return RouteNames.home;
              }
              return null;
            }
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.loading,
          name: 'loading',
          builder: (context, state) => const _ProfileLoadingScreen(),
        ),
        GoRoute(
          path: RouteNames.onboarding,
          name: 'onboarding',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder: _fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: _fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RouteNames.register,
          name: 'register',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: RouteNames.updateProfile,
          name: 'updateProfile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const UpdateProfile(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: RouteNames.forgotPassword,
          name: 'forgotPassword',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: _fadeTransition,
          ),
          routes: [
            GoRoute(
              path: 'profile',
              name: 'profile',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
                transitionsBuilder: _slideTransition,
              ),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SettingsScreen(),
                transitionsBuilder: _slideTransition,
              ),
            ),
            GoRoute(
              path: 'scan-dispatch',
              name: 'scanDispatch',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<InventoryBloc>()),
                    BlocProvider.value(value: context.read<ScannerBloc>()),
                  ],
                  child: const ScanDispatchScreen(),
                ),
                transitionsBuilder: _slideTransition,
              ),
            ),
            GoRoute(
              path: 'stockIn',
              name: 'stockIn',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StockInScreen(),
                transitionsBuilder: _slideTransition,
              ),
            ),
            GoRoute(
              path: 'ai-assistant',
              name: 'aiAssistant',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const BluetoothPrinterScreen(),
                transitionsBuilder: _slideTransition,
              ),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }

  static Widget _fadeSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class StreamGroup {
  static Stream<T> merge<T>(List<Stream<T>> streams) {
    late StreamController<T> controller;
    final subscriptions = <StreamSubscription<T>>[];

    controller = StreamController<T>(
      onListen: () {
        for (final stream in streams) {
          subscriptions.add(stream.listen(
            controller.add,
            onError: controller.addError,
          ));
        }
      },
      onCancel: () async {
        for (final sub in subscriptions) {
          await sub.cancel();
        }
      },
      sync: true,
    );

    return controller.stream;
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_bloc.dart';
import 'package:flutter_bloc_app/repositories/inventory_repository.dart';
import 'package:flutter_bloc_app/repositories/master_data_repository.dart';
import 'package:flutter_bloc_app/repositories/user_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/blocs.dart';
import 'bloc/inventory/inventory_bloc.dart';
import 'bloc/locale/locale_event.dart';
import 'bloc/locale/locale_state.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'local_storage/local_storage_service.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationService = NotificationService();
  await LocalStorageService.instance.init();
  runApp(MyApp(notificationService: notificationService));
  await notificationService.initialize();
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) =>
              AuthBloc(authService: AuthService())..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<LocaleBloc>(
          lazy: false,
          create: (_) => LocaleBloc()..add(LocaleLoadEvent()),
        ),
        BlocProvider<UserBloc>(
          lazy: false,
          create: (_) => UserBloc(UserRepositoryImpl()),
        ),
        BlocProvider<ThemeBloc>(
          lazy: false,
          create: (_) => ThemeBloc()..add(ThemeLoadEvent()),
        ),
        BlocProvider<MasterDataBloc>(
          lazy: false,
          create: (_) => MasterDataBloc(MasterDataRepositoryImpl())
            ..add(const LoadMasterData()),
        ),
        BlocProvider<InventoryBloc>(
            lazy: false,
            create: (_) => InventoryBloc(InventoryRepositoryImpl())),
        BlocProvider<NotificationBloc>(
          lazy: false,
          create: (_) => NotificationBloc(
            notificationService: notificationService,
          ),
        ),
        BlocProvider<ScannerBloc>(
          lazy: false,
          create: (_) => ScannerBloc(),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                title: 'Flutter BLoC App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.createRouter(
                    context.read<AuthBloc>(), context.read<UserBloc>()),
              );
            },
          );
        },
      ),
    );
  }
}

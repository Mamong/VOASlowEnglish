import 'dart:async';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:feed_repository/feed_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:domain_models/domain_models.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:remote_api/remote_api.dart';
import 'package:user_profile/user_profile.dart';
import 'package:user_repository/user_repository.dart';

import 'l10n/app_localizations.dart';
import 'routing_table.dart';

void main() async {
  // Has to be late so it doesn't instantiate before the
  // `initializeMonitoringPackage()` call.
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(
    () async {
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      await initializeMonitoringPackage();
// debugPaintSizeEnabled = true;
      //final remoteValueService = RemoteValueService();
      //await remoteValueService.load();

      FlutterError.onError = errorReportingService.recordFlutterError;

      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await errorReportingService.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
          );
        }).sendPort,
      );

      runApp(
        const MyApp(),
      );
      FlutterNativeSplash.remove();
    },
    (error, stack) => errorReportingService.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    //required this.remoteValueService,
    Key? key,
  }) : super(key: key);

  //final RemoteValueService remoteValueService;

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();
  final _dynamicLinkService = DynamicLinkService();

  late final _feedApi = FeedApi();

  late final _feedRepository = FeedRepository(
    remoteApi: _feedApi,
    keyValueStorage: _keyValueStorage,
  );
  late final _userRepository = UserRepository(
    noSqlStorage: _keyValueStorage,
  );

  final _lightTheme = LightAppThemeData();
  final _darkTheme = DarkAppThemeData();
  late final _router = router(_feedRepository, _userRepository);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DarkModePreference>(
      stream: _userRepository.getDarkModePreference(),
      builder: (context, snapshot) {
        final darkModePreference = snapshot.data;

        return AppTheme(
          lightTheme: _lightTheme,
          darkTheme: _darkTheme,
          child: MaterialApp.router(
            theme: _lightTheme.materialThemeData,
            darkTheme: _darkTheme.materialThemeData,
            themeMode: darkModePreference?.toThemeMode(),
            supportedLocales: const [
              Locale('en', ''),
              Locale('zh', ''),
            ],
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              AppLocalizations.delegate,
              // ComponentLibraryLocalizations.delegate,
              ProfileMenuLocalizations.delegate,
              RefreshLocalizations.delegate,
              // SignInLocalizations.delegate,
              // ForgotMyPasswordLocalizations.delegate,
              // SignUpLocalizations.delegate,
              // UpdateProfileLocalizations.delegate,
            ],
            routerConfig: _router,
            //routerDelegate: _routerDelegate,
            //routeInformationParser: const RoutemasterParser(),
          ),
        );
      },
    );
  }
}

extension on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings:
        return ThemeMode.system;
      case DarkModePreference.alwaysLight:
        return ThemeMode.light;
      case DarkModePreference.alwaysDark:
        return ThemeMode.dark;
    }
  }
}

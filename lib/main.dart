import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudkip_frontend/core/reyveld.dart';
import 'package:mudkip_frontend/core/settings.dart';
import 'package:mudkip_frontend/screens/app_shell.dart';
import 'package:mudkip_frontend/mudkipc.dart';
import 'package:mudkip_frontend/screens/dex.dart';
import 'package:mudkip_frontend/screens/pc.dart';
import 'package:mudkip_frontend/screens/views/views.dart';
import 'package:mudkip_frontend/theme/theme_constants.dart';
import 'package:mudkip_frontend/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mudkip_frontend/screens.dart';
import 'package:talker_flutter/talker_flutter.dart';

ThemeManager themeManager = ThemeManager();
late PackageInfo packageInfo;
late File logFile;
final router = GoRouter(
    initialLocation: "/pc",
    redirect: (context, state) {
      if (state.fullPath == "/") {
        return "/pc";
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
          path: "/about",
          builder: (context, state) {
            return const AboutScreen();
          }),
      GoRoute(
          path: "/debug",
          builder: (context, state) => TalkerScreen(talker: MudkiPC.talker)),
      GoRoute(
          path: "/view/species",
          builder: (context, state) => SpeciesView(id: state.extra as int)),
      ShellRoute(
          routes: <RouteBase>[
            GoRoute(
              path: "/pc",
              builder: (context, state) {
                return const PCScreen();
              },
            ),
            GoRoute(
              path: "/dex",
              builder: (context, state) {
                return const DexScreen();
              },
            ),
          ],
          builder: (context, state, child) {
            return AppShell(child: child);
          }),
    ]);

void main(List<String> args) async {
  logFile = File("${await MudkiPC.cacheFolder}log.txt");
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print("${record.level.name}: ${record.time}: ${record.message}");
    if (record.level == Level.INFO ||
        record.level == Level.WARNING ||
        record.level == Level.SEVERE) {
      logFile.writeAsStringSync(
          '\n${record.level.name}: ${record.time}: ${record.message}',
          mode: FileMode.append);
    }
  });
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  MudkiPC.databasePath =
      await MudkiPC.extractFileFromAssets("db/Global.db", overwrite: true);
  await Settings.doPrefs();
  Reyveld.start();
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeManager>(context);
        return MaterialApp.router(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider);
      }));
}

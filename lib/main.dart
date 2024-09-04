import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/core/core.dart';

void main() async {

  /// Config flavors
  // AppConfig.create(
  //   flavor: Flavor.prod
  // );

  await Environments.initEnvironment();
  await LocalNotifications.initializeLocalNotifications();

  /// we read the topic saved by the user if they have it
  final prefs = await StorageService().getSharedPrefs();
  return runApp(
    ProviderScope(
      overrides: [
        darkModeProvider.overrideWith((ref) => prefs.getString('mode') == 'dark')
      ],
      child: const MainApp()
    )
  );

}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final AppTheme appTheme = ref.watch( themeNotifierProvider );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme.getTheme(),
      routerConfig: appRouter
    );
  }
}
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/providers/items_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
      ],
      child: const OrigoApp(),
    ),
  );
}

class OrigoApp extends StatelessWidget {
  const OrigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final profileProv = context.watch<ProfileProvider>();

    Widget homeWidget;
    if (!profileProv.isLoaded) {
      homeWidget = Scaffold(
        backgroundColor: themeProv.isDark
            ? const Color(0xFF11121F)
            : const Color(0xFFEBECF6),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (!profileProv.isFirstLaunchDone) {
      homeWidget = const OnboardingScreen();
    } else {
      homeWidget = const HomeScreen();
    }

    return MaterialApp(
      title: 'ORIGO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProv.mode,
      home: homeWidget,
    );
  }
}

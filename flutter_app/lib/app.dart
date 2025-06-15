import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'theme/ios_theme.dart';
import 'features/auth/login_screen.dart';

class MixologistApp extends StatelessWidget {
  const MixologistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _SmoothScrollBehavior(),
      child: CupertinoApp(
        title: 'Mixologist',
        theme: _buildCupertinoTheme(),
        home: const LoginScreen(),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
      ),
    );
  }

  CupertinoThemeData _buildCupertinoTheme() {
    return const CupertinoThemeData(
      primaryColor: iOSTheme.whiskey,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: CupertinoColors.systemBackground,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: iOSTheme.whiskey,
        textStyle: iOSTheme.body,
        actionTextStyle: iOSTheme.headline,
        tabLabelTextStyle: iOSTheme.caption1,
        navTitleTextStyle: iOSTheme.headline,
        navLargeTitleTextStyle: iOSTheme.largeTitle,
      ),
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

// You can add routing logic here if needed

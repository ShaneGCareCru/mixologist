import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'theme/ios_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'features/auth/login_screen.dart';
import 'widgets/theme/drink_theme_provider.dart';
import 'widgets/theme/drink_theme_engine.dart';

class MixologistApp extends StatelessWidget {
  const MixologistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DrinkThemeProvider(
      theme: DrinkThemeEngine.getThemeForDrink('default'),
      child: ScrollConfiguration(
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

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.richWhiskey,
        brightness: Brightness.light,
        primary: AppColors.richWhiskey,
        secondary: AppColors.goldenAmber,
        surface: AppColors.crystallIce,
        error: AppColors.deepBitters,
        tertiary: AppColors.citrushZest,
        primaryContainer: AppColors.champagneGold,
        secondaryContainer: AppColors.champagneGold.withOpacity(0.3),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: AppColors.richWhiskey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withOpacity(0.9),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: AppColors.richWhiskey.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: AppColors.richWhiskey.withOpacity(0.2),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.richWhiskey,
        titleTextStyle: const TextStyle(
          color: AppColors.richWhiskey,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.goldenAmber.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.goldenAmber.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.richWhiskey, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkAmber,
        brightness: Brightness.dark,
        primary: AppColors.darkAmber,
        secondary: AppColors.warmCopper,
        surface: AppColors.charcoalSurface,
        error: AppColors.crimsonBitters,
        tertiary: AppColors.citrusGlow,
        primaryContainer: AppColors.warmCopper.withOpacity(0.3),
        secondaryContainer: AppColors.smokyGlass,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Colors.white,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Colors.white,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: Colors.white,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: Colors.white,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white54,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white60,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 16,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: AppColors.smokyGlass.withOpacity(0.85),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 8,
        shadowColor: Colors.black54,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkAmber,
        titleTextStyle: const TextStyle(
          color: AppColors.darkAmber,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.smokyGlass.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.warmCopper.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.warmCopper.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkAmber, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: const EdgeInsets.all(20),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
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

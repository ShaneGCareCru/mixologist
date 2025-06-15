import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Import centralized theme files
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_constants.dart';
import 'theme/ios_theme.dart';

// Import screens - will be updated once feature folders are created
import 'pages/unified_inventory_page.dart';
import 'pages/ai_assistant_page.dart';

/// Main application widget that configures themes, routing, and app-level settings
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
  
  /// Builds the Cupertino (iOS-style) theme using centralized theme files
  CupertinoThemeData _buildCupertinoTheme() {
    return CupertinoThemeData(
      primaryColor: AppColors.richWhiskey,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: CupertinoColors.systemBackground,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.richWhiskey,
        textStyle: iOSTheme.body,
        actionTextStyle: iOSTheme.headline,
        tabLabelTextStyle: iOSTheme.caption1,
        navTitleTextStyle: iOSTheme.headline,
        navLargeTitleTextStyle: iOSTheme.largeTitle,
      ),
    );
  }

  /// Builds Material light theme using centralized theme files
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTextStyles.lightTextTheme,
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shadowColor: AppColors.cardShadowColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.cardColor(context),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: AppColors.richWhiskey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          padding: AppConstants.buttonPadding,
          textStyle: AppTextStyles.buttonText.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: AppConstants.appBarElevation,
        scrolledUnderElevation: 4,
        shadowColor: AppColors.richWhiskey.withOpacity(0.2),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.richWhiskey,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.richWhiskey,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.goldenAmber.withOpacity(0.3),
            width: AppConstants.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.goldenAmber.withOpacity(0.5),
            width: AppConstants.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.richWhiskey,
            width: AppConstants.inputFocusedBorderWidth,
          ),
        ),
        contentPadding: AppConstants.inputContentPadding,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Builds Material dark theme using centralized theme files
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTextStyles.darkTextTheme,
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation + 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.smokyGlass.withOpacity(0.85),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          padding: AppConstants.buttonPadding,
          textStyle: AppTextStyles.buttonText.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: AppConstants.appBarElevation,
        scrolledUnderElevation: 8,
        shadowColor: Colors.black54,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkAmber,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.darkAmber,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.smokyGlass.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.warmCopper.withOpacity(0.3),
            width: AppConstants.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.warmCopper.withOpacity(0.5),
            width: AppConstants.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.darkAmber,
            width: AppConstants.inputFocusedBorderWidth,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: AppConstants.inputContentPadding,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

/// Custom scroll behavior that provides smooth, bouncy scrolling on all platforms
class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

/// Temporary LoginScreen placeholder - will be moved to features/auth/ folder
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
            border: null,
            largeTitle: Text(
              'Mixologist',
              style: iOSTheme.largeTitle.copyWith(
                color: AppColors.richWhiskey,
              ),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: AppConstants.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.person_circle,
                      size: 80,
                      color: AppColors.richWhiskey,
                    ),
                    SizedBox(height: AppConstants.spacing24),
                    Text(
                      'Welcome to Mixologist',
                      style: iOSTheme.title1.copyWith(
                        color: AppColors.richWhiskey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppConstants.spacing16),
                    Text(
                      'Your personal cocktail companion',
                      style: iOSTheme.body.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppConstants.spacing40),
                    CupertinoButton.filled(
                      child: const Text('Get Started'),
                      onPressed: () {
                        // Navigate to main app - will be updated with proper routing
                        Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(
                            builder: (context) => const UnifiedInventoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
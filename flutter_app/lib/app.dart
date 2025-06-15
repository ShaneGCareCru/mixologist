import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_constants.dart';
import 'theme/ios_theme.dart';

/// Main application widget for the Mixologist app
/// 
/// This widget sets up the overall app structure, themes, and routing.
/// It uses our organized theme system with extracted colors, text styles, and constants.
class MixologistApp extends StatelessWidget {
  /// The home widget to display when the app starts
  final Widget home;

  const MixologistApp({
    super.key,
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _SmoothScrollBehavior(),
      child: CupertinoApp(
        title: 'Mixologist',
        theme: _buildCupertinoTheme(),
        home: home,
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
  
  /// Builds the Cupertino theme using our organized theme system
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

  /// Builds the light Material theme using our organized theme constants
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
      textTheme: AppTextStyles.lightTextTheme,
      cardTheme: CardThemeData(
        elevation: AppConstants.lightCardElevation,
        shadowColor: AppConstants.lightCardShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withOpacity(AppConstants.lightCardOpacity),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.lightButtonElevation,
          shadowColor: AppConstants.lightButtonShadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          padding: AppConstants.buttonPadding,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: AppConstants.lightCardShadowColor,
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
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: BorderSide(
            color: AppColors.goldenAmber.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: BorderSide(
            color: AppColors.goldenAmber.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: const BorderSide(
            color: AppColors.richWhiskey, 
            width: 2,
          ),
        ),
        contentPadding: AppConstants.inputPadding,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Builds the dark Material theme using our organized theme constants
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
      textTheme: AppTextStyles.darkTextTheme,
      cardTheme: CardThemeData(
        elevation: AppConstants.darkCardElevation,
        shadowColor: AppConstants.darkCardShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.smokyGlass.withOpacity(AppConstants.darkCardOpacity),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.darkButtonElevation,
          shadowColor: AppConstants.darkButtonShadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          padding: AppConstants.buttonPadding,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 8,
        shadowColor: AppConstants.darkCardShadowColor,
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
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: BorderSide(
            color: AppColors.warmCopper.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: BorderSide(
            color: AppColors.warmCopper.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: const BorderSide(
            color: AppColors.darkAmber, 
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: AppConstants.inputPadding,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

/// Enhanced background component with gradient and subtle patterns
/// 
/// This widget provides a consistent background across the app using our theme system.
class MixologistBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  
  const MixologistBackground({
    super.key, 
    required this.child,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppConstants.getBackgroundGradient(brightness),
      ),
      child: Container(
        decoration: BoxDecoration(
          backgroundBlendMode: BlendMode.overlay,
          color: AppConstants.getOverlayColor(brightness),
        ),
        child: child,
      ),
    );
  }
}

/// Enhanced glass card effect using our theme system
/// 
/// This widget creates glassmorphic cards with consistent styling.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppConstants.radiusXL,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: AppConstants.getGlassmorphicGradient(brightness),
        border: Border.all(
          color: AppConstants.getGlassmorphicBorderColor(brightness),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.getCardShadowColor(brightness),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding ?? AppConstants.cardPadding,
          color: color ?? AppConstants.getGlassmorphicBackgroundColor(brightness),
          child: child,
        ),
      ),
    );
  }
}

/// Custom scroll behavior for smooth scrolling across the app
class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_constants.dart';

/// iOS-specific theme helpers and utilities for the Mixologist app
/// Works in conjunction with the centralized app_colors.dart and app_constants.dart
class iOSTheme {
  // Private constructor to prevent instantiation
  iOSTheme._();

  // iOS System Colors (native iOS colors not covered in app_colors.dart)
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // Backward compatibility aliases to app_colors.dart
  static Color get whiskey => AppColors.richWhiskey;
  static Color get amber => AppColors.goldenAmber;
  static Color get champagne => AppColors.champagneGold;
  static Color get bitters => AppColors.deepBitters;
  static Color get citrus => AppColors.citrushZest;
  static Color get ice => AppColors.crystallIce;

  // Backward compatibility aliases to app_constants.dart
  static double get smallPadding => AppConstants.smallPadding;
  static double get mediumPadding => AppConstants.mediumPadding;
  static double get largePadding => AppConstants.largePadding;
  static double get extraLargePadding => AppConstants.extraLargePadding;
  static double get minimumTouchTarget => AppConstants.minimumTouchTarget;
  static double get smallRadius => AppConstants.radiusSmall;
  static double get mediumRadius => AppConstants.radiusMedium;
  static double get largeRadius => AppConstants.radiusLarge;
  static double get extraLargeRadius => AppConstants.radiusExtraLarge;
  static Duration get shortAnimation => AppConstants.shortAnimation;
  static Duration get mediumAnimation => AppConstants.mediumAnimation;
  static Duration get longAnimation => AppConstants.longAnimation;
  static Curve get iOSCurve => AppConstants.iOSCurve;
  static EdgeInsets get screenPadding => AppConstants.screenPadding;
  static EdgeInsets get cardPadding => AppConstants.cardPadding;
  static EdgeInsets get buttonPadding => AppConstants.buttonPadding;
  static List<BoxShadow> get cardShadow => AppConstants.cardShadow;
  static List<BoxShadow> get buttonShadow => AppConstants.buttonShadow;

  // iOS-specific typography scale (native iOS text styles)
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // iOS-specific adaptive color helper
  static Color adaptiveColor(BuildContext context, Color lightColor, Color darkColor) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark 
        ? darkColor 
        : lightColor;
  }
  
  // iOS-specific card decoration helper
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: adaptiveColor(
        context, 
        CupertinoColors.systemBackground, 
        AppColors.charcoalSurface,
      ),
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      boxShadow: AppConstants.cardShadow,
    );
  }

  // iOS-specific Cupertino theme data builder
  static CupertinoThemeData buildCupertinoTheme() {
    return CupertinoThemeData(
      primaryColor: AppColors.richWhiskey,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: CupertinoColors.systemBackground,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      textTheme: const CupertinoTextThemeData(
        primaryColor: AppColors.richWhiskey,
        textStyle: body,
        actionTextStyle: headline,
        tabLabelTextStyle: caption1,
        navTitleTextStyle: headline,
        navLargeTitleTextStyle: largeTitle,
      ),
    );
  }

  // iOS-specific navigation bar styling
  static Widget buildNavigationBar({
    required String title,
    Widget? leading,
    List<Widget>? trailing,
    bool automaticallyImplyLeading = true,
  }) {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
      border: null,
      middle: Text(
        title,
        style: headline.copyWith(
          color: AppColors.richWhiskey,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: leading,
      trailing: trailing != null && trailing.isNotEmpty 
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: trailing,
          )
        : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
}
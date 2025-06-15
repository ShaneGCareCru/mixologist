import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/ios_theme.dart';

class LoginScreen extends StatelessWidget {
  final Widget Function()? homeScreenBuilder;
  
  const LoginScreen({super.key, this.homeScreenBuilder});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('AI Mixologist'),
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: iOSTheme.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon area with cocktail glass icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iOSTheme.whiskey,
                        iOSTheme.amber,
                      ],
                    ),
                    boxShadow: iOSTheme.cardShadow,
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    size: 60,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: iOSTheme.extraLargePadding),
                
                // Welcome text with iOS styling
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: iOSTheme.cardDecoration(context),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to',
                        style: iOSTheme.title3.copyWith(
                          color: iOSTheme.adaptiveColor(
                            context, 
                            iOSTheme.whiskey.withOpacity(0.8), 
                            CupertinoColors.white.withOpacity(0.8)
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'AI Mixologist',
                        style: iOSTheme.largeTitle.copyWith(
                          color: iOSTheme.adaptiveColor(
                            context, 
                            iOSTheme.whiskey, 
                            CupertinoColors.white
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: iOSTheme.mediumPadding),
                      Text(
                        'Craft perfect cocktails with AI-powered recipes and step-by-step guidance',
                        style: iOSTheme.body.copyWith(
                          color: iOSTheme.adaptiveColor(
                            context, 
                            CupertinoColors.secondaryLabel, 
                            CupertinoColors.secondaryLabel
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // iOS-style sign-in button
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: CupertinoButton.filled(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signInAnonymously();
                        if (context.mounted && homeScreenBuilder != null) {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => homeScreenBuilder!(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Error'),
                              content: Text('Error signing in: $e'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(iOSTheme.largeRadius),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.play_fill, size: 18),
                        const SizedBox(width: 8),
                        Text('Start Mixing', style: iOSTheme.headline.copyWith(color: CupertinoColors.white)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: iOSTheme.extraLargePadding),
                
                // iOS-style feature highlights
                Container(
                  padding: iOSTheme.cardPadding,
                  decoration: iOSTheme.cardDecoration(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureIcon(
                        context,
                        CupertinoIcons.star,
                        'AI Recipes',
                      ),
                      _buildFeatureIcon(
                        context,
                        CupertinoIcons.checkmark_circle,
                        'Step Guide',
                      ),
                      _buildFeatureIcon(
                        context,
                        CupertinoIcons.paintbrush,
                        'Visual Aid',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: iOSTheme.adaptiveColor(
            context, 
            iOSTheme.whiskey.withOpacity(0.7), 
            CupertinoColors.white.withOpacity(0.7)
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: iOSTheme.caption1.copyWith(
            color: iOSTheme.adaptiveColor(
              context, 
              CupertinoColors.secondaryLabel, 
              CupertinoColors.secondaryLabel
            ),
          ),
        ),
      ],
    );
  }
}
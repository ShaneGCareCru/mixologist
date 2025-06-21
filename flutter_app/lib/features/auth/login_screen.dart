import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mixologist_flutter/theme/ios_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/logger.dart';
import '../home/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    MixologistLogger.logNavigation('app_start', 'login_screen');
  }

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
                              CupertinoColors.white.withOpacity(0.8)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'AI Mixologist',
                        style: iOSTheme.largeTitle.copyWith(
                          color: iOSTheme.adaptiveColor(
                              context, iOSTheme.whiskey, CupertinoColors.white),
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
                              CupertinoColors.secondaryLabel),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Google Sign-In button
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: CupertinoButton.filled(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    borderRadius: BorderRadius.circular(iOSTheme.largeRadius),
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.person_circle, size: 18),
                              const SizedBox(width: 8),
                              Text('Sign in with Google',
                                  style: iOSTheme.headline
                                      .copyWith(color: CupertinoColors.white)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: iOSTheme.mediumPadding),

                // Anonymous sign-in button for development
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: CupertinoButton(
                    onPressed: _isLoading ? null : _signInAnonymously,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.play_fill, size: 18),
                        const SizedBox(width: 8),
                        Text('Start Mixing (Guest)',
                            style: iOSTheme.body
                                .copyWith(color: iOSTheme.adaptiveColor(
                                    context, iOSTheme.whiskey, CupertinoColors.white))),
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

  Future<void> _signInWithGoogle() async {
    MixologistLogger.logUserAction('anonymous', 'attempt_google_signin');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential != null && mounted) {
        MixologistLogger.logNavigation('login_screen', 'home_screen', 
          userId: userCredential.user?.uid);
        
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      MixologistLogger.error('Google sign-in navigation failed', error: e);
      if (mounted) {
        _showErrorDialog('Sign-in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    MixologistLogger.logUserAction('anonymous', 'attempt_anonymous_signin');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await AuthService.signInAnonymously();
      if (userCredential != null && mounted) {
        MixologistLogger.logNavigation('login_screen', 'home_screen', 
          userId: userCredential.user?.uid);
        
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      MixologistLogger.error('Anonymous sign-in navigation failed', error: e);
      if (mounted) {
        _showErrorDialog('Anonymous sign-in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign-in Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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
              CupertinoColors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: iOSTheme.caption1.copyWith(
            color: iOSTheme.adaptiveColor(context,
                CupertinoColors.secondaryLabel, CupertinoColors.secondaryLabel),
          ),
        ),
      ],
    );
  }
}

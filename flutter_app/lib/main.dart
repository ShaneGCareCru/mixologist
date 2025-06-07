import 'dart:async'; // For StreamSubscription
import 'dart:convert'; // For jsonDecode, base64Decode, utf8, LineSplitter
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // HTTP package
// No longer importing flutter_client_sse
import 'firebase_options.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/section_preview.dart';
import 'widgets/connection_line.dart';
import 'widgets/drink_progress_glass.dart';
import 'widgets/method_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MixologistApp());
}

class MixologistApp extends StatelessWidget {
  const MixologistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _SmoothScrollBehavior(),
      child: MaterialApp(
        title: 'Mixologist',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    // Enhanced cocktail-inspired color palette
    const richWhiskey = Color(0xFF6D4C2D);
    const goldenAmber = Color(0xFFD4A574);
    const champagneGold = Color(0xFFF7E7CE);
    const deepBitters = Color(0xFF722F37);
    const citrushZest = Color(0xFFE67E22);
    const crystallIce = Color(0xFFF8FAFE);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: richWhiskey,
        brightness: Brightness.light,
        primary: richWhiskey,
        secondary: goldenAmber,
        surface: crystallIce,
        error: deepBitters,
        tertiary: citrushZest,
        primaryContainer: champagneGold,
        secondaryContainer: champagneGold.withOpacity(0.3),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, 
          fontWeight: FontWeight.w800, 
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.w700, 
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w600, 
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w600, 
          letterSpacing: -0.25,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: richWhiskey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withOpacity(0.9),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: richWhiskey.withOpacity(0.3),
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
        shadowColor: richWhiskey.withOpacity(0.2),
        backgroundColor: Colors.transparent,
        foregroundColor: richWhiskey,
        titleTextStyle: const TextStyle(
          color: richWhiskey,
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
          borderSide: BorderSide(color: goldenAmber.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: goldenAmber.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: richWhiskey, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    // Enhanced dark cocktail bar theme
    const darkAmber = Color(0xFFD4A574);
    const warmCopper = Color(0xFFB8860B);
    const charcoalSurface = Color(0xFF1C1C1E);
    const smokyGlass = Color(0xFF2C2C2E);
    const crimsonBitters = Color(0xFF8B1538);
    const citrusGlow = Color(0xFFFFB347);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkAmber,
        brightness: Brightness.dark,
        primary: darkAmber,
        secondary: warmCopper,
        surface: charcoalSurface,
        error: crimsonBitters,
        tertiary: citrusGlow,
        primaryContainer: warmCopper.withOpacity(0.3),
        secondaryContainer: smokyGlass,
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
          color: Colors.white87,
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
        color: smokyGlass.withOpacity(0.85),
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
        foregroundColor: darkAmber,
        titleTextStyle: const TextStyle(
          color: darkAmber,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: smokyGlass.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: warmCopper.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: warmCopper.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: darkAmber, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: const EdgeInsets.all(20),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

// Enhanced background component with gradient and subtle patterns
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
    final isCurrentlyDark = brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isCurrentlyDark ? _buildDarkGradient() : _buildLightGradient(),
      ),
      child: Container(
        decoration: BoxDecoration(
          backgroundBlendMode: BlendMode.overlay,
          color: isCurrentlyDark 
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
        ),
        child: child,
      ),
    );
  }
  
  LinearGradient _buildLightGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF7E7CE), // Champagne gold
        Color(0xFFE8D5B7), // Warm cream
        Color(0xFFD4A574), // Golden amber
        Color(0xFFF8FAFE), // Crystal ice
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );
  }
  
  LinearGradient _buildDarkGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1C1C1E), // Charcoal surface
        Color(0xFF2C2C2E), // Smoky glass
        Color(0xFF1A1A1A), // Deep black
        Color(0xFF2A2A2A), // Warm charcoal
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );
  }
}

// Enhanced glass card effect
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
    this.borderRadius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          color: color ??
              (isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1)),
          child: child,
        ),
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Mixologist'),
        centerTitle: true,
      ),
      body: MixologistBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo/icon area with cocktail glass icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_bar,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Welcome text with enhanced styling
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          'Welcome to',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'AI Mixologist',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Craft perfect cocktails with AI-powered recipes and step-by-step guidance',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Enhanced sign-in button
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signInAnonymously();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error signing in: $e'),
                                backgroundColor: theme.colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text('Start Mixing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subtle feature highlights
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureIcon(
                          context,
                          Icons.auto_awesome,
                          'AI Recipes',
                        ),
                        _buildFeatureIcon(
                          context,
                          Icons.check_circle_outline,
                          'Step Guide',
                        ),
                        _buildFeatureIcon(
                          context,
                          Icons.palette,
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
      ),
    );
  }
  
  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drinkQueryController = TextEditingController();
  final _drinkPreferencesController = TextEditingController();
  bool _isLoadingRecipe = false;
  bool _isLoadingCustom = false;
  String? _recipeError;
  String? _customError;

  Future<void> _getRecipe() async {
    if (_drinkQueryController.text.isEmpty) {
      setState(() { _recipeError = 'Please enter a drink name.'; });
      return;
    }
    setState(() { _isLoadingRecipe = true; _recipeError = null; });
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/create'), // Changed port to 8081
        body: {'drink_query': _drinkQueryController.text},
      );
      setState(() { _isLoadingRecipe = false; });
      if (response.statusCode == 200) {
        final recipeData = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecipeScreen(recipeData: recipeData)),
          );
        }
      } else {
        setState(() { _recipeError = 'Error fetching recipe: ${response.statusCode}'; });
        print('Error fetching recipe: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() { _isLoadingRecipe = false; _recipeError = 'Failed to connect: $e'; });
      print('Exception fetching recipe: $e');
    }
  }

  Future<void> _createCustomDrink() async {
    if (_drinkPreferencesController.text.isEmpty) {
      setState(() { _customError = 'Please describe your ideal drink.'; });
      return;
    }
    setState(() { _isLoadingCustom = true; _customError = null; });
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/create_from_description'),
        body: {'drink_description': _drinkPreferencesController.text},
      );
      setState(() { _isLoadingCustom = false; });
      if (response.statusCode == 200) {
        final recipeData = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecipeScreen(recipeData: recipeData)),
          );
        }
      } else {
        setState(() { _customError = 'Error creating drink: ${response.statusCode}'; });
      }
    } catch (e) {
      setState(() { _isLoadingCustom = false; _customError = 'Failed to connect: $e'; });
    }
  }

  @override
  void dispose() {
    _drinkQueryController.dispose();
    _drinkPreferencesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Mixologist'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: MixologistBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                
                // Welcome section with user info
                if (user != null)
                  GlassmorphicCard(
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.isAnonymous
                                    ? 'Guest User (${user.uid.substring(0,6)}...)'
                                    : user.displayName ?? user.email ?? 'User',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Quick actions section
                GlassmorphicCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_bar,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Create Your Perfect Drink',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find a classic recipe or describe your ideal cocktail',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Search by name field
                      TextField(
                        controller: _drinkQueryController,
                        decoration: InputDecoration(
                          labelText: 'Search by Drink Name',
                          hintText: 'e.g., Margarita, Old Fashioned, Mojito',
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                          errorText: _recipeError,
                        ),
                        onSubmitted: (_) => _getRecipe(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Quick search buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickSearchChip(context, 'Margarita'),
                          _buildQuickSearchChip(context, 'Old Fashioned'),
                          _buildQuickSearchChip(context, 'Mojito'),
                          _buildQuickSearchChip(context, 'Manhattan'),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Get recipe button
                      SizedBox(
                        width: double.infinity,
                        child: _isLoadingRecipe
                            ? Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _getRecipe,
                                icon: const Icon(Icons.search, size: 20),
                                label: const Text('Find Recipe'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Custom drink section
                GlassmorphicCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.secondary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'AI Custom Creation',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Describe your perfect drink and let AI create a custom recipe',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      TextField(
                        controller: _drinkPreferencesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Describe Your Ideal Drink',
                          hintText: 'I want something fruity and bubbly with rum, maybe with tropical flavors...',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.edit, color: theme.colorScheme.secondary),
                          ),
                          errorText: _customError,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: _isLoadingCustom
                            ? Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.colorScheme.secondary.withOpacity(0.1),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _createCustomDrink,
                                icon: const Icon(Icons.auto_awesome, size: 20),
                                label: const Text('Create Custom Drink'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickSearchChip(BuildContext context, String drinkName) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(drinkName),
      onPressed: () {
        _drinkQueryController.text = drinkName;
        _getRecipe();
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class RecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  const RecipeScreen({super.key, required this.recipeData});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  Uint8List? _currentImageBytes;
  String? _imageStreamError;
  bool _isImageStreamComplete = false;
  StreamSubscription<String>? _imageStreamSubscription; // Changed type
  final http.Client _httpClient = http.Client(); // HTTP client for streaming request
  
  // Epic 2: Interactive Recipe Components
  int _servingSize = 1;
  bool _isMetric = false; // false = oz, true = ml
  Map<String, bool> _ingredientChecklist = {};
  
  // Epic 3: Visual Recipe Steps
  Map<int, bool> _stepCompletion = {};
  
  // Dynamic Visual Generation System
  Map<String, Uint8List?> _specializedImages = {};
  Map<String, bool> _imageGenerationProgress = {};
  String _selectedSection = 'overview'; // Navigation state
  String? _expandedSection;
  final Map<String, double> _sectionHeights = {};
  final Map<int, List<String>> _stepIngredientMap = {};
  final Map<int, List<String>> _stepEquipmentMap = {};
  final Map<String, GlobalKey> _ingredientIconKeys = {};
  final Map<String, GlobalKey> _equipmentIconKeys = {};
  final List<GlobalKey> _stepCardKeys = [];
  int? _hoveredStep;
  bool _isGeneratingVisuals = false;
  bool _isLoadingRelatedCocktail = false;
  
  DrinkProgress get _currentDrinkProgress {
    final totalSteps = _stepCompletion.length;
    final completedSteps = _stepCompletion.values.where((completed) => completed).length;
    
    if (completedSteps == 0) return DrinkProgress.emptyGlass;
    if (completedSteps < totalSteps * 0.4) return DrinkProgress.ingredientsAdded;
    if (completedSteps < totalSteps * 0.8) return DrinkProgress.mixed;
    if (completedSteps < totalSteps) return DrinkProgress.garnished;
    return DrinkProgress.complete;
  }
  
  String _getProgressText() {
    switch (_currentDrinkProgress) {
      case DrinkProgress.emptyGlass:
        return 'Ready to start mixing';
      case DrinkProgress.ingredientsAdded:
        return 'Adding ingredients...';
      case DrinkProgress.mixed:
        return 'Mixing and blending...';
      case DrinkProgress.garnished:
        return 'Almost finished!';
      case DrinkProgress.complete:
        return 'Cocktail complete! 🍹';
    }
  }

  void _completeStep(int stepIndex) {
    setState(() {
      _stepCompletion[stepIndex] = true;
    });
    _saveProgress(); // Save progress when step is completed
  }

  void _toggleStepCompleted(int stepIndex, bool completed) {
    setState(() {
      _stepCompletion[stepIndex] = completed;
    });
    _saveProgress();
  }

  void _goToPreviousStep(int currentStepIndex) {
    if (currentStepIndex > 0) {
      setState(() {
        _stepCompletion[currentStepIndex - 1] = false;
      });
      _saveProgress(); // Save progress when step is unchecked
    }
  }

  String? _getProTipForStep(String stepText) {
    // Simple pro tip generation based on step content
    final stepLower = stepText.toLowerCase();
    
    if (stepLower.contains('shake') || stepLower.contains('shaking')) {
      return 'Shake vigorously for 10-15 seconds to properly chill and dilute the drink.';
    } else if (stepLower.contains('stir') || stepLower.contains('stirring')) {
      return 'Stir gently for 20-30 seconds to avoid over-dilution while chilling.';
    } else if (stepLower.contains('strain')) {
      return 'Double strain through a fine mesh strainer for the smoothest texture.';
    } else if (stepLower.contains('garnish')) {
      return 'Express citrus oils over the drink by gently twisting the peel.';
    } else if (stepLower.contains('muddle')) {
      return 'Muddle gently to release oils without creating bitter flavors from over-crushing.';
    }
    
    return null; // No pro tip for this step
  }

  TipCategory? _getTipCategoryForStep(String stepText) {
    final stepLower = stepText.toLowerCase();
    
    if (stepLower.contains('shake') || stepLower.contains('shaking') ||
        stepLower.contains('stir') || stepLower.contains('stirring') ||
        stepLower.contains('muddle')) {
      return TipCategory.technique;
    } else if (stepLower.contains('strain')) {
      return TipCategory.equipment;
    } else if (stepLower.contains('garnish') || stepLower.contains('serve')) {
      return TipCategory.presentation;
    } else if (stepLower.contains('chill') || stepLower.contains('temperature')) {
      return TipCategory.timing;
    } else if (stepLower.contains('fresh') || stepLower.contains('quality')) {
      return TipCategory.ingredient;
    }
    
    return null;
  }

  IconData _getIngredientIcon(String ingredientName) {
    final nameLower = ingredientName.toLowerCase();
    
    if (nameLower.contains('whiskey') || nameLower.contains('bourbon') || nameLower.contains('scotch')) {
      return Icons.local_bar;
    } else if (nameLower.contains('vodka') || nameLower.contains('gin') || nameLower.contains('rum')) {
      return Icons.local_bar;
    } else if (nameLower.contains('lemon') || nameLower.contains('lime') || nameLower.contains('orange')) {
      return Icons.circle;
    } else if (nameLower.contains('syrup') || nameLower.contains('honey') || nameLower.contains('sugar')) {
      return Icons.water_drop;
    } else if (nameLower.contains('bitters') || nameLower.contains('vermouth')) {
      return Icons.opacity;
    } else if (nameLower.contains('ice') || nameLower.contains('water')) {
      return Icons.ac_unit;
    } else if (nameLower.contains('mint') || nameLower.contains('herb') || nameLower.contains('basil')) {
      return Icons.eco;
    } else if (nameLower.contains('cherry') || nameLower.contains('olive') || nameLower.contains('garnish')) {
      return Icons.circle_outlined;
    } else {
      return Icons.local_grocery_store;
    }
  }

  @override
  void initState() {
    super.initState();
    _connectToImageStream();
    _initializeIngredientChecklist();
    _initializeSpecializedImages();
    _initializeStepConnections();
    _loadCachedImages(); // Check for existing cached images
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreExpandedFromHash());
  }

  void _restoreExpandedFromHash() {
    final fragment = Uri.base.fragment;
    const sections = ['ingredients', 'method', 'equipment', 'variations'];
    if (sections.contains(fragment)) {
      setState(() {
        _expandedSection = fragment;
      });
    }
  }

  void _toggleExpandedSection(String id) {
    setState(() {
      if (_expandedSection == id) {
        _expandedSection = null;
        if (kIsWeb) {
          html.window.history.replaceState(null, '', '#');
        }
      } else {
        _expandedSection = id;
        if (kIsWeb) {
          html.window.history.replaceState(null, '', '#$id');
        }
        
        // Auto-generate ingredient images when ingredients section is expanded
        if (id == 'ingredients') {
          _autoGenerateIngredientImages();
        }
      }
    });
  }

  void _autoGenerateIngredientImages() {
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        final ingredientName = ingredient['name'];
        final imageKey = 'ingredient_$ingredientName';
        
        // Only generate if we don't already have the image and aren't currently generating
        if (_specializedImages[imageKey] == null && 
            _imageGenerationProgress[imageKey] != true) {
          _generateSpecializedImage(imageKey, ingredientName, context: 'ingredient');
        }
      }
    }
  }

  bool _ingredientActive(String name) {
    if (_hoveredStep == null) return false;
    return _stepIngredientMap[_hoveredStep!]?.contains(name.toLowerCase()) ?? false;
  }

  bool _equipmentActive(String name) {
    if (_hoveredStep == null) return false;
    return _stepEquipmentMap[_hoveredStep!]?.contains(name.toLowerCase()) ?? false;
  }
  
  void _initializeSpecializedImages() {
    _specializedImages = {
      'glassware': null,
      'garnish': null,
    };
    _imageGenerationProgress = {
      'glassware': false,
      'garnish': false,
    };
    
    // Initialize ingredient images
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        final ingredientName = ingredient['name'];
        _specializedImages['ingredient_$ingredientName'] = null;
        _imageGenerationProgress['ingredient_$ingredientName'] = false;
      }
    }
    
    // Initialize equipment images
    if (widget.recipeData['equipment_needed'] is List) {
      for (var equipment in widget.recipeData['equipment_needed']) {
        final equipmentName = equipment['item'] ?? equipment;
        _specializedImages['equipment_$equipmentName'] = null;
        _imageGenerationProgress['equipment_$equipmentName'] = false;
      }
    }
    
    // Initialize method/step images
    if (widget.recipeData['steps'] is List) {
      for (int i = 0; i < widget.recipeData['steps'].length; i++) {
        _specializedImages['method_step_$i'] = null;
        _imageGenerationProgress['method_step_$i'] = false;
      }
    }
  }
  
  // Load cached images by checking endpoints without generating new ones
  Future<void> _loadCachedImages() async {
    // Try to load glassware
    final glassType = widget.recipeData['serving_glass'];
    if (glassType != null && glassType.isNotEmpty) {
      await _checkCachedImage('glassware', glassType);
    }
    
    // Try to load garnish
    final garnishes = widget.recipeData['garnish'];
    if (garnishes is List && garnishes.isNotEmpty) {
      await _checkCachedImage('garnish', garnishes.first);
    }
    
    // Try to load ALL ingredient images
    if (widget.recipeData['ingredients'] is List) {
      final ingredients = widget.recipeData['ingredients'] as List;
      for (var ingredient in ingredients) {
        final ingredientName = ingredient['name'];
        await _checkCachedImage('ingredient_$ingredientName', ingredientName);
        // Small delay to not overwhelm the server
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    // Try to load equipment images
    if (widget.recipeData['equipment_needed'] is List) {
      final equipment = widget.recipeData['equipment_needed'] as List;
      for (var item in equipment) {
        final equipmentName = item['item'] ?? item;
        await _checkCachedImage('equipment_$equipmentName', equipmentName);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
  
  // Check if an image is cached on the server and load it if available
  Future<void> _checkCachedImage(String imageType, String subject) async {
    try {
      String endpoint;
      Map<String, String> bodyFields;
      
      // Determine endpoint based on image type
      if (imageType == 'glassware') {
        endpoint = 'generate_glassware_image';
        bodyFields = {'glass_type': subject};
      } else if (imageType == 'garnish') {
        endpoint = 'generate_garnish_image';
        bodyFields = {'garnish_description': subject};
      } else if (imageType.startsWith('ingredient_')) {
        endpoint = 'generate_ingredient_image';
        bodyFields = {'ingredient_name': subject};
      } else if (imageType.startsWith('equipment_')) {
        endpoint = 'generate_equipment_image';
        bodyFields = {'equipment_name': subject};
      } else {
        return;
      }
      
      final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/$endpoint'));
      request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
      request.bodyFields = bodyFields;
      
      final http.StreamedResponse response = await _httpClient.send(request);
      if (response.statusCode == 200) {
        bool foundCachedImage = false;
        
        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final eventDataString = line.substring('data: '.length);
              try {
                final jsonData = jsonDecode(eventDataString);
                if (jsonData['type'] == 'partial_image' && jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _specializedImages[imageType] = base64Decode(jsonData['b64_data']);
                      foundCachedImage = true;
                    });
                  }
                }
              } catch (e) {
                // Ignore parsing errors for cache check
              }
            }
          },
          onDone: () {
            // If we didn't find a cached image, we don't set any error state
            // The user can still manually generate or use "Generate Visuals"
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
      // Silently fail for cache checks - images can be generated later
      print('Cache check failed for $imageType: $e');
    }
  }

  void _initializeIngredientChecklist() {
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        _ingredientChecklist[ingredient['name']] = false;
      }
    }
    
    // Epic 3: Initialize step completion tracking
    if (widget.recipeData['steps'] is List) {
      for (int i = 0; i < widget.recipeData['steps'].length; i++) {
        _stepCompletion[i] = false;
      }
    }
    
    // Load saved progress
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      if (kIsWeb) {
        await _loadProgressWeb();
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final recipeKey = _getRecipeKey();
      
      // Load ingredient checklist
      final ingredientKeys = _ingredientChecklist.keys.toList();
      for (String ingredient in ingredientKeys) {
        final saved = prefs.getBool('${recipeKey}_ingredient_$ingredient');
        if (saved != null) {
          _ingredientChecklist[ingredient] = saved;
        }
      }
      
      // Load step completion
      final stepKeys = _stepCompletion.keys.toList();
      for (int step in stepKeys) {
        final saved = prefs.getBool('${recipeKey}_step_$step');
        if (saved != null) {
          _stepCompletion[step] = saved;
        }
      }
      
      // Update UI if any progress was loaded
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading progress: $e');
      // Fallback to web storage if SharedPreferences fails
      if (kIsWeb) {
        await _loadProgressWeb();
      }
    }
  }

  Future<void> _saveProgress() async {
    try {
      if (kIsWeb) {
        await _saveProgressWeb();
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final recipeKey = _getRecipeKey();
      
      // Save ingredient checklist
      for (String ingredient in _ingredientChecklist.keys) {
        await prefs.setBool('${recipeKey}_ingredient_$ingredient', _ingredientChecklist[ingredient]!);
      }
      
      // Save step completion
      for (int step in _stepCompletion.keys) {
        await prefs.setBool('${recipeKey}_step_$step', _stepCompletion[step]!);
      }
    } catch (e) {
      print('Error saving progress: $e');
      // Fallback to web storage if SharedPreferences fails
      if (kIsWeb) {
        await _saveProgressWeb();
      }
    }
  }

  String _getRecipeKey() {
    // Generate a unique key for this recipe based on its content
    final recipeName = widget.recipeData['name'] ?? 'unknown';
    final ingredientCount = (widget.recipeData['ingredients'] as List?)?.length ?? 0;
    final stepCount = (widget.recipeData['steps'] as List?)?.length ?? 0;
    return '${recipeName}_${ingredientCount}_$stepCount';
  }


  Future<void> _saveProgressWeb() async {
    if (!kIsWeb) return;
    
    try {
      final recipeKey = _getRecipeKey();
      
      // Save ingredient checklist
      for (String ingredient in _ingredientChecklist.keys) {
        html.window.localStorage['${recipeKey}_ingredient_$ingredient'] = 
            _ingredientChecklist[ingredient].toString();
      }
      
      // Save step completion
      for (int step in _stepCompletion.keys) {
        html.window.localStorage['${recipeKey}_step_$step'] = 
            _stepCompletion[step].toString();
      }
    } catch (e) {
      print('Error saving progress to localStorage: $e');
    }
  }

  Future<void> _loadProgressWeb() async {
    if (!kIsWeb) return;
    
    try {
      final recipeKey = _getRecipeKey();
      
      // Load ingredient checklist
      final ingredientKeys = _ingredientChecklist.keys.toList();
      for (String ingredient in ingredientKeys) {
        final saved = html.window.localStorage['${recipeKey}_ingredient_$ingredient'];
        if (saved != null) {
          _ingredientChecklist[ingredient] = saved.toLowerCase() == 'true';
        }
      }
      
      // Load step completion
      final stepKeys = _stepCompletion.keys.toList();
      for (int step in stepKeys) {
        final saved = html.window.localStorage['${recipeKey}_step_$step'];
        if (saved != null) {
          _stepCompletion[step] = saved.toLowerCase() == 'true';
        }
      }
      
      // Update UI if any progress was loaded
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading progress from localStorage: $e');
    }
  }

  void _initializeStepConnections() {
    final ingredients = (widget.recipeData['ingredients'] as List?)
            ?.map((e) => e['name'].toString().toLowerCase())
            .toList() ??
        [];
    final equipment = (widget.recipeData['equipment_needed'] as List?)
            ?.map((e) => (e['item'] ?? e).toString().toLowerCase())
            .toList() ??
        [];
    final steps = (widget.recipeData['steps'] as List?)?.map((e) => e.toString()) ?? [];
    int idx = 0;
    for (final step in steps) {
      final stepLower = step.toLowerCase();
      _stepIngredientMap[idx] = [
        for (final ing in ingredients)
          if (stepLower.contains(ing)) ing
      ];
      _stepEquipmentMap[idx] = [
        for (final eq in equipment)
          if (stepLower.contains(eq)) eq
      ];
      idx++;
    }
  }
  
  // Navigate to a new cocktail recipe
  Future<void> _loadRelatedCocktail(String cocktailName) async {
    setState(() {
      _isLoadingRelatedCocktail = true;
    });
    
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/create'),
        body: {'drink_query': cocktailName},
      );
      
      if (response.statusCode == 200) {
        final newRecipeData = jsonDecode(response.body);
        if (mounted) {
          // Navigate to the new recipe page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeData: newRecipeData),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading $cocktailName: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load $cocktailName: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRelatedCocktail = false;
        });
      }
    }
  }

  // Epic 2: Task 2.1 - Serving Size Calculator Logic
  String _scaleIngredientAmount(String originalAmount, int servings) {
    // Extract number from amount string (e.g., "2 oz" -> 2.0)
    final RegExp numberRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = numberRegex.firstMatch(originalAmount);
    
    if (match != null) {
      final double baseAmount = double.parse(match.group(1)!);
      final double scaledAmount = baseAmount * servings;
      final String unit = originalAmount.replaceAll(numberRegex, '').trim();
      
      // Epic 2: Task 2.2 - Unit conversion
      if (_isMetric && unit.toLowerCase().contains('oz')) {
        final double mlAmount = scaledAmount * 29.5735;
        return '${mlAmount.toStringAsFixed(1)} ml';
      } else if (!_isMetric && unit.toLowerCase().contains('ml')) {
        final double ozAmount = scaledAmount / 29.5735;
        return '${ozAmount.toStringAsFixed(1)} oz';
      }
      
      return '${scaledAmount % 1 == 0 ? scaledAmount.toInt() : scaledAmount.toStringAsFixed(1)} $unit';
    }
    
    return originalAmount; // Return original if no number found
  }
  
  // Specialized Image Generation Functions
  Future<void> _generateSpecializedImage(String imageType, String subject, {String context = ""}) async {
    if (_imageGenerationProgress[imageType] == true) return;
    
    setState(() {
      _imageGenerationProgress[imageType] = true;
    });
    
    String endpoint;
    Map<String, String> bodyFields;
    
    // Determine endpoint and parameters based on image type
    if (imageType == 'glassware') {
      endpoint = 'generate_glassware_image';
      bodyFields = {
        'glass_type': subject,
        'drink_context': widget.recipeData['drink_name'] ?? '',
      };
    } else if (imageType == 'garnish') {
      endpoint = 'generate_garnish_image';
      bodyFields = {
        'garnish_description': subject,
        'preparation_method': '',
      };
    } else if (imageType.startsWith('ingredient_')) {
      endpoint = 'generate_ingredient_image';
      bodyFields = {
        'ingredient_name': subject,
        'drink_context': widget.recipeData['drink_name'] ?? '',
      };
    } else if (imageType.startsWith('method_') || imageType.startsWith('step_')) {
      endpoint = 'generate_method_image';
      bodyFields = {
        'step_text': subject,
        'step_index': context.isNotEmpty ? context : '0',
      };
    } else if (imageType.startsWith('equipment_')) {
      endpoint = 'generate_equipment_image';
      bodyFields = {
        'equipment_name': subject,
        'drink_context': widget.recipeData['drink_name'] ?? '',
      };
    } else {
      return; // Unknown image type
    }
    
    final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/$endpoint'));
    request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
    request.bodyFields = bodyFields;
    
    try {
      final http.StreamedResponse response = await _httpClient.send(request);
      
      if (response.statusCode == 200) {
        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final eventDataString = line.substring('data: '.length);
              try {
                final jsonData = jsonDecode(eventDataString);
                if (jsonData['type'] == 'partial_image' && jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _specializedImages[imageType] = base64Decode(jsonData['b64_data']);
                    });
                  }
                } else if (jsonData['type'] == 'stream_complete') {
                  if (mounted) {
                    setState(() {
                      _imageGenerationProgress[imageType] = false;
                    });
                  }
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageGenerationProgress[imageType] = false;
                    });
                  }
                }
              } catch (e) {
                print("Error parsing specialized image SSE data: $e");
              }
            }
          },
          onError: (error) {
            print('Specialized image stream error: $error');
            if (mounted) {
              setState(() {
                _imageGenerationProgress[imageType] = false;
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _imageGenerationProgress[imageType] = false;
              });
            }
          },
        );
      }
    } catch (e) {
      print('Error generating specialized image: $e');
      if (mounted) {
        setState(() {
          _imageGenerationProgress[imageType] = false;
        });
      }
    }
  }
  
  // Generate all visual assets for the recipe
  Future<void> _generateRecipeVisuals() async {
    setState(() {
      _isGeneratingVisuals = true;
    });
    
    // Generate glassware image (if not already cached)
    final glassType = widget.recipeData['serving_glass'];
    if (glassType != null && glassType.isNotEmpty && _specializedImages['glassware'] == null) {
      await _generateSpecializedImage('glassware', glassType);
    }
    
    // Generate garnish image (if not already cached)
    final garnishes = widget.recipeData['garnish'];
    if (garnishes is List && garnishes.isNotEmpty && _specializedImages['garnish'] == null) {
      await _generateSpecializedImage('garnish', garnishes.first);
    }
    
    // Generate ALL ingredient images (not just first 3)
    if (widget.recipeData['ingredients'] is List) {
      final ingredients = widget.recipeData['ingredients'] as List;
      for (var ingredient in ingredients) {
        final ingredientName = ingredient['name'];
        final imageKey = 'ingredient_$ingredientName';
        
        // Only generate if not already cached or being generated
        if (_specializedImages[imageKey] == null && _imageGenerationProgress[imageKey] != true) {
          await _generateSpecializedImage(imageKey, ingredientName);
          // Add delay between requests to prevent overload
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    
    // Generate equipment images
    if (widget.recipeData['equipment_needed'] is List) {
      final equipment = widget.recipeData['equipment_needed'] as List;
      for (var item in equipment) {
        final equipmentName = item['item'] ?? item;
        final imageKey = 'equipment_$equipmentName';
        
        // Only generate if not already cached or being generated
        if (_specializedImages[imageKey] == null && _imageGenerationProgress[imageKey] != true) {
          await _generateSpecializedImage(imageKey, equipmentName);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    
    // Generate method/step images
    if (widget.recipeData['steps'] is List) {
      final steps = widget.recipeData['steps'] as List;
      for (int i = 0; i < steps.length; i++) {
        final stepDescription = steps[i];
        final imageKey = 'method_step_$i';
        
        // Only generate if not already cached or being generated
        if (_specializedImages[imageKey] == null && _imageGenerationProgress[imageKey] != true) {
          await _generateSpecializedImage(imageKey, stepDescription, context: i.toString());
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    
    setState(() {
      _isGeneratingVisuals = false;
    });
  }

  void _connectToImageStream() async {
    setState(() {
      _currentImageBytes = null;
      _imageStreamError = null;
      _isImageStreamComplete = false;
    });

    final imageDescription = widget.recipeData['drink_image_description'] ?? 'A delicious cocktail.';
    final drinkName = widget.recipeData['drink_name'] ?? 'Cocktail';
    final servingGlass = widget.recipeData['serving_glass'] ?? '';
    final ingredients = widget.recipeData['ingredients'];

    _imageStreamSubscription?.cancel(); // Cancel previous subscription

    final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/generate_image')); // Changed port to 8081
    request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
    request.bodyFields = { // Use bodyFields for form data
        'image_description': imageDescription,
        'drink_query': drinkName,
        'serving_glass': servingGlass,
        'ingredients': jsonEncode(ingredients),
        'steps': jsonEncode(widget.recipeData['steps'] ?? []),
        'garnish': jsonEncode(widget.recipeData['garnish'] ?? []),
        'equipment_needed': jsonEncode(widget.recipeData['equipment_needed'] ?? []),
    };

    try {
      final http.StreamedResponse response = await _httpClient.send(request);

      if (response.statusCode == 200) {
        _imageStreamSubscription = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter()) // Process line by line
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final eventDataString = line.substring('data: '.length);
              try {
                final jsonData = jsonDecode(eventDataString);
                // Only log event type for cleaner logs
                if (jsonData['type'] != null) {
                  print("SSE Event: ${jsonData['type']}");
                }
                if (jsonData['type'] == 'partial_image' && jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _currentImageBytes = base64Decode(jsonData['b64_data']);
                      _imageStreamError = null;
                    });
                  }
                } else if (jsonData['type'] == 'stream_complete') {
                  if (mounted) {
                    setState(() { _isImageStreamComplete = true; });
                  }
                  print("Image stream complete from server.");
                  _imageStreamSubscription?.cancel(); 
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageStreamError = jsonData['message'] ?? 'Unknown stream error';
                      _currentImageBytes = null;
                    });
                  }
                  print("Error from image stream: ${jsonData['message']}");
                  _imageStreamSubscription?.cancel();
                }
              } catch (e) {
                print("Error parsing SSE JSON data: $e. Data: ${eventDataString.length > 50 ? '${eventDataString.substring(0, 50)}...' : eventDataString}");
                if (mounted) { setState(() { _imageStreamError = "Error parsing stream data."; });}
              }
            }
          },
          onError: (error) {
            print('SSE Stream Listen Error: $error');
            if (mounted) { setState(() { _imageStreamError = 'SSE stream error: $error'; _currentImageBytes = null; });}
          },
          onDone: () {
            print('SSE Stream Listen Done.');
            if (mounted && !_isImageStreamComplete && _imageStreamError == null) {
                 // setState(() { _imageStreamError = 'Image stream closed prematurely.'; });
            }
          },
          cancelOnError: true,
        );
      } else {
        print('SSE initial request failed: ${response.statusCode} ${response.reasonPhrase}');
        if (mounted) { setState(() { _imageStreamError = 'Failed to connect to image stream: ${response.statusCode}';});}
      }
    } catch (e) {
      print('Error sending SSE request: $e');
      if (mounted) { setState(() { _imageStreamError = 'Error connecting to image stream: $e';});}
    }
  }

  @override
  void dispose() {
    _imageStreamSubscription?.cancel();
    _httpClient.close(); // Close the client when the widget is disposed
    super.dispose();
  }
  
  // Visual Navigation System
  Widget _buildNavigationBar() {
    final sections = [
      {'id': 'overview', 'icon': Icons.home, 'label': 'Overview'},
      {'id': 'ingredients', 'icon': Icons.local_grocery_store, 'label': 'Ingredients'},
      {'id': 'method', 'icon': Icons.format_list_numbered, 'label': 'Method'},
      {'id': 'equipment', 'icon': Icons.build, 'label': 'Equipment'},
      {'id': 'variations', 'icon': Icons.auto_awesome, 'label': 'Variations'},
    ];
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final isSelected = _selectedSection == section['id'];
          
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSection = section['id'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        section['icon'] as IconData,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section['label'] as String,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Section Content Builders
  Widget _buildOverviewSection() {
    return Column(
      children: [
        // Main layout: Image left, Details right
        SizedBox(
          height: 500,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Hero Image
              Expanded(
                flex: 7,
                child: Card(
                  elevation: 8,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[200]!,
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_currentImageBytes != null)
                          Image.memory(
                            _currentImageBytes!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        if (_currentImageBytes == null && _imageStreamError == null)
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Creating your cocktail image...'),
                            ],
                          ),
                        // Time Overlay - Top Right
                        if (_currentImageBytes != null)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.recipeData['preparation_time_minutes'] ?? 5} min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        // Alcohol Overlay - Bottom Right  
                        if (_currentImageBytes != null)
                          Positioned(
                            bottom: 80, // Above the generate button
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(widget.recipeData['alcohol_content'] * 100).toStringAsFixed(1)}% ABV',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        // Generate Visuals Button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.extended(
                            onPressed: _isGeneratingVisuals ? null : _generateRecipeVisuals,
                            icon: _isGeneratingVisuals 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isGeneratingVisuals ? 'Generating All Images...' : 'Generate All Visuals'),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Right: Details Sidebar
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Quick Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Icon(Icons.local_bar, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    Text('${(widget.recipeData['alcohol_content'] * 100).toStringAsFixed(1)}% ABV'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Icon(Icons.timer, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    Text('${widget.recipeData['preparation_time_minutes'] ?? 5} min'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Variations Section
                      if (widget.recipeData['suggested_variations'] is List && 
                          (widget.recipeData['suggested_variations'] as List).isNotEmpty) ...[
                        Text('Variations', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...((widget.recipeData['suggested_variations'] as List).take(2).map((v) {
                          final name = v['name'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.arrow_right,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })),
                        const SizedBox(height: 16),
                      ],
                      
                      // History Section
                      if (widget.recipeData['drink_history'] != null && 
                          widget.recipeData['drink_history'].toString().isNotEmpty) ...[
                        Text('History', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              widget.recipeData['drink_history'].toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Debug: Print trivia data
                      Builder(
                        builder: (context) {
                          print('=== TRIVIA DEBUG ===');
                          print('Recipe data keys: ${widget.recipeData.keys.toList()}');
                          print('drink_trivia exists: ${widget.recipeData.containsKey('drink_trivia')}');
                          print('drink_trivia value: ${widget.recipeData['drink_trivia']}');
                          print('drink_trivia type: ${widget.recipeData['drink_trivia'].runtimeType}');
                          if (widget.recipeData['drink_trivia'] is List) {
                            print('drink_trivia length: ${(widget.recipeData['drink_trivia'] as List).length}');
                          }
                          print('===================');
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // Trivia Section
                      if (widget.recipeData['drink_trivia'] is List && 
                          (widget.recipeData['drink_trivia'] as List).isNotEmpty) ...[
                        Text('Trivia', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...((widget.recipeData['drink_trivia'] as List).take(3).map((trivia) {
                          final fact = trivia['fact'] ?? trivia.toString();
                          final category = trivia['category'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (category.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          category.toUpperCase(),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      fact,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                      ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionPreviews(),
      ],
    );
  }

  Widget _buildSectionPreviews() {
    return Stack(
      children: [
        Column(
          children: [
            SectionPreview(
              title: 'Method',
              icon: Icons.format_list_numbered,
              previewContent: _buildMethodPreviewWidget(),
              expandedContent: _buildMethodSection(),
              totalItems: (widget.recipeData['steps'] as List?)?.length ?? 0,
              completedItems: _stepCompletion.values.where((e) => e).length,
              expanded: _expandedSection == 'method',
              onOpen: () => _toggleExpandedSection('method'),
              onClose: () => _toggleExpandedSection('method'),
            ),
            const SizedBox(height: 12),
            SectionPreview(
              title: 'Ingredients',
              icon: Icons.local_grocery_store,
              previewContent: _buildIngredientsPreviewWidget(),
              expandedContent: _buildIngredientsSection(),
              totalItems: (widget.recipeData['ingredients'] as List?)?.length ?? 0,
              completedItems: _ingredientChecklist.values.where((e) => e).length,
              expanded: _expandedSection == 'ingredients',
              onOpen: () => _toggleExpandedSection('ingredients'),
              onClose: () => _toggleExpandedSection('ingredients'),
            ),
            const SizedBox(height: 12),
            SectionPreview(
              title: 'Equipment',
              icon: Icons.build,
              previewContent: _buildEquipmentPreviewWidget(),
              expandedContent: _buildEquipmentSection(),
              totalItems: (widget.recipeData['equipment_needed'] as List?)?.length ?? 0,
              expanded: _expandedSection == 'equipment',
              onOpen: () => _toggleExpandedSection('equipment'),
              onClose: () => _toggleExpandedSection('equipment'),
            ),
            const SizedBox(height: 12),
            SectionPreview(
              title: 'Variations',
              icon: Icons.auto_awesome,
              previewContent: _buildVariationsPreviewWidget(),
              expandedContent: _buildVariationsSection(),
              totalItems: (widget.recipeData['suggested_variations'] as List?)?.length ?? 0,
              expanded: _expandedSection == 'variations',
              onOpen: () => _toggleExpandedSection('variations'),
              onClose: () => _toggleExpandedSection('variations'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsPreviewWidget() {
    final ingredients =
        (widget.recipeData['ingredients'] as List?)?.take(4).toList() ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        final name = ingredient['name'] ?? ingredient.toString();
        final imageKey = 'ingredient_$name';
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: _specializedImages[imageKey] != null
                      ? Image.memory(
                          _specializedImages[imageKey]!,
                          fit: BoxFit.cover,
                        )
                      : _imageGenerationProgress[imageKey] == true
                          ? Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, 
                                           color: Colors.grey, size: 32),
                              ),
                            ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMethodPreviewWidget() {
    final steps = (widget.recipeData['steps'] as List?) ?? [];
    if (steps.isEmpty) return const SizedBox.shrink();
    return Text(
      steps.first.toString(),
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEquipmentPreviewWidget() {
    final equipment =
        (widget.recipeData['equipment_needed'] as List?)?.take(3).toList() ?? [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: equipment.map((e) {
        final name = e['item'] ?? e.toString();
        final imageKey = 'equipment_$name';
        Widget child;
        if (_specializedImages[imageKey] != null) {
          child = ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(
              _specializedImages[imageKey]!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          );
        } else {
          child = Container(
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: Icon(
              Icons.build,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child);
      }).toList(),
    );
  }

  Widget _buildVariationsPreviewWidget() {
    final variations =
        (widget.recipeData['suggested_variations'] as List?)?.take(3).toList() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variations.map((v) {
        final name = v['name'] ?? '';
        return Row(
          children: [
            Icon(
              Icons.arrow_right,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildIngredientIcons() {
    final ingredients = (widget.recipeData['ingredients'] as List?) ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ingredients.map((ingredient) {
          final name = ingredient['name'];
          final key = _ingredientIconKeys.putIfAbsent(name, () => GlobalKey());
          final active = _ingredientActive(name);
          return Container(
            key: key,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: active
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
                  width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(name,
                style: Theme.of(context).textTheme.labelSmall),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEquipmentIcons() {
    final equipment = (widget.recipeData['equipment_needed'] as List?) ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: equipment.map((e) {
          final name = e['item'] ?? e.toString();
          final key = _equipmentIconKeys.putIfAbsent(name, () => GlobalKey());
          final active = _equipmentActive(name);
          return Container(
            key: key,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.6),
                        blurRadius: 6,
                      )
                    ]
                  : [],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.build,
                size: 16,
                color: active
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Serving Size Controls
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Serving Size', style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        Text('oz', style: Theme.of(context).textTheme.bodySmall),
                        Switch(
                          value: _isMetric,
                          onChanged: (value) => setState(() => _isMetric = value),
                          activeColor: Theme.of(context).colorScheme.secondary,
                        ),
                        Text('ml', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _servingSize > 1 ? () => setState(() => _servingSize--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 32,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(
                        '$_servingSize',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _servingSize < 12 ? () => setState(() => _servingSize++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 32,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Visual Ingredients Grid
        if (widget.recipeData['ingredients'] is List)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: (widget.recipeData['ingredients'] as List).length,
            itemBuilder: (context, index) {
              final ingredient = widget.recipeData['ingredients'][index];
              final ingredientName = ingredient['name'];
              final imageKey = 'ingredient_$ingredientName';
              final hasImage = _specializedImages[imageKey] != null;
              final isGenerating = _imageGenerationProgress[imageKey] == true;
              
              return Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Ingredient Image or Placeholder
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: hasImage
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _specializedImages[imageKey]!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : isGenerating
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(strokeWidth: 2),
                                          SizedBox(height: 8),
                                          Text('Generating...', style: TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!, width: 1),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getIngredientIcon(ingredientName),
                                            size: 32,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ingredientName,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap "Generate Visuals"',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ingredient Details
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              ingredientName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _scaleIngredientAmount(ingredient['quantity'], _servingSize),
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Checkbox(
                              value: _ingredientChecklist[ingredientName] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  _ingredientChecklist[ingredientName] = value ?? false;
                                });
                                _saveProgress(); // Save progress when ingredient is checked/unchecked
                              },
                              activeColor: Theme.of(context).colorScheme.secondary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildMethodSection() {
    return Stack(
      children: [
        Column(
          children: [
            if (widget.recipeData['ingredients'] is List)
              _buildIngredientIcons(),
            if (widget.recipeData['ingredients'] is List)
              const SizedBox(height: 8),
            if (widget.recipeData['equipment_needed'] is List)
              _buildEquipmentIcons(),
            const SizedBox(height: 16),
        // Progress indicator with animated glass
        if (widget.recipeData['steps'] is List)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '${_stepCompletion.values.where((completed) => completed).length}/${widget.recipeData['steps'].length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Animated glass visualization
                      DrinkProgressGlass(
                        progress: _currentDrinkProgress,
                        liquidColors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Traditional progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _stepCompletion.values.where((completed) => completed).length / 
                                     widget.recipeData['steps'].length,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getProgressText(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Step Cards with MethodCard widgets in a grid
        if (widget.recipeData['steps'] is List)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 
                             MediaQuery.of(context).size.width > 800 ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2, // Slightly taller to accommodate content
            ),
            itemCount: widget.recipeData['steps'].length,
            itemBuilder: (context, i) {
              final key = _stepCardKeys.length > i ? _stepCardKeys[i] : GlobalKey();
              if (_stepCardKeys.length <= i) _stepCardKeys.add(key);
              final step = widget.recipeData['steps'][i];
              final stepImageKey = 'method_step_$i';
              final stepImageBytes = _specializedImages[stepImageKey];
              final isGeneratingStepImage = _imageGenerationProgress[stepImageKey] == true;
              
              return Container(
                key: key,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredStep = i),
                  onExit: (_) => setState(() => _hoveredStep = null),
                  child: MethodCard(
                      data: MethodCardData(
                        stepNumber: i + 1,
                        title: '',
                        description: step,
                        imageBytes: stepImageBytes,
                        isGenerating: isGeneratingStepImage,
                        imageAlt: 'Step ${i + 1} illustration',
                        isCompleted: _stepCompletion[i] ?? false,
                        duration: '30 sec',
                        difficulty: 'Easy',
                        proTip: _getProTipForStep(step),
                        tipCategory: _getTipCategoryForStep(step),
                      ),
                      state: _stepCompletion[i] == true
                          ? MethodCardState.completed
                          : _hoveredStep == i
                              ? MethodCardState.active
                              : MethodCardState.defaultState,
                      onCompleted: () => _toggleStepCompleted(i, true),
                      onPrevious: () => _toggleStepCompleted(i, false),
                      enableSwipeGestures: true,
                      enableKeyboardNavigation: true,
                      onCheckboxChanged: (value) =>
                          _toggleStepCompleted(i, value ?? false),
                    ),
                  ),
                );
            },
          ),
      ],
    ),
        if (_hoveredStep != null)
          ConnectionLine(
            from: _stepCardKeys[_hoveredStep!],
            to: [
              ...?_stepIngredientMap[_hoveredStep!]
                  ?.map((n) => _ingredientIconKeys[n])
                  .whereType<GlobalKey>(),
              ...?_stepEquipmentMap[_hoveredStep!]
                  ?.map((n) => _equipmentIconKeys[n])
                  .whereType<GlobalKey>(),
            ],
            active: true,
          ),
      ],
    );
  }
  
  Widget _buildEquipmentSection() {
    if (widget.recipeData['equipment_needed'] is! List || 
        (widget.recipeData['equipment_needed'] as List).isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No specific equipment required'),
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: (widget.recipeData['equipment_needed'] as List).length,
      itemBuilder: (context, index) {
        final equipment = widget.recipeData['equipment_needed'][index];
        final equipmentName = equipment['item'] ?? equipment;
        final imageKey = 'equipment_$equipmentName';
        final hasImage = _specializedImages[imageKey] != null;
        final isGenerating = _imageGenerationProgress[imageKey] == true;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Equipment Image or Placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _specializedImages[imageKey]!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : isGenerating
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 2),
                                    SizedBox(height: 8),
                                    Text('Generating...', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.build, 
                                         color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    Text('Use Generate Visuals', 
                                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                         textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 8),
                // Equipment Details
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        equipmentName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (equipment is Map && equipment['essential'] == true)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Essential',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildVariationsSection() {
    return Column(
      children: [
        // Related Cocktails
        if (widget.recipeData['related_cocktails'] is List && 
            (widget.recipeData['related_cocktails'] as List).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Related Cocktails', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.recipeData['related_cocktails'].length,
                  itemBuilder: (context, index) {
                    final cocktail = widget.recipeData['related_cocktails'][index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: _isLoadingRelatedCocktail 
                              ? null 
                              : () => _loadRelatedCocktail(cocktail),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoadingRelatedCocktail
                                    ? const SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(strokeWidth: 3),
                                      )
                                    : Icon(
                                        Icons.local_bar,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                const SizedBox(height: 8),
                                Text(
                                  cocktail,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _isLoadingRelatedCocktail 
                                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                                        : null,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (!_isLoadingRelatedCocktail)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Tap to try',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        // Suggested Variations
        if (widget.recipeData['suggested_variations'] is List && 
            (widget.recipeData['suggested_variations'] as List).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Variations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (var variation in widget.recipeData['suggested_variations'])
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variation['name'] ?? 'Variation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          variation['description'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (variation['changes'] is List)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              children: (variation['changes'] as List)
                                  .map((change) => Chip(
                                        label: Text(change),
                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        // Food Pairings
        if (widget.recipeData['food_pairings'] is List && 
            (widget.recipeData['food_pairings'] as List).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Food Pairings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (widget.recipeData['food_pairings'] as List)
                    .map((pairing) => Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.restaurant, 
                                     size: 16, 
                                     color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(pairing),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _getCurrentSectionContent() {
    switch (_selectedSection) {
      case 'ingredients':
        return _buildIngredientsSection();
      case 'method':
        return _buildMethodSection();
      case 'equipment':
        return _buildEquipmentSection();
      case 'variations':
        return _buildVariationsSection();
      case 'overview':
      default:
        return _buildOverviewSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData['drink_name'] ?? 'Recipe'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // Visual Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: _buildNavigationBar(),
          ),
          // Section Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _getCurrentSectionContent(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_constants.dart';

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
        gradient: isCurrentlyDark ? AppConstants.darkBackgroundGradient : AppConstants.lightBackgroundGradient,
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
}
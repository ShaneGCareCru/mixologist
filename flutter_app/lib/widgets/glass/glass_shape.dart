import 'package:flutter/material.dart';

/// Base abstract class for all glass shapes in the adaptive glass visualization.
/// Each glass type defines its outline and liquid fill paths.
abstract class GlassShape {
  /// Returns the outline path for the glass at the given size
  Path getOutlinePath(Size size);
  
  /// Returns the liquid fill path for the glass at given size and fill level
  /// [fillLevel] ranges from 0.0 (empty) to 1.0 (full)
  Path getLiquidPath(Size size, double fillLevel);
  
  /// Returns the rim area path for rim decorations (salt, sugar, etc.)
  Path getRimPath(Size size, double rimThickness);
  
  /// Returns the offset position for garnish placement
  Offset getGarnishPosition(Size size);
  
  /// Returns the glass's relative width at a given height ratio
  /// [heightRatio] ranges from 0.0 (bottom) to 1.0 (top)
  double getWidthAtHeight(double heightRatio);
}

/// Margarita glass with wide rim and tapered bowl
class MargaritaGlass extends GlassShape {
  @override
  Path getOutlinePath(Size size) {
    final path = Path();
    final center = size.width / 2;
    final rimWidth = size.width * 0.9;
    final bowlWidth = size.width * 0.3;
    
    // Start at top left of rim
    path.moveTo(center - rimWidth / 2, size.height * 0.1);
    
    // Top rim (wide)
    path.lineTo(center + rimWidth / 2, size.height * 0.1);
    
    // DISABLED: Simple straight line to prevent curve errors
    path.lineTo(center + bowlWidth / 2, size.height * 0.7);
    
    // Bottom of bowl (rounded)
    path.arcToPoint(
      Offset(center - bowlWidth / 2, size.height * 0.7),
      radius: Radius.circular(bowlWidth / 2),
      clockwise: false,
    );
    
    // DISABLED: Simple straight line to prevent curve errors
    path.lineTo(center - rimWidth / 2, size.height * 0.1);
    
    path.close();
    return path;
  }

  @override
  Path getLiquidPath(Size size, double fillLevel) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.3;
    
    if (fillLevel <= 0) return path;
    
    final fillHeight = size.height * 0.6 * fillLevel; // Bowl height is 60% of total
    final bottomY = size.height * 0.7;
    final topY = bottomY - fillHeight;
    
    // Get liquid width at this fill level
    final liquidWidth = bowlWidth * getWidthAtHeight(1.0 - fillLevel);
    
    path.moveTo(center - liquidWidth / 2, bottomY);
    
    // DISABLED: Simple flat liquid surface to prevent curve endpoint errors
    path.lineTo(center + liquidWidth / 2, topY);
    path.lineTo(center - liquidWidth / 2, topY);
    
    // Bottom arc
    path.arcToPoint(
      Offset(center + liquidWidth / 2, bottomY),
      radius: Radius.circular(liquidWidth / 2),
      clockwise: false,
    );
    
    path.close();
    return path;
  }

  @override
  Path getRimPath(Size size, double rimThickness) {
    final path = Path();
    final center = size.width / 2;
    final outerWidth = size.width * 0.9;
    final innerWidth = outerWidth - (rimThickness * 2);
    final rimY = size.height * 0.1;
    
    // Outer rim
    path.moveTo(center - outerWidth / 2, rimY);
    path.lineTo(center + outerWidth / 2, rimY);
    path.lineTo(center + outerWidth / 2, rimY + rimThickness);
    path.lineTo(center - outerWidth / 2, rimY + rimThickness);
    path.close();
    
    return path;
  }

  @override
  Offset getGarnishPosition(Size size) {
    return Offset(size.width * 0.8, size.height * 0.1);
  }

  @override
  double getWidthAtHeight(double heightRatio) {
    // Tapered from narrow bottom to wide rim
    return 0.3 + (0.6 * heightRatio);
  }
}

/// Highball glass with straight sides
class HighballGlass extends GlassShape {
  @override
  Path getOutlinePath(Size size) {
    final path = Path();
    final center = size.width / 2;
    final glassWidth = size.width * 0.6;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - glassWidth / 2, 
        size.height * 0.1,
        glassWidth,
        size.height * 0.8,
      ),
      const Radius.circular(8),
    ));
    
    return path;
  }

  @override
  Path getLiquidPath(Size size, double fillLevel) {
    final path = Path();
    final center = size.width / 2;
    final glassWidth = size.width * 0.55; // Slightly smaller than outline
    
    if (fillLevel <= 0) return path;
    
    final fillHeight = size.height * 0.75 * fillLevel;
    final bottomY = size.height * 0.85;
    final topY = bottomY - fillHeight;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - glassWidth / 2,
        topY,
        glassWidth,
        fillHeight,
      ),
      const Radius.circular(6),
    ));
    
    return path;
  }

  @override
  Path getRimPath(Size size, double rimThickness) {
    final path = Path();
    final center = size.width / 2;
    final glassWidth = size.width * 0.6;
    final rimY = size.height * 0.1;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - glassWidth / 2,
        rimY,
        glassWidth,
        rimThickness,
      ),
      const Radius.circular(8),
    ));
    
    return path;
  }

  @override
  Offset getGarnishPosition(Size size) {
    return Offset(size.width * 0.75, size.height * 0.1);
  }

  @override
  double getWidthAtHeight(double heightRatio) {
    return 0.6; // Constant width
  }
}

/// Wine glass with stemmed bowl
class WineGlass extends GlassShape {
  @override
  Path getOutlinePath(Size size) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.8;
    final stemWidth = size.width * 0.08;
    final baseWidth = size.width * 0.4;
    
    // Bowl (top 60% of glass)
    final bowlHeight = size.height * 0.6;
    path.addOval(Rect.fromCenter(
      center: Offset(center, size.height * 0.35),
      width: bowlWidth,
      height: bowlHeight,
    ));
    
    // Stem
    path.addRect(Rect.fromLTWH(
      center - stemWidth / 2,
      size.height * 0.65,
      stemWidth,
      size.height * 0.2,
    ));
    
    // Base
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - baseWidth / 2,
        size.height * 0.85,
        baseWidth,
        size.height * 0.1,
      ),
      const Radius.circular(4),
    ));
    
    return path;
  }

  @override
  Path getLiquidPath(Size size, double fillLevel) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.75;
    
    if (fillLevel <= 0) return path;
    
    final fillHeight = size.height * 0.55 * fillLevel;
    final bowlBottom = size.height * 0.62;
    final liquidTop = bowlBottom - fillHeight;
    
    // Create elliptical liquid fill
    path.addOval(Rect.fromLTWH(
      center - bowlWidth / 2,
      liquidTop,
      bowlWidth,
      fillHeight,
    ));
    
    return path;
  }

  @override
  Path getRimPath(Size size, double rimThickness) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.8;
    final rimY = size.height * 0.05;
    
    path.addOval(Rect.fromLTWH(
      center - bowlWidth / 2,
      rimY,
      bowlWidth,
      rimThickness * 2,
    ));
    
    return path;
  }

  @override
  Offset getGarnishPosition(Size size) {
    return Offset(size.width * 0.85, size.height * 0.05);
  }

  @override
  double getWidthAtHeight(double heightRatio) {
    // Elliptical bowl shape
    return 0.8 * (1.0 - (heightRatio * heightRatio * 0.3));
  }
}

/// Rocks/Old Fashioned glass - short and wide
class RocksGlass extends GlassShape {
  @override
  Path getOutlinePath(Size size) {
    final path = Path();
    final center = size.width / 2;
    final glassWidth = size.width * 0.8;
    final glassHeight = size.height * 0.6;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - glassWidth / 2,
        size.height * 0.3,
        glassWidth,
        glassHeight,
      ),
      const Radius.circular(12),
    ));
    
    return path;
  }

  @override
  Path getLiquidPath(Size size, double fillLevel) {
    final path = Path();
    final center = size.width / 2;
    final glassWidth = size.width * 0.75;
    
    if (fillLevel <= 0) return path;
    
    final fillHeight = size.height * 0.55 * fillLevel;
    final bottomY = size.height * 0.85;
    final topY = bottomY - fillHeight;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - glassWidth / 2,
        topY,
        glassWidth,
        fillHeight,
      ),
      const Radius.circular(10),
    ));
    
    return path;
  }

  @override
  Path getRimPath(Size size, double rimThickness) {
    final path = Path();
    final center = size.width / 2;
    final glassWidth = size.width * 0.8;
    final rimY = size.height * 0.3;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - glassWidth / 2,
        rimY,
        glassWidth,
        rimThickness,
      ),
      const Radius.circular(12),
    ));
    
    return path;
  }

  @override
  Offset getGarnishPosition(Size size) {
    return Offset(size.width * 0.75, size.height * 0.3);
  }

  @override
  double getWidthAtHeight(double heightRatio) {
    return 0.8; // Constant width
  }
}

/// Coupe glass - wide shallow bowl
class CoupeGlass extends GlassShape {
  @override
  Path getOutlinePath(Size size) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.85;
    final stemWidth = size.width * 0.08;
    final baseWidth = size.width * 0.4;
    
    // Bowl (shallow and wide)
    path.addOval(Rect.fromCenter(
      center: Offset(center, size.height * 0.25),
      width: bowlWidth,
      height: size.height * 0.4,
    ));
    
    // Stem
    path.addRect(Rect.fromLTWH(
      center - stemWidth / 2,
      size.height * 0.45,
      stemWidth,
      size.height * 0.35,
    ));
    
    // Base
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center - baseWidth / 2,
        size.height * 0.8,
        baseWidth,
        size.height * 0.15,
      ),
      const Radius.circular(4),
    ));
    
    return path;
  }

  @override
  Path getLiquidPath(Size size, double fillLevel) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.8;
    
    if (fillLevel <= 0) return path;
    
    final fillHeight = size.height * 0.35 * fillLevel;
    final bowlBottom = size.height * 0.43;
    final liquidTop = bowlBottom - fillHeight;
    
    path.addOval(Rect.fromLTWH(
      center - bowlWidth / 2,
      liquidTop,
      bowlWidth,
      fillHeight,
    ));
    
    return path;
  }

  @override
  Path getRimPath(Size size, double rimThickness) {
    final path = Path();
    final center = size.width / 2;
    final bowlWidth = size.width * 0.85;
    final rimY = size.height * 0.05;
    
    path.addOval(Rect.fromLTWH(
      center - bowlWidth / 2,
      rimY,
      bowlWidth,
      rimThickness * 2,
    ));
    
    return path;
  }

  @override
  Offset getGarnishPosition(Size size) {
    return Offset(size.width * 0.85, size.height * 0.05);
  }

  @override
  double getWidthAtHeight(double heightRatio) {
    // Wide shallow bowl
    return 0.85 * (1.0 - (heightRatio * 0.2));
  }
}
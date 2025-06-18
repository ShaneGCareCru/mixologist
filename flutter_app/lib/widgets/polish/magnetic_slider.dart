import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// Magnetic slider that snaps to predefined measurement points
/// Perfect for cocktail ingredient measurements with haptic feedback
class MagneticSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final List<double> snapPoints;
  final double magneticRadius; // Pixel radius for magnetic attraction
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final ValueChanged<double>? onSnapPoint;
  final String? label;
  final String Function(double)? labelFormatter;
  final Color activeColor;
  final Color inactiveColor;
  final Color snapPointColor;
  final bool enableHaptics;
  final bool showTooltip;
  final bool showSnapPoints;
  final double thumbRadius;
  final double trackHeight;
  final List<String>? snapPointLabels;
  final AnimationDuration snapDuration;
  
  const MagneticSlider({
    super.key,
    required this.value,
    required this.snapPoints,
    this.min = 0.0,
    this.max = 1.0,
    this.magneticRadius = 20.0,
    this.onChanged,
    this.onChangeEnd,
    this.onSnapPoint,
    this.label,
    this.labelFormatter,
    this.activeColor = const Color(0xFFB8860B),
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.snapPointColor = const Color(0xFF87A96B),
    this.enableHaptics = true,
    this.showTooltip = true,
    this.showSnapPoints = true,
    this.thumbRadius = 12.0,
    this.trackHeight = 4.0,
    this.snapPointLabels,
    this.snapDuration = const Duration(milliseconds: 200),
  });

  @override
  State<MagneticSlider> createState() => _MagneticSliderState();
}

typedef AnimationDuration = Duration;

class _MagneticSliderState extends State<MagneticSlider>
    with TickerProviderStateMixin {
  late AnimationController _snapController;
  late AnimationController _thumbController;
  late AnimationController _tooltipController;
  
  late Animation<double> _snapAnimation;
  late Animation<double> _thumbScaleAnimation;
  late Animation<double> _tooltipOpacityAnimation;
  
  double _currentValue = 0.0;
  double _dragStartValue = 0.0;
  bool _isDragging = false;
  bool _isSnapping = false;
  String? _tooltipText;
  Offset? _thumbPosition;
  
  @override
  void initState() {
    super.initState();
    
    _currentValue = widget.value;
    
    _snapController = AnimationController(
      duration: widget.snapDuration,
      vsync: this,
    );
    
    _thumbController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _tooltipController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _snapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.elasticOut,
    ));
    
    _thumbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _thumbController,
      curve: Curves.easeOut,
    ));
    
    _tooltipOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tooltipController,
      curve: Curves.easeOut,
    ));
    
    _snapAnimation.addListener(() {
      if (_isSnapping) {
        setState(() {
          _currentValue = _dragStartValue + 
                         (_getTargetSnapValue() - _dragStartValue) * _snapAnimation.value;
        });
      }
    });
    
    _snapAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isSnapping) {
        _isSnapping = false;
        final snapValue = _getTargetSnapValue();
        widget.onSnapPoint?.call(snapValue);
        
        if (widget.enableHaptics) {
          HapticFeedback.mediumImpact();
        }
      }
    });
  }
  
  @override
  void didUpdateWidget(MagneticSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value && !_isDragging) {
      setState(() {
        _currentValue = widget.value;
      });
    }
  }
  
  @override
  void dispose() {
    _snapController.dispose();
    _thumbController.dispose();
    _tooltipController.dispose();
    super.dispose();
  }
  
  double _getTargetSnapValue() {
    if (widget.snapPoints.isEmpty) return _currentValue;
    
    // Find the closest snap point
    double closestDistance = double.infinity;
    double closestSnapPoint = widget.snapPoints.first;
    
    for (final snapPoint in widget.snapPoints) {
      final distance = (_currentValue - snapPoint).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestSnapPoint = snapPoint;
      }
    }
    
    return closestSnapPoint;
  }
  
  bool _isWithinMagneticRadius(double value, double snapPoint, double sliderWidth) {
    final valuePosition = (value - widget.min) / (widget.max - widget.min) * sliderWidth;
    final snapPosition = (snapPoint - widget.min) / (widget.max - widget.min) * sliderWidth;
    
    return (valuePosition - snapPosition).abs() <= widget.magneticRadius;
  }
  
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartValue = _currentValue;
    _thumbController.forward();
    
    if (widget.showTooltip) {
      _updateTooltip();
      _tooltipController.forward();
    }
    
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }
  
  void _onPanUpdate(DragUpdateDetails details, double sliderWidth) {
    if (!_isDragging) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate new value based on position
    final relativePosition = (localPosition.dx / sliderWidth).clamp(0.0, 1.0);
    double newValue = widget.min + (widget.max - widget.min) * relativePosition;
    
    // Check for magnetic attraction
    bool snappedToPoint = false;
    for (final snapPoint in widget.snapPoints) {
      if (_isWithinMagneticRadius(newValue, snapPoint, sliderWidth)) {
        newValue = snapPoint;
        snappedToPoint = true;
        
        if (widget.enableHaptics && (_currentValue - snapPoint).abs() > 0.01) {
          HapticFeedback.lightImpact();
        }
        break;
      }
    }
    
    setState(() {
      _currentValue = newValue.clamp(widget.min, widget.max);
    });
    
    widget.onChanged?.call(_currentValue);
    
    if (widget.showTooltip) {
      _updateTooltip();
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _thumbController.reverse();
    _tooltipController.reverse();
    
    // Check if we should snap to a point
    final targetSnap = _getTargetSnapValue();
    if ((_currentValue - targetSnap).abs() > 0.01) {
      _isSnapping = true;
      _dragStartValue = _currentValue;
      _snapController.forward(from: 0.0);
    }
    
    widget.onChangeEnd?.call(_currentValue);
  }
  
  void _updateTooltip() {
    if (widget.labelFormatter != null) {
      _tooltipText = widget.labelFormatter!(_currentValue);
    } else {
      _tooltipText = _currentValue.toStringAsFixed(2);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = constraints.maxWidth - widget.thumbRadius * 2;
        
        return Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: widget.thumbRadius),
          child: Stack(
            children: [
              // Slider track and snap points
              Positioned(
                top: 30 - widget.trackHeight / 2,
                left: widget.thumbRadius,
                right: widget.thumbRadius,
                child: _buildTrack(sliderWidth),
              ),
              
              // Thumb
              AnimatedBuilder(
                animation: Listenable.merge([
                  _thumbScaleAnimation,
                  _snapAnimation,
                ]),
                builder: (context, child) {
                  final thumbPosition = _currentValue.isNaN 
                      ? 0.0 
                      : ((_currentValue - widget.min) / (widget.max - widget.min)) * sliderWidth;
                  
                  return Positioned(
                    top: 30 - widget.thumbRadius,
                    left: thumbPosition,
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: (details) => _onPanUpdate(details, sliderWidth),
                      onPanEnd: _onPanEnd,
                      child: Transform.scale(
                        scale: _thumbScaleAnimation.value,
                        child: _buildThumb(),
                      ),
                    ),
                  );
                },
              ),
              
              // Tooltip
              if (widget.showTooltip && _tooltipText != null)
                AnimatedBuilder(
                  animation: _tooltipOpacityAnimation,
                  builder: (context, child) {
                    final thumbPosition = ((_currentValue - widget.min) / (widget.max - widget.min)) * sliderWidth;
                    
                    return Positioned(
                      top: 5,
                      left: thumbPosition - 20 + widget.thumbRadius,
                      child: Opacity(
                        opacity: _tooltipOpacityAnimation.value,
                        child: _buildTooltip(),
                      ),
                    );
                  },
                ),
              
              // Snap point labels
              if (widget.showSnapPoints && widget.snapPointLabels != null)
                ..._buildSnapPointLabels(sliderWidth),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTrack(double sliderWidth) {
    return Stack(
      children: [
        // Inactive track
        Container(
          height: widget.trackHeight,
          decoration: BoxDecoration(
            color: widget.inactiveColor,
            borderRadius: BorderRadius.circular(widget.trackHeight / 2),
          ),
        ),
        
        // Active track
        Container(
          height: widget.trackHeight,
          width: sliderWidth * ((_currentValue - widget.min) / (widget.max - widget.min)),
          decoration: BoxDecoration(
            color: widget.activeColor,
            borderRadius: BorderRadius.circular(widget.trackHeight / 2),
          ),
        ),
        
        // Snap points
        if (widget.showSnapPoints)
          ...widget.snapPoints.map((snapPoint) {
            final position = ((snapPoint - widget.min) / (widget.max - widget.min)) * sliderWidth;
            return Positioned(
              left: position - 3,
              top: -2,
              child: Container(
                width: 6,
                height: widget.trackHeight + 4,
                decoration: BoxDecoration(
                  color: widget.snapPointColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
  
  Widget _buildThumb() {
    return Container(
      width: widget.thumbRadius * 2,
      height: widget.thumbRadius * 2,
      decoration: BoxDecoration(
        color: widget.activeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTooltip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _tooltipText!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  List<Widget> _buildSnapPointLabels(double sliderWidth) {
    final labels = <Widget>[];
    
    for (int i = 0; i < widget.snapPoints.length && i < widget.snapPointLabels!.length; i++) {
      final snapPoint = widget.snapPoints[i];
      final label = widget.snapPointLabels![i];
      final position = ((snapPoint - widget.min) / (widget.max - widget.min)) * sliderWidth;
      
      labels.add(
        Positioned(
          bottom: 5,
          left: position - 15 + widget.thumbRadius,
          child: SizedBox(
            width: 30,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.snapPointColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    
    return labels;
  }
}

/// Specialized magnetic slider for cocktail measurements
class CocktailMeasurementSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final MeasurementUnit unit;
  final bool showImperialConversion;
  
  const CocktailMeasurementSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.unit = MeasurementUnit.oz,
    this.showImperialConversion = true,
  });
  
  List<double> _getSnapPoints() {
    switch (unit) {
      case MeasurementUnit.oz:
        return [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0];
      case MeasurementUnit.ml:
        return [7.5, 15, 22.5, 30, 37.5, 45, 60, 75, 90];
      case MeasurementUnit.tsp:
        return [0.25, 0.5, 1.0, 1.5, 2.0];
      case MeasurementUnit.tbsp:
        return [0.25, 0.5, 1.0, 1.5, 2.0];
      case MeasurementUnit.dash:
        return [1, 2, 3, 4, 5];
      case MeasurementUnit.splash:
        return [1, 2, 3];
    }
  }
  
  List<String> _getSnapPointLabels() {
    switch (unit) {
      case MeasurementUnit.oz:
        return ['1/4', '1/2', '3/4', '1', '1¼', '1½', '2', '2½', '3'];
      case MeasurementUnit.ml:
        return ['7.5', '15', '22.5', '30', '37.5', '45', '60', '75', '90'];
      case MeasurementUnit.tsp:
        return ['1/4', '1/2', '1', '1½', '2'];
      case MeasurementUnit.tbsp:
        return ['1/4', '1/2', '1', '1½', '2'];
      case MeasurementUnit.dash:
        return ['1', '2', '3', '4', '5'];
      case MeasurementUnit.splash:
        return ['1', '2', '3'];
    }
  }
  
  double _getMaxValue() {
    switch (unit) {
      case MeasurementUnit.oz:
        return 3.0;
      case MeasurementUnit.ml:
        return 90;
      case MeasurementUnit.tsp:
      case MeasurementUnit.tbsp:
        return 2.0;
      case MeasurementUnit.dash:
        return 5;
      case MeasurementUnit.splash:
        return 3;
    }
  }
  
  String _formatValue(double value) {
    switch (unit) {
      case MeasurementUnit.oz:
        if (value == 0.25) return '1/4 oz';
        if (value == 0.5) return '1/2 oz';
        if (value == 0.75) return '3/4 oz';
        if (value == 1.25) return '1¼ oz';
        if (value == 1.5) return '1½ oz';
        if (value == 2.5) return '2½ oz';
        return '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} oz';
      case MeasurementUnit.ml:
        return '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} ml';
      case MeasurementUnit.tsp:
        if (value == 0.25) return '1/4 tsp';
        if (value == 0.5) return '1/2 tsp';
        if (value == 1.5) return '1½ tsp';
        return '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} tsp';
      case MeasurementUnit.tbsp:
        if (value == 0.25) return '1/4 tbsp';
        if (value == 0.5) return '1/2 tbsp';
        if (value == 1.5) return '1½ tbsp';
        return '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} tbsp';
      case MeasurementUnit.dash:
        return '${value.round()} dash${value.round() != 1 ? 'es' : ''}';
      case MeasurementUnit.splash:
        return '${value.round()} splash${value.round() != 1 ? 'es' : ''}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        MagneticSlider(
          value: value,
          min: 0.0,
          max: _getMaxValue(),
          snapPoints: _getSnapPoints(),
          snapPointLabels: _getSnapPointLabels(),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          labelFormatter: _formatValue,
          magneticRadius: 25.0,
        ),
        if (showImperialConversion && unit == MeasurementUnit.ml) ...[
          const SizedBox(height: 4),
          Text(
            'Approximately ${(value / 29.5735).toStringAsFixed(2)} oz',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

/// Measurement units for cocktails
enum MeasurementUnit {
  oz,
  ml,
  tsp,
  tbsp,
  dash,
  splash,
}

/// Preset magnetic sliders for common cocktail measurements
class CocktailPresets {
  /// Standard spirit measurement (0.5 - 2.5 oz)
  static MagneticSlider spirit({
    required double value,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return MagneticSlider(
      value: value,
      min: 0.5,
      max: 2.5,
      snapPoints: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5],
      snapPointLabels: const ['1/2', '3/4', '1', '1¼', '1½', '2', '2½'],
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      labelFormatter: (value) => '${value.toStringAsFixed(2)} oz',
    );
  }
  
  /// Citrus measurement (0.25 - 1.0 oz)
  static MagneticSlider citrus({
    required double value,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return MagneticSlider(
      value: value,
      min: 0.25,
      max: 1.0,
      snapPoints: const [0.25, 0.5, 0.75, 1.0],
      snapPointLabels: const ['1/4', '1/2', '3/4', '1'],
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      labelFormatter: (value) => '${value.toStringAsFixed(2)} oz',
      activeColor: const Color(0xFFFFEB3B),
    );
  }
  
  /// Syrup measurement (0.25 - 1.0 oz)
  static MagneticSlider syrup({
    required double value,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return MagneticSlider(
      value: value,
      min: 0.25,
      max: 1.0,
      snapPoints: const [0.25, 0.5, 0.75, 1.0],
      snapPointLabels: const ['1/4', '1/2', '3/4', '1'],
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      labelFormatter: (value) => '${value.toStringAsFixed(2)} oz',
      activeColor: const Color(0xFFFF9800),
    );
  }
  
  /// Bitters measurement (1-5 dashes)
  static MagneticSlider bitters({
    required double value,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return MagneticSlider(
      value: value,
      min: 1,
      max: 5,
      snapPoints: const [1, 2, 3, 4, 5],
      snapPointLabels: const ['1', '2', '3', '4', '5'],
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      labelFormatter: (value) => '${value.round()} dash${value.round() != 1 ? 'es' : ''}',
      activeColor: const Color(0xFF8B4513),
    );
  }
}
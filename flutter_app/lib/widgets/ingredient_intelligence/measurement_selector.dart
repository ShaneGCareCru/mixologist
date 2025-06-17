import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../models/ingredient.dart';
import '../../theme/app_colors.dart';

/// Swipeable unit selector with measurement conversion
class MeasurementSelector extends StatefulWidget {
  final double amount;
  final Unit currentUnit;
  final Function(double, Unit) onChanged;
  final bool showCommonMeasures;
  final List<Unit> availableUnits;

  const MeasurementSelector({
    super.key,
    required this.amount,
    required this.currentUnit,
    required this.onChanged,
    this.showCommonMeasures = true,
    this.availableUnits = const [
      Unit.oz,
      Unit.ml,
      Unit.cl,
      Unit.shots,
      Unit.tsp,
      Unit.tbsp,
      Unit.dash,
      Unit.splash,
    ],
  });

  @override
  State<MeasurementSelector> createState() => _MeasurementSelectorState();
}

class _MeasurementSelectorState extends State<MeasurementSelector>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.availableUnits.indexOf(widget.currentUnit);
    if (_currentIndex == -1) _currentIndex = 0;
    
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.3,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onUnitChanged(int index) {
    if (index != _currentIndex) {
      final newUnit = widget.availableUnits[index];
      final ozAmount = widget.currentUnit.toOz(widget.amount);
      final newAmount = newUnit.fromOz(ozAmount);
      
      setState(() {
        _currentIndex = index;
      });
      
      widget.onChanged(newAmount, newUnit);
      _triggerHapticFeedback();
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }

  void _triggerHapticFeedback() {
    if (Vibration.hasVibrator() != null) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.smokyGlass.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.smokyGlass.withOpacity(0.2),
                  AppColors.charcoalSurface.withOpacity(0.4),
                ],
              ),
            ),
          ),
          
          Column(
            children: [
              // Header
              _buildHeader(),
              
              // Unit selector
              Expanded(
                child: _buildUnitSelector(),
              ),
              
              // Common measures
              if (widget.showCommonMeasures)
                _buildCommonMeasures(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.slider_horizontal_3,
            size: 16,
            color: AppColors.champagneGold.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          const Text(
            'MEASUREMENT',
            style: TextStyle(
              color: AppColors.champagneGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _buildAmountDisplay(),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.deepBitters.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warmCopper.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatAmount(widget.amount),
                  style: const TextStyle(
                    color: AppColors.citrusGlow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.currentUnit.displayName,
                  style: TextStyle(
                    color: AppColors.champagneGold.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitSelector() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onUnitChanged,
      itemCount: widget.availableUnits.length,
      itemBuilder: (context, index) {
        final unit = widget.availableUnits[index];
        final isSelected = index == _currentIndex;
        final convertedAmount = _convertToUnit(widget.amount, widget.currentUnit, unit);
        
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.warmCopper.withOpacity(0.3)
                  : AppColors.charcoalSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.warmCopper.withOpacity(0.8)
                    : AppColors.champagneGold.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.warmCopper.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  unit.displayName.toUpperCase(),
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.champagneGold
                        : AppColors.champagneGold.withOpacity(0.6),
                    fontSize: isSelected ? 16 : 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(convertedAmount),
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.citrusGlow
                        : AppColors.citrusGlow.withOpacity(0.6),
                    fontSize: isSelected ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommonMeasures() {
    final commonMeasures = _getCommonMeasures();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.champagneGold.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMMON BARTENDER MEASURES',
            style: TextStyle(
              color: AppColors.champagneGold.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: commonMeasures.map((measure) => _buildMeasureChip(measure)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureChip(CommonMeasure measure) {
    return GestureDetector(
      onTap: () => _applyCommonMeasure(measure),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.charcoalSurface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.champagneGold.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              measure.name,
              style: TextStyle(
                color: AppColors.champagneGold.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${_formatAmount(measure.amount)} ${measure.unit.displayName}',
              style: TextStyle(
                color: AppColors.citrusGlow.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _convertToUnit(double amount, Unit fromUnit, Unit toUnit) {
    final ozAmount = fromUnit.toOz(amount);
    return toUnit.fromOz(ozAmount);
  }

  void _applyCommonMeasure(CommonMeasure measure) {
    widget.onChanged(measure.amount, measure.unit);
    _triggerHapticFeedback();
    
    // Update the page controller to show the selected unit
    final unitIndex = widget.availableUnits.indexOf(measure.unit);
    if (unitIndex != -1) {
      _pageController.animateToPage(
        unitIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<CommonMeasure> _getCommonMeasures() {
    return [
      CommonMeasure('Jigger', 1.5, Unit.oz),
      CommonMeasure('Shot', 1.0, Unit.oz),
      CommonMeasure('Pony', 1.0, Unit.oz),
      CommonMeasure('Splash', 0.125, Unit.oz),
      CommonMeasure('Dash', 0.03125, Unit.oz),
      CommonMeasure('Rinse', 0.25, Unit.oz),
      CommonMeasure('Float', 0.5, Unit.oz),
    ];
  }

  String _formatAmount(double amount) {
    if (amount < 0.1) {
      return amount.toStringAsFixed(3);
    } else if (amount < 1) {
      return amount.toStringAsFixed(2);
    } else if (amount == amount.toInt()) {
      return amount.toInt().toString();
    } else {
      return amount.toStringAsFixed(1);
    }
  }
}

/// Common bartender measurement
class CommonMeasure {
  final String name;
  final double amount;
  final Unit unit;

  const CommonMeasure(this.name, this.amount, this.unit);
}
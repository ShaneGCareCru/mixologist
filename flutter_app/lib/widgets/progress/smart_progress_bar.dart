import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// Data model for recipe steps with timing and metadata
class RecipeStep {
  final int stepNumber;
  final String title;
  final String description;
  final Duration estimatedTime;
  final RecipeStepType type;
  final String? technique;
  final bool isCompleted;
  final bool isActive;
  final String? tip;
  
  const RecipeStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.estimatedTime,
    this.type = RecipeStepType.preparation,
    this.technique,
    this.isCompleted = false,
    this.isActive = false,
    this.tip,
  });
  
  RecipeStep copyWith({
    int? stepNumber,
    String? title,
    String? description,
    Duration? estimatedTime,
    RecipeStepType? type,
    String? technique,
    bool? isCompleted,
    bool? isActive,
    String? tip,
  }) {
    return RecipeStep(
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      type: type ?? this.type,
      technique: technique ?? this.technique,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      tip: tip ?? this.tip,
    );
  }
}

/// Types of recipe steps for visual differentiation
enum RecipeStepType {
  preparation,
  mixing,
  shaking,
  stirring,
  straining,
  garnishing,
  serving,
}

/// Smart progress bar with segmented indicators, timing, and contextual tips
class SmartProgressBar extends StatefulWidget {
  final List<RecipeStep> steps;
  final int currentStep;
  final bool showTips;
  final bool showTiming;
  final bool enableInteraction;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onComplete;
  final EdgeInsets padding;
  final double height;
  
  const SmartProgressBar({
    super.key,
    required this.steps,
    required this.currentStep,
    this.showTips = true,
    this.showTiming = true,
    this.enableInteraction = true,
    this.onStepTapped,
    this.onComplete,
    this.padding = const EdgeInsets.all(16),
    this.height = 120,
  });

  @override
  State<SmartProgressBar> createState() => _SmartProgressBarState();
}

class _SmartProgressBarState extends State<SmartProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // DISABLED: Static animations to prevent curve endpoint errors
    _progressAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_progressController);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // No pulsing
    ).animate(_pulseController);
    
    _updateProgress();
    _startPulseAnimation();
  }
  
  @override
  void didUpdateWidget(SmartProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _updateProgress();
    }
  }
  
  void _updateProgress() {
    // DISABLED: No progress animation to prevent curve errors
    if (widget.steps.isEmpty) return;
    
    // Set progress immediately without animation
    _progressController.value = 1.0;
    
    // Check if recipe is complete
    if (widget.currentStep >= widget.steps.length) {
      widget.onComplete?.call();
    }
  }
  
  void _startPulseAnimation() {
    // DISABLED: No pulse animation
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header with timing
          _buildProgressHeader(),
          
          const SizedBox(height: 12),
          
          // Main progress bar
          _buildProgressBar(),
          
          const SizedBox(height: 8),
          
          // Step labels
          _buildStepLabels(),
          
          if (widget.showTips) ...[
            const SizedBox(height: 12),
            _buildContextualTip(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildProgressHeader() {
    final currentStepData = _getCurrentStepData();
    final totalTime = _calculateTotalTime();
    final elapsedTime = _calculateElapsedTime();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Current step info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentStepData?.title ?? 'Recipe Complete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB8860B), // Amber
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (currentStepData != null)
                Text(
                  _getStepTypeLabel(currentStepData.type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        
        // Timing info
        if (widget.showTiming)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.currentStep}/${widget.steps.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF87A96B), // Sage
                ),
              ),
              Text(
                '${_formatDuration(elapsedTime)} / ${_formatDuration(totalTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _pulseController]),
      builder: (context, child) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              // Background segments
              ...widget.steps.asMap().entries.map(
                (entry) => _buildSegmentBackground(entry.key, entry.value),
              ),
              
              // Filled progress
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB8860B), // Amber
                        const Color(0xFF87A96B), // Sage
                      ],
                    ),
                  ),
                ),
              ),
              
              // Active step pulse
              if (widget.currentStep < widget.steps.length)
                _buildActiveStepPulse(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSegmentBackground(int index, RecipeStep step) {
    final segmentWidth = 1.0 / widget.steps.length;
    final leftPosition = index * segmentWidth;
    
    return Positioned(
      left: leftPosition * MediaQuery.of(context).size.width * 0.9,
      width: segmentWidth * MediaQuery.of(context).size.width * 0.9 - 2,
      top: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: _getStepTypeColor(step.type).withOpacity(0.2),
          border: Border.all(
            color: _getStepTypeColor(step.type).withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
    );
  }
  
  Widget _buildActiveStepPulse() {
    if (widget.currentStep >= widget.steps.length) return const SizedBox.shrink();
    
    final activePosition = widget.currentStep / widget.steps.length;
    
    return FractionallySizedBox(
      widthFactor: activePosition,
      child: Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB8860B).withOpacity(0.6),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepLabels() {
    return Row(
      children: widget.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < widget.currentStep;
        final isActive = index == widget.currentStep;
        
        return Expanded(
          child: GestureDetector(
            onTap: widget.enableInteraction ? () => _onStepTapped(index) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  // Step number indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                          ? const Color(0xFF87A96B) // Sage
                          : isActive 
                              ? const Color(0xFFB8860B) // Amber
                              : Colors.grey[300],
                      border: Border.all(
                        color: isActive 
                            ? const Color(0xFFB8860B)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${step.stepNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Step timing
                  if (widget.showTiming)
                    Text(
                      _formatDuration(step.estimatedTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isActive 
                            ? const Color(0xFFB8860B)
                            : Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildContextualTip() {
    final currentStepData = _getCurrentStepData();
    if (currentStepData?.tip == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8860B).withOpacity(0.1), // Amber
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFB8860B).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: const Color(0xFFB8860B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentStepData!.tip!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB8860B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  RecipeStep? _getCurrentStepData() {
    if (widget.currentStep >= widget.steps.length) return null;
    return widget.steps[widget.currentStep];
  }
  
  Duration _calculateTotalTime() {
    return widget.steps.fold(
      Duration.zero,
      (total, step) => total + step.estimatedTime,
    );
  }
  
  Duration _calculateElapsedTime() {
    if (widget.currentStep >= widget.steps.length) {
      return _calculateTotalTime();
    }
    
    return widget.steps
        .take(widget.currentStep)
        .fold(Duration.zero, (total, step) => total + step.estimatedTime);
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  String _getStepTypeLabel(RecipeStepType type) {
    switch (type) {
      case RecipeStepType.preparation:
        return 'Preparation';
      case RecipeStepType.mixing:
        return 'Mixing';
      case RecipeStepType.shaking:
        return 'Shaking';
      case RecipeStepType.stirring:
        return 'Stirring';
      case RecipeStepType.straining:
        return 'Straining';
      case RecipeStepType.garnishing:
        return 'Garnishing';
      case RecipeStepType.serving:
        return 'Serving';
    }
  }
  
  Color _getStepTypeColor(RecipeStepType type) {
    switch (type) {
      case RecipeStepType.preparation:
        return const Color(0xFF2196F3); // Blue
      case RecipeStepType.mixing:
        return const Color(0xFF9C27B0); // Purple
      case RecipeStepType.shaking:
        return const Color(0xFFFF9800); // Orange
      case RecipeStepType.stirring:
        return const Color(0xFF4CAF50); // Green
      case RecipeStepType.straining:
        return const Color(0xFF00BCD4); // Cyan
      case RecipeStepType.garnishing:
        return const Color(0xFFE91E63); // Pink
      case RecipeStepType.serving:
        return const Color(0xFFB8860B); // Amber
    }
  }
  
  void _onStepTapped(int stepIndex) {
    if (!widget.enableInteraction) return;
    
    // Haptic feedback
    HapticFeedback.selectionClick();
    
    widget.onStepTapped?.call(stepIndex);
  }
}

/// Compact version of the progress bar for smaller spaces
class CompactProgressBar extends StatelessWidget {
  final List<RecipeStep> steps;
  final int currentStep;
  final double height;
  final bool showLabels;
  
  const CompactProgressBar({
    super.key,
    required this.steps,
    required this.currentStep,
    this.height = 40,
    this.showLabels = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    
    final progress = currentStep / steps.length;
    
    return Container(
      height: height,
      child: Column(
        children: [
          // Progress bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 4),
                color: Colors.grey[300],
              ),
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 4),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB8860B), // Amber
                        const Color(0xFF87A96B), // Sage
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Labels
          if (showLabels) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentStep/${steps.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension methods for progress bar convenience
extension SmartProgressBarExtensions on List<RecipeStep> {
  /// Create a smart progress bar from a list of steps
  Widget toSmartProgressBar({
    required int currentStep,
    bool showTips = true,
    bool showTiming = true,
    ValueChanged<int>? onStepTapped,
    VoidCallback? onComplete,
  }) {
    return SmartProgressBar(
      steps: this,
      currentStep: currentStep,
      showTips: showTips,
      showTiming: showTiming,
      onStepTapped: onStepTapped,
      onComplete: onComplete,
    );
  }
  
  /// Create a compact progress bar
  Widget toCompactProgressBar({
    required int currentStep,
    double height = 40,
    bool showLabels = false,
  }) {
    return CompactProgressBar(
      steps: this,
      currentStep: currentStep,
      height: height,
      showLabels: showLabels,
    );
  }
}
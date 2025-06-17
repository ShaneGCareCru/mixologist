import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Collapsible section widget with smooth expand/collapse animations,
/// chevron rotation, content fade, and expansion preference saving
class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final String? preferenceKey;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets contentPadding;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? headerColor;
  final Color? contentColor;
  final bool enableHapticFeedback;
  final VoidCallback? onExpansionChanged;
  final double borderRadius;
  final bool showDivider;
  
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.preferenceKey,
    this.leading,
    this.trailing,
    this.contentPadding = const EdgeInsets.all(16),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.headerColor,
    this.contentColor,
    this.enableHapticFeedback = true,
    this.onExpansionChanged,
    this.borderRadius = 12,
    this.showDivider = true,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _chevronController;
  late AnimationController _fadeController;
  
  late Animation<double> _expansionAnimation;
  late Animation<double> _chevronAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    _expansionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _chevronController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds ~/ 2),
      vsync: this,
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: widget.animationCurve,
    );
    
    _chevronAnimation = Tween<double>(
      begin: 0,
      end: 0.5, // 180 degrees rotation
    ).animate(CurvedAnimation(
      parent: _chevronController,
      curve: widget.animationCurve,
    ));
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _initializeExpansionState();
  }
  
  Future<void> _initializeExpansionState() async {
    bool shouldExpand = widget.initiallyExpanded;
    
    // Load saved preference if available
    if (widget.preferenceKey != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        shouldExpand = prefs.getBool(widget.preferenceKey!) ?? widget.initiallyExpanded;
      } catch (e) {
        // Use default if preference loading fails
        shouldExpand = widget.initiallyExpanded;
      }
    }
    
    setState(() {
      _isExpanded = shouldExpand;
      _isInitialized = true;
    });
    
    if (_isExpanded) {
      _expansionController.value = 1.0;
      _chevronController.value = 1.0;
      _fadeController.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _expansionController.dispose();
    _chevronController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  Future<void> _toggleExpansion() async {
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expansionController.forward();
      _chevronController.forward();
      _fadeController.forward();
    } else {
      _fadeController.reverse();
      _chevronController.reverse();
      _expansionController.reverse();
    }
    
    // Save preference
    if (widget.preferenceKey != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(widget.preferenceKey!, _isExpanded);
      } catch (e) {
        // Continue without saving if preference storage fails
      }
    }
    
    widget.onExpansionChanged?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.headerColor ?? Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          // Divider
          if (widget.showDivider && _isExpanded)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                );
              },
            ),
          
          // Content
          _buildContent(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(widget.borderRadius),
        bottom: _isExpanded ? Radius.zero : Radius.circular(widget.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Leading widget
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 12),
            ],
            
            // Title
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB8860B), // Amber
                ),
              ),
            ),
            
            // Trailing widget
            if (widget.trailing != null) ...[
              const SizedBox(width: 12),
              widget.trailing!,
            ],
            
            // Chevron
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _chevronAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _chevronAnimation.value * pi,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: const Color(0xFF87A96B), // Sage
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    return SizeTransition(
      sizeFactor: _expansionAnimation,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: widget.contentPadding,
              decoration: BoxDecoration(
                color: widget.contentColor ?? Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(widget.borderRadius),
                ),
              ),
              child: widget.content,
            ),
          );
        },
      ),
    );
  }
}

/// Specialized collapsible section for recipe information
class RecipeDetailSection extends StatelessWidget {
  final String title;
  final List<DetailItem> items;
  final bool initiallyExpanded;
  final IconData? icon;
  
  const RecipeDetailSection({
    super.key,
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: title,
      initiallyExpanded: initiallyExpanded,
      preferenceKey: 'recipe_section_${title.toLowerCase().replaceAll(' ', '_')}',
      leading: icon != null 
          ? Icon(
              icon,
              color: const Color(0xFFB8860B),
              size: 20,
            )
          : null,
      content: _buildDetailContent(),
    );
  }
  
  Widget _buildDetailContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;
        
        return Column(
          children: [
            _DetailItemWidget(item: item),
            if (!isLast) const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}

/// Data model for detail items
class DetailItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final Widget? customContent;
  
  const DetailItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.customContent,
  });
}

/// Widget for individual detail items
class _DetailItemWidget extends StatelessWidget {
  final DetailItem item;
  
  const _DetailItemWidget({required this.item});
  
  @override
  Widget build(BuildContext context) {
    if (item.customContent != null) {
      return item.customContent!;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 16,
            color: item.color ?? const Color(0xFF87A96B),
          ),
          const SizedBox(width: 8),
        ],
        
        // Label
        SizedBox(
          width: 80,
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Value
        Expanded(
          child: Text(
            item.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Multi-section collapsible panel for complex content
class CollapsiblePanel extends StatefulWidget {
  final List<CollapsibleSectionData> sections;
  final bool allowMultipleExpanded;
  final EdgeInsets sectionSpacing;
  final String? groupPreferenceKey;
  
  const CollapsiblePanel({
    super.key,
    required this.sections,
    this.allowMultipleExpanded = true,
    this.sectionSpacing = const EdgeInsets.only(bottom: 8),
    this.groupPreferenceKey,
  });

  @override
  State<CollapsiblePanel> createState() => _CollapsiblePanelState();
}

class _CollapsiblePanelState extends State<CollapsiblePanel> {
  late List<bool> _expansionStates;
  
  @override
  void initState() {
    super.initState();
    _expansionStates = widget.sections
        .map((section) => section.initiallyExpanded)
        .toList();
  }
  
  void _handleExpansionChanged(int index) {
    setState(() {
      if (!widget.allowMultipleExpanded) {
        // Collapse all other sections
        for (int i = 0; i < _expansionStates.length; i++) {
          _expansionStates[i] = i == index ? !_expansionStates[i] : false;
        }
      } else {
        _expansionStates[index] = !_expansionStates[index];
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final isLast = index == widget.sections.length - 1;
        
        return Column(
          children: [
            CollapsibleSection(
              title: section.title,
              content: section.content,
              initiallyExpanded: section.initiallyExpanded,
              leading: section.leading,
              trailing: section.trailing,
              preferenceKey: widget.groupPreferenceKey != null 
                  ? '${widget.groupPreferenceKey}_section_$index'
                  : null,
              onExpansionChanged: () => _handleExpansionChanged(index),
            ),
            if (!isLast) SizedBox(height: widget.sectionSpacing.bottom),
          ],
        );
      }).toList(),
    );
  }
}

/// Data model for collapsible sections
class CollapsibleSectionData {
  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final Widget? leading;
  final Widget? trailing;
  
  const CollapsibleSectionData({
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.leading,
    this.trailing,
  });
}

/// Extension methods for easy collapsible section creation
extension CollapsibleExtensions on Widget {
  /// Wrap widget in a collapsible section
  Widget collapsible({
    required String title,
    bool initiallyExpanded = false,
    String? preferenceKey,
    Widget? leading,
    Widget? trailing,
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    Duration animationDuration = const Duration(milliseconds: 300),
    VoidCallback? onExpansionChanged,
  }) {
    return CollapsibleSection(
      title: title,
      content: this,
      initiallyExpanded: initiallyExpanded,
      preferenceKey: preferenceKey,
      leading: leading,
      trailing: trailing,
      contentPadding: contentPadding,
      animationDuration: animationDuration,
      onExpansionChanged: onExpansionChanged,
    );
  }
}

/// Utility class for managing expansion states
class ExpansionStateManager {
  static final Map<String, bool> _states = {};
  
  static bool getState(String key, [bool defaultValue = false]) {
    return _states[key] ?? defaultValue;
  }
  
  static void setState(String key, bool value) {
    _states[key] = value;
  }
  
  static void toggleState(String key, [bool defaultValue = false]) {
    _states[key] = !(_states[key] ?? defaultValue);
  }
  
  static void clearStates() {
    _states.clear();
  }
  
  static Map<String, bool> getAllStates() {
    return Map.from(_states);
  }
}
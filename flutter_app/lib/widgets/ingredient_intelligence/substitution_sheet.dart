import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/ingredient.dart';
import '../../services/substitution_service.dart';
import '../../theme/app_colors.dart';
import 'ingredient_card.dart';

/// Draggable bottom sheet for ingredient substitution suggestions
class SubstitutionSheet extends StatelessWidget {
  final String originalIngredient;
  final List<Substitution> options;
  final Function(Substitution)? onSubstitutionSelected;
  final VoidCallback? onClose;

  const SubstitutionSheet({
    super.key,
    required this.originalIngredient,
    required this.options,
    this.onSubstitutionSelected,
    this.onClose,
  });

  /// Static method to show the substitution sheet
  static void show(
    BuildContext context,
    String originalIngredient, {
    Function(Substitution)? onSubstitutionSelected,
  }) {
    final substitutions = SubstitutionService()
        .getSubstitutionsSorted(originalIngredient);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubstitutionSheet(
        originalIngredient: originalIngredient,
        options: substitutions,
        onSubstitutionSelected: onSubstitutionSelected,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.charcoalSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              _buildHandleBar(),
              
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: options.isEmpty
                    ? _buildNoSubstitutionsView()
                    : _buildSubstitutionsList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.champagneGold.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.smokyGlass.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Original ingredient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.deepBitters.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              originalIngredient.toUpperCase(),
              style: const TextStyle(
                color: AppColors.champagneGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Arrow
          Icon(
            CupertinoIcons.arrow_right,
            color: AppColors.champagneGold.withOpacity(0.7),
            size: 16,
          ),
          
          const SizedBox(width: 12),
          
          // Substitutes label
          const Expanded(
            child: Text(
              'SUBSTITUTE OPTIONS',
              style: TextStyle(
                color: AppColors.champagneGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Close button
          if (onClose != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 32,
              onPressed: onClose,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: AppColors.champagneGold.withOpacity(0.7),
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSubstitutionsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 64,
            color: AppColors.champagneGold.withOpacity(0.3),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'No Substitutions Found',
            style: TextStyle(
              color: AppColors.champagneGold.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'This ingredient doesn\'t have any\nknown substitutions in our database.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.champagneGold.withOpacity(0.6),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstitutionsList(ScrollController scrollController) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final substitution = options[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSubstitutionCard(substitution),
                );
              },
              childCount: options.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubstitutionCard(Substitution substitution) {
    return GestureDetector(
      onTap: () => onSubstitutionSelected?.call(substitution),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.smokyGlass.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.champagneGold.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Substitute name
                Expanded(
                  child: Text(
                    substitution.ingredient.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.champagneGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                // Compatibility rating
                _buildCompatibilityRating(substitution.compatibilityRating),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Conversion ratio
            _buildConversionRatio(substitution.conversionRatio),
            
            const SizedBox(height: 12),
            
            // Reason why
            _buildReasonWhy(substitution.reasonWhy),
            
            const SizedBox(height: 16),
            
            // Action button
            _buildActionButton(substitution),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityRating(double rating) {
    final percentage = (rating * 100).round();
    final color = _getRatingColor(rating);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRatingIcon(rating),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionRatio(String ratio) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.arrow_2_squarepath,
          size: 14,
          color: AppColors.citrusGlow.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          'Use $ratio ratio',
          style: TextStyle(
            color: AppColors.citrusGlow.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonWhy(String reason) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lightbulb,
            size: 14,
            color: AppColors.warmCopper.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why this works:',
                  style: TextStyle(
                    color: AppColors.warmCopper.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: TextStyle(
                    color: AppColors.champagneGold.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Substitution substitution) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: AppColors.deepBitters.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        onPressed: () => onSubstitutionSelected?.call(substitution),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_circle,
              size: 16,
              color: AppColors.champagneGold.withOpacity(0.9),
            ),
            const SizedBox(width: 6),
            Text(
              'Use This Substitute',
              style: TextStyle(
                color: AppColors.champagneGold.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 0.8) return Colors.green;
    if (rating >= 0.6) return AppColors.citrusGlow;
    if (rating >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getRatingIcon(double rating) {
    if (rating >= 0.8) return CupertinoIcons.checkmark_seal_fill;
    if (rating >= 0.6) return CupertinoIcons.checkmark_seal;
    if (rating >= 0.4) return CupertinoIcons.exclamationmark_triangle;
    return CupertinoIcons.xmark_seal;
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/ingredient.dart';
import '../../services/brand_recommendation_service.dart';
import '../../theme/app_colors.dart';

/// Long-press overlay showing brand recommendations by price tier
class BrandRecommendations extends StatelessWidget {
  final String spiritType;
  final BudgetLevel budget;
  final VoidCallback? onDismiss;
  final Function(BrandRecommendation)? onBrandSelected;

  const BrandRecommendations({
    super.key,
    required this.spiritType,
    required this.budget,
    this.onDismiss,
    this.onBrandSelected,
  });

  /// Static method to show brand recommendations overlay
  static void show(
    BuildContext context,
    String spiritType, {
    BudgetLevel budget = BudgetLevel.mid,
    Function(BrandRecommendation)? onBrandSelected,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => BrandRecommendations(
        spiritType: spiritType,
        budget: budget,
        onDismiss: () => Navigator.of(context).pop(),
        onBrandSelected: onBrandSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = BrandRecommendationService()
        .getRecommendations(spiritType);
    
    return GestureDetector(
      onTap: onDismiss,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping content
            child: Container(
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 600,
              ),
              decoration: BoxDecoration(
                color: AppColors.charcoalSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Budget selector
                  _buildBudgetSelector(),
                  
                  // Recommendations list
                  Flexible(
                    child: recommendations.isEmpty
                        ? _buildNoRecommendationsView()
                        : _buildRecommendationsList(recommendations),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Spirit icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.richWhiskey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSpiritIcon(spiritType),
              color: AppColors.goldenAmber,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spiritType.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.champagneGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'BRAND RECOMMENDATIONS',
                  style: TextStyle(
                    color: AppColors.warmCopper,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: onDismiss,
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.champagneGold.withOpacity(0.7),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text(
            'BUDGET LEVEL:',
            style: TextStyle(
              color: AppColors.champagneGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          ...BudgetLevel.values.map((level) => _buildBudgetChip(level)),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(BudgetLevel level) {
    final isSelected = level == budget;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.warmCopper.withOpacity(0.3)
              : AppColors.smokyGlass.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.warmCopper
                : AppColors.champagneGold.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          level.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            color: isSelected 
                ? AppColors.champagneGold
                : AppColors.champagneGold.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildNoRecommendationsView() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.star_circle,
            size: 64,
            color: AppColors.champagneGold.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recommendations',
            style: TextStyle(
              color: AppColors.champagneGold.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No brand recommendations available\nfor this spirit type.',
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

  Widget _buildRecommendationsList(List<BrandRecommendation> recommendations) {
    // Group by budget level
    final groupedRecs = <BudgetLevel, List<BrandRecommendation>>{};
    for (final rec in recommendations) {
      groupedRecs.putIfAbsent(rec.budgetLevel, () => []).add(rec);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: BudgetLevel.values.map((level) {
          final levelRecs = groupedRecs[level] ?? [];
          if (levelRecs.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetLevelHeader(level),
              const SizedBox(height: 12),
              ...levelRecs.map((rec) => _buildRecommendationCard(rec)),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetLevelHeader(BudgetLevel level) {
    return Row(
      children: [
        Icon(
          _getBudgetIcon(level),
          size: 16,
          color: _getBudgetColor(level),
        ),
        const SizedBox(width: 8),
        Text(
          level.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            color: _getBudgetColor(level),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: _getBudgetColor(level).withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(BrandRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.smokyGlass.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.champagneGold.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => onBrandSelected?.call(recommendation),
        child: Row(
          children: [
            // Brand info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand name and staff pick
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.name,
                          style: const TextStyle(
                            color: AppColors.champagneGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (recommendation.isStaffPick)
                        _buildStaffPickBadge(),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating and price
                  Row(
                    children: [
                      _buildRatingStars(recommendation.rating),
                      const SizedBox(width: 12),
                      Text(
                        '\$${recommendation.priceRange.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.warmCopper,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // Description
                  if (recommendation.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      recommendation.description!,
                      style: TextStyle(
                        color: AppColors.champagneGold.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Select button
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.deepBitters.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              minSize: 32,
              onPressed: () => onBrandSelected?.call(recommendation),
              child: const Text(
                'SELECT',
                style: TextStyle(
                  color: AppColors.champagneGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffPickBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.citrusGlow.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.star_fill,
            size: 8,
            color: Colors.white,
          ),
          SizedBox(width: 2),
          Text(
            'STAFF PICK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(
            CupertinoIcons.star_fill,
            size: 12,
            color: AppColors.citrusGlow,
          ),
        if (hasHalfStar)
          const Icon(
            CupertinoIcons.star_lefthalf_fill,
            size: 12,
            color: AppColors.citrusGlow,
          ),
        for (int i = fullStars + (hasHalfStar ? 1 : 0); i < 5; i++)
          Icon(
            CupertinoIcons.star,
            size: 12,
            color: AppColors.citrusGlow.withOpacity(0.3),
          ),
      ],
    );
  }

  IconData _getSpiritIcon(String spiritType) {
    final type = spiritType.toLowerCase();
    if (type.contains('whiskey') || type.contains('bourbon') || type.contains('scotch')) {
      return CupertinoIcons.square_fill_on_circle_fill;
    } else if (type.contains('gin')) {
      return CupertinoIcons.drop_triangle_fill;
    } else if (type.contains('vodka')) {
      return CupertinoIcons.circle_fill;
    } else if (type.contains('rum')) {
      return CupertinoIcons.waveform;
    } else if (type.contains('tequila') || type.contains('mezcal')) {
      return CupertinoIcons.flame_fill;
    }
    return CupertinoIcons.star_circle_fill;
  }

  IconData _getBudgetIcon(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return CupertinoIcons.circle;
      case BudgetLevel.mid:
        return CupertinoIcons.circle_fill;
      case BudgetLevel.premium:
        return CupertinoIcons.star_fill;
    }
  }

  Color _getBudgetColor(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return Colors.green;
      case BudgetLevel.mid:
        return AppColors.citrusGlow;
      case BudgetLevel.premium:
        return AppColors.warmCopper;
    }
  }
}
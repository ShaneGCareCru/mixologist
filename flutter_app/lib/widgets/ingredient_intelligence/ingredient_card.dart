import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/ingredient.dart';
import '../../services/tasting_note_service.dart';
import '../../services/cost_calculator.dart';
import '../../theme/app_colors.dart';

/// Smart ingredient card with quality tier, fill level, and cost information
class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final double amount;
  final Unit unit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCost;
  final bool showTastingNotes;
  final String region;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.amount,
    required this.unit,
    this.onTap,
    this.onLongPress,
    this.showCost = true,
    this.showTastingNotes = true,
    this.region = 'US',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.smokyGlass,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                    AppColors.smokyGlass,
                    AppColors.charcoalSurface,
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quality tier badge
                  _buildQualityBadge(),
                  
                  const SizedBox(height: 8),
                  
                  // Ingredient image/icon
                  _buildIngredientImage(),
                  
                  const SizedBox(height: 8),
                  
                  // Ingredient name
                  Text(
                    ingredient.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.champagneGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Fill level indicator
                  const SizedBox(height: 6),
                  _buildFillIndicator(),
                  
                  // Tasting note
                  if (showTastingNotes) ...[
                    const SizedBox(height: 4),
                    _buildTastingNote(),
                  ],
                  
                  const Spacer(),
                  
                  // Amount and cost
                  _buildAmountAndCost(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ingredient.tier.badgeColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTierIcon(),
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            ingredient.tier.displayName.toUpperCase(),
            style: const TextStyle(
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

  Widget _buildIngredientImage() {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ingredient.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: ingredient.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholderImage(),
                errorWidget: (context, url, error) => _buildPlaceholderImage(),
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(),
          size: 24,
          color: AppColors.champagneGold.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildFillIndicator() {
    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.charcoalSurface.withOpacity(0.3),
          ),
          child: Row(
            children: [
              Expanded(
                flex: (ingredient.fillLevel * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        _getFillColor(),
                        _getFillColor().withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: ((1 - ingredient.fillLevel) * 100).round(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTastingNote() {
    final tastingNote = TastingNoteService()
        .getTastingNote(ingredient.name, region: region) ??
        TastingNoteService().getFallbackDescription(ingredient.name);
    
    return Text(
      '"$tastingNote"',
      style: TextStyle(
        color: AppColors.champagneGold.withOpacity(0.8),
        fontSize: 8,
        fontStyle: FontStyle.italic,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAmountAndCost() {
    final cost = showCost 
        ? CostCalculator().calculatePourCost(
            ingredient.name,
            amount,
            unit,
            tier: ingredient.tier,
            region: region,
          )
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Amount
        Text(
          '${_formatAmount(amount)} ${unit.displayName}',
          style: const TextStyle(
            color: AppColors.citrusGlow,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Cost
        if (showCost)
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.warmCopper,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  IconData _getTierIcon() {
    switch (ingredient.tier) {
      case QualityTier.budget:
        return CupertinoIcons.circle;
      case QualityTier.standard:
        return CupertinoIcons.circle_fill;
      case QualityTier.premium:
        return CupertinoIcons.star;
      case QualityTier.luxury:
        return CupertinoIcons.star_fill;
    }
  }

  IconData _getCategoryIcon() {
    final category = ingredient.category.toLowerCase();
    
    if (category.contains('spirit') || category.contains('vodka') || 
        category.contains('gin') || category.contains('rum') ||
        category.contains('whiskey') || category.contains('tequila')) {
      return CupertinoIcons.square_fill_on_circle_fill;
    } else if (category.contains('liqueur')) {
      return CupertinoIcons.drop_fill;
    } else if (category.contains('wine') || category.contains('champagne')) {
      return CupertinoIcons.waveform;
    } else if (category.contains('juice') || category.contains('mixer')) {
      return CupertinoIcons.drop;
    } else if (category.contains('syrup')) {
      return CupertinoIcons.drop_triangle_fill;
    } else if (category.contains('bitters')) {
      return CupertinoIcons.flame_fill;
    }
    
    return CupertinoIcons.circle_fill;
  }

  Color _getFillColor() {
    final category = ingredient.category.toLowerCase();
    
    if (category.contains('spirit')) {
      return AppColors.richWhiskey;
    } else if (category.contains('citrus') || category.contains('juice')) {
      return AppColors.citrusGlow;
    } else if (category.contains('mixer')) {
      return AppColors.crystallIce;
    } else if (category.contains('liqueur')) {
      return AppColors.goldenAmber;
    } else if (category.contains('wine')) {
      return AppColors.deepBitters;
    }
    
    return AppColors.champagneGold;
  }

  String _formatAmount(double amount) {
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    } else {
      return amount.toStringAsFixed(1);
    }
  }
}
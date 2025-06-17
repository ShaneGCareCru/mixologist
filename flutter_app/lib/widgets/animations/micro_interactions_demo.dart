import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/interaction_feedback.dart';
import 'liquid_drop_animation.dart';
import 'cocktail_shaker_animation.dart';
import 'morphing_favorite_icon.dart';
import 'glass_clink_animation.dart';

/// Demonstration screen showcasing all micro-interactions in the library
class MicroInteractionsDemo extends StatefulWidget {
  const MicroInteractionsDemo({super.key});

  @override
  State<MicroInteractionsDemo> createState() => _MicroInteractionsDemoState();
}

class _MicroInteractionsDemoState extends State<MicroInteractionsDemo>
    with InteractionFeedbackMixin {
  bool _isFavorited = false;
  double _progress = 0.3;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Interactions Demo'),
        backgroundColor: const Color(0xFFB8860B), // Amber
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Haptic Feedback Patterns'),
            _buildHapticSection(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Liquid Drop Animation'),
            _buildLiquidDropSection(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Cocktail Shaker Animation'),
            _buildShakerSection(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Morphing Favorite Icon'),
            _buildFavoriteSection(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Glass Clink Share Animation'),
            _buildShareSection(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Interaction Feedback Coordinator'),
            _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: const Color(0xFFB8860B),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildHapticSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Various haptic feedback patterns for different interactions:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildHapticButton('Light Selection', () => haptics.selection()),
                _buildHapticButton('Ingredient Check', () => haptics.ingredientCheck()),
                _buildHapticButton('Step Complete', () => haptics.stepComplete()),
                _buildHapticButton('Recipe Finish', () => haptics.recipeFinish()),
                _buildHapticButton('Heavy Impact', () => haptics.heavyImpact()),
                _buildHapticButton('Error', () => haptics.error()),
                _buildHapticButton('Glass Clink', () => haptics.glassClink()),
                _buildHapticButton('Cocktail Shake', () => haptics.cocktailShake()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHapticButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF87A96B), // Sage
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
  
  Widget _buildLiquidDropSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap anywhere in the area below to create a liquid drop animation:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            LiquidDropWrapper(
              liquidColor: const Color(0xFFB8860B),
              onDropComplete: () {
                context.feedbackSuccess('Ingredient added!');
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.blue.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_bar, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to add liquid drop'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShakerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive cocktail shaker with shake motion and haptics:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              child: InteractiveCocktailShaker(
                onShakeStart: () {
                  context.feedbackProgress('Shaking cocktail...');
                },
                onShakeComplete: () {
                  context.feedbackSuccess('Cocktail mixed perfectly!');
                },
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to shake!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFavoriteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Morphing favorite icon with heart to cocktail glass transition:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                MorphingFavoriteIcon(
                  isFavorited: _isFavorited,
                  size: 48,
                  onToggle: () {
                    setState(() {
                      _isFavorited = !_isFavorited;
                    });
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isFavorited ? 'Favorited!' : 'Not favorited',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _isFavorited 
                            ? 'Shows cocktail glass with particle burst'
                            : 'Shows heart shape',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                CocktailFavoriteButton(
                  isFavorited: _isFavorited,
                  onChanged: (value) {
                    setState(() {
                      _isFavorited = value;
                    });
                  },
                  tooltip: 'Toggle favorite',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Glass clink animation for sharing actions:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CocktailShareButton(
                  onShare: () {
                    context.feedbackSuccess('Recipe shared successfully!');
                  },
                  tooltip: 'Share recipe',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share with Clink',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Plays glass clink animation with haptic feedback',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeedbackSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Standardized feedback patterns for common interactions:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Progress indicator with feedback
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recipe Progress'),
                          Text('${(_progress * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF87A96B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _progress = (_progress + 0.1).clamp(0.0, 1.0);
                    });
                    context.feedbackProgress('Step completed!');
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Add progress',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Feedback action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeedbackButton(
                  'Success',
                  Icons.check_circle,
                  const Color(0xFF87A96B),
                  () => context.feedbackSuccess('Operation completed successfully!'),
                ),
                _buildFeedbackButton(
                  'Error',
                  Icons.error_outline,
                  const Color(0xFFD32F2F),
                  () => context.feedbackError('Something went wrong!'),
                ),
                _buildFeedbackButton(
                  'Selection',
                  Icons.touch_app,
                  const Color(0xFF2196F3),
                  () => context.feedbackSelection(),
                ),
                _buildFeedbackButton(
                  'Shake',
                  Icons.sports_bar,
                  const Color(0xFFB8860B),
                  () => context.feedbackShake(() {
                    context.feedbackSuccess('Cocktail ready!');
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeedbackButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Extension methods for easy demo integration
extension MicroInteractionDemoExtensions on BuildContext {
  /// Show the micro-interactions demo
  void showMicroInteractionsDemo() {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => const MicroInteractionsDemo(),
      ),
    );
  }
}
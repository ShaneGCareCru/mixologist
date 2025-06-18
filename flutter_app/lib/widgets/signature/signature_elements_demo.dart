import 'package:flutter/material.dart';
import 'cocktail_ring_progress.dart';
import 'bar_tool_icons.dart';
import 'coaster_loader.dart';
import 'mixologist_transitions.dart';
import 'brand_mark.dart';
import 'mixologist_gestures.dart';

/// Comprehensive demonstration of all signature visual elements
/// Showcases the complete ownable UI pattern library
class SignatureElementsDemo extends StatefulWidget {
  const SignatureElementsDemo({super.key});

  @override
  State<SignatureElementsDemo> createState() => _SignatureElementsDemoState();
}

class _SignatureElementsDemoState extends State<SignatureElementsDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  double _ringProgress = 0.3;
  bool _isLoading = false;
  int _currentNavIndex = 0;
  bool _showGestureTutorials = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveBrandMark(showInAppBar: true),
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Progress'),
            Tab(text: 'Navigation'),
            Tab(text: 'Loading'),
            Tab(text: 'Transitions'),
            Tab(text: 'Brand'),
            Tab(text: 'Gestures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgressDemo(),
          _buildNavigationDemo(),
          _buildLoadingDemo(),
          _buildTransitionsDemo(),
          _buildBrandDemo(),
          _buildGesturesDemo(),
        ],
      ),
      bottomNavigationBar: BarToolNavigation(
        tabs: [
          BarToolTab(tool: BarTool.shaker, label: 'Shake'),
          BarToolTab(tool: BarTool.strainer, label: 'Strain'),
          BarToolTab(tool: BarTool.jigger, label: 'Measure'),
          BarToolTab(tool: BarTool.glass, label: 'Serve'),
        ],
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }
  
  Widget _buildProgressDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cocktail Ring Progress',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CocktailRingProgress(
                      progress: _ringProgress,
                      rimType: RimType.salt,
                      hasRim: true,
                      showDroplets: true,
                      centerText: '${(_ringProgress * 100).round()}%',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _ringProgress,
                    onChanged: (value) {
                      setState(() {
                        _ringProgress = value;
                      });
                    },
                    activeColor: const Color(0xFFB8860B),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Different Rim Types',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: RimType.values.map((rimType) {
                      return Column(
                        children: [
                          CocktailRingProgress(
                            progress: 0.7,
                            rimType: rimType,
                            size: 80,
                            animated: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rimType.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bar Tool Icons',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: BarTool.values.map((tool) {
                      final isActive = BarTool.values.indexOf(tool) == _currentNavIndex;
                      return BarToolIcon(
                        tool: tool,
                        isActive: isActive,
                        size: 48,
                        label: tool.displayName,
                        onTap: () {
                          setState(() {
                            _currentNavIndex = BarTool.values.indexOf(tool);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Bar Tool Navigation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: BarToolNavigation(
                      tabs: [
                        BarToolTab(tool: BarTool.shaker, label: 'Shake'),
                        BarToolTab(tool: BarTool.strainer, label: 'Strain'),
                        BarToolTab(tool: BarTool.jigger, label: 'Measure'),
                        BarToolTab(tool: BarTool.muddle, label: 'Muddle'),
                        BarToolTab(tool: BarTool.glass, label: 'Serve'),
                      ],
                      currentIndex: _currentNavIndex,
                      onTap: (index) {
                        setState(() {
                          _currentNavIndex = index;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selected: ${BarTool.values[_currentNavIndex.clamp(0, BarTool.values.length - 1)].displayName}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFB8860B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coaster Loaders',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = !_isLoading;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB8860B),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_isLoading ? 'Stop Loading' : 'Start Loading'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading) ...[
                    const Center(
                      child: CoasterLoader(
                        brandLogo: 'DEMO',
                        loadingText: 'Mixing cocktail...',
                        size: 150,
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'Tap "Start Loading" to see the coaster loader',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Different Coaster Styles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Column(
                        children: [
                          CoasterThemes.classic(
                            brandLogo: 'CLASSIC',
                            size: 100,
                          ),
                          const SizedBox(height: 8),
                          const Text('Classic'),
                        ],
                      ),
                      Column(
                        children: [
                          CoasterThemes.modern(
                            brandLogo: 'MODERN',
                            size: 100,
                          ),
                          const SizedBox(height: 8),
                          const Text('Modern'),
                        ],
                      ),
                      Column(
                        children: [
                          CoasterThemes.vintage(
                            brandLogo: 'VINTAGE',
                            size: 100,
                          ),
                          const SizedBox(height: 8),
                          const Text('Vintage'),
                        ],
                      ),
                      Column(
                        children: [
                          CoasterThemes.elegant(
                            brandLogo: 'ELEGANT',
                            size: 100,
                          ),
                          const SizedBox(height: 8),
                          const Text('Elegant'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransitionsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signature Transitions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Experience custom transitions that bring cocktail-making to life',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTransitionButton(
                    'Cocktail Pour',
                    'Liquid pour effect',
                    Icons.water_drop,
                    () => _navigateWithTransition(MixologistTransitions.cocktailPour),
                  ),
                  const SizedBox(height: 12),
                  _buildTransitionButton(
                    'Shaker Shake',
                    'Vigorous shaking motion',
                    Icons.sports_bar,
                    () => _navigateWithTransition(MixologistTransitions.shakerShake),
                  ),
                  const SizedBox(height: 12),
                  _buildTransitionButton(
                    'Glass Clink',
                    'Elegant glass collision',
                    Icons.wine_bar,
                    () => _navigateWithTransition(MixologistTransitions.glassClink),
                  ),
                  const SizedBox(height: 12),
                  _buildTransitionButton(
                    'Muddle Press',
                    'Crushing motion',
                    Icons.construction,
                    () => _navigateWithTransition(MixologistTransitions.muddlePress),
                  ),
                  const SizedBox(height: 12),
                  _buildTransitionButton(
                    'Ingredient Drop',
                    'Ingredient falling effect',
                    Icons.scatter_plot,
                    () => _navigateWithTransition(MixologistTransitions.ingredientDrop),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransitionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFB8860B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFB8860B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateWithTransition(Route Function(Widget) transitionBuilder) {
    Navigator.of(context).push(
      transitionBuilder(
        Scaffold(
          appBar: AppBar(
            title: const Text('Transition Demo'),
            backgroundColor: const Color(0xFF87A96B),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_bar,
                  size: 100,
                  color: Color(0xFFB8860B),
                ),
                SizedBox(height: 16),
                Text(
                  'Transition Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8860B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the back button to return',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBrandDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brand Mark System',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Adaptive brand marks for different contexts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: BrandStyle.values.map((style) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: BrandMark(
                              style: style,
                              size: style == BrandStyle.full 
                                  ? const Size(140, 40)
                                  : const Size(60, 60),
                              animated: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            style.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dark Mode Adaptation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Brand marks automatically adapt to dark backgrounds',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: BrandMark(
                      style: BrandStyle.full,
                      size: const Size(160, 50),
                      darkMode: true,
                      animated: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGesturesDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gesture Library',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Switch(
                        value: _showGestureTutorials,
                        onChanged: (value) {
                          setState(() {
                            _showGestureTutorials = value;
                          });
                        },
                        activeColor: const Color(0xFFB8860B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Interactive cocktail-making gestures',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_showGestureTutorials) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8860B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFB8860B),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tutorial mode enabled - gesture hints are visible',
                            style: TextStyle(
                              color: Color(0xFFB8860B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildGestureCard(
            'Stir Gesture',
            'Draw circular motions to stir',
            Icons.refresh,
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFB8860B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFB8860B).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.refresh,
                      size: 40,
                      color: Color(0xFFB8860B),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Draw circles here',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ).withStirGesture(
              onComplete: () => _showGestureSuccess('Stir Complete!'),
              showTutorial: _showGestureTutorials,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildGestureCard(
            'Shake Gesture',
            'Move device vigorously to shake',
            Icons.sports_bar,
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF87A96B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF87A96B).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_bar,
                      size: 40,
                      color: Color(0xFF87A96B),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shake your device',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ).withShakeGesture(
              onComplete: () => _showGestureSuccess('Shake Complete!'),
              showTutorial: _showGestureTutorials,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildGestureCard(
            'Muddle Gesture',
            'Tap repeatedly to muddle ingredients',
            Icons.construction,
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.construction,
                      size: 40,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap repeatedly here',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ).withMuddleGesture(
              onComplete: () => _showGestureSuccess('Muddle Complete!'),
              showTutorial: _showGestureTutorials,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGestureCard(String title, String description, IconData icon, Widget gestureArea) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFB8860B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            gestureArea,
          ],
        ),
      ),
    );
  }
  
  void _showGestureSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Extension for easy navigation to the signature elements demo
extension SignatureElementsDemoExtensions on BuildContext {
  /// Show the signature elements demo
  void showSignatureElementsDemo() {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => const SignatureElementsDemo(),
      ),
    );
  }
}
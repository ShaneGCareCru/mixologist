import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shimmer_components.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecipeGenerationShimmer();
  }
}
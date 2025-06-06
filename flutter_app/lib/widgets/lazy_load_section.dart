import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LazyLoadSection extends StatefulWidget {
  final WidgetBuilder builder;
  const LazyLoadSection({super.key, required this.builder});

  @override
  State<LazyLoadSection> createState() => _LazyLoadSectionState();
}

class _LazyLoadSectionState extends State<LazyLoadSection> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('lazy-${widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0) {
          setState(() => _visible = true);
        }
      },
      child: _visible ? widget.builder(context) : const SizedBox.shrink(),
    );
  }
}

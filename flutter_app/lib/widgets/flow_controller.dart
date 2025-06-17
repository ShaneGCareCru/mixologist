import 'package:flutter/scheduler.dart';

/// Central ticker provider for flow animations.
class FlowAnimationController with ChangeNotifier implements TickerProvider {
  FlowAnimationController() {
    _ticker = createTicker(_onTick)..start();
  }

  late final Ticker _ticker;
  final List<void Function(Duration)> _listeners = [];

  void register(void Function(Duration) callback) {
    _listeners.add(callback);
  }

  void unregister(void Function(Duration) callback) {
    _listeners.remove(callback);
  }

  void _onTick(Duration d) {
    for (final l in _listeners) {
      l(d);
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);

  void disposeController() {
    _ticker.dispose();
  }
}

Duration stagger(int index, [Duration base = const Duration(milliseconds: 100)]) {
  return base * index;
}

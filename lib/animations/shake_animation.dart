import 'package:flutter/material.dart';

/// A controller for managing shake animations
class ShakeAnimationController {
  late AnimationController controller;
  late Animation<double> animation;

  ShakeAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    controller = AnimationController(duration: duration, vsync: vsync);

    animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(controller);
  }

  void shake() {
    controller.forward(from: 0);
  }

  void dispose() {
    controller.dispose();
  }
}

/// A widget that applies a shake animation to its child
class ShakeAnimationBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Axis direction;

  const ShakeAnimationBuilder({
    Key? key,
    required this.animation,
    required this.child,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              direction == Axis.horizontal
                  ? Offset(animation.value, 0)
                  : Offset(0, animation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

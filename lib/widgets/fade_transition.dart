import 'package:flutter/material.dart';

/// Custom widget for smooth slide and fade animations
class AnimatedSlideAndFadeTransition extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AnimatedSlideAndFadeTransition({
    required this.child,
    this.delay = Duration.zero,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedSlideAndFadeTransition> createState() =>
      _AnimatedSlideAndFadeTransitionState();
}

class _AnimatedSlideAndFadeTransitionState
    extends State<AnimatedSlideAndFadeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.03), // Very subtle slide from 3% below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation after specified delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

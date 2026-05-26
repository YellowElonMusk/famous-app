import 'dart:math';
import 'package:flutter/material.dart';

class FloatingHeart {
  final double x;
  final double size;
  final Color color;
  final Duration duration;
  double progress;

  FloatingHeart({
    required this.x,
    required this.size,
    required this.color,
    required this.duration,
    this.progress = 0,
  });
}

class FloatingHeartsOverlay extends StatefulWidget {
  const FloatingHeartsOverlay({super.key});

  @override
  State<FloatingHeartsOverlay> createState() => FloatingHeartsOverlayState();
}

class FloatingHeartsOverlayState extends State<FloatingHeartsOverlay>
    with TickerProviderStateMixin {
  final _rng = Random();
  final List<_HeartAnimation> _hearts = [];

  final _colors = [
    Colors.red, Colors.pink, Colors.orange, Colors.yellow,
    Colors.purple, Colors.deepOrange,
  ];

  void addHeart() {
    final ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200 + _rng.nextInt(600)),
    );
    final heart = _HeartAnimation(
      controller: ctrl,
      x: 0.6 + _rng.nextDouble() * 0.3,
      size: 20 + _rng.nextDouble() * 20,
      color: _colors[_rng.nextInt(_colors.length)],
    );
    ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _hearts.remove(heart));
        ctrl.dispose();
      }
    });
    setState(() => _hearts.add(heart));
    ctrl.forward();
  }

  @override
  void dispose() {
    for (final h in _hearts) {
      h.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _hearts.map((h) => _HeartWidget(heart: h)).toList(),
      ),
    );
  }
}

class _HeartAnimation {
  final AnimationController controller;
  final double x;
  final double size;
  final Color color;

  late final Animation<double> y;
  late final Animation<double> opacity;
  late final Animation<double> scale;
  late final Animation<double> wobble;

  _HeartAnimation({
    required this.controller,
    required this.x,
    required this.size,
    required this.color,
  }) {
    y = Tween<double>(begin: 0.85, end: 0.1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(controller);
    scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 80),
    ]).animate(controller);
    wobble = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticIn),
    );
  }
}

class _HeartWidget extends StatelessWidget {
  final _HeartAnimation heart;

  const _HeartWidget({required this.heart});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: heart.controller,
      builder: (_, __) {
        final left = heart.x * screen.width + sin(heart.wobble.value) * 15;
        final top = heart.y.value * screen.height;
        return Positioned(
          left: left,
          top: top,
          child: Opacity(
            opacity: heart.opacity.value,
            child: Transform.scale(
              scale: heart.scale.value,
              child: Icon(
                Icons.favorite,
                color: heart.color,
                size: heart.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

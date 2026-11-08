import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarBounceAnimator extends StatefulWidget {
  final double score; // e.g. 97.0
  final double size;

  const StarBounceAnimator({
    Key? key,
    required this.score,
    this.size = 28.0,
  }) : super(key: key);

  @override
  State<StarBounceAnimator> createState() => _StarBounceAnimatorState();
}

class _StarBounceAnimatorState extends State<StarBounceAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );

    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value * math.pi,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: AppColors.accentGold,
                  size: widget.size,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: widget.size * 0.65,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


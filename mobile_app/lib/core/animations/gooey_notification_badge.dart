import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GooeyNotificationBadge extends StatefulWidget {
  final int count;
  final Widget child;

  const GooeyNotificationBadge({
    Key? key,
    required this.count,
    required this.child,
  }) : super(key: key);

  @override
  State<GooeyNotificationBadge> createState() => _GooeyNotificationBadgeState();
}

class _GooeyNotificationBadgeState extends State<GooeyNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _dropController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeOutBack,
    ));

    _offsetAnimation = Tween<double>(begin: -8.0, end: 0.0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.bounceOut),
    );

    if (widget.count > 0) {
      _dropController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant GooeyNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > 0 && oldWidget.count != widget.count) {
      _dropController.reset();
      _dropController.forward();
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: AnimatedBuilder(
              animation: _dropController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _offsetAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeCtaGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.count > 99 ? '99+' : widget.count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

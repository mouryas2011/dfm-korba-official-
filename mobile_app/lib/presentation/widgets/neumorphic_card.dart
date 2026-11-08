import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum NeuDepth { elevated, inset, flat }

class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final NeuDepth depth;
  final VoidCallback? onTap;
  final Color? surfaceColor;
  final Border? border;

  const NeuCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 18,
    this.depth = NeuDepth.elevated,
    this.onTap,
    this.surfaceColor,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = surfaceColor ??
        (depth == NeuDepth.inset
            ? AppColors.surfaceDarkInset
            : AppColors.surfaceDark);

    List<BoxShadow> shadows;

    if (depth == NeuDepth.elevated) {
      shadows = const [
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(4, 5),
          blurRadius: 10,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-2, -3),
          blurRadius: 6,
        ),
      ];
    } else if (depth == NeuDepth.inset) {
      shadows = const [
        BoxShadow(
          color: Color(0x66000000),
          offset: Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Color(0x0AFFFFFF),
          offset: Offset(-1, -1),
          blurRadius: 2,
        ),
      ];
    } else {
      shadows = [];
    }

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppColors.borderSubtle, width: 1.0),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}


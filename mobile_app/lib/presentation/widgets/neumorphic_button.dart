import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeuButton extends StatelessWidget {
  final String? label;
  final String? text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double height;
  final double? width;

  const NeuButton({
    Key? key,
    this.label,
    this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.color,
    this.textColor,
    this.icon,
    this.height = 50.0,
    this.width,
  }) : super(key: key);

  String get buttonText => label ?? text ?? '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          gradient: gradient ?? (color == null ? AppColors.orangeCtaGradient : null),
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: (gradient != null || color == null)
                  ? AppColors.primaryOrange.withOpacity(0.4)
                  : Colors.black.withOpacity(0.3),
              offset: const Offset(0, 6),
              blurRadius: 14,
              spreadRadius: -2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


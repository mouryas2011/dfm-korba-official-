import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ArrowLaunchButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const ArrowLaunchButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ArrowLaunchButton> createState() => _ArrowLaunchButtonState();
}

class _ArrowLaunchButtonState extends State<ArrowLaunchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _launchController;
  late Animation<Offset> _arrowOffset;

  @override
  void initState() {
    super.initState();
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _arrowOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, -0.8),
    ).animate(CurvedAnimation(
      parent: _launchController,
      curve: Curves.easeInQuad,
    ));
  }

  @override
  void dispose() {
    _launchController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.isLoading) return;
    await _launchController.forward();
    widget.onPressed();
    _launchController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.orangeCtaGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.45),
              offset: const Offset(0, 8),
              blurRadius: 18,
              spreadRadius: -2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SlideTransition(
                    position: _arrowOffset,
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


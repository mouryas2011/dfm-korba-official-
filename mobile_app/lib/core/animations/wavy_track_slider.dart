import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WavyTrackSlider extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final String? label;

  const WavyTrackSlider({
    Key? key,
    required this.progress,
    this.height = 48.0,
    this.label,
  }) : super(key: key);

  @override
  State<WavyTrackSlider> createState() => _WavyTrackSliderState();
}

class _WavyTrackSliderState extends State<WavyTrackSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(widget.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceDarkInset,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle.withOpacity(0.5),
            ),
            boxShadow: const [
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
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _WavyProgressPainter(
                    progress: widget.progress,
                    wavePhase: _waveController.value * 2 * math.pi,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _WavyProgressPainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  _WavyProgressPainter({
    required this.progress,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    final waveAmplitude = 5.0;
    final waveFrequency = 0.04;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= fillWidth; x += 2) {
      final y = (size.height / 2) +
          math.sin(x * waveFrequency + wavePhase) * waveAmplitude;
      if (x == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(fillWidth, size.height);
    path.close();

    final gradient = LinearGradient(
      colors: [
        AppColors.primaryOrange,
        AppColors.primaryOrangeLight,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, fillWidth, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Subtle leading spark circle
    if (progress > 0.02 && progress < 0.98) {
      final sparkY = (size.height / 2) +
          math.sin(fillWidth * waveFrequency + wavePhase) * waveAmplitude;
      final sparkPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(fillWidth, sparkY), 4, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) => true;
}


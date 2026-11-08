import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DroneLoadingIndicator extends StatefulWidget {
  final double size;
  final String? message;

  const DroneLoadingIndicator({
    Key? key,
    this.size = 70.0,
    this.message,
  }) : super(key: key);

  @override
  State<DroneLoadingIndicator> createState() => _DroneLoadingIndicatorState();
}

class _DroneLoadingIndicatorState extends State<DroneLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final hoverOffset = math.sin(_controller.value * 2 * math.pi) * 6;
            final rotorAngle = _controller.value * 8 * math.pi;

            return Transform.translate(
              offset: Offset(0, hoverOffset),
              child: CustomPaint(
                size: Size(widget.size, widget.size * 0.7),
                painter: _DronePainter(rotorAngle: rotorAngle),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]
      ],
    );
  }
}

class _DronePainter extends CustomPainter {
  final double rotorAngle;

  _DronePainter({required this.rotorAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final bodyPaint = Paint()
      ..color = AppColors.surfaceDarkElevated
      ..style = PaintingStyle.fill;

    final armPaint = Paint()
      ..color = AppColors.accentCyan
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rotorPaint = Paint()
      ..color = AppColors.primaryOrange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerGlow = Paint()
      ..color = AppColors.accentCyan.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Center glow
    canvas.drawCircle(center, 12, centerGlow);

    // Arms
    final armLengthX = size.width * 0.36;
    final armLengthY = size.height * 0.28;

    final arm1 = Offset(center.dx - armLengthX, center.dy - armLengthY);
    final arm2 = Offset(center.dx + armLengthX, center.dy - armLengthY);
    final arm3 = Offset(center.dx - armLengthX, center.dy + armLengthY);
    final arm4 = Offset(center.dx + armLengthX, center.dy + armLengthY);

    canvas.drawLine(center, arm1, armPaint);
    canvas.drawLine(center, arm2, armPaint);
    canvas.drawLine(center, arm3, armPaint);
    canvas.drawLine(center, arm4, armPaint);

    // Central Drone Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 28, height: 20),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Camera gimbal lens
    final lensPaint = Paint()..color = AppColors.accentCyan;
    canvas.drawCircle(center + const Offset(0, 4), 3.5, lensPaint);

    // Rotors
    _drawRotor(canvas, arm1, rotorAngle, rotorPaint);
    _drawRotor(canvas, arm2, -rotorAngle, rotorPaint);
    _drawRotor(canvas, arm3, -rotorAngle, rotorPaint);
    _drawRotor(canvas, arm4, rotorAngle, rotorPaint);
  }

  void _drawRotor(Canvas canvas, Offset center, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), paint);
    canvas.drawCircle(Offset.zero, 2.5, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DronePainter oldDelegate) => true;
}

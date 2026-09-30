import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Custom Loading Indicator featuring the Govi Mithuru logo in the center
/// surrounded by a continuously rotating rounded square border with a small gap.
class LogoLoadingIndicator extends StatefulWidget {
  /// Controls the size of the central logo (width & height)
  final double logoSize;

  /// Controls the outer dimension of the rotating square box
  final double boxSize;

  /// Thickness of the rotating box border
  final double strokeWidth;

  /// Color of the rotating border
  final Color borderColor;

  /// Speed of full 360 rotation
  final Duration rotationDuration;

  const LogoLoadingIndicator({
    super.key,
    this.logoSize = 75.0,
    this.boxSize = 135.0,
    this.strokeWidth = 3.5,
    this.borderColor = AppColors.darkPill,
    this.rotationDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<LogoLoadingIndicator> createState() => _LogoLoadingIndicatorState();
}

class _LogoLoadingIndicatorState extends State<LogoLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boxSize,
      height: widget.boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Continuously Rotating Rounded Square Border with Gap
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.boxSize, widget.boxSize),
                  painter: _GapSquarePainter(
                    strokeWidth: widget.strokeWidth,
                    color: widget.borderColor,
                  ),
                ),
              );
            },
          ),

          // 2. Central Logo Image
          Image.asset(
            'assets/images/logo.png',
            width: widget.logoSize,
            height: widget.logoSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.eco_rounded,
                size: widget.logoSize * 0.6,
                color: AppColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom Painter drawing a rounded square path with a small gap
class _GapSquarePainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  _GapSquarePainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      const Radius.circular(24),
    );

    final Path path = Path()..addRRect(rrect);

    // Extract path metrics to draw 82% of the square, leaving an 18% gap
    for (final metric in path.computeMetrics()) {
      final double totalLength = metric.length;
      final double extractLength = totalLength * 0.82; // 82% drawn, 18% gap
      final Path extractPath = metric.extractPath(0, extractLength);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GapSquarePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

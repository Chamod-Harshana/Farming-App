import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Custom Loading Indicator featuring:
/// - A STATIONARY (non-rotating) rounded rectangle surrounding the Govi Mithuru logo.
/// - A white/light gap segment that travels continuously ALONG the perimeter of the rectangle.
class LogoLoadingIndicator extends StatefulWidget {
  /// Size of the central logo
  final double logoSize;

  /// Width of the stationary rectangle
  final double boxWidth;

  /// Height of the stationary rectangle
  final double boxHeight;

  /// Thickness of the rectangle border
  final double strokeWidth;

  /// Corner radius of the stationary rectangle
  final double borderRadius;

  /// Main color of the stationary rectangle border
  final Color rectColor;

  /// Color of the traveling gap / highlight segment
  final Color gapColor;

  /// Length of the gap as a percentage of the total perimeter (e.g. 0.22 = 22%)
  final double gapPercentage;

  /// Time taken for the gap to complete 1 full loop around the rectangle
  final Duration duration;

  const LogoLoadingIndicator({
    super.key,
    this.logoSize = 75.0,
    this.boxWidth = 170.0,
    this.boxHeight = 105.0,
    this.strokeWidth = 4.0,
    this.borderRadius = 22.0,
    this.rectColor = AppColors.darkPill,
    this.gapColor = Colors.white,
    this.gapPercentage = 0.22,
    this.duration = const Duration(milliseconds: 1800),
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
      duration: widget.duration,
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
      width: widget.boxWidth,
      height: widget.boxHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Stationary Rounded Rectangle with Traveling White Gap along perimeter
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.boxWidth, widget.boxHeight),
                painter: _TravelingGapRectanglePainter(
                  progress: _controller.value,
                  strokeWidth: widget.strokeWidth,
                  borderRadius: widget.borderRadius,
                  rectColor: widget.rectColor,
                  gapColor: widget.gapColor,
                  gapPercentage: widget.gapPercentage,
                ),
              );
            },
          ),

          // 2. Central Govi Mithuru Logo (Stationary)
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

/// Custom Painter that draws a stationary rounded rectangle and animates a white gap moving along its edges
class _TravelingGapRectanglePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double borderRadius;
  final Color rectColor;
  final Color gapColor;
  final double gapPercentage;

  _TravelingGapRectanglePainter({
    required this.progress,
    required this.strokeWidth,
    required this.borderRadius,
    required this.rectColor,
    required this.gapColor,
    required this.gapPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Outer bounds with stroke inset
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final Path fullPath = Path()..addRRect(rrect);

    // 1. Draw the Base Stationary Rectangle Border
    final Paint basePaint = Paint()
      ..color = rectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fullPath, basePaint);

    // 2. Draw the White Gap Traveling ALONG the Stationary Rectangle Perimeter
    final Paint gapPaint = Paint()
      ..color = gapColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 0.5 // slightly thicker highlight
      ..strokeCap = StrokeCap.round;

    for (final metric in fullPath.computeMetrics()) {
      final double totalLength = metric.length;
      final double gapLength = totalLength * gapPercentage;
      final double startDistance = progress * totalLength;
      final double endDistance = startDistance + gapLength;

      if (endDistance <= totalLength) {
        // Gap is within single continuous path segment
        final Path gapPath = metric.extractPath(startDistance, endDistance);
        canvas.drawPath(gapPath, gapPaint);
      } else {
        // Gap wraps around the end of the perimeter back to the start
        final Path gapPath1 = metric.extractPath(startDistance, totalLength);
        final Path gapPath2 = metric.extractPath(0, endDistance - totalLength);
        canvas.drawPath(gapPath1, gapPaint);
        canvas.drawPath(gapPath2, gapPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TravelingGapRectanglePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rectColor != rectColor ||
        oldDelegate.gapColor != gapColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

import 'package:flutter/material.dart';

class BorderLoadingPainter extends CustomPainter {
  final double rotationValue; // 0.0 to 1.0
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  BorderLoadingPainter({
    required this.rotationValue,
    required this.color,
    this.strokeWidth = 2.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();
    
    for (final metric in pathMetrics) {
      final totalLength = metric.length;
      final arcLength = totalLength * 0.25; // 25% of the border is glowing
      final startOffset = totalLength * rotationValue;
      
      // Extract the path segment. If it wraps around, we draw two segments
      if (startOffset + arcLength <= totalLength) {
        final segment = metric.extractPath(startOffset, startOffset + arcLength);
        canvas.drawPath(segment, paint);
      } else {
        final segment1 = metric.extractPath(startOffset, totalLength);
        final segment2 = metric.extractPath(0, (startOffset + arcLength) % totalLength);
        canvas.drawPath(segment1, paint);
        canvas.drawPath(segment2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BorderLoadingPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}

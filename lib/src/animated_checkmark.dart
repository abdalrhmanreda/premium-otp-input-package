import 'package:flutter/material.dart';

class AnimatedCheckmark extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;
  final VoidCallback? onCompleted;

  const AnimatedCheckmark({
    super.key,
    this.size = 60.0,
    this.color = const Color(0xFF22C55E),
    this.strokeWidth = 4.0,
    this.duration = const Duration(milliseconds: 600),
    this.onCompleted,
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleProgress;
  late Animation<double> _checkProgress;
  late Animation<double> _scaleProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration == Duration.zero
          ? const Duration(milliseconds: 1)
          : widget.duration,
    );

    // Circle draws in the first 45% of the animation duration
    _circleProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeInOut),
      ),
    );

    // Checkmark draws in the next 45% of the animation duration (from 40% to 85%)
    _checkProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Scale pop in the last 20% of the animation duration (from 80% to 100%)
    _scaleProgress = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0),
      ),
    );

    if (widget.duration == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onCompleted?.call();
        }
      });
    } else {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.duration == Duration.zero) {
      return CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _CheckmarkPainter(
          circleProgress: 1.0,
          checkProgress: 1.0,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleProgress.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CheckmarkPainter(
              circleProgress: _circleProgress.value,
              checkProgress: _checkProgress.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the circle outer ring
    if (circleProgress > 0) {
      final circlePath = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          -1.5708, // Start at the top (-pi/2)
          6.28319 * circleProgress, // 2*pi * progress
        );
      canvas.drawPath(circlePath, paint);
    }

    // Draw the checkmark itself
    if (checkProgress > 0) {
      final checkPath = Path();
      // Define checkmark path coordinates based on the canvas size
      checkPath.moveTo(size.width * 0.28, size.height * 0.5);
      checkPath.lineTo(size.width * 0.45, size.height * 0.67);
      checkPath.lineTo(size.width * 0.72, size.height * 0.35);

      final pathMetrics = checkPath.computeMetrics();
      final animatedPath = Path();
      for (final metric in pathMetrics) {
        animatedPath.addPath(
          metric.extractPath(0, metric.length * checkProgress),
          Offset.zero,
        );
      }
      
      canvas.drawPath(animatedPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkProgress != checkProgress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

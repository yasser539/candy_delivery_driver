import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/design_system/design_system.dart';

/// Reusable order timeline widget used by LiveOrderCard and Accepted cards.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.step, required this.accent});
  final int step; // 0..3
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const labels = [
      'مراجعة\nالطلب',
      'تحضير\nالطلب',
      'جاري\nالتوصيل',
      'تم\nالتوصيل',
    ];

    const double dotSize = 18.0;
    const double stroke = 1.6;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const double horizontalPadding = 30.0;
          final usable = width - dotSize - (horizontalPadding * 2);
          final segment = usable / 3.0;

          final centers = List.generate(4, (i) {
            return Offset(
              horizontalPadding + (dotSize / 2) + (segment * i),
              dotSize / 2,
            );
          });

          return Column(
            children: [
              SizedBox(
                height: dotSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(width, dotSize),
                      painter: _ConnectorPainter(
                        step: step,
                        centers: centers,
                        accent: accent,
                        inactive: scheme.outline.withOpacity(0.3),
                        strokeWidth: stroke,
                        dotRadius: dotSize / 2,
                        shorten: 14.0,
                        underlap: 6.0,
                      ),
                    ),
                    for (int i = 0; i < 4; i++)
                      Positioned(
                        left: centers[i].dx - (dotSize / 2),
                        top: 0,
                        width: dotSize,
                        height: dotSize,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              DesignSystem.getBrandGradient(
                                'primary',
                              ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: _DotStep(
                            filled: (3 - i) <= step,
                            color: Colors.white,
                            size: dotSize,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: width,
                height: 56,
                child: Stack(
                  children: List.generate(4, (i) {
                    final labelIndex = 3 - i;
                    const double labelWidth = 84.0;
                    var left = centers[i].dx - (labelWidth / 2);
                    left = left.clamp(0.0, width - labelWidth);
                    return Positioned(
                      left: left,
                      top: 0,
                      width: labelWidth,
                      child: Center(
                        child: Text(
                          labels[labelIndex],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 10,
                                color: scheme.onSurface.withOpacity(0.72),
                                height: 1.05,
                              ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.step,
    required this.centers,
    required this.accent,
    required this.inactive,
    required this.strokeWidth,
    this.dotRadius = 0,
    this.shorten = 8.0,
    this.underlap = 2.0,
  });

  final int step;
  final List<Offset> centers;
  final Color accent;
  final Color inactive;
  final double strokeWidth;
  final double dotRadius;
  final double shorten;
  final double underlap;

  @override
  void paint(Canvas canvas, Size size) {
    final paintActive = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = DesignSystem.getBrandGradient(
        'primary',
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paintInactive = Paint()
      ..color = inactive
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final edgeGap = dotRadius - (strokeWidth / 2);
    final edgeWithUnderlap = (edgeGap - underlap).clamp(0.0, edgeGap);

    for (int i = 0; i < 3; i++) {
      final from = centers[i];
      final to = centers[i + 1];

      final angle = (to - from).direction;

      var p1 =
          from +
          Offset(
            math.cos(angle) * edgeWithUnderlap,
            math.sin(angle) * edgeWithUnderlap,
          );
      var p2 =
          to -
          Offset(
            math.cos(angle) * edgeWithUnderlap,
            math.sin(angle) * edgeWithUnderlap,
          );

      final halfShorten = shorten / 2;
      final midShift = Offset(
        math.cos(angle) * halfShorten,
        math.sin(angle) * halfShorten,
      );
      p1 = p1 + midShift;
      p2 = p2 - midShift;

      final isActive = i >= (3 - step);
      canvas.drawLine(p1, p2, isActive ? paintActive : paintInactive);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter old) =>
      old.step != step ||
      old.accent != accent ||
      old.strokeWidth != strokeWidth ||
      old.shorten != shorten ||
      old.underlap != underlap;
}

class _DotStep extends StatelessWidget {
  const _DotStep({required this.filled, required this.color, this.size = 12});
  final bool filled;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 2),
      ),
    );
  }
}

